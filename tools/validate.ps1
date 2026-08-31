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
    foreach ($formatName in @('JSON', 'SQF', 'LIST')) {
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

$creatorUiPath = Join-Path $addonsDirectory 'core\ui\RscDisplayCreator.hpp'
if (Test-Path -LiteralPath $creatorUiPath -PathType Leaf) {
    $creatorUiSource = Get-Content -Raw -LiteralPath $creatorUiPath
    if ($creatorUiSource -notmatch 'RACA_IDC_DELETE_PRESET' -or $creatorUiSource -notmatch 'RACA_fnc_deletePreset') {
        $failures.Add("The creator must expose preset deletion from Preset Management.")
    }
}

$edenPopulatePath = Join-Path $addonsDirectory 'eden\functions\fn_edenPopulate.sqf'
if (Test-Path -LiteralPath $edenPopulatePath -PathType Leaf) {
    $edenPopulate = Get-Content -Raw -LiteralPath $edenPopulatePath
    if ($edenPopulate -notmatch 'RACA_fnc_flattenPreset') {
        $failures.Add("Eden must embed standalone preset copies with no runtime source dependency.")
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
