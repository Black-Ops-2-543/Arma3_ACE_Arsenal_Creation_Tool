[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $CfgConvertPath = 'F:\SteamLibrary\steamapps\common\Arma 3 Tools\CfgConvert\CfgConvert.exe',

    [Parameter()]
    [string] $SqfLintJar,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $JavaPath = 'java',

    [Parameter()]
    [switch] $SkipConfig,

    [Parameter()]
    [switch] $SkipSqf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$addonsDirectory = Join-Path $repositoryRoot 'addons'
$failures = New-Object 'System.Collections.Generic.List[string]'

function Find-SqfLintJar {
    $userProfile = [System.Environment]::GetFolderPath('UserProfile')
    if ([string]::IsNullOrWhiteSpace($userProfile)) {
        $userProfile = $env:USERPROFILE
    }
    if ([string]::IsNullOrWhiteSpace($userProfile)) {
        return $null
    }

    $extensionRoots = @(
        (Join-Path $userProfile '.vscode\extensions'),
        (Join-Path $userProfile '.vscode-insiders\extensions'),
        (Join-Path $userProfile '.cursor\extensions')
    )

    foreach ($extensionRoot in $extensionRoots) {
        if (-not (Test-Path -LiteralPath $extensionRoot -PathType Container)) {
            continue
        }

        $candidate = Get-ChildItem -LiteralPath $extensionRoot -Directory -Filter 'skacekachna.sqflint-*' |
            Sort-Object -Property LastWriteTimeUtc -Descending |
            ForEach-Object { Join-Path $_.FullName 'server\bin\SQFLint.jar' } |
            Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
            Select-Object -First 1

        if ($candidate) {
            return $candidate
        }
    }

    return $null
}

if (-not (Test-Path -LiteralPath $addonsDirectory -PathType Container)) {
    throw "The add-ons source directory was not found at '$addonsDirectory'."
}

$sourceFiles = @(
    Get-ChildItem -LiteralPath $addonsDirectory -Recurse -File |
        Where-Object { $_.Extension -in @('.cpp', '.ext', '.hpp', '.sqf', '.sqfc') } |
        Sort-Object -Property FullName
)

foreach ($sourceFile in $sourceFiles) {
    $conflictMarkers = @(Select-String -LiteralPath $sourceFile.FullName -Pattern '^(<<<<<<<|=======|>>>>>>>)' -CaseSensitive)
    foreach ($marker in $conflictMarkers) {
        $failures.Add("$($sourceFile.FullName):$($marker.LineNumber): unresolved merge-conflict marker")
    }
}

# Structural checks for integration points that can pass syntax validation but
# still fail at runtime because Arma resolves them by exact config path.
$requiredRelativeFiles = @(
    'addons\core\CfgMissions.hpp',
    'addons\core\missions\Creator.VR\mission.sqm',
    'addons\core\missions\Creator.VR\description.ext',
    'addons\core\missions\Creator.VR\initPlayerLocal.sqf',
    'addons\core\functions\presets\fn_decodePortablePreset.sqf',
    'addons\core\functions\presets\fn_decodeSqfPreset.sqf',
    'addons\core\functions\presets\fn_exportPreset.sqf',
    'addons\core\functions\presets\fn_applyBasePreset.sqf',
    'addons\core\functions\presets\fn_flattenCurrentPreset.sqf',
    'addons\core\functions\presets\fn_flattenPreset.sqf',
    'addons\core\functions\presets\fn_formatPortableJson.sqf',
    'addons\core\functions\presets\fn_formatSqfExport.sqf',
    'addons\core\functions\presets\fn_wouldCreateCycle.sqf',
    'addons\core\functions\ui\fn_refreshCategoryCombo.sqf',
    'addons\core\functions\ui\fn_switchCreatorTab.sqf',
    'addons\eden\ui\PresetAttribute.hpp',
    'addons\eden\ui\EdenConfigDialog.hpp',
    'addons\eden\functions\fn_edenAttributeOnLoad.sqf',
    'addons\eden\functions\fn_edenEditorApply.sqf',
    'addons\eden\functions\fn_edenEditorSelectSlot.sqf',
    'addons\eden\functions\fn_edenDashboardBulk.sqf',
    'docs\PORTABLE_PRESET_FORMAT.md'
)
foreach ($relativeFile in $requiredRelativeFiles) {
    $requiredFile = Join-Path $repositoryRoot $relativeFile
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        $failures.Add("Required runtime file is missing: '$requiredFile'.")
    }
}

foreach ($addonSource in Get-ChildItem -LiteralPath $addonsDirectory -Directory) {
    $prefixFile = Join-Path $addonSource.FullName '$PBOPREFIX$'
    if (-not (Test-Path -LiteralPath $prefixFile -PathType Leaf)) {
        $failures.Add("PBO prefix file is missing: '$prefixFile'.")
        continue
    }

    $expectedPrefix = 'x\raca\addons\' + $addonSource.Name
    $actualPrefix = (Get-Content -Raw -LiteralPath $prefixFile).Trim()
    if (-not $actualPrefix.Equals($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $failures.Add("'$prefixFile' contains '$actualPrefix'; expected '$expectedPrefix'.")
    }
}

$edenCfgPath = Join-Path $addonsDirectory 'eden\Cfg3DEN.hpp'
if (Test-Path -LiteralPath $edenCfgPath -PathType Leaf) {
    $edenCfg = Get-Content -Raw -LiteralPath $edenCfgPath
    if ($edenCfg -notmatch '(?s)class\s+Cfg3DEN\s*\{\s*class\s+Attributes\s*\{\s*#include\s+"ui\\PresetAttribute\.hpp"') {
        $failures.Add("The custom Eden control must be registered under Cfg3DEN >> Attributes in '$edenCfgPath'.")
    }
    if ($edenCfg -notmatch 'control\s*=\s*"RACA_PresetAttribute"') {
        $failures.Add("The Eden preset attribute does not reference RACA_PresetAttribute in '$edenCfgPath'.")
    }
    if ($edenCfg -notmatch 'expression\s*=\s*"[^"\r\n]*isServer') {
        $failures.Add("The Eden runtime expression must initialize the global ACE arsenal from the server only in '$edenCfgPath'.")
    }
    if ($edenCfg -notmatch 'RACA_fnc_applyObjectConfig') {
        $failures.Add("The Eden runtime expression must apply the authored multi-slot object configuration.")
    }
}

$edenDialogPath = Join-Path $addonsDirectory 'eden\ui\EdenConfigDialog.hpp'
if (Test-Path -LiteralPath $edenDialogPath -PathType Leaf) {
    $edenDialog = Get-Content -Raw -LiteralPath $edenDialogPath
    foreach ($requiredText in @('SLOTS ON THIS OBJECT', 'ACCESS RULES', 'MISSION-WIDE DASHBOARD', 'APPLY CONFIGURATION', 'ASSIGN TO SELECTED', 'CLEAR SELECTED')) {
        if ($edenDialog -notmatch [regex]::Escape($requiredText)) {
            $failures.Add("The Eden configuration editor is missing '$requiredText'.")
        }
    }
    if ($edenDialog -notmatch 'spawn\s+RACA_fnc_edenDashboardBulk') {
        $failures.Add('Mission-wide Eden confirmations must run in a scheduled environment.')
    }
}

$edenAttributeOnLoadPath = Join-Path $addonsDirectory 'eden\functions\fn_edenAttributeOnLoad.sqf'
if (Test-Path -LiteralPath $edenAttributeOnLoadPath -PathType Leaf) {
    $edenAttributeOnLoad = Get-Content -Raw -LiteralPath $edenAttributeOnLoadPath
    if ($edenAttributeOnLoad -notmatch '_this\s+isEqualType\s+controlNull' -or
        $edenAttributeOnLoad -notmatch 'RACA_fnc_edenPopulate') {
        $failures.Add('The Eden attribute onLoad handler must accept the direct ControlsGroup value supplied by 3den.')
    }
}

$edenSelectSlotPath = Join-Path $addonsDirectory 'eden\functions\fn_edenEditorSelectSlot.sqf'
if (Test-Path -LiteralPath $edenSelectSlotPath -PathType Leaf) {
    $edenSelectSlot = Get-Content -Raw -LiteralPath $edenSelectSlotPath
    if ($edenSelectSlot -match 'find\s+_mode\s+max') {
        $failures.Add('The Eden access-mode selection must clamp the numeric find result, not pass the mode string to max.')
    }
}

$edenBulkPath = Join-Path $addonsDirectory 'eden\functions\fn_edenDashboardBulk.sqf'
if (Test-Path -LiteralPath $edenBulkPath -PathType Leaf) {
    $edenBulk = Get-Content -Raw -LiteralPath $edenBulkPath
    foreach ($requiredPattern in @('get3DENSelected', 'BIS_fnc_guiMessage', 'collect3DENHistory', 'set3DENAttribute')) {
        if ($edenBulk -notmatch $requiredPattern) {
            $failures.Add("Mission-wide Eden updates are missing '$requiredPattern'.")
        }
    }
}

$creatorMenuPath = Join-Path $addonsDirectory 'core\RscDisplayMain.hpp'
if (Test-Path -LiteralPath $creatorMenuPath -PathType Leaf) {
    $creatorMenu = Get-Content -Raw -LiteralPath $creatorMenuPath
    if ($creatorMenu -notmatch "playMission\s*\[\s*''\s*,\s*'\\x\\raca\\addons\\core\\missions\\Creator\.VR'\s*\]") {
        $failures.Add("The Tutorials menu entry does not use the ACE-compatible direct Creator.VR mission path.")
    }
}

$cfgMissionsPath = Join-Path $addonsDirectory 'core\CfgMissions.hpp'
if (Test-Path -LiteralPath $cfgMissionsPath -PathType Leaf) {
    $cfgMissions = Get-Content -Raw -LiteralPath $cfgMissionsPath
    if ($cfgMissions -notmatch [regex]::Escape("\x\raca\addons\core\missions\Creator.VR")) {
        $failures.Add("CfgMissions does not point RACA_Creator at the packaged Creator.VR mission.")
    }
}

$creatorMissionPath = Join-Path $addonsDirectory 'core\missions\Creator.VR\mission.sqm'
if (Test-Path -LiteralPath $creatorMissionPath -PathType Leaf) {
    $creatorMission = Get-Content -Raw -LiteralPath $creatorMissionPath
    foreach ($sceneName in @('Mission', 'Intro', 'OutroWin', 'OutroLoose')) {
        $scenePattern = 'class\s+' + [regex]::Escape($sceneName) + '(?:\s*:\s*\w+)?\s*\{'
        if ($creatorMission -notmatch $scenePattern) {
            $failures.Add("The Creator.VR mission must define the legacy '$sceneName' scene section.")
        }
    }
}

$creatorUiPath = Join-Path $addonsDirectory 'core\ui\RscDisplayCreator.hpp'
if (Test-Path -LiteralPath $creatorUiPath -PathType Leaf) {
    $creatorUi = Get-Content -Raw -LiteralPath $creatorUiPath
    if ($creatorUi -notmatch 'onMouseButtonUp\s*=\s*"[^"\r\n]*spawn[^"\r\n]*uiSleep[^"\r\n]*RACA_fnc_toggleRow') {
        $failures.Add("The item list must defer its mouse-up toggle until ListNBox commits the clicked row.")
    }
    if ($creatorUi -notmatch 'idc\s*=\s*RACA_IDC_EXPORT_FORMAT' -or
        $creatorUi -notmatch 'text\s*=\s*"IMPORT AUTO"') {
        $failures.Add("The creator must expose the export-format selector and automatic importer.")
    }
    if ($creatorUi -notmatch 'spawn\s+RACA_fnc_importPreset') {
        $failures.Add('Import Auto must run in a scheduled environment so duplicate-preset confirmation can suspend safely.')
    }
    if ($creatorUi -notmatch 'idc\s*=\s*RACA_IDC_BASE_PRESET' -or
        $creatorUi -notmatch 'text\s*=\s*"ADOPT / REFRESH"' -or
        $creatorUi -notmatch 'text\s*=\s*"MAKE STANDALONE"') {
        $failures.Add("The creator must expose source-preset selection, explicit adoption, and standalone conversion.")
    }
    if ($creatorUi -notmatch 'text\s*=\s*"ARSENAL CREATION ASSISTANT"' -or
        $creatorUi -notmatch 'text\s*=\s*"PRESET MANAGEMENT"' -or
        $creatorUi -notmatch 'text\s*=\s*"ASSIGNMENT"' -or
        $creatorUi -match 'PRESET LIBRARY') {
        $failures.Add("The creator must use the centered title and two-tab Preset Management/Assignment layout.")
    }
}

$categoryUiPath = Join-Path $addonsDirectory 'core\functions\ui\fn_refreshCategoryCombo.sqf'
if (Test-Path -LiteralPath $categoryUiPath -PathType Leaf) {
    $categoryUi = Get-Content -Raw -LiteralPath $categoryUiPath
    foreach ($categoryName in @('Weapons', 'Attachments', 'Magazines', 'Uniforms', 'Vests', 'Backpacks', 'Headgear', 'NVGs', 'Facewear', 'Equipment', 'Included', 'Inherited')) {
        if ($categoryUi -notmatch ('"' + $categoryName + '"')) {
            $failures.Add("The creator category selector is missing '$categoryName'.")
        }
    }
    if ($categoryUi -notmatch 'count\s+_inherited') {
        $failures.Add("The Inherited category must only appear when an adopted source snapshot exists.")
    }
}

$itemRefreshPath = Join-Path $addonsDirectory 'core\functions\ui\fn_refreshItemList.sqf'
if (Test-Path -LiteralPath $itemRefreshPath -PathType Leaf) {
    $itemRefresh = Get-Content -Raw -LiteralPath $itemRefreshPath
    if ($itemRefresh -notmatch '"Included"' -or $itemRefresh -notmatch '"Inherited"' -or
        $itemRefresh -notmatch '0\.55,\s*0\.82,\s*1') {
        $failures.Add("Assignment filtering must support Included/Inherited and mark adopted-source rows light blue.")
    }
}

$classificationPath = Join-Path $addonsDirectory 'core\functions\catalog\fn_classifyClass.sqf'
if (Test-Path -LiteralPath $classificationPath -PathType Leaf) {
    $classification = Get-Content -Raw -LiteralPath $classificationPath
    foreach ($categoryName in @('Weapons', 'Attachments', 'Magazines', 'Uniforms', 'Vests', 'Backpacks', 'Headgear', 'NVGs', 'Facewear', 'Equipment')) {
        if ($classification -notmatch ('"' + $categoryName + '"')) {
            $failures.Add("Item classification is missing '$categoryName'.")
        }
    }
    if ($classification -match 'RACA_nonAmmunitionMagazines') {
        $failures.Add("All ammunition magazines, including throwables and launcher rounds, must remain in Magazines.")
    }
    if ($classification -notmatch 'CBA_MiscItem' -or $classification -notmatch 'ACE_ItemCore') {
        $failures.Add("Generic CBA/ACE inventory items must be classified as Equipment before itemType's bipod compatibility value is considered.")
    }
}

$catalogPath = Join-Path $addonsDirectory 'core\functions\catalog\fn_scanItems.sqf'
if (Test-Path -LiteralPath $catalogPath -PathType Leaf) {
    $catalogSource = Get-Content -Raw -LiteralPath $catalogPath
    if ($catalogSource -match 'configSourceAddonList\s+_config\s*;') {
        $failures.Add("Catalogue search must not index every compatibility patch in configSourceAddonList.")
    }
    if ($catalogSource -match 'modParams\s*\[[^\]]*"author"') {
        $failures.Add("Catalogue scanning must not request the unsupported modParams 'author' option.")
    }
}

$portableImportPath = Join-Path $addonsDirectory 'core\functions\presets\fn_decodePortablePreset.sqf'
if (Test-Path -LiteralPath $portableImportPath -PathType Leaf) {
    $portableImport = Get-Content -Raw -LiteralPath $portableImportPath
    if ($portableImport -notmatch '\bfromJSON\b') {
        $failures.Add("Portable preset import must use Arma's data-only fromJSON parser.")
    }
    if ($portableImport -match '(?i)\bcompile(?:Final)?\s+(?:_text|copyFromClipboard)\b') {
        $failures.Add("Portable preset import must never compile clipboard or imported text.")
    }
    if ($portableImport -match '1000000|1 MB' -or $portableImport -notmatch 'RACA_PORTABLE_PRESET') {
        $failures.Add("Portable preset import must retain its versioned signature check without a fixed 1 MB ceiling.")
    }
}

$portableExportPath = Join-Path $addonsDirectory 'core\functions\presets\fn_exportPreset.sqf'
if (Test-Path -LiteralPath $portableExportPath -PathType Leaf) {
    $portableExport = Get-Content -Raw -LiteralPath $portableExportPath
    foreach ($formatName in @('JSON', 'SQF', 'LIST', 'MANIFEST', 'SUPPORT')) {
        if ($portableExport -notmatch ('"' + $formatName + '"')) {
            $failures.Add("Preset export is missing the '$formatName' format path.")
        }
    }
    if ($portableExport -notmatch '\bcopyToClipboard\b') {
        $failures.Add("Preset export must copy its selected output to the clipboard.")
    }
}

$portableJsonFormatPath = Join-Path $addonsDirectory 'core\functions\presets\fn_formatPortableJson.sqf'
if (Test-Path -LiteralPath $portableJsonFormatPath -PathType Leaf) {
    $portableJsonFormat = Get-Content -Raw -LiteralPath $portableJsonFormatPath
    if ($portableJsonFormat -notmatch '\btoJSON\b') {
        $failures.Add("Portable preset export must serialize JSON with Arma's toJSON command.")
    }
}

$sqfImportPath = Join-Path $addonsDirectory 'core\functions\presets\fn_decodeSqfPreset.sqf'
if (Test-Path -LiteralPath $sqfImportPath -PathType Leaf) {
    $sqfImport = Get-Content -Raw -LiteralPath $sqfImportPath
    if ($sqfImport -match '(?i)\b(?:compile|compileFinal|execVM|preprocessFile|loadFile)\b') {
        $failures.Add("Legacy SQF import must scan text only and must never load or execute it.")
    }
    if ($sqfImport -match '1000000|1 MB' -or $sqfImport -notmatch '\bRACA_fnc_classifyClass\b') {
        $failures.Add("Legacy SQF import must use current-config classification without a fixed 1 MB ceiling.")
    }
    if ($sqfImport -notmatch '_isSqfIdentifier' -or $sqfImport -notmatch '\(_candidate find "_fnc_"\)') {
        $failures.Add("Legacy SQF import must ignore quoted local variables and function identifiers.")
    }
}

$sqfExportPath = Join-Path $addonsDirectory 'core\functions\presets\fn_formatSqfExport.sqf'
if (Test-Path -LiteralPath $sqfExportPath -PathType Leaf) {
    $sqfExport = Get-Content -Raw -LiteralPath $sqfExportPath
    foreach ($requiredPattern in @(
        'params \[\["_box"',
        'if \(!isServer\)',
        'private _arsenalItems',
        'arrayIntersect _arsenalItems',
        'ace_arsenal_fnc_removeBox',
        'ace_arsenal_fnc_initBox',
        '\[this\] execVM "raca_arsenal\.sqf"'
    )) {
        if ($sqfExport -notmatch $requiredPattern) {
            $failures.Add("Reusable SQF export is missing required mission behavior matching '$requiredPattern'.")
        }
    }
}

$presetValidationPath = Join-Path $addonsDirectory 'core\functions\presets\fn_validatePreset.sqf'
if (Test-Path -LiteralPath $presetValidationPath -PathType Leaf) {
    $presetValidation = Get-Content -Raw -LiteralPath $presetValidationPath
    if ($presetValidation -notmatch 'RACA_ADOPTION' -or
        $presetValidation -notmatch 'RACA_COMPOSITION' -or
        $presetValidation -notmatch 'An unsafe adoption removal was rejected') {
        $failures.Add("Preset validation must emit safe versioned adoption metadata and accept the legacy composition signature.")
    }
}

$cyclePath = Join-Path $addonsDirectory 'core\functions\presets\fn_wouldCreateCycle.sqf'
if (Test-Path -LiteralPath $cyclePath -PathType Leaf) {
    $cycleSource = Get-Content -Raw -LiteralPath $cyclePath
    if ($cycleSource -notmatch 'createHashMap' -or $cycleSource -notmatch 'RACA_fnc_getComposition') {
        $failures.Add("Adoption ancestry must track visited presets and inspect source metadata.")
    }
}

$deletePresetPath = Join-Path $addonsDirectory 'core\functions\presets\fn_deletePreset.sqf'
if (-not (Test-Path -LiteralPath $deletePresetPath -PathType Leaf)) {
    $failures.Add("The preset library must provide a guarded deletion workflow.")
}
else {
    $deletePresetSource = Get-Content -Raw -LiteralPath $deletePresetPath
    foreach ($requiredPattern in @('BIS_fnc_guiMessage', 'deleteAt', 'saveProfileNamespace', 'unsaved recovery copy')) {
        if ($deletePresetSource -notmatch [regex]::Escape($requiredPattern)) {
            $failures.Add("Preset deletion is missing required behavior '$requiredPattern'.")
        }
    }
}

$modalWorkflowPaths = @(
    'core\functions\presets\fn_deletePreset.sqf',
    'core\functions\presets\fn_importPreset.sqf',
    'core\functions\ui\fn_requestCreatorClose.sqf',
    'core\functions\ui\fn_restorePresetRevision.sqf',
    'core\functions\runtime\fn_adminExecute.sqf',
    'eden\functions\fn_edenDashboardBulk.sqf'
)
foreach ($modalWorkflowRelativePath in $modalWorkflowPaths) {
    $modalWorkflowPath = Join-Path $addonsDirectory $modalWorkflowRelativePath
    if (-not (Test-Path -LiteralPath $modalWorkflowPath -PathType Leaf)) {
        $failures.Add("Modal workflow '$modalWorkflowRelativePath' is missing.")
        continue
    }

    $modalWorkflowSource = Get-Content -Raw -LiteralPath $modalWorkflowPath
    if ($modalWorkflowSource -notmatch 'disableSerialization\s*;') {
        $failures.Add("Modal workflow '$modalWorkflowRelativePath' must preserve UI handles across scheduled confirmation dialogs.")
    }
    if ($modalWorkflowSource -notmatch 'findDisplay\s+RACA_') {
        $failures.Add("Modal workflow '$modalWorkflowRelativePath' must reacquire its active parent display after confirmation.")
    }
}

foreach ($uiTextRelativePath in @(
    'core\functions\presets\fn_deletePreset.sqf',
    'core\functions\ui\fn_refreshItemList.sqf',
    'core\functions\ui\fn_runCreatorDiagnostics.sqf',
    'eden\functions\fn_edenDashboardBulk.sqf',
    'eden\functions\fn_edenUpdateSummary.sqf'
)) {
    $uiTextPath = Join-Path $addonsDirectory $uiTextRelativePath
    if (Test-Path -LiteralPath $uiTextPath -PathType Leaf) {
        $uiTextSource = Get-Content -Raw -LiteralPath $uiTextPath
        if ($uiTextSource.Contains('\n')) {
            $failures.Add("User-facing text in '$uiTextRelativePath' contains a literal backslash-n instead of an Arma line break.")
        }
    }
}

$creatorUiPath = Join-Path $addonsDirectory 'core\ui\RscDisplayCreator.hpp'
if (Test-Path -LiteralPath $creatorUiPath -PathType Leaf) {
    $creatorUiSource = Get-Content -Raw -LiteralPath $creatorUiPath
    if ($creatorUiSource -notmatch 'RACA_IDC_DELETE_PRESET' -or $creatorUiSource -notmatch 'RACA_fnc_deletePreset') {
        $failures.Add("The creator must expose preset deletion from Preset Management.")
    }
    foreach ($creatorFeature in @('QUICK START', 'REVISION HISTORY', 'COMPARE DRAFT', 'LIMIT CATEGORY', 'FAVORITE', 'RACA_IDC_SOURCE_FILTER', 'RACA_fnc_requestCreatorClose')) {
        if ($creatorUiSource -notmatch [regex]::Escape($creatorFeature)) {
            $failures.Add("The creator excellence workflow is missing '$creatorFeature'.")
        }
    }
}

$historyArchivePath = Join-Path $addonsDirectory 'core\functions\presets\fn_archivePreset.sqf'
if (Test-Path -LiteralPath $historyArchivePath -PathType Leaf) {
    $historyArchive = Get-Content -Raw -LiteralPath $historyArchivePath
    if ($historyArchive -notmatch 'RACA_presetHistory_v1' -or $historyArchive -notmatch '_matchingKept < 20' -or $historyArchive -notmatch 'saveProfileNamespace') {
        $failures.Add("Preset revision history must be profile-persistent and retain at most 20 snapshots per preset.")
    }
}

$savePresetPath = Join-Path $addonsDirectory 'core\functions\presets\fn_saveCurrentPreset.sqf'
if (Test-Path -LiteralPath $savePresetPath -PathType Leaf) {
    $savePreset = Get-Content -Raw -LiteralPath $savePresetPath
    if ($savePreset -notmatch 'RACA_fnc_archivePreset' -or $savePreset -notmatch 'RACA_creatorDirty"\s*,\s*false') {
        $failures.Add("Preset overwrite must archive the outgoing revision and mark the saved creator state clean.")
    }
}

$manifestPath = Join-Path $addonsDirectory 'core\functions\presets\fn_buildModManifest.sqf'
$supportPath = Join-Path $addonsDirectory 'core\functions\presets\fn_buildSupportBundle.sqf'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf) -or
    (Get-Content -Raw -LiteralPath $manifestPath) -notmatch 'RACA_MOD_MANIFEST') {
    $failures.Add("The creator must provide a versioned required-mod manifest export.")
}
if (-not (Test-Path -LiteralPath $supportPath -PathType Leaf) -or
    (Get-Content -Raw -LiteralPath $supportPath) -notmatch 'RACA_SUPPORT_BUNDLE') {
    $failures.Add("The creator must provide a versioned diagnostic support-bundle export.")
}

$historyPushPath = Join-Path $addonsDirectory 'core\functions\ui\fn_pushCreatorHistory.sqf'
$historyRestorePath = Join-Path $addonsDirectory 'core\functions\ui\fn_restoreCreatorHistory.sqf'
if (-not (Test-Path -LiteralPath $historyPushPath -PathType Leaf) -or -not (Test-Path -LiteralPath $historyRestorePath -PathType Leaf)) {
    $failures.Add("The creator must provide bounded undo and redo state transitions.")
}

$edenPopulatePath = Join-Path $addonsDirectory 'eden\functions\fn_edenPopulate.sqf'
if (Test-Path -LiteralPath $edenPopulatePath -PathType Leaf) {
    $edenPopulate = Get-Content -Raw -LiteralPath $edenPopulatePath
    if ($edenPopulate -notmatch 'RACA_fnc_flattenPreset') {
        $failures.Add("Eden must embed standalone preset copies with no runtime source dependency.")
    }
}

$coreConfigPath = Join-Path $addonsDirectory 'core\config.cpp'
if (Test-Path -LiteralPath $coreConfigPath -PathType Leaf) {
    $coreConfig = Get-Content -Raw -LiteralPath $coreConfigPath
    if ($coreConfig -match 'class\s+RACA_fnc_applyObjectConfig\s*\{[^}]*allowedTargets') {
        $failures.Add("Clients must not be allowed to remotely replace an object's authoritative configuration.")
    }
    foreach ($remoteFunction in @('RACA_fnc_requestOpen', 'RACA_fnc_finishSession', 'RACA_fnc_requestLoadoutApply', 'RACA_fnc_applyAuthorizedLoadout', 'RACA_fnc_requestAdminAccess', 'RACA_fnc_receiveAdminAccess', 'RACA_fnc_requestAdminSnapshot', 'RACA_fnc_receiveAdminSnapshot', 'RACA_fnc_requestQuotaStatus', 'RACA_fnc_receiveQuotaStatus')) {
        if ($coreConfig -notmatch ('class\s+' + $remoteFunction + '\s*\{')) {
            $failures.Add("CfgRemoteExec is missing the controlled runtime endpoint '$remoteFunction'.")
        }
    }
    if ($coreConfig -notmatch 'class\s+RACA_fnc_registerActions\s*\{[^}]*allowedTargets\s*=\s*0\s*;[^}]*jip\s*=\s*1\s*;') {
        $failures.Add("Only the sanitized client action registrar must be enabled for persistent JIP execution.")
    }
}

$applyObjectPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_applyObjectConfig.sqf'
if (Test-Path -LiteralPath $applyObjectPath -PathType Leaf) {
    $applyObject = Get-Content -Raw -LiteralPath $applyObjectPath
    if ($applyObject -notmatch '!isServer\s*\|\|' -or
        $applyObject -notmatch 'RACA_objectConfig"\s*,\s*_config\s*,\s*false' -or
        $applyObject -notmatch 'RACA_fnc_buildActionManifest' -or
        $applyObject -notmatch 'remoteExecCall\s*\["RACA_fnc_registerActions"\s*,\s*0\s*,\s*_object\s*\]') {
        $failures.Add("Runtime object application must stay server-only, keep full configuration private, and broadcast only an action manifest.")
    }
}

$bulkUpdatePath = Join-Path $addonsDirectory 'core\functions\runtime\fn_bulkUpdateObjects.sqf'
if (Test-Path -LiteralPath $bulkUpdatePath -PathType Leaf) {
    $bulkUpdate = Get-Content -Raw -LiteralPath $bulkUpdatePath
    if ($bulkUpdate -notmatch 'remoteExecCall\s*\["RACA_fnc_registerActions"\s*,\s*0\s*,\s*_object\s*\]') {
        $failures.Add("Clearing an object must replace its object-bound JIP action registration.")
    }
}

$actionManifestPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_buildActionManifest.sqf'
if (Test-Path -LiteralPath $actionManifestPath -PathType Leaf) {
    $actionManifest = Get-Content -Raw -LiteralPath $actionManifestPath
    if ($actionManifest -notmatch 'RACA_ACTION_MANIFEST' -or $actionManifest -notmatch '_slots pushBack \[_id, _name, \[\]') {
        $failures.Add("The JIP action manifest must omit embedded preset contents and quota policy.")
    }
}

$requestOpenPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_requestOpen.sqf'
if (Test-Path -LiteralPath $requestOpenPath -PathType Leaf) {
    $requestOpen = Get-Content -Raw -LiteralPath $requestOpenPath
    foreach ($requiredPattern in @('owner _unit isNotEqualTo remoteExecutedOwner', '_unit distance _object', 'RACA_openSessions', 'RACA_fnc_evaluateAccess')) {
        if ($requestOpen -notmatch [regex]::Escape($requiredPattern)) {
            $failures.Add("The arsenal-open endpoint is missing authority check '$requiredPattern'.")
        }
    }
}

$finishSessionPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_finishSession.sqf'
if (Test-Path -LiteralPath $finishSessionPath -PathType Leaf) {
    $finishSession = Get-Content -Raw -LiteralPath $finishSessionPath
    if ($finishSession -match 'RACA_quotaState"\s*,\s*_quota\s*,\s*true' -or
        $finishSession -notmatch 'getUnitLoadout\s+_unit' -or
        $finishSession -notmatch '_unauthorized') {
        $failures.Add("Session completion must use the server-observed loadout, reject unauthorized additions, and keep quota state server-local.")
    }
}

$savedLoadoutPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_applyPlayerLoadout.sqf'
if (Test-Path -LiteralPath $savedLoadoutPath -PathType Leaf) {
    $savedLoadout = Get-Content -Raw -LiteralPath $savedLoadoutPath
    if ($savedLoadout -notmatch 'RACA_fnc_requestLoadoutApply' -or $savedLoadout -match '\bsetUnitLoadout\b') {
        $failures.Add("Saved loadouts must pass through the server authorization and quota session instead of applying directly on the client.")
    }
}

$countLoadoutPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_countLoadout.sqf'
if (Test-Path -LiteralPath $countLoadoutPath -PathType Leaf) {
    $countLoadout = Get-Content -Raw -LiteralPath $countLoadoutPath
    if ($countLoadout -notmatch '_quantity' -or $countLoadout -notmatch '_countContainer' -or $countLoadout -notmatch 'floor \(_quantity max 0\)') {
        $failures.Add("Loadout accounting must preserve container stack quantities rather than counting every cargo entry as one.")
    }
}

$adminSnapshotPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_requestAdminSnapshot.sqf'
$adminUiPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_adminRefresh.sqf'
if (-not (Test-Path -LiteralPath $adminSnapshotPath -PathType Leaf) -or -not (Test-Path -LiteralPath $adminUiPath -PathType Leaf)) {
    $failures.Add("Authenticated runtime administration must provide both a server snapshot endpoint and a client dashboard renderer.")
}
else {
    $adminSnapshot = Get-Content -Raw -LiteralPath $adminSnapshotPath
    if ($adminSnapshot -notmatch 'owner _unit isNotEqualTo remoteExecutedOwner' -or
        $adminSnapshot -notmatch 'RACA_fnc_isAdminAuthorized' -or
        $adminSnapshot -match 'RACA_objectConfig') {
        $failures.Add("The administration snapshot must bind to the requesting owner, recheck authorization, and avoid broadcasting full object configurations.")
    }
}

$zeusAssignPath = Join-Path $addonsDirectory 'core\functions\zeus\fn_moduleAssign.sqf'
if (Test-Path -LiteralPath $zeusAssignPath -PathType Leaf) {
    $zeusAssign = Get-Content -Raw -LiteralPath $zeusAssignPath
    if ($zeusAssign -notmatch 'RACA_fnc_getMissionRegistry' -or $zeusAssign -notmatch 'embedded mission slot') {
        $failures.Add("Zeus assignment must fall back to presets already embedded in registered mission objects for dedicated-server use.")
    }
}

$quotaStatusPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_requestQuotaStatus.sqf'
if (Test-Path -LiteralPath $quotaStatusPath -PathType Leaf) {
    $quotaStatus = Get-Content -Raw -LiteralPath $quotaStatusPath
    if ($quotaStatus -notmatch 'owner _unit isNotEqualTo remoteExecutedOwner' -or
        $quotaStatus -notmatch '_unit distance _object' -or
        $quotaStatus -notmatch 'RACA_fnc_evaluateAccess') {
        $failures.Add("Player quota inspection must be owner-bound, distance-limited, and access-authorized on the server.")
    }
}

$catalogSortPath = Join-Path $addonsDirectory 'core\functions\ui\fn_setSortMode.sqf'
$catalogRefreshPath = Join-Path $addonsDirectory 'core\functions\ui\fn_refreshItemList.sqf'
$creatorUiPath = Join-Path $addonsDirectory 'core\ui\RscDisplayCreator.hpp'
if (-not (Test-Path -LiteralPath $catalogSortPath -PathType Leaf)) {
    $failures.Add("The creator must provide the persistent catalogue sorting controller.")
}
elseif ((Test-Path -LiteralPath $catalogRefreshPath -PathType Leaf) -and (Test-Path -LiteralPath $creatorUiPath -PathType Leaf)) {
    $catalogSort = Get-Content -Raw -LiteralPath $catalogSortPath
    $catalogRefresh = Get-Content -Raw -LiteralPath $catalogRefreshPath
    $creatorUi = Get-Content -Raw -LiteralPath $creatorUiPath
    foreach ($field in @('included', 'item', 'class', 'mod', 'author')) {
        $handlerPattern = "'" + [regex]::Escape($field) + "'\]\s+call\s+RACA_fnc_setSortMode"
        if ($catalogSort -notmatch [regex]::Escape('"' + $field + '"') -or
            $creatorUi -notmatch $handlerPattern) {
            $failures.Add("Catalogue sorting must expose the '$field' header through the shared sorting controller.")
        }
    }
    if ($catalogSort -notmatch 'RACA_catalogSort_v1' -or
        $catalogRefresh -notmatch '_decorated\s+sort' -or
        $catalogRefresh -notmatch '_previousClass' -or
        $catalogRefresh -notmatch 'lnbSetCurSelRow') {
        $failures.Add("Catalogue sorting must persist its mode, sort filtered rows deterministically, and restore the selected class.")
    }
}

$simulatorPath = Join-Path $addonsDirectory 'eden\functions\fn_edenAccessSimulatorRefresh.sqf'
$simulatorOnLoadPath = Join-Path $addonsDirectory 'eden\functions\fn_edenAccessSimulatorOnLoad.sqf'
$simulatorOpenPath = Join-Path $addonsDirectory 'eden\functions\fn_edenOpenAccessSimulator.sqf'
$accessEvaluatorPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_evaluateAccess.sqf'
$edenDialogPath = Join-Path $addonsDirectory 'eden\ui\EdenConfigDialog.hpp'
if (-not (Test-Path -LiteralPath $simulatorPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $simulatorOnLoadPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $simulatorOpenPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $accessEvaluatorPath -PathType Leaf)) {
    $failures.Add("Eden must provide access-rule simulator open and evaluation functions.")
}
elseif (Test-Path -LiteralPath $edenDialogPath -PathType Leaf) {
    $simulator = Get-Content -Raw -LiteralPath $simulatorPath
    $simulatorOnLoad = Get-Content -Raw -LiteralPath $simulatorOnLoadPath
    $simulatorOpen = Get-Content -Raw -LiteralPath $simulatorOpenPath
    $accessEvaluator = Get-Content -Raw -LiteralPath $accessEvaluatorPath
    $edenDialog = Get-Content -Raw -LiteralPath $edenDialogPath
    if ($simulator -notmatch 'INDETERMINATE' -or
        $simulator -notmatch 'Runtime player UID only' -or
        $simulator -notmatch 'Runtime mission permission only' -or
        $simulator -notmatch 'RACA_accessSimulatorUnits' -or
        $simulator -match '(?m)to(?:Upper|Lower)ANSI\s+str\s+_value' -or
        $accessEvaluator -match '(?m)to(?:Upper|Lower)ANSI\s+str\s+_value' -or
        $simulatorOnLoad -notmatch 'all3DENEntities\s+select\s+0' -or
        $simulatorOpen -notmatch 'RACA_fnc_edenEditorCommitSlot' -or
        $edenDialog -notmatch 'RACA_RscDisplayAccessSimulator' -or
        $edenDialog -notmatch 'SIMULATE ACCESS') {
        $failures.Add("The Eden access simulator must use the unsaved slot draft, offer mission units, and preserve runtime-only rules as unknown rather than passing them.")
    }
}

$preflightUiPath = Join-Path $addonsDirectory 'core\functions\ui\fn_preflightRefresh.sqf'
$preflightSelectPath = Join-Path $addonsDirectory 'core\functions\ui\fn_preflightSelect.sqf'
if (-not (Test-Path -LiteralPath $preflightUiPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $preflightSelectPath -PathType Leaf)) {
    $failures.Add("The creator must provide visual preflight filtering and affected-item navigation.")
}
elseif (Test-Path -LiteralPath $creatorUiPath -PathType Leaf) {
    $preflightUi = Get-Content -Raw -LiteralPath $preflightUiPath
    $preflightSelect = Get-Content -Raw -LiteralPath $preflightSelectPath
    $creatorUi = Get-Content -Raw -LiteralPath $creatorUiPath
    if ($preflightUi -notmatch 'ERROR' -or
        $preflightUi -notmatch 'WARNING' -or
        $preflightUi -notmatch 'INFO' -or
        $preflightUi -notmatch 'lnbSetColor' -or
        $preflightSelect -notmatch 'RACA_fnc_switchCreatorTab' -or
        $preflightSelect -notmatch 'RACA_IDC_ITEM_LIST' -or
        $creatorUi -notmatch 'RACA_RscDisplayPreflight' -or
        $creatorUi -notmatch 'VIEW DETAILS') {
        $failures.Add("Visual preflight must color and filter every severity, expose a details display, and navigate available affected classes to Assignment.")
    }
}

$releaseScriptPath = Join-Path $repositoryRoot 'tools\release.ps1'
$releaseProcessPath = Join-Path $repositoryRoot 'docs\RELEASE_PROCESS.md'
$changelogPath = Join-Path $repositoryRoot 'CHANGELOG.md'
if (-not (Test-Path -LiteralPath $releaseScriptPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $releaseProcessPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $changelogPath -PathType Leaf)) {
    $failures.Add("Release tooling requires tools/release.ps1, docs/RELEASE_PROCESS.md, and CHANGELOG.md.")
}
else {
    $releaseScript = Get-Content -Raw -LiteralPath $releaseScriptPath
    $changelog = Get-Content -Raw -LiteralPath $changelogPath
    if ($releaseScript -notmatch 'status --porcelain' -or
        $releaseScript -notmatch 'versionStr' -or
        $releaseScript -notmatch 'checksums\.sha256' -or
        $releaseScript -notmatch 'RACA_RELEASE_REPORT' -or
        $releaseScript -notmatch 'Get-FileHash' -or
        $changelog -notmatch '(?m)^## \[Unreleased\]\s*$') {
        $failures.Add("Release packaging must require a clean tree, consistent versions, verified PBO checksums, a hashed release report, and an Unreleased changelog section.")
    }
}

if (-not $SkipConfig) {
    if (-not (Test-Path -LiteralPath $CfgConvertPath -PathType Leaf)) {
        throw "CfgConvert was not found at '$CfgConvertPath'. Pass its full path with -CfgConvertPath or use -SkipConfig."
    }

    $configFiles = @(
        Get-ChildItem -LiteralPath $addonsDirectory -Recurse -File |
            Where-Object { $_.Name -in @('config.cpp', 'description.ext', 'mission.sqm') } |
            Sort-Object -Property FullName
    )

    if ($configFiles.Count -eq 0) {
        $failures.Add("No config.cpp, description.ext, or mission.sqm files were found in '$addonsDirectory'.")
    }
    else {
        foreach ($configFile in $configFiles) {
            Write-Host "Checking config syntax: $($configFile.FullName)"
            & $CfgConvertPath '-test' $configFile.FullName
            $toolExitCode = $LASTEXITCODE

            if ($toolExitCode -ne 0) {
                $failures.Add("CfgConvert rejected '$($configFile.FullName)' (exit code $toolExitCode).")
            }
        }
    }
}

if (-not $SkipSqf) {
    if ([string]::IsNullOrWhiteSpace($SqfLintJar)) {
        $SqfLintJar = Find-SqfLintJar
    }

    if ([string]::IsNullOrWhiteSpace($SqfLintJar) -or -not (Test-Path -LiteralPath $SqfLintJar -PathType Leaf)) {
        throw 'SQFLint.jar was not found. Pass its full path with -SqfLintJar or use -SkipSqf.'
    }

    $javaCommand = Get-Command $JavaPath -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $javaCommand) {
        throw "Java was not found as '$JavaPath'. Pass its executable path with -JavaPath or use -SkipSqf."
    }

    $sqfFiles = @(
        Get-ChildItem -LiteralPath $addonsDirectory -Recurse -File |
            Where-Object { $_.Extension -in @('.sqf', '.sqfc') } |
            Sort-Object -Property FullName
    )

    if ($sqfFiles.Count -eq 0) {
        Write-Host 'No SQF files found; SQFLint had nothing to check.'
    }
    else {
        foreach ($sqfFile in $sqfFiles) {
            Write-Host "Checking SQF syntax: $($sqfFile.FullName)"
            $lintTarget = $sqfFile.FullName
            $temporaryLintTarget = $null

            try {
                $sqfSource = Get-Content -Raw -LiteralPath $sqfFile.FullName
                if ($sqfSource -match '\b(?:fromJSON|toJSON)\b') {
                    # SQFLint 0.12.4 predates Arma 3's 2.18 JSON commands. Give
                    # it syntax-equivalent unary commands while retaining the
                    # real, data-only engine commands in the shipped source.
                    $temporaryLintTarget = Join-Path $sqfFile.DirectoryName ('.' + $sqfFile.BaseName + '.raca-lint-' + [guid]::NewGuid().ToString('N') + $sqfFile.Extension)
                    $lintSource = $sqfSource -replace '\bfromJSON\b', 'parseSimpleArray' -replace '\btoJSON\b', 'str'
                    [System.IO.File]::WriteAllText($temporaryLintTarget, $lintSource, [System.Text.UTF8Encoding]::new($false))
                    $lintTarget = $temporaryLintTarget
                }

                & $javaCommand.Source '-jar' $SqfLintJar '-nw' '-oc' $lintTarget
                $toolExitCode = $LASTEXITCODE
            }
            finally {
                if ($null -ne $temporaryLintTarget -and (Test-Path -LiteralPath $temporaryLintTarget -PathType Leaf)) {
                    Remove-Item -LiteralPath $temporaryLintTarget -Force
                }
            }

            if ($toolExitCode -ne 0) {
                $failures.Add("SQFLint rejected '$($sqfFile.FullName)' (exit code $toolExitCode).")
            }
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host ''
    Write-Host 'Validation failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host "- $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host ''
Write-Host "Validation passed for '$repositoryRoot'." -ForegroundColor Green
