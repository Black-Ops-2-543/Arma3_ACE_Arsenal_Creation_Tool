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

if (-not $SkipConfig) {
    if (-not (Test-Path -LiteralPath $CfgConvertPath -PathType Leaf)) {
        throw "CfgConvert was not found at '$CfgConvertPath'. Pass its full path with -CfgConvertPath or use -SkipConfig."
    }

    $configFiles = @(
        Get-ChildItem -LiteralPath $addonsDirectory -Recurse -File |
            Where-Object { $_.Name -in @('config.cpp', 'description.ext') } |
            Sort-Object -Property FullName
    )

    if ($configFiles.Count -eq 0) {
        $failures.Add("No config.cpp or description.ext files were found in '$addonsDirectory'.")
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
