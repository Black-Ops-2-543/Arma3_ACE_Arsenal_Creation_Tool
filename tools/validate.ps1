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
    'addons\eden\ui\PresetAttribute.hpp'
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
            & $javaCommand.Source '-jar' $SqfLintJar '-nw' '-oc' $sqfFile.FullName
            $toolExitCode = $LASTEXITCODE

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
