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
    'addons\core\functions\ui\fn_clearDraftRecovery.sqf',
    'addons\core\functions\ui\fn_offerDraftRecovery.sqf',
    'addons\core\functions\ui\fn_queueDraftRecovery.sqf',
    'addons\core\functions\ui\fn_saveDraftRecovery.sqf',
    'addons\core\functions\ui\fn_switchCreatorTab.sqf',
    'addons\eden\ui\PresetAttribute.hpp',
    'addons\eden\ui\EdenConfigDialog.hpp',
    'addons\eden\functions\fn_edenAttributeOnLoad.sqf',
    'addons\eden\functions\fn_edenEditorApply.sqf',
    'addons\eden\functions\fn_edenEditorSelectSlot.sqf',
    'addons\eden\functions\fn_edenDashboardBulk.sqf',
    'addons\eden\functions\fn_edenDashboardCopy.sqf',
    'addons\eden\functions\fn_edenDashboardRefresh.sqf',
    'addons\eden\functions\fn_edenDashboardSelect.sqf',
    'addons\eden\functions\fn_edenConfigurationToObjectConfig.sqf',
    'addons\eden\functions\fn_edenGetConfigurations.sqf',
    'addons\eden\functions\fn_edenStoreConfigurations.sqf',
    'addons\eden\functions\fn_edenSwitchTab.sqf',
    'docs\PORTABLE_PRESET_FORMAT.md',
    'tests\multiplayer\RACA_Rehearsal.VR\mission.sqm',
    'tests\multiplayer\RACA_Rehearsal.VR\description.ext',
    'tests\multiplayer\RACA_Rehearsal.VR\initServer.sqf',
    'tests\multiplayer\RACA_Rehearsal.VR\initPlayerLocal.sqf',
    'tests\multiplayer\server.cfg',
    'tests\multiplayer\README.md',
    'tools\prepare-multiplayer-smoke.ps1',
    'tests\autotest\RACA_Automated.VR\mission.sqm',
    'tests\autotest\RACA_Automated.VR\description.ext',
    'tests\autotest\RACA_Automated.VR\initPlayerLocal.sqf',
    'tests\autotest\README.md',
    'tools\prepare-autotest.ps1'
)
foreach ($relativeFile in $requiredRelativeFiles) {
    $requiredFile = Join-Path $repositoryRoot $relativeFile
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        $failures.Add("Required runtime file is missing: '$requiredFile'.")
    }
}

$multiplayerMissionPath = Join-Path $repositoryRoot 'tests\multiplayer\RACA_Rehearsal.VR\mission.sqm'
$multiplayerDescriptionPath = Join-Path $repositoryRoot 'tests\multiplayer\RACA_Rehearsal.VR\description.ext'
$multiplayerServerInitPath = Join-Path $repositoryRoot 'tests\multiplayer\RACA_Rehearsal.VR\initServer.sqf'
$multiplayerClientInitPath = Join-Path $repositoryRoot 'tests\multiplayer\RACA_Rehearsal.VR\initPlayerLocal.sqf'
$multiplayerServerConfigPath = Join-Path $repositoryRoot 'tests\multiplayer\server.cfg'
$multiplayerPreparePath = Join-Path $repositoryRoot 'tools\prepare-multiplayer-smoke.ps1'
if (@(
    $multiplayerMissionPath,
    $multiplayerDescriptionPath,
    $multiplayerServerInitPath,
    $multiplayerClientInitPath,
    $multiplayerServerConfigPath,
    $multiplayerPreparePath
).Where({-not (Test-Path -LiteralPath $_ -PathType Leaf)}).Count -gt 0) {
    $failures.Add("The reproducible dedicated multiplayer smoke harness is incomplete.")
}
else {
    $multiplayerMission = Get-Content -Raw -LiteralPath $multiplayerMissionPath
    $multiplayerDescription = Get-Content -Raw -LiteralPath $multiplayerDescriptionPath
    $multiplayerServerInit = Get-Content -Raw -LiteralPath $multiplayerServerInitPath
    $multiplayerClientInit = Get-Content -Raw -LiteralPath $multiplayerClientInitPath
    $multiplayerServerConfig = Get-Content -Raw -LiteralPath $multiplayerServerConfigPath
    $multiplayerPrepare = Get-Content -Raw -LiteralPath $multiplayerPreparePath
    if ($multiplayerMission -notmatch 'items\s*=\s*2\s*;' -or
        $multiplayerMission -notmatch 'player\s*=\s*"PLAYER COMMANDER"\s*;' -or
        $multiplayerMission -notmatch 'player\s*=\s*"PLAY CDG"\s*;' -or
        $multiplayerDescription -notmatch 'skipLobby\s*=\s*1\s*;' -or
        $multiplayerServerInit -notmatch 'RACA_fnc_applyObjectConfig' -or
        $multiplayerServerInit -notmatch 'RACA_MPTestStartUID' -or
        $multiplayerClientInit -notmatch 'RACA_fnc_requestRehearsal' -or
        $multiplayerClientInit -notmatch 'RACA_fnc_rehearsalClientReady' -or
        $multiplayerServerConfig -notmatch 'template\s*=\s*"RACA_Rehearsal\.VR"\s*;' -or
        $multiplayerPrepare -notmatch 'arma3server_x64\.exe' -or
        $multiplayerPrepare -notmatch 'Profiles\\') {
        $failures.Add("The dedicated multiplayer smoke harness must configure a real RACA object and distinguish initial-client, reconnect, and JIP pathways.")
    }
}

$autotestMissionPath = Join-Path $repositoryRoot 'tests\autotest\RACA_Automated.VR\mission.sqm'
$autotestDescriptionPath = Join-Path $repositoryRoot 'tests\autotest\RACA_Automated.VR\description.ext'
$autotestClientInitPath = Join-Path $repositoryRoot 'tests\autotest\RACA_Automated.VR\initPlayerLocal.sqf'
$autotestReadmePath = Join-Path $repositoryRoot 'tests\autotest\README.md'
$autotestPreparePath = Join-Path $repositoryRoot 'tools\prepare-autotest.ps1'
if (@(
    $autotestMissionPath,
    $autotestDescriptionPath,
    $autotestClientInitPath,
    $autotestReadmePath,
    $autotestPreparePath
).Where({-not (Test-Path -LiteralPath $_ -PathType Leaf)}).Count -gt 0) {
    $failures.Add('The unattended Arma automated acceptance harness is incomplete.')
}
else {
    $autotestMission = Get-Content -Raw -LiteralPath $autotestMissionPath
    $autotestDescription = Get-Content -Raw -LiteralPath $autotestDescriptionPath
    $autotestClientInit = Get-Content -Raw -LiteralPath $autotestClientInitPath
    $autotestReadme = Get-Content -Raw -LiteralPath $autotestReadmePath
    $autotestPrepare = Get-Content -Raw -LiteralPath $autotestPreparePath
    if ($autotestMission -notmatch 'briefingName\s*=\s*"RACA Automated Acceptance"\s*;' -or
        $autotestDescription -notmatch 'debriefing\s*=\s*0\s*;' -or
        $autotestClientInit -notmatch '\[RACA AUTOTEST\] BEGIN' -or
        $autotestClientInit -notmatch 'RACA_fnc_decodePortablePreset' -or
        $autotestClientInit -notmatch 'RACA_fnc_decodeSqfPreset' -or
        $autotestClientInit -notmatch 'RACA_fnc_preflightObjectConfig' -or
        $autotestClientInit -notmatch 'RACA_fnc_applyObjectConfig' -or
        $autotestClientInit -notmatch 'RACA_fnc_evaluateAccess' -or
        $autotestClientInit -notmatch 'RACA_fnc_requestOpen' -or
        $autotestClientInit -notmatch 'RACA_fnc_isAdminAuthorized' -or
        $autotestClientInit -notmatch 'RACA_fnc_unregisterObject' -or
        $autotestClientInit -notmatch 'RACA_fnc_countLoadout' -or
        $autotestClientInit -notmatch 'RACA_fnc_resetQuotas' -or
        $autotestClientInit -notmatch 'RACA_fnc_savePlayerLoadout' -or
        $autotestClientInit -notmatch 'RACA_fnc_applyPlayerLoadout' -or
        $autotestClientInit -notmatch 'RACA_fnc_deletePlayerLoadout' -or
        $autotestClientInit -notmatch 'RACA_fnc_finishSession' -or
        $autotestClientInit -notmatch 'RACA_fnc_moduleAssign' -or
        $autotestClientInit -notmatch 'RACA_fnc_moduleClear' -or
        $autotestClientInit -notmatch 'RACA_fnc_moduleToggle' -or
        $autotestClientInit -notmatch 'RACA_fnc_moduleResetQuotas' -or
        $autotestClientInit -notmatch 'RACA_fnc_openCreatorDiagnostics' -or
        $autotestClientInit -notmatch 'RACA_fnc_deletePreset' -or
        $autotestClientInit -notmatch 'RACA_fnc_removePresetFromLibrary' -or
        $autotestClientInit -notmatch 'RACA_fnc_getPresetHistory' -or
        $autotestClientInit -notmatch 'RACA_fnc_analyzeEnvironment' -or
        $autotestClientInit -notmatch 'RACA_fnc_buildModManifest' -or
        $autotestClientInit -notmatch 'RACA_fnc_buildSupportBundle' -or
        $autotestClientInit -notmatch 'RACA_fnc_applyTemplateParameters' -or
        $autotestClientInit -notmatch 'RACA_fnc_getRolePacks' -or
        $autotestClientInit -notmatch 'RACA_fnc_getSavedCatalogViews' -or
        $autotestClientInit -notmatch 'RACA_fnc_getCatalogTags' -or
        $autotestClientInit -notmatch 'RACA_fnc_openQuickStart' -or
        $autotestClientInit -notmatch 'RACA_fnc_openItemDetails' -or
        $autotestClientInit -notmatch 'RACA_fnc_openRolePacks' -or
        $autotestClientInit -notmatch 'RACA_fnc_openSavedCatalogViews' -or
        $autotestClientInit -notmatch 'RACA_fnc_openCatalogTags' -or
        $autotestClientInit -notmatch 'RACA_fnc_toggleFavorite' -or
        $autotestClientInit -notmatch 'RACA_fnc_restoreCreatorHistory' -or
        $autotestClientInit -notmatch 'Deleted from profile library' -or
        $autotestClientInit -notmatch 'RACA_RscDisplayCreator' -or
        $autotestClientInit -notmatch 'displayCtrl 1616' -or
        $autotestClientInit -notmatch 'endMission' -or
        $autotestReadme -notmatch '\[RACA AUTOTEST\]' -or
        $autotestPrepare -notmatch 'arma3_x64\.exe' -or
        $autotestPrepare -notmatch 'RACA_Automated\.VR' -or
        $autotestPrepare -notmatch '-autotest=' -or
        $autotestPrepare -notmatch 'Profiles\\') {
        $failures.Add('The unattended acceptance harness must exercise packaged creator, interchange, Eden, runtime, Zeus, quota, and deletion behavior and emit a machine-readable result.')
    }
}

$preflightRefreshPath = Join-Path $addonsDirectory 'core\functions\ui\fn_preflightRefresh.sqf'
if (-not (Test-Path -LiteralPath $preflightRefreshPath -PathType Leaf)) {
    $failures.Add('The Creator compatibility-detail renderer is missing.')
}
else {
    $preflightRefresh = Get-Content -Raw -LiteralPath $preflightRefreshPath
    if ($preflightRefresh -notmatch '_modName\s*\+\s*\(if\s*\(') {
        $failures.Add('The Creator compatibility-detail source label must parenthesize its conditional suffix before concatenation.')
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
    if ($edenCfg -match '(?s)class\s+RACA_Preset\s*\{.*?\bvalue\s*=') {
        $failures.Add("The array-valued Eden preset attribute must not declare the scalar-only 'value' property.")
    }
    if ($edenCfg -notmatch 'RACA_ArsenalConfigurations' -or
        $edenCfg -notmatch 'RACA_missionArsenalConfigurations') {
        $failures.Add("Eden must serialize the reusable Arsenal Configuration library into a mission attribute.")
    }
}

$edenAddonConfigPath = Join-Path $addonsDirectory 'eden\config.cpp'
if (Test-Path -LiteralPath $edenAddonConfigPath -PathType Leaf) {
    $edenAddonConfig = Get-Content -Raw -LiteralPath $edenAddonConfigPath
    foreach ($requiredPattern in @('class\s+display3DEN', 'class\s+Tools', 'items\[\]\s*\+=', 'RACA Mission Arsenal Tool', 'RACA_fnc_edenOpenEditor')) {
        if ($edenAddonConfig -notmatch $requiredPattern) {
            $failures.Add("The Eden Tools menu integration is missing '$requiredPattern'.")
        }
    }
}

$edenDialogPath = Join-Path $addonsDirectory 'eden\ui\EdenConfigDialog.hpp'
if (Test-Path -LiteralPath $edenDialogPath -PathType Leaf) {
    $edenDialog = Get-Content -Raw -LiteralPath $edenDialogPath
    foreach ($requiredPattern in @(
        '(?i)MISSION\s+DASHBOARD',
        '(?i)CONFIGURE',
        '(?i)ARSENAL\s+CONFIGURATION',
        '(?i)ITEM\s+NAME',
        '(?i)CLASS\s+NAME',
        '(?i)VARIABLE\s+NAME',
        '(?i)APPLY\s+TO\s+OBJECT',
        '(?i)ACCESS\s+RULES',
        '(?i)SAVE\s+CONFIGURATION',
        '(?i)COPY\s+REPORT',
        'RACA_EDEN_IDC_DASHBOARD_GROUP',
        'RACA_EDEN_IDC_CONFIGURE_GROUP',
        'GUI_BCG_RGB_R',
        'font\s*=\s*"Purista'
    )) {
        if ($edenDialog -notmatch $requiredPattern) {
            $failures.Add("The Eden configuration editor is missing required pattern '$requiredPattern'.")
        }
    }
    if ($edenDialog -notmatch 'spawn\s+RACA_fnc_edenDashboardBulk') {
        $failures.Add('Mission-wide Eden confirmations must run in a scheduled environment.')
    }
    if ($edenDialog -notmatch '(?s)class\s+HeaderBar\s*:\s*ctrlStatic\s*\{.*?text\s*=\s*"RACA Mission Arsenal Tool".*?colorText\[\]\s*=\s*\{1,\s*1,\s*1,\s*1\}' -or
        $edenDialog -notmatch '(?s)class\s+HeaderBar\s*:\s*ctrlStatic\s*\{.*?text\s*=\s*"RACA Access-Rule Test".*?colorText\[\]\s*=\s*\{1,\s*1,\s*1,\s*1\}') {
        $failures.Add('Eden tool profile-color header bars must directly render their centered white titles.')
    }
    if ($edenDialog -match 'class\s+\w+\s*:\s*ctrlButton') {
        $failures.Add('Eden tool buttons must use the title-case RscButton style instead of ctrlButton uppercase rendering.')
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

$edenCommitPath = Join-Path $addonsDirectory 'eden\functions\fn_edenEditorCommitSlot.sqf'
$edenApplyPath = Join-Path $addonsDirectory 'eden\functions\fn_edenEditorApply.sqf'
$edenCommitCallers = @(
    (Join-Path $addonsDirectory 'eden\functions\fn_edenEditorAddSlot.sqf'),
    (Join-Path $addonsDirectory 'eden\functions\fn_edenEditorAddCondition.sqf'),
    (Join-Path $addonsDirectory 'eden\functions\fn_edenEditorMoveSlot.sqf'),
    (Join-Path $addonsDirectory 'eden\functions\fn_edenEditorRemoveCondition.sqf')
)
if (-not (Test-Path -LiteralPath $edenCommitPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $edenApplyPath -PathType Leaf) -or
    $edenCommitCallers.Where({-not (Test-Path -LiteralPath $_ -PathType Leaf)}).Count -gt 0) {
    $failures.Add('The Eden slot editor must preserve transactional validation across every editing action.')
}
else {
    $edenCommit = Get-Content -Raw -LiteralPath $edenCommitPath
    $edenApply = Get-Content -Raw -LiteralPath $edenApplyPath
    if ($edenCommit -notmatch 'count _name\) > 128' -or
        $edenCommit -notmatch 'count _denialMessage\) > 512' -or
        $edenCommit -notmatch 'count _icon\) > 512' -or
        $edenApply -notmatch 'if !\(\[_display, -1, false\] call RACA_fnc_edenEditorCommitSlot\)' -or
        $edenApply -notmatch 'RACA_fnc_validateConfigurationForAssignment') {
        $failures.Add('Eden slot edits must validate field bounds, stop when commit fails, and pass object preflight before application.')
    }
    foreach ($edenCommitCaller in $edenCommitCallers) {
        $edenCommitCallerSource = Get-Content -Raw -LiteralPath $edenCommitCaller
        if ($edenCommitCallerSource -notmatch 'if !\(\[_display, -1, false\] call RACA_fnc_edenEditorCommitSlot\)') {
            $failures.Add("Eden editor action '$([System.IO.Path]::GetFileName($edenCommitCaller))' must stop when the current slot cannot be committed.")
        }
    }
    if ((Test-Path -LiteralPath $edenSelectSlotPath -PathType Leaf)) {
        $edenSelectSlot = Get-Content -Raw -LiteralPath $edenSelectSlotPath
        if ($edenSelectSlot -notmatch '_canLeavePrevious' -or $edenSelectSlot -notmatch 'lbSetCurSel _previous') {
            $failures.Add('Eden slot navigation must remain on the current slot when its pending fields cannot be committed.')
        }
    }
}

$edenBulkPath = Join-Path $addonsDirectory 'eden\functions\fn_edenDashboardBulk.sqf'
if (Test-Path -LiteralPath $edenBulkPath -PathType Leaf) {
    $edenBulk = Get-Content -Raw -LiteralPath $edenBulkPath
    foreach ($requiredPattern in @('RACA_EDEN_IDC_DASHBOARD_LIST', 'RACA_EDEN_IDC_DASHBOARD_ASSIGNMENT', 'RACA_fnc_validateConfigurationForAssignment', 'BIS_fnc_guiMessage', 'closeDisplay 1', 'RACA_fnc_edenOpenEditor', 'set3DENAttributes', 'get3DENEntityID', 'do3DENAction "OpenAttributes"', 'RACA_edenNativeTransaction', '_didSet', 'get3DENAttribute', '_stored isEqualTo _value')) {
        if ($edenBulk -notmatch $requiredPattern) {
            $failures.Add("The Eden Dashboard assignment workflow is missing '$requiredPattern'.")
        }
    }
}

$edenAttributeLoadPath = Join-Path $addonsDirectory 'eden\functions\fn_edenAttributeLoad.sqf'
if (Test-Path -LiteralPath $edenAttributeLoadPath -PathType Leaf) {
    $edenAttributeLoad = Get-Content -Raw -LiteralPath $edenAttributeLoadPath
    foreach ($requiredPattern in @('RACA_EDEN_NATIVE_TRANSACTION', 'RACA_edenNativeTransaction', 'get3DENSelected "Object"', 'RACA_EDEN_IDC_PRESET', 'ctrlActivate', 'displayCtrl 1', 'library changed', 'selection changed')) {
        if ($edenAttributeLoad -notmatch $requiredPattern) {
            $failures.Add("The native Eden attribute bridge is missing '$requiredPattern'.")
        }
    }
}

$edenDashboardRefreshPath = Join-Path $addonsDirectory 'eden\functions\fn_edenDashboardRefresh.sqf'
$edenDashboardCopyPath = Join-Path $addonsDirectory 'eden\functions\fn_edenDashboardCopy.sqf'
$edenDashboardRenderPath = Join-Path $addonsDirectory 'eden\functions\fn_edenDashboardRenderPage.sqf'
if (-not (Test-Path -LiteralPath $edenDashboardRefreshPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $edenDashboardCopyPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $edenDashboardRenderPath -PathType Leaf)) {
    $failures.Add('The Eden mission dashboard must provide mission-wide preflight and report-copy functions.')
}
else {
    $edenDashboard = (Get-Content -Raw -LiteralPath $edenDashboardRefreshPath) +
        [Environment]::NewLine +
        (Get-Content -Raw -LiteralPath $edenDashboardRenderPath) +
        [Environment]::NewLine +
        (Get-Content -Raw -LiteralPath $edenDashboardCopyPath)
    foreach ($requiredPattern in @('all3DENEntities\s+select\s+0', 'RACA_EDEN_IDC_VARIABLE_FILTER', 'RACA_EDEN_IDC_OBJECT_FILTER', 'RACA_EDEN_IDC_DASHBOARD_SEARCH', 'lnbAddRow', 'lnbSetColor', 'RACA_fnc_preflightObjectConfig', 'RACA_dashboardMissionReport', 'RACA_fnc_copyTextAndLog')) {
        if ($edenDashboard -notmatch $requiredPattern) {
            $failures.Add("The Eden mission-object Dashboard is missing '$requiredPattern'.")
        }
    }
    foreach ($requiredPattern in @('RACA_transactionPreflightReport', 'RACA_transactionPreflightSummary')) {
        if ($edenDashboard -notmatch $requiredPattern) {
            $failures.Add("The Eden dashboard cannot copy the last unsaved preflight because '$requiredPattern' is missing.")
        }
    }
}

$objectPreflightPath = Join-Path $addonsDirectory 'core\functions\diagnostics\fn_preflightObjectConfig.sqf'
if (-not (Test-Path -LiteralPath $objectPreflightPath -PathType Leaf)) {
    $failures.Add('Object preflight must fail closed on malformed slot, access, and quota policy fields.')
}
else {
    $objectPreflight = Get-Content -Raw -LiteralPath $objectPreflightPath
    foreach ($requiredDiagnostic in @(
        'INVALID_SLOT_CONTAINER',
        'DUPLICATE_SLOT_ID',
        'INVALID_ACCESS_CONTAINER',
        'MALFORMED_ACCESS_CONDITION',
        'UNSUPPORTED_ACCESS_CONDITION',
        'INVALID_ACCESS_VALUE',
        'INVALID_LIMIT_CONTAINER',
        'INVALID_LIMIT_VALUE_TYPE',
        'INVALID_LIMIT_SCOPE_TYPE',
        'INVALID_RESET_POLICY_TYPE',
        'SLOT_NAME_TOO_LONG',
        'DENIAL_MESSAGE_TOO_LONG',
        'SLOT_ICON_TOO_LONG'
    )) {
        if ($objectPreflight -notmatch [regex]::Escape($requiredDiagnostic)) {
            $failures.Add("Object preflight is missing fail-closed diagnostic '$requiredDiagnostic'.")
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
    if ($creatorUi -notmatch 'style\s*=\s*32' -or $creatorUi -notmatch 'RACA_fnc_toggleRow') {
        $failures.Add("The item list must use explicit multi-selection style and the class-identity toggle controller.")
    }
    if ($creatorUi -notmatch 'idc\s*=\s*RACA_IDC_EXPORT_FORMAT' -or
        $creatorUi -notmatch 'text\s*=\s*"Import Automatically"') {
        $failures.Add("The creator must expose the export-format selector and automatic importer.")
    }
    $creatorOnLoadPath = Join-Path $addonsDirectory 'core\functions\ui\fn_creatorOnLoad.sqf'
    if (Test-Path -LiteralPath $creatorOnLoadPath -PathType Leaf) {
        $creatorOnLoad = Get-Content -Raw -LiteralPath $creatorOnLoadPath
        if ($creatorOnLoad -notmatch 'lbSetTooltip' -or
            $creatorOnLoad -notmatch 'lossless RACA re-import' -or
            $creatorOnLoad -notmatch 'mission-folder script' -or
            $creatorOnLoad -notmatch 'comma-separated list' -or
            $creatorOnLoad -notmatch 'mission deployment' -or
            $creatorOnLoad -notmatch 'diagnostic context') {
            $failures.Add('Every Creator export format must provide option-specific hover guidance explaining when to choose it.')
        }
    }
    if ($creatorUi -notmatch 'text\s*=\s*"Limit Selection"' -or
        $creatorUi -match 'text\s*=\s*"Limit Item"') {
        $failures.Add("The multi-row quantity action must be labelled 'Limit Selection'.")
    }
    if ($creatorUi -notmatch 'spawn\s+RACA_fnc_importPreset') {
        $failures.Add('Import Auto must run in a scheduled environment so duplicate-preset confirmation can suspend safely.')
    }
    if ($creatorUi -notmatch 'onKeyUp\s*=\s*"[^"\r\n]*RACA_fnc_queueDraftRecovery') {
        $failures.Add('Preset-name edits must mark and checkpoint the creator draft.')
    }
    if ($creatorUi -notmatch 'idc\s*=\s*RACA_IDC_BASE_PRESET' -or
        $creatorUi -notmatch 'text\s*=\s*"Inherit / Refresh"' -or
        $creatorUi -notmatch 'text\s*=\s*"Make Standalone"') {
        $failures.Add("The creator must expose source-preset selection, explicit inheritance, and standalone conversion.")
    }
    if ($creatorUi -notmatch 'text\s*=\s*"Arsenal Creation Assistant"' -or
        $creatorUi -notmatch 'text\s*=\s*"Preset Management"' -or
        $creatorUi -notmatch 'text\s*=\s*"Arsenal Contents"' -or
        $creatorUi -match 'PRESET LIBRARY') {
        $failures.Add("The creator must use the centered title and two-tab Preset Management/Arsenal Contents layout.")
    }
    if ($creatorUi -notmatch 'RACA_IDC_SEARCH_MODE' -or
        $creatorUi -notmatch 'RACA_IDC_PRESET_TOOL' -or
        $creatorUi -notmatch 'RACA_IDC_QUICK_SETTINGS' -or
        $creatorUi -match 'idc\s*=\s*RACA_IDC_VIEW_MODE') {
        $failures.Add("The creator must expose persistent Basic/Advanced search and consolidated preset tools, move role starters into Quick Start settings, and keep item icons always visible.")
    }
    if ($creatorUi -notmatch 'GUI_BCG_RGB_R' -or
        $creatorUi -notmatch 'GUI_BCG_RGB_G' -or
        $creatorUi -notmatch 'GUI_BCG_RGB_B') {
        $failures.Add("Creator accent surfaces must use the player's Menu Background profile color.")
    }
    if ($creatorUi -notmatch 'RACA_IDC_TAB_PRESETS_INDICATOR' -or
        $creatorUi -notmatch 'RACA_IDC_TAB_ASSIGNMENT_INDICATOR' -or
        $creatorUi -notmatch 'colorBackgroundDisabled\[\].*GUI_BCG_RGB_R' -or
        $creatorUi -notmatch 'periodFocus\s*=\s*0') {
        $failures.Add("The active Creator tab must retain an unfaded profile-color indicator without focus pulsing.")
    }
    if ($creatorUi -notmatch 'text\s*=\s*"Preset Analysis"' -or
        $creatorUi -notmatch 'text\s*=\s*"See History"' -or
        $creatorUi -notmatch 'text\s*=\s*"Compare With Draft"' -or
        $creatorUi -match 'JSON is the lossless backup format') {
        $failures.Add("Preset Management must provide the dedicated Preset Analysis selector and direct actions without the former export explanation block.")
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
        $failures.Add("The Inherited category must only appear when an inherited source snapshot exists.")
    }
}

$itemRefreshPath = Join-Path $addonsDirectory 'core\functions\ui\fn_refreshItemList.sqf'
if (Test-Path -LiteralPath $itemRefreshPath -PathType Leaf) {
    $itemRefresh = Get-Content -Raw -LiteralPath $itemRefreshPath
    if ($itemRefresh -notmatch '"Included"' -or $itemRefresh -notmatch '"Inherited"' -or
        $itemRefresh -notmatch '0\.55,\s*0\.82,\s*1') {
        $failures.Add("Arsenal Contents filtering must support Included/Inherited and mark inherited-source rows light blue.")
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
    if ($catalogSource -match 'modParams\s*\[[^\]]*"author"') {
        $failures.Add("Catalogue scanning must not request the unsupported modParams 'author' option.")
    }
    if ($catalogSource -notmatch 'configFile\s*>>\s*"CfgPatches"' -or
        $catalogSource -notmatch 'getArray\s*\(_patch\s*>>\s*_x\)' -or
        $catalogSource -notmatch 'configSourceMod\s+_sourcePatch' -or
        $catalogSource -notmatch 'modParams\s*\[\s*_sourceMod') {
        $failures.Add("Catalogue mod labels must resolve the declaring CfgPatches add-on and its source mod before reading the display name.")
    }
}

$settingsRegistrationPath = Join-Path $addonsDirectory 'core\functions\settings\fn_registerSettings.sqf'
$stringtablePath = Join-Path $addonsDirectory 'core\stringtable.xml'
if (-not (Test-Path -LiteralPath $settingsRegistrationPath -PathType Leaf)) {
    $failures.Add('CBA settings must be registered from the preInit Settings function group.')
} else {
    $settingsRegistration = Get-Content -Raw -LiteralPath $settingsRegistrationPath
    foreach ($settingName in @(
        'RACA_catalogPageSize', 'RACA_defaultSearchMode', 'RACA_defaultCompatibilitySeverity',
        'RACA_openItemDetailsOnSelection', 'RACA_draftRecoveryEnabled', 'RACA_showOnboardingGuidance',
        'RACA_statusVerbosity', 'RACA_enableZeusModules', 'RACA_allowZeusProfilePresetFallback'
    )) {
        $registrationPattern = [regex]::Escape('"' + $settingName + '"') + '\s*,\s*"(?:LIST|CHECKBOX)"'
        if (([regex]::Matches($settingsRegistration, $registrationPattern)).Count -ne 1) {
            $failures.Add("CBA setting '$settingName' must be registered exactly once.")
        }
    }
    if ($settingsRegistration -notmatch 'CBA_fnc_addSetting' -or
        $settingsRegistration -match 'RACA_fnc_scanItems|createDisplay|saveProfileNamespace|remoteExec') {
        $failures.Add('Settings preInit registration must be side-effect free outside CBA registration.')
    }
    if ($settingsRegistration -notmatch 'RACA_fnc_dispatchSettingChange') {
        $failures.Add('Every CBA callback must route through the centralized setting dispatcher.')
    }
}
$settingsAccessorPath = Join-Path $addonsDirectory 'core\functions\settings\fn_getSetting.sqf'
$settingsDispatcherPath = Join-Path $addonsDirectory 'core\functions\settings\fn_dispatchSettingChange.sqf'
if (-not (Test-Path -LiteralPath $settingsAccessorPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $settingsDispatcherPath -PathType Leaf)) {
    $failures.Add('CBA consumers require a typed accessor and centralized callback dispatcher.')
} else {
    $settingsAccessor = Get-Content -Raw -LiteralPath $settingsAccessorPath
    $settingsDispatcher = Get-Content -Raw -LiteralPath $settingsDispatcherPath
    if ($settingsAccessor -notmatch 'missionNamespace getVariable' -or
        $settingsAccessor -notmatch '\[50, 100, 200, 400\]' -or
        $settingsAccessor -notmatch 'isEqualType') {
        $failures.Add('Settings accessor must normalize types, ranges, and defaults.')
    }
    if ($settingsDispatcher -notmatch 'RACA_settingDispatchRevisions' -or
        $settingsDispatcher -notmatch 'isNull _display' -or
        $settingsDispatcher -notmatch 'RACA_generation') {
        $failures.Add('Settings callbacks must be coalesced and reject closed or stale Creator displays.')
    }
}

$catalogPagingPaths = @(
    'core\functions\ui\fn_refreshItemList.sqf',
    'core\functions\ui\fn_catalogPage.sqf',
    'core\functions\ui\fn_restoreCatalogView.sqf',
    'core\functions\ui\fn_catalogTagMembersRefresh.sqf'
)
foreach ($relativePath in $catalogPagingPaths) {
    $pagingPath = Join-Path $addonsDirectory $relativePath
    if (Test-Path -LiteralPath $pagingPath -PathType Leaf) {
        $pagingSource = Get-Content -Raw -LiteralPath $pagingPath
        if ($pagingSource -match '(?<![0-9])200(?![0-9])' -or $pagingSource -notmatch 'RACA_catalogPageSize') {
            $failures.Add("Catalogue paging in '$relativePath' must use the validated CBA page-size setting.")
        }
    }
}

$creatorOnLoadPath = Join-Path $addonsDirectory 'core\functions\ui\fn_creatorOnLoad.sqf'
$searchModePath = Join-Path $addonsDirectory 'core\functions\ui\fn_setSearchMode.sqf'
if ((Test-Path -LiteralPath $creatorOnLoadPath -PathType Leaf) -and (Test-Path -LiteralPath $searchModePath -PathType Leaf)) {
    $creatorOnLoad = Get-Content -Raw -LiteralPath $creatorOnLoadPath
    $searchModeSource = Get-Content -Raw -LiteralPath $searchModePath
    if ($creatorOnLoad -notmatch '\["RACA_defaultSearchMode"\] call RACA_fnc_getSetting' -or
        $creatorOnLoad -match 'profileNamespace getVariable \["RACA_catalogSearchMode_v1"') {
        $failures.Add('A new Creator must use the typed default Search Mode preference, not stale profile view state.')
    }
    if ($settingsDispatcher -notmatch 'RACA_defaultSearchMode' -or
        $settingsDispatcher -notmatch 'RACA_fnc_setSearchMode') {
        $failures.Add('Live Search Mode preference changes must use the normal mode transition.')
    }
    if ($searchModeSource -notmatch 'RACA_fnc_refreshItemList') {
        $failures.Add('Search Mode transitions must finish through the normal catalogue refresh path.')
    }
}

$preflightOnLoadPath = Join-Path $addonsDirectory 'core\functions\ui\fn_preflightOnLoad.sqf'
$preflightRefreshPath = Join-Path $addonsDirectory 'core\functions\ui\fn_preflightRefresh.sqf'
if ((Test-Path -LiteralPath $preflightOnLoadPath -PathType Leaf) -and (Test-Path -LiteralPath $preflightRefreshPath -PathType Leaf)) {
    $preflightOnLoad = Get-Content -Raw -LiteralPath $preflightOnLoadPath
    $preflightRefresh = Get-Content -Raw -LiteralPath $preflightRefreshPath
    if ($preflightOnLoad -notmatch 'RACA_defaultCompatibilitySeverity' -or
        $preflightOnLoad -notmatch 'RACA_preflightDisplay') {
        $failures.Add('A new Compatibility Check must use the typed severity preference and expose its live display safely.')
    }
    if ($settingsDispatcher -notmatch 'RACA_defaultCompatibilitySeverity' -or
        $settingsDispatcher -match 'RACA_defaultCompatibilitySeverity[\s\S]{0,600}RACA_fnc_runCreatorDiagnostics') {
        $failures.Add('Live Compatibility severity changes must filter cached analysis without recomputing diagnostics.')
    }
    if ($preflightRefresh -notmatch 'RACA_fnc_preflightSelectionChanged') {
        $failures.Add('Compatibility filtering must revalidate selected-row action state after every refresh.')
    }
}

$toggleRowPath = Join-Path $addonsDirectory 'core\functions\ui\fn_toggleRow.sqf'
$openItemDetailsPath = Join-Path $addonsDirectory 'core\functions\ui\fn_openItemDetails.sqf'
$itemDetailsUnloadPath = Join-Path $addonsDirectory 'core\functions\ui\fn_itemDetailsOnUnload.sqf'
if ((Test-Path -LiteralPath $toggleRowPath -PathType Leaf) -and (Test-Path -LiteralPath $openItemDetailsPath -PathType Leaf)) {
    $toggleRow = Get-Content -Raw -LiteralPath $toggleRowPath
    $openItemDetails = Get-Content -Raw -LiteralPath $openItemDetailsPath
    if ($toggleRow -notmatch 'RACA_openItemDetailsOnSelection' -or
        $toggleRow -notmatch '!_keyboard' -or $toggleRow -notmatch '!_shift' -or
        $toggleRow -notmatch '!_ctrl' -or $toggleRow -notmatch '!_alt') {
        $failures.Add('Selection-driven Item Details must be gated to an unmodified primary mouse selection.')
    }
    if ($openItemDetails -notmatch '_expectedGeneration' -or
        $openItemDetails -notmatch 'RACA_itemDetailsOpening' -or
        $openItemDetails -notmatch 'RACA_itemDetailsDisplay') {
        $failures.Add('Item Details opening must validate Creator generation and enforce one live details display.')
    }
}

$saveDraftRecoveryPath = Join-Path $addonsDirectory 'core\functions\ui\fn_saveDraftRecovery.sqf'
if (Test-Path -LiteralPath $saveDraftRecoveryPath -PathType Leaf) {
    $saveDraftRecovery = Get-Content -Raw -LiteralPath $saveDraftRecoveryPath
    if ($saveDraftRecovery -notmatch '\["RACA_draftRecoveryEnabled"\] call RACA_fnc_getSetting' -or
        $saveDraftRecovery -match 'RACA_draftRecoveryEnabled[\s\S]{0,300}(?:setVariable \["RACA_creatorDraftRecovery_v1", nil\]|RACA_fnc_clearDraftRecovery)') {
        $failures.Add('Draft recovery opt-out must block only new writes and must not erase an existing record.')
    }
}

$statusFormatterPath = Join-Path $addonsDirectory 'core\functions\settings\fn_formatStatus.sqf'
$guidancePath = Join-Path $addonsDirectory 'core\functions\ui\fn_applyGuidancePreference.sqf'
if (-not (Test-Path -LiteralPath $statusFormatterPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $guidancePath -PathType Leaf)) {
    $failures.Add('Guidance and status preferences require centralized format/apply functions.')
} else {
    $statusFormatter = Get-Content -Raw -LiteralPath $statusFormatterPath
    $guidanceSource = Get-Content -Raw -LiteralPath $guidancePath
    if ($statusFormatter -notmatch 'RACA_statusVerbosity' -or
        $statusFormatter -notmatch 'critical' -or $statusFormatter -match 'exitWith \{\s*""\s*\}') {
        $failures.Add('Status verbosity must select wording without hiding critical messages.')
    }
    if ($guidanceSource -notmatch 'RACA_showOnboardingGuidance' -or
        $guidanceSource -match 'RACA_IDC_QUICK_START|RACA_fnc_refreshItemList') {
        $failures.Add('Guidance preference may hide optional copy only and must not hide Quick Start or redraw the catalogue.')
    }
    if ($settingsDispatcher -notmatch 'RACA_fnc_applyGuidancePreference') {
        $failures.Add('Live guidance changes must update optional controls through the centralized dispatcher.')
    }
}

$zeusHandlerPath = Join-Path $addonsDirectory 'core\functions\zeus\fn_handleZeusModuleRequest.sqf'
if (Test-Path -LiteralPath $zeusHandlerPath -PathType Leaf) {
    $zeusHandler = Get-Content -Raw -LiteralPath $zeusHandlerPath
    if (([regex]::Matches($zeusHandler, '\["RACA_enableZeusModules"\] call RACA_fnc_getSetting')).Count -lt 2 -or
        $zeusHandler -notmatch '\["RACA_allowZeusProfilePresetFallback"\] call RACA_fnc_getSetting') {
        $failures.Add('The server Zeus handler must use typed authoritative settings and re-check enablement at commit time.')
    }
    if ($zeusHandler -match 'RACA_allowZeusModules|RACA_allowZeusProfileFallback') {
        $failures.Add('Legacy missionNamespace Zeus toggles must not bypass authoritative CBA settings.')
    }
    $embeddedLookup = $zeusHandler.IndexOf('RACA_missionArsenalConfigurations')
    $fallbackLookup = $zeusHandler.IndexOf('RACA_allowZeusProfilePresetFallback')
    if ($embeddedLookup -lt 0 -or $fallbackLookup -le $embeddedLookup) {
        $failures.Add('Zeus assignment must resolve embedded mission configurations before profile fallback.')
    }
}
if (-not (Test-Path -LiteralPath $itemDetailsUnloadPath -PathType Leaf) -or
    (Get-Content -Raw -LiteralPath $itemDetailsUnloadPath) -notmatch 'ctrlSetFocus') {
    $failures.Add('Closing Item Details must restore focus to the Creator list without opening another display.')
}
if (-not (Test-Path -LiteralPath $stringtablePath -PathType Leaf)) {
    $failures.Add('CBA setting labels and tooltips require a localization resource.')
} else {
    try {[void][xml](Get-Content -Raw -LiteralPath $stringtablePath)} catch {$failures.Add("stringtable.xml is not valid XML: $($_.Exception.Message)")}
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
    if ($portableImport -match '2000000|20000-reference|metadata safety limit' -or
        $portableImport -notmatch 'RACA_fnc_importCheckpoint' -or
        $portableImport -notmatch 'RACA_PORTABLE_PRESET') {
        $failures.Add("Portable import must use measured, cancellable batches without obsolete arbitrary size ceilings.")
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
    if ($portableExport -notmatch 'RACA_fnc_copyTextAndLog') {
        $failures.Add("Preset export must route its immutable output through the clipboard/RPT archive helper.")
    }
}

$portableJsonFormatPath = Join-Path $addonsDirectory 'core\functions\presets\fn_formatPortableJson.sqf'
$clipboardRecoveryPath = Join-Path $repositoryRoot 'tools\reconstruct-rpt-copy.ps1'
if (-not (Test-Path -LiteralPath $clipboardRecoveryPath -PathType Leaf)) {
    $failures.Add("The RPT clipboard archive must include its integrity-checking reconstruction utility.")
}
$directClipboardUse = Get-ChildItem -LiteralPath $addonsDirectory -Recurse -File -Filter '*.sqf' |
    Where-Object {$_.Name -ne 'fn_copyTextAndLog.sqf'} |
    Select-String -Pattern '\bcopyToClipboard\b'
if ($directClipboardUse) {
    $failures.Add("All clipboard writes must route through fn_copyTextAndLog.sqf so the exact payload is archived to RPT.")
}
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
    if ($sqfImport -match '2000000|50000|20000' -or
        $sqfImport -notmatch 'RACA_fnc_importCheckpoint' -or
        $sqfImport -notmatch 'LINECOMMENT' -or
        $sqfImport -notmatch 'BLOCKCOMMENT' -or
        $sqfImport -notmatch '\bRACA_fnc_resolveCatalogClass\b') {
        $failures.Add("Legacy SQF import must use a comment-aware, measured, cancellable lexer without obsolete arbitrary size ceilings.")
    }
    if ($sqfImport -notmatch '_isSqfIdentifier' -or $sqfImport -notmatch '\(_candidate find "_fnc_"\)') {
        $failures.Add("Legacy SQF import must ignore quoted local variables and function identifiers.")
    }
    if ($sqfImport -notmatch 'RACA_fnc_decodeGeneratedSqfLiteral') {
        $failures.Add('SQF import must try the strict generated-export fast path before generic recovery.')
    }
    if ($sqfImport -match 'private\s+_values\s*=\s*\[' -or
        $sqfImport -notmatch '\[toString _buffer\] call _consume' -or
        $sqfImport -notmatch '_missingSamples' -or
        $sqfImport -notmatch '_missingCount') {
        $failures.Add('Generic SQF recovery must consume completed strings immediately and retain only bounded unavailable samples.')
    }
}

$catalogImportResolverPath = Join-Path $addonsDirectory 'core\functions\presets\fn_resolveCatalogClass.sqf'
if (-not (Test-Path -LiteralPath $catalogImportResolverPath -PathType Leaf)) {
    $failures.Add('Import resolution must use the current catalogue index.')
} else {
    $catalogImportResolver = Get-Content -Raw -LiteralPath $catalogImportResolverPath
    if ($catalogImportResolver -notmatch 'RACA_fnc_indexCatalog' -or
        $catalogImportResolver -notmatch 'getOrDefault \["class"' -or
        $catalogImportResolver -notmatch 'RACA_fnc_classifyCached' -or
        $catalogImportResolver -notmatch '\[-1, -1, _fallbackBucket\]') {
        $failures.Add('Import resolver must prefer the indexed ACE catalogue and keep absent classes unavailable.')
    }
}

$importResourcePolicyPath = Join-Path $addonsDirectory 'core\functions\presets\fn_getImportResourcePolicy.sqf'
if (-not (Test-Path -LiteralPath $importResourcePolicyPath -PathType Leaf)) {
    $failures.Add('Large imports require named resource safeguards.')
} else {
    $importResourcePolicy = Get-Content -Raw -LiteralPath $importResourcePolicyPath
    foreach ($resourceName in @('maxInputCharacters', 'maxLiteralCharacters', 'maxGenericCandidates', 'maxUnavailableSamples', 'maxWarningRows')) {
        if ($importResourcePolicy -notmatch $resourceName) {$failures.Add("Import resource policy is missing '$resourceName'.")}
    }
    if ($sqfImport -notmatch 'RACA_fnc_getImportResourcePolicy' -or
        $sqfImport -notmatch 'Use portable JSON, a plain class list, or a narrowed migration source') {
        $failures.Add('SQF resource failures must be bounded and provide actionable migration guidance.')
    }
}

$importCoordinatorPath = Join-Path $addonsDirectory 'core\functions\presets\fn_importPreset.sqf'
$importTelemetryPath = Join-Path $addonsDirectory 'core\functions\presets\fn_importTelemetry.sqf'
$presetValidationPath = Join-Path $addonsDirectory 'core\functions\presets\fn_validatePreset.sqf'
if (-not (Test-Path -LiteralPath $importTelemetryPath -PathType Leaf)) {
    $failures.Add('Import telemetry must have a dedicated payload-free logger.')
} elseif (Test-Path -LiteralPath $importCoordinatorPath -PathType Leaf) {
    $importCoordinator = Get-Content -Raw -LiteralPath $importCoordinatorPath
    $importTelemetry = Get-Content -Raw -LiteralPath $importTelemetryPath
    foreach ($phase in @('clipboard_acquisition', 'format_detection', 'review_preparation', 'commit')) {
        if ($importCoordinator -notmatch [regex]::Escape($phase)) {
            $failures.Add("Import coordination is missing the '$phase' telemetry phase.")
        }
    }
    foreach ($phase in @('lexical_scan', 'candidate_filtering', 'catalogue_resolution', 'unavailable_handling', 'preset_validation')) {
        if ($sqfImport -notmatch [regex]::Escape($phase) -and $portableImport -notmatch [regex]::Escape($phase) -and
            (Get-Content -Raw -LiteralPath $presetValidationPath) -notmatch [regex]::Escape($phase)) {
            $failures.Add("Import decoding is missing the '$phase' telemetry phase.")
        }
    }
    if ($importTelemetry -match 'copyFromClipboard|_text|_preset|profileName' -or
        $importCoordinator -match 'elapsed=%2 result=%3') {
        $failures.Add('Import telemetry must not log clipboard payloads, presets, profile names, or user-facing result text.')
    }
}

$sqfExportPath = Join-Path $addonsDirectory 'core\functions\presets\fn_formatSqfExport.sqf'
if (Test-Path -LiteralPath $sqfExportPath -PathType Leaf) {
    $sqfExport = Get-Content -Raw -LiteralPath $sqfExportPath
    foreach ($requiredPattern in @(
        'RACA_REUSABLE_SQF_FORMAT:2',
        'params \[\["_box"',
        'if \(!isServer\)',
        'private _arsenalItems',
        'arrayIntersect _arsenalItems',
        'ace_arsenal_fnc_removeBox',
        'ace_arsenal_fnc_initBox',
        '\[this\] execVM ""raca_arsenal\.sqf""'
    )) {
        if ($sqfExport -notmatch $requiredPattern) {
            $failures.Add("Reusable SQF export is missing required mission behavior matching '$requiredPattern'.")
        }
    }
}

$generatedSqfDecoderPath = Join-Path $addonsDirectory 'core\functions\presets\fn_decodeGeneratedSqfLiteral.sqf'
if (-not (Test-Path -LiteralPath $generatedSqfDecoderPath -PathType Leaf)) {
    $failures.Add('Generated reusable SQF requires its strict data-only literal decoder.')
} else {
    $generatedSqfDecoder = Get-Content -Raw -LiteralPath $generatedSqfDecoderPath
    if ($generatedSqfDecoder -match '(?i)\b(?:compile|compileFinal|execVM|preprocessFile|loadFile)\b' -or
        $generatedSqfDecoder -notmatch 'RACA_REUSABLE_SQF_FORMAT:2' -or
        $generatedSqfDecoder -notmatch 'private _arsenalItems = \[' -or
        $generatedSqfDecoder -notmatch 'RACA_fnc_importCheckpoint') {
        $failures.Add('Generated SQF fast path must require the known envelope and parse it as cancellable data only.')
    }
}

if (Test-Path -LiteralPath $presetValidationPath -PathType Leaf) {
    $presetValidation = Get-Content -Raw -LiteralPath $presetValidationPath
    if ($presetValidation -notmatch 'RACA_INHERITANCE' -or
        $presetValidation -notmatch 'RACA_ADOPTION' -or
        $presetValidation -notmatch 'RACA_COMPOSITION' -or
        $presetValidation -notmatch 'An unsafe inheritance removal was rejected') {
        $failures.Add("Preset validation must emit safe versioned inheritance metadata and accept both legacy signatures.")
    }
}

$cyclePath = Join-Path $addonsDirectory 'core\functions\presets\fn_wouldCreateCycle.sqf'
if (Test-Path -LiteralPath $cyclePath -PathType Leaf) {
    $cycleSource = Get-Content -Raw -LiteralPath $cyclePath
    if ($cycleSource -notmatch 'createHashMap' -or $cycleSource -notmatch 'RACA_fnc_getComposition') {
        $failures.Add("Inheritance ancestry must track visited presets and inspect source metadata.")
    }
}

$deletePresetPath = Join-Path $addonsDirectory 'core\functions\presets\fn_deletePreset.sqf'
$removePresetPath = Join-Path $addonsDirectory 'core\functions\presets\fn_removePresetFromLibrary.sqf'
$presetDeletionOnLoadPath = Join-Path $addonsDirectory 'core\functions\presets\fn_presetDeletionOnLoad.sqf'
$confirmPresetDeletionPath = Join-Path $addonsDirectory 'core\functions\presets\fn_confirmPresetDeletion.sqf'
if (-not (Test-Path -LiteralPath $deletePresetPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $removePresetPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $presetDeletionOnLoadPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $confirmPresetDeletionPath -PathType Leaf)) {
    $failures.Add("The preset library must provide a guarded deletion workflow.")
}
else {
    $deletePresetSource = Get-Content -Raw -LiteralPath $deletePresetPath
    $removePresetSource = Get-Content -Raw -LiteralPath $removePresetPath
    $presetDeletionOnLoadSource = Get-Content -Raw -LiteralPath $presetDeletionOnLoadPath
    $confirmPresetDeletionSource = Get-Content -Raw -LiteralPath $confirmPresetDeletionPath
    $presetDeletionSource = $deletePresetSource + $presetDeletionOnLoadSource + $confirmPresetDeletionSource
    foreach ($requiredPattern in @('RACA_RscDisplayPresetDeletion', 'Are you sure you want to delete %1?', 'RACA_fnc_removePresetFromLibrary', 'unsaved recovery copy')) {
        if ($presetDeletionSource -notmatch [regex]::Escape($requiredPattern)) {
            $failures.Add("Preset deletion is missing required behavior '$requiredPattern'.")
        }
    }
    foreach ($requiredPattern in @('RACA_fnc_archivePreset', 'deleteAt', 'saveProfileNamespace', 'Deleted from profile library')) {
        if ($removePresetSource -notmatch [regex]::Escape($requiredPattern)) {
            $failures.Add("Confirmed preset removal is missing required behavior '$requiredPattern'.")
        }
    }
}

$draftRecoveryPaths = @(
    (Join-Path $addonsDirectory 'core\functions\ui\fn_saveDraftRecovery.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_clearDraftRecovery.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_queueDraftRecovery.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_offerDraftRecovery.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_creatorOnUnload.sqf')
)
if ($draftRecoveryPaths.Where({-not (Test-Path -LiteralPath $_ -PathType Leaf)}).Count -gt 0) {
    $failures.Add('Creator draft recovery is incomplete.')
}
else {
    $draftRecovery = ($draftRecoveryPaths | ForEach-Object {Get-Content -Raw -LiteralPath $_}) -join [Environment]::NewLine
    foreach ($requiredPattern in @(
        'RACA_creatorDraftRecovery_v1',
        'RACA_DRAFT_RECOVERY',
        'saveProfileNamespace',
        'RACA_fnc_validatePreset',
        'BIS_fnc_guiMessage',
        'RACA_creatorDiscarding',
        'RACA_fnc_saveDraftRecovery'
    )) {
        if ($draftRecovery -notmatch $requiredPattern) {
            $failures.Add("Creator draft recovery is missing '$requiredPattern'.")
        }
    }
}

$modalWorkflowPaths = @(
    'core\functions\presets\fn_importPreset.sqf',
    'core\functions\ui\fn_requestCreatorClose.sqf',
    'core\functions\ui\fn_offerDraftRecovery.sqf',
    'core\functions\ui\fn_restorePresetRevision.sqf',
    'core\functions\runtime\fn_adminExecute.sqf',
    'eden\functions\fn_edenDashboardBulk.sqf',
    'eden\functions\fn_edenEditorRemoveSlot.sqf'
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
    if ($modalWorkflowRelativePath -eq 'core\functions\presets\fn_importPreset.sqf') {
        if ($modalWorkflowSource -notmatch 'RACA_importId' -or $modalWorkflowSource -notmatch 'RACA_choice' -or $modalWorkflowSource -notmatch 'OVERWRITE' -or $modalWorkflowSource -notmatch 'COPY') {
            $failures.Add("Modal import must retain explicit operation ownership and a three-way dialog result.")
        }
    }
    elseif ($modalWorkflowSource -notmatch 'findDisplay\s+RACA_') {
        $failures.Add("Modal workflow '$modalWorkflowRelativePath' must reacquire its active parent display after confirmation.")
    }
}

$confirmationGatePaths = @{
    'core\functions\runtime\fn_adminExecute.sqf' = @('private _confirmed = true', 'if (!_confirmed) exitWith {false}', 'remoteExecCall ["RACA_fnc_adminCommand", 2]')
    'core\functions\runtime\fn_rehearsalExecute.sqf' = @('private _confirmed = true', 'if (!_confirmed) exitWith {false}', 'remoteExecCall ["RACA_fnc_requestRehearsal", 2]')
}
foreach ($confirmationGateRelativePath in $confirmationGatePaths.Keys) {
    $confirmationGatePath = Join-Path $addonsDirectory $confirmationGateRelativePath
    if (-not (Test-Path -LiteralPath $confirmationGatePath -PathType Leaf)) {
        $failures.Add("Confirmed action workflow '$confirmationGateRelativePath' is missing.")
        continue
    }

    $confirmationGateSource = Get-Content -Raw -LiteralPath $confirmationGatePath
    foreach ($requiredPattern in $confirmationGatePaths[$confirmationGateRelativePath]) {
        if (-not $confirmationGateSource.Contains($requiredPattern)) {
            $failures.Add("Confirmed action workflow '$confirmationGateRelativePath' must stop after cancellation and is missing '$requiredPattern'.")
        }
    }
}

foreach ($guardedCaptureRelativePath in @(
    'core\functions\ui\fn_rolePackCapture.sqf',
    'core\functions\ui\fn_savedCatalogViewCapture.sqf'
)) {
    $guardedCapturePath = Join-Path $addonsDirectory $guardedCaptureRelativePath
    if (-not (Test-Path -LiteralPath $guardedCapturePath -PathType Leaf)) {
        $failures.Add("Guarded profile capture '$guardedCaptureRelativePath' is missing.")
        continue
    }

    $guardedCaptureSource = Get-Content -Raw -LiteralPath $guardedCapturePath
    foreach ($requiredPattern in @('private _canSave = true', '_canSave = false', 'if (!_canSave) exitWith {}')) {
        if (-not $guardedCaptureSource.Contains($requiredPattern)) {
            $failures.Add("Guarded profile capture '$guardedCaptureRelativePath' must not report or persist a cancelled replacement and is missing '$requiredPattern'.")
        }
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
    foreach ($creatorFeature in @('Quick Start', 'Preset Analysis', 'See History', 'Compare With Draft', 'RACA_IDC_PRESET_TOOL', 'Limit Category', 'Favorite', 'RACA_IDC_SOURCE_FILTER', 'RACA_IDC_TAG_FILTER', 'RACA_RscDisplayCatalogTags', 'RACA_RscDisplayPresetDeletion', 'Preset Deletion', 'RACA_fnc_requestCreatorClose')) {
        if ($creatorUiSource -notmatch [regex]::Escape($creatorFeature)) {
            $failures.Add("The creator excellence workflow is missing '$creatorFeature'.")
        }
    }
}

$catalogTagPaths = @(
    (Join-Path $addonsDirectory 'core\functions\ui\fn_getCatalogTags.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_refreshCatalogTagIndex.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_catalogTagsExecute.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_refreshItemList.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_savedCatalogViewCapture.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_getSavedCatalogViews.sqf')
)
if ($catalogTagPaths.Where({-not (Test-Path -LiteralPath $_ -PathType Leaf)}).Count -gt 0) {
    $failures.Add("The creator must provide profile-wide catalogue tagging and tag-aware saved views.")
}
else {
    $catalogTags = ($catalogTagPaths | ForEach-Object {Get-Content -Raw -LiteralPath $_}) -join [Environment]::NewLine
    if ($catalogTags -notmatch 'RACA_catalogTags_v1' -or
        $catalogTags -notmatch 'RACA_CATALOG_TAG' -or
        $catalogTags -notmatch 'RACA_fnc_isSafeClassName' -or
        $catalogTags -notmatch 'RACA_catalogTagIndex' -or
        $catalogTags -notmatch '_tag\s+in\s+_classTags' -or
        $catalogTags -notmatch 'RACA_IDC_TAG_FILTER' -or
        $catalogTags -notmatch 'saveProfileNamespace' -or
        $catalogTags -notmatch 'BIS_fnc_guiMessage' -or
        $catalogTags -notmatch '"RACA_CATALOG_VIEW"\s*,\s*3' -or
        $catalogTags -notmatch '_version\s+in\s+\[1,\s*2,\s*3\]') {
        $failures.Add("Catalogue tags must be uncapped, safe-class-only, profile-persistent, searchable/filterable, confirmation-protected, and backward-compatible with saved views.")
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
    if ($edenPopulate -notmatch 'RACA_fnc_flattenPreset' -or
        $edenPopulate -notmatch 'RACA_fnc_edenGetConfigurations' -or
        $edenPopulate -notmatch '<No Arsenal Configuration>') {
        $failures.Add("The Eden object attribute must offer mission-wide configurations while preserving standalone preset copies.")
    }
}

$coreConfigPath = Join-Path $addonsDirectory 'core\config.cpp'
if (Test-Path -LiteralPath $coreConfigPath -PathType Leaf) {
    $coreConfig = Get-Content -Raw -LiteralPath $coreConfigPath
    if ($coreConfig -match 'class\s+RACA_fnc_applyObjectConfig\s*\{[^}]*allowedTargets') {
        $failures.Add("Clients must not be allowed to remotely replace an object's authoritative configuration.")
    }
    foreach ($remoteFunction in @('RACA_fnc_requestOpen', 'RACA_fnc_finishSession', 'RACA_fnc_requestLoadoutApply', 'RACA_fnc_applyAuthorizedLoadout', 'RACA_fnc_requestAdminAccess', 'RACA_fnc_receiveAdminAccess', 'RACA_fnc_requestAdminSnapshot', 'RACA_fnc_receiveAdminSnapshot', 'RACA_fnc_requestQuotaStatus', 'RACA_fnc_receiveQuotaStatus', 'RACA_fnc_requestRehearsal', 'RACA_fnc_rehearsalClientReady', 'RACA_fnc_rehearsalProbeClient', 'RACA_fnc_receiveRehearsalProbe', 'RACA_fnc_receiveRehearsalSnapshot')) {
        if ($coreConfig -notmatch ('class\s+' + $remoteFunction + '\s*\{')) {
            $failures.Add("CfgRemoteExec is missing the controlled runtime endpoint '$remoteFunction'.")
        }
    }
    if ($coreConfig -notmatch 'class\s+RACA_fnc_registerActions\s*\{[^}]*allowedTargets\s*=\s*0\s*;[^}]*jip\s*=\s*1\s*;') {
        $failures.Add("Only the sanitized client action registrar must be enabled for persistent JIP execution.")
    }
}

$rehearsalPaths = @(
    (Join-Path $addonsDirectory 'core\functions\runtime\fn_requestRehearsal.sqf'),
    (Join-Path $addonsDirectory 'core\functions\runtime\fn_rehearsalClientReady.sqf'),
    (Join-Path $addonsDirectory 'core\functions\runtime\fn_rehearsalProbeClient.sqf'),
    (Join-Path $addonsDirectory 'core\functions\runtime\fn_receiveRehearsalProbe.sqf'),
    (Join-Path $addonsDirectory 'core\functions\runtime\fn_buildRehearsalSnapshot.sqf'),
    (Join-Path $addonsDirectory 'core\functions\runtime\fn_receiveRehearsalSnapshot.sqf'),
    (Join-Path $addonsDirectory 'core\functions\runtime\fn_rehearsalRefresh.sqf'),
    (Join-Path $addonsDirectory 'core\functions\runtime\fn_rehearsalCopy.sqf')
)
$registerActionsPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_registerActions.sqf'
$initClientPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_initClient.sqf'
if ($rehearsalPaths.Where({-not (Test-Path -LiteralPath $_ -PathType Leaf)}).Count -gt 0 -or
    -not (Test-Path -LiteralPath $registerActionsPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $initClientPath -PathType Leaf)) {
    $failures.Add("Runtime administration must provide the guided multiplayer rehearsal and client-ready instrumentation.")
}
elseif (Test-Path -LiteralPath $creatorUiPath -PathType Leaf) {
    $rehearsal = ($rehearsalPaths | ForEach-Object {Get-Content -Raw -LiteralPath $_}) -join [Environment]::NewLine
    $registerActions = Get-Content -Raw -LiteralPath $registerActionsPath
    $initClient = Get-Content -Raw -LiteralPath $initClientPath
    $creatorUi = Get-Content -Raw -LiteralPath $creatorUiPath
    $requestRehearsal = Get-Content -Raw -LiteralPath $rehearsalPaths[0]
    $receiveRehearsalProbe = Get-Content -Raw -LiteralPath $rehearsalPaths[3]
    if ($creatorUi -notmatch 'RACA_RscDisplayRehearsal' -or
        $creatorUi -notmatch 'RACA_IDC_ADMIN_REHEARSAL' -or
        $registerActions -notmatch 'RACA_localActionState' -or
        $initClient -notmatch 'RACA_fnc_rehearsalClientReady' -or
        $rehearsal -notmatch 'RACA_fnc_isAdminAuthorized' -or
        $rehearsal -notmatch 'owner _unit isNotEqualTo remoteExecutedOwner' -or
        $rehearsal -notmatch 'RACA_REHEARSAL_PROBE' -or
        $rehearsal -notmatch '"HOST"' -or
        $rehearsal -notmatch '"CLIENT"' -or
        $rehearsal -notmatch '"JIP"' -or
        $rehearsal -notmatch 'RACA_localActionState' -or
        $rehearsal -notmatch 'INCOMPLETE' -or
        $rehearsal -notmatch 'RACA_fnc_copyTextAndLog' -or
        $requestRehearsal -notmatch 'initialParticipants' -or
        $receiveRehearsalProbe -notmatch '_initialParticipants\s+findIf' -or
        $receiveRehearsalProbe -notmatch 'distinct JIP identity cannot be proven') {
        $failures.Add("Multiplayer rehearsal must be admin-authorized, owner-bound, JIP-aware, action-manifest based, and produce a copyable gated report.")
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
    if ($finishSession -notmatch '_applicableRuleIds' -or
        $finishSession -notmatch '_exactRuleIndex' -or
        $finishSession -notmatch '_categoryRuleIndex' -or
        $finishSession -notmatch 'forEach _applicableRuleIds') {
        $failures.Add("Session accounting must charge both exact-class and category quota rules when both apply to one issued item.")
    }
}

$runtimeInitPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_initRuntime.sqf'
if (Test-Path -LiteralPath $runtimeInitPath -PathType Leaf) {
    $runtimeInit = Get-Content -Raw -LiteralPath $runtimeInitPath
    if ($runtimeInit -notmatch 'EntityRespawned' -or
        $runtimeInit -notmatch '_oldEntity' -or
        $runtimeInit -notmatch 'RACA_openSessions' -or
        $runtimeInit -notmatch 'Old arsenal sessions discarded') {
        $failures.Add("Player respawn must immediately discard sessions that still reference the old unit.")
    }
}

$savedLoadoutPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_applyPlayerLoadout.sqf'
if (Test-Path -LiteralPath $savedLoadoutPath -PathType Leaf) {
    $savedLoadout = Get-Content -Raw -LiteralPath $savedLoadoutPath
    if ($savedLoadout -notmatch 'RACA_fnc_requestLoadoutApply' -or $savedLoadout -match '\bsetUnitLoadout\b') {
        $failures.Add("Saved loadouts must pass through the server authorization and quota session instead of applying directly on the client.")
    }
}

$listenHostServerEndpoints = @(
    'fn_requestLoadoutApply.sqf',
    'fn_requestQuotaStatus.sqf',
    'fn_requestAdminAccess.sqf',
    'fn_requestAdminSnapshot.sqf',
    'fn_requestRehearsal.sqf',
    'fn_rehearsalClientReady.sqf',
    'fn_receiveRehearsalProbe.sqf'
)
foreach ($endpointName in $listenHostServerEndpoints) {
    $endpointPath = Join-Path $addonsDirectory ("core\functions\runtime\" + $endpointName)
    if (-not (Test-Path -LiteralPath $endpointPath -PathType Leaf)) {
        $failures.Add("Listen-host server endpoint is missing: '$endpointName'.")
        continue
    }
    $endpointSource = Get-Content -Raw -LiteralPath $endpointPath
    if ($endpointSource -match '!\s*isRemoteExecuted\s*\|\|' -or
        $endpointSource -notmatch 'isRemoteExecuted\s*&&') {
        $failures.Add("Listen-host server endpoint '$endpointName' must accept trusted server-local execution while retaining remote-owner validation.")
    }
}

$listenHostClientResponses = @(
    'fn_openAuthorized.sqf',
    'fn_applyCorrectedLoadout.sqf',
    'fn_applyAuthorizedLoadout.sqf',
    'fn_registerActions.sqf',
    'fn_rehearsalProbeClient.sqf',
    'fn_receiveAdminAccess.sqf',
    'fn_receiveAdminSnapshot.sqf',
    'fn_receiveQuotaStatus.sqf',
    'fn_receiveRehearsalSnapshot.sqf'
)
foreach ($responseName in $listenHostClientResponses) {
    $responsePath = Join-Path $addonsDirectory ("core\functions\runtime\" + $responseName)
    if (-not (Test-Path -LiteralPath $responsePath -PathType Leaf)) {
        $failures.Add("Listen-host client response is missing: '$responseName'.")
        continue
    }
    $responseSource = Get-Content -Raw -LiteralPath $responsePath
    if ($responseSource -notmatch 'isRemoteExecuted\s*&&' -or
        $responseSource -notmatch '!isRemoteExecuted\s*&&\s*\{!isServer\}') {
        $failures.Add("Listen-host client response '$responseName' must accept server-local delivery while rejecting untrusted direct client calls.")
    }
}

$authorizedOpenPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_openAuthorized.sqf'
if (Test-Path -LiteralPath $authorizedOpenPath -PathType Leaf) {
    $authorizedOpen = Get-Content -Raw -LiteralPath $authorizedOpenPath
    if ($authorizedOpen -notmatch 'isNull\s+_object' -or
        $authorizedOpen -notmatch '_sessionId\s+isEqualTo\s+""' -or
        $authorizedOpen -notmatch '_classes\s+isEqualTo\s+\[\]') {
        $failures.Add("Authorized arsenal responses must reject stale objects, missing sessions, and empty catalogues before opening ACE Arsenal.")
    }
}

$correctedLoadoutPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_applyCorrectedLoadout.sqf'
if (Test-Path -LiteralPath $correctedLoadoutPath -PathType Leaf) {
    $correctedLoadout = Get-Content -Raw -LiteralPath $correctedLoadoutPath
    if ($correctedLoadout -notmatch '_loadout\s+isEqualTo\s+\[\]') {
        $failures.Add("Corrective loadout responses must reject an empty or malformed rollback payload.")
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

$zeusAssignPath = Join-Path $addonsDirectory 'core\functions\zeus\fn_handleZeusModuleRequest.sqf'
if (Test-Path -LiteralPath $zeusAssignPath -PathType Leaf) {
    $zeusAssign = Get-Content -Raw -LiteralPath $zeusAssignPath
    if ($zeusAssign -notmatch 'RACA_fnc_getMissionRegistry' -or $zeusAssign -notmatch 'RACA_missionArsenalConfigurations') {
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

$limitResetUiPath = Join-Path $addonsDirectory 'core\functions\ui\fn_creatorOnLoad.sqf'
$limitResetSyncPath = Join-Path $addonsDirectory 'core\functions\ui\fn_syncLimitPolicy.sqf'
$quantityPolicyPath = Join-Path $addonsDirectory 'core\functions\ui\fn_readQuantityPolicy.sqf'
$categoryLimitPath = Join-Path $addonsDirectory 'core\functions\ui\fn_setCategoryLimit.sqf'
$itemLimitPath = Join-Path $addonsDirectory 'core\functions\ui\fn_setItemLimit.sqf'
$creatorUiPath = Join-Path $addonsDirectory 'core\ui\RscDisplayCreator.hpp'
if (-not (Test-Path -LiteralPath $limitResetUiPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $limitResetSyncPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $quantityPolicyPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $categoryLimitPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $itemLimitPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $creatorUiPath -PathType Leaf)) {
    $failures.Add("The creator must expose the complete scope, reset, and maximum quantity policy.")
}
else {
    $limitResetUi = Get-Content -Raw -LiteralPath $limitResetUiPath
    $limitResetSync = Get-Content -Raw -LiteralPath $limitResetSyncPath
    $quantityPolicy = Get-Content -Raw -LiteralPath $quantityPolicyPath
    $categoryLimit = Get-Content -Raw -LiteralPath $categoryLimitPath
    $itemLimit = Get-Content -Raw -LiteralPath $itemLimitPath
    $creatorUi = Get-Content -Raw -LiteralPath $creatorUiPath
    foreach ($resetPolicy in @('never', 'interaction', 'respawn', 'round', 'phase')) {
        if ($limitResetUi -notmatch ('"' + $resetPolicy + '"')) {
            $failures.Add("The quantity reset selector is missing policy '$resetPolicy'.")
        }
    }
    if ($creatorUi -notmatch 'RACA_IDC_LIMIT_RESET' -or
        $limitResetSync -notmatch '_scope isEqualTo "interaction"' -or
        $limitResetSync -notmatch 'ctrlEnable false' -or
        $quantityPolicy -notmatch 'RACA_IDC_LIMIT_RESET' -or
        $quantityPolicy -notmatch 'trim ctrlText' -or
        $quantityPolicy -notmatch 'toArray _limitText' -or
        $itemLimit -notmatch 'RACA_fnc_readQuantityPolicy' -or
        $itemLimit -notmatch '_scope, _reset' -or
        $categoryLimit -notmatch 'RACA_fnc_readQuantityPolicy' -or
        $categoryLimit -notmatch '_scope, _reset') {
        $failures.Add("Quantity authoring must store reset policy and force interaction scope to reset on every use.")
    }
}

$quotaPrunePath = Join-Path $addonsDirectory 'core\functions\runtime\fn_pruneObjectQuotas.sqf'
$unregisterObjectPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_unregisterObject.sqf'
$missionRegistryPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_getMissionRegistry.sqf'
$loadoutRequestPath = Join-Path $addonsDirectory 'core\functions\runtime\fn_requestLoadoutApply.sqf'
if (-not (Test-Path -LiteralPath $quotaPrunePath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $unregisterObjectPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $missionRegistryPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $loadoutRequestPath -PathType Leaf)) {
    $failures.Add("Quota lifecycle cleanup must cover reconfiguration, unregistration, stale objects, and saved loadouts.")
}
else {
    $quotaPrune = Get-Content -Raw -LiteralPath $quotaPrunePath
    $unregisterObject = Get-Content -Raw -LiteralPath $unregisterObjectPath
    $missionRegistry = Get-Content -Raw -LiteralPath $missionRegistryPath
    $loadoutRequest = Get-Content -Raw -LiteralPath $loadoutRequestPath
    if ($quotaPrune -notmatch 'RACA_quotaState' -or
        $quotaPrune -notmatch '_currentPolicy isEqualTo \[_recordScope, _recordReset\]' -or
        $applyObject -notmatch 'RACA_fnc_pruneObjectQuotas' -or
        $unregisterObject -notmatch 'RACA_fnc_pruneObjectQuotas' -or
        $missionRegistry -notmatch 'RACA_fnc_pruneObjectQuotas' -or
        $requestOpen -notmatch '"interaction"\s*,\s*_object\s*,\s*_slotId' -or
        $loadoutRequest -notmatch '"interaction"\s*,\s*_object\s*,\s*_slotId') {
        $failures.Add("Quota counters must reset at interaction boundaries and be pruned when their slot or object lifecycle ends.")
    }
}

$catalogSortPath = Join-Path $addonsDirectory 'core\functions\ui\fn_setSortMode.sqf'
$catalogRefreshPath = Join-Path $addonsDirectory 'core\functions\ui\fn_refreshItemList.sqf'
$catalogFilterPath = Join-Path $addonsDirectory 'core\functions\ui\fn_refreshSourceCombo.sqf'
$catalogTogglePath = Join-Path $addonsDirectory 'core\functions\ui\fn_toggleRow.sqf'
$favoritePath = Join-Path $addonsDirectory 'core\functions\ui\fn_toggleFavorite.sqf'
$itemLimitPath = Join-Path $addonsDirectory 'core\functions\ui\fn_setItemLimit.sqf'
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
        $catalogRefresh -notmatch 'RACA_focusedClass' -or
        $catalogRefresh -notmatch 'lnbSetCurSelRow') {
        $failures.Add("Catalogue sorting must persist its mode, sort filtered rows deterministically, and restore the selected class.")
    }
    if (-not (Test-Path -LiteralPath $catalogFilterPath -PathType Leaf) -or
        -not (Test-Path -LiteralPath $catalogTogglePath -PathType Leaf) -or
        -not (Test-Path -LiteralPath $favoritePath -PathType Leaf) -or
        -not (Test-Path -LiteralPath $itemLimitPath -PathType Leaf)) {
        $failures.Add("Advanced catalogue filtering and multi-row action controllers are missing.")
    }
    else {
        $catalogFilters = Get-Content -Raw -LiteralPath $catalogFilterPath
        $catalogToggle = Get-Content -Raw -LiteralPath $catalogTogglePath
        $favorite = Get-Content -Raw -LiteralPath $favoritePath
        $itemLimit = Get-Content -Raw -LiteralPath $itemLimitPath
        if ($catalogFilters -notmatch 'RACA_IDC_ADDON_FILTER' -or
            $catalogFilters -notmatch 'RACA_IDC_AUTHOR_FILTER' -or
            $catalogFilters -notmatch '_counts\s+getOrDefault' -or
            $catalogRefresh -notmatch '_addon' -or
            $catalogRefresh -notmatch '_author' -or
            $creatorUi -notmatch 'multiSelect\s*=\s*1' -or
            $creatorUi -notmatch 'Ctrl-click' -or
            $catalogToggle -notmatch 'RACA_highlighted' -or
            $favorite -notmatch 'RACA_fnc_resolveCreatorSelection' -or
            $itemLimit -notmatch 'RACA_fnc_resolveCreatorSelection') {
            $failures.Add("Catalogue filters must expose counted mod/add-on/author dimensions, and selection, favorite, and item limits must honor Ctrl/Shift multi-selection.")
        }
        if ($catalogToggle -match '\[\s*""\s*,') {
            $failures.Add("Catalogue mouse-event parameters must use private variable names when type-checked by params.")
        }
    }
}

$environmentHealthPath = Join-Path $addonsDirectory 'core\functions\diagnostics\fn_analyzeEnvironment.sqf'
$creatorPreflightPath = Join-Path $addonsDirectory 'core\functions\ui\fn_runCreatorDiagnostics.sqf'
$supportBundlePath = Join-Path $addonsDirectory 'core\functions\presets\fn_buildSupportBundle.sqf'
if (-not (Test-Path -LiteralPath $environmentHealthPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $creatorPreflightPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $supportBundlePath -PathType Leaf)) {
    $failures.Add("Creator preflight must include a reusable loaded-mod and catalogue-health analysis.")
}
else {
    $environmentHealth = Get-Content -Raw -LiteralPath $environmentHealthPath
    $creatorPreflight = Get-Content -Raw -LiteralPath $creatorPreflightPath
    $supportBundle = Get-Content -Raw -LiteralPath $supportBundlePath
    if ($environmentHealth -notmatch 'ace_main' -or
        $environmentHealth -notmatch 'cba_main' -or
        $environmentHealth -notmatch 'RACA_Eden' -or
        $environmentHealth -notmatch 'CATALOG_SCOPE' -or
        $environmentHealth -notmatch 'The catalogue reflects only mods loaded before Arma started' -or
        $creatorPreflight -notmatch 'RACA_fnc_analyzeEnvironment' -or
        $supportBundle -notmatch 'RACA_fnc_analyzeEnvironment') {
        $failures.Add("Preflight and support bundles must explain dependency health and the session-scoped catalogue.")
    }
}

$savedViewPaths = @(
    (Join-Path $addonsDirectory 'core\functions\ui\fn_getSavedCatalogViews.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_openSavedCatalogViews.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_savedCatalogViewApply.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_savedCatalogViewCapture.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_savedCatalogViewDelete.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_savedCatalogViewRefresh.sqf')
)
if ($savedViewPaths.Where({-not (Test-Path -LiteralPath $_ -PathType Leaf)}).Count -gt 0) {
    $failures.Add("The creator must provide a complete saved-catalogue-view manager.")
}
elseif (Test-Path -LiteralPath $creatorUiPath -PathType Leaf) {
    $savedViews = ($savedViewPaths | ForEach-Object {Get-Content -Raw -LiteralPath $_}) -join [Environment]::NewLine
    $creatorUi = Get-Content -Raw -LiteralPath $creatorUiPath
    if ($creatorUi -notmatch 'RACA_RscDisplaySavedViews' -or
        $creatorUi -notmatch 'RACA_IDC_SAVED_VIEWS' -or
        $savedViews -notmatch 'RACA_savedCatalogViews_v1' -or
        $savedViews -notmatch 'RACA_IDC_CATEGORY' -or
        $savedViews -notmatch 'RACA_IDC_SOURCE_FILTER' -or
        $savedViews -notmatch 'RACA_IDC_ADDON_FILTER' -or
        $savedViews -notmatch 'RACA_IDC_AUTHOR_FILTER' -or
        $savedViews -notmatch 'RACA_catalogSort' -or
        $savedViews -notmatch 'RACA_catalogSearchMode' -or
        $savedViews -notmatch 'RACA_IDC_TAG_FILTER' -or
        $savedViews -notmatch 'BIS_fnc_guiMessage' -or
        $savedViews -notmatch 'saveProfileNamespace') {
        $failures.Add("Saved catalogue views must persist and restore search, category, mod, add-on, author, and sort state with guarded replacement/deletion.")
    }
}

$itemDetailPaths = @(
    (Join-Path $addonsDirectory 'core\functions\ui\fn_openItemDetails.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_itemDetailsOnLoad.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_itemDetailsRefresh.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_itemDetailsToggleIncluded.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_itemDetailsToggleFavorite.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_itemDetailsCopy.sqf')
)
if ($itemDetailPaths.Where({-not (Test-Path -LiteralPath $_ -PathType Leaf)}).Count -gt 0) {
    $failures.Add("The creator must provide the detailed catalogue-item inspector.")
}
elseif (Test-Path -LiteralPath $creatorUiPath -PathType Leaf) {
    $itemDetails = ($itemDetailPaths | ForEach-Object {Get-Content -Raw -LiteralPath $_}) -join [Environment]::NewLine
    $creatorUi = Get-Content -Raw -LiteralPath $creatorUiPath
    if ($creatorUi -notmatch 'RACA_RscDisplayItemDetails' -or
        $creatorUi -notmatch 'RACA_IDC_ITEM_DETAILS_BUTTON' -or
        $itemDetails -notmatch 'configSourceAddonList' -or
        $itemDetails -notmatch 'inheritsFrom' -or
        $itemDetails -notmatch 'BIS_fnc_itemType' -or
        $itemDetails -notmatch 'RACA_builderLimits' -or
        $itemDetails -notmatch 'RACA_fnc_pushCreatorHistory' -or
        $itemDetails -notmatch 'RACA_favoriteClasses_v1' -or
        $itemDetails -notmatch 'RACA_fnc_copyTextAndLog') {
        $failures.Add("Item details must expose config/source/type/policy context and support undoable inclusion, favorites, and report copying.")
    }
}

$rolePackPaths = @(
    (Join-Path $addonsDirectory 'core\functions\templates\fn_getRolePacks.sqf'),
    (Join-Path $addonsDirectory 'core\functions\templates\fn_getRoleTemplates.sqf'),
    (Join-Path $addonsDirectory 'core\functions\templates\fn_applyRoleTemplate.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_openRolePacks.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_rolePackCapture.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_rolePackApply.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_rolePackDelete.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_rolePackRefresh.sqf')
    (Join-Path $addonsDirectory 'core\functions\ui\fn_refreshQuickRoleCombo.sqf')
)
if ($rolePackPaths.Where({-not (Test-Path -LiteralPath $_ -PathType Leaf)}).Count -gt 0) {
    $failures.Add("The creator must provide profile-wide custom role packs.")
}
elseif (Test-Path -LiteralPath $creatorUiPath -PathType Leaf) {
    $rolePacks = ($rolePackPaths | ForEach-Object {Get-Content -Raw -LiteralPath $_}) -join [Environment]::NewLine
    $creatorUi = Get-Content -Raw -LiteralPath $creatorUiPath
    if ($creatorUi -notmatch 'RACA_RscDisplayRolePacks' -or
        $creatorUi -notmatch 'RACA_IDC_ROLE_PACKS_BUTTON' -or
        $rolePacks -notmatch 'RACA_rolePacks_v1' -or
        $rolePacks -notmatch 'RACA_ROLE_PACK' -or
        $rolePacks -notmatch 'pack:' -or
        $rolePacks -notmatch 'RACA_fnc_pushCreatorHistory' -or
        $rolePacks -notmatch 'RACA_rolePacksReturn' -or
        $rolePacks -notmatch 'RACA_fnc_refreshQuickRoleCombo' -or
        $rolePacks -notmatch 'BIS_fnc_guiMessage' -or
        $rolePacks -notmatch 'saveProfileNamespace' -or
        $creatorUi -notmatch 'text\s*=\s*"Custom Unit Role Packs"' -or
        $creatorUi -notmatch 'text\s*=\s*"Return to Quick Start"') {
        $failures.Add("Custom role packs must use the current visual style, persist explicit class sets, support merge/replace, return to Quick Start, and guard replacement/deletion independently of presets.")
    }
}

$dropdownHelperPaths = @(
    (Join-Path $addonsDirectory 'core\functions\ui\fn_refreshSourceCombo.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_refreshRoleTemplateCombo.sqf'),
    (Join-Path $addonsDirectory 'core\functions\ui\fn_refreshQuickRoleCombo.sqf')
)
if ($dropdownHelperPaths.Where({-not (Test-Path -LiteralPath $_ -PathType Leaf)}).Count -gt 0) {
    $failures.Add("Creator dropdown helpers must be present for hover-help validation.")
}
else {
    $dropdownHelpers = ($dropdownHelperPaths | ForEach-Object {Get-Content -Raw -LiteralPath $_}) -join [Environment]::NewLine
    if ($dropdownHelpers -match '\blbSetTooltip\b') {
        $failures.Add("Creator dropdown rows must not add hover-help tooltips.")
    }
}

$templateParameterPath = Join-Path $addonsDirectory 'core\functions\templates\fn_applyTemplateParameters.sqf'
$quickStartOnLoadPath = Join-Path $addonsDirectory 'core\functions\ui\fn_quickStartOnLoad.sqf'
$quickStartApplyPath = Join-Path $addonsDirectory 'core\functions\ui\fn_quickStartApply.sqf'
if (-not (Test-Path -LiteralPath $templateParameterPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $quickStartOnLoadPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $quickStartApplyPath -PathType Leaf)) {
    $failures.Add("Quick Start must provide parameterized concrete-preset generation.")
}
elseif (Test-Path -LiteralPath $creatorUiPath -PathType Leaf) {
    $templateParameters = Get-Content -Raw -LiteralPath $templateParameterPath
    $quickStartOnLoad = Get-Content -Raw -LiteralPath $quickStartOnLoadPath
    $quickStartApply = Get-Content -Raw -LiteralPath $quickStartApplyPath
    $creatorUi = Get-Content -Raw -LiteralPath $creatorUiPath
    if ($creatorUi -notmatch 'text\s*=\s*"Quick Start"' -or
        $creatorUi -notmatch 'RACA_IDC_QUICK_SETTINGS' -or
        $creatorUi -notmatch 'RACA_IDC_QUICK_OPTICS' -or
        $creatorUi -notmatch 'RACA_IDC_QUICK_SUPPRESSORS' -or
        $creatorUi -notmatch 'RACA_IDC_QUICK_NVG' -or
        $creatorUi -notmatch 'RACA_IDC_QUICK_MEDICAL' -or
        $quickStartOnLoad -notmatch 'RACA_generatorParameters_v1' -or
        $quickStartApply -notmatch 'RACA_fnc_applyTemplateParameters' -or
        $templateParameters -notmatch 'Attachments' -or
        $templateParameters -notmatch 'NVGs' -or
        $templateParameters -notmatch 'Medical' -or
        $templateParameters -notmatch 'EXCLUDE') {
        $failures.Add("Parameterized Quick Start must persist and apply source-aware optic, suppressor, night-vision, and medical policies.")
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
        $edenDialog -notmatch '(?i)(TEST ACCESS|RUN TEST)') {
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
    ) + @(
        Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'tests') -Recurse -File |
            Where-Object { $_.Name -in @('description.ext', 'mission.sqm') } |
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
    ) + @(
        Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'tests') -Recurse -File |
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
