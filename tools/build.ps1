[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $AddonBuilderPath = 'F:\SteamLibrary\steamapps\common\Arma 3 Tools\AddonBuilder\AddonBuilder.exe',

    [Parameter()]
    [string] $ArmaToolsDirectory,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $OutputDirectory = 'build\@RestrictedArsenalCreationAssistant',

    [Parameter()]
    [switch] $Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$addonsDirectory = Join-Path $repositoryRoot 'addons'

if (-not [System.IO.Path]::IsPathRooted($OutputDirectory)) {
    $OutputDirectory = Join-Path $repositoryRoot $OutputDirectory
}
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
$outputAddonsDirectory = Join-Path $OutputDirectory 'addons'

if (-not (Test-Path -LiteralPath $AddonBuilderPath -PathType Leaf)) {
    throw "AddonBuilder was not found at '$AddonBuilderPath'. Pass its full path with -AddonBuilderPath."
}

$AddonBuilderPath = [System.IO.Path]::GetFullPath($AddonBuilderPath)
if ([string]::IsNullOrWhiteSpace($ArmaToolsDirectory)) {
    $addonBuilderDirectory = Split-Path -Parent $AddonBuilderPath
    $ArmaToolsDirectory = Split-Path -Parent $addonBuilderDirectory
}
$ArmaToolsDirectory = [System.IO.Path]::GetFullPath($ArmaToolsDirectory)

if (-not (Test-Path -LiteralPath $ArmaToolsDirectory -PathType Container)) {
    throw "The Arma 3 Tools directory was not found at '$ArmaToolsDirectory'. Pass its full path with -ArmaToolsDirectory."
}

if (-not (Test-Path -LiteralPath $addonsDirectory -PathType Container)) {
    throw "The add-ons source directory was not found at '$addonsDirectory'."
}

$addonSources = @(
    Get-ChildItem -LiteralPath $addonsDirectory -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'config.cpp') -PathType Leaf } |
        Sort-Object -Property Name
)

if ($addonSources.Count -eq 0) {
    throw "No add-on source folders containing config.cpp were found in '$addonsDirectory'."
}

if ($Clean -and (Test-Path -LiteralPath $OutputDirectory)) {
    $safeBuildRoot = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot 'build'))
    $safeBuildPrefix = $safeBuildRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $isSafeBuildTarget = $OutputDirectory.Equals($safeBuildRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
        $OutputDirectory.StartsWith($safeBuildPrefix, [System.StringComparison]::OrdinalIgnoreCase)

    if (-not $isSafeBuildTarget) {
        throw "Refusing to clean '$OutputDirectory' because it is outside the repository build directory."
    }

    Remove-Item -LiteralPath $OutputDirectory -Recurse -Force
}

$null = New-Item -ItemType Directory -Path $outputAddonsDirectory -Force

foreach ($addonSource in $addonSources) {
    Write-Host "Building $($addonSource.Name)..."

    $expectedPbo = Join-Path $outputAddonsDirectory ($addonSource.Name + '.pbo')
    if (Test-Path -LiteralPath $expectedPbo -PathType Leaf) {
        Remove-Item -LiteralPath $expectedPbo -Force
    }

    $toolsDirectoryArgument = '-toolsDirectory=' + $ArmaToolsDirectory
    # Keep the packed PBO prefix aligned with the paths used by CfgFunctions,
    # mission launch entries, and the other runtime references in the source.
    $prefixArgument = '-prefix=x\raca\addons\' + $addonSource.Name
    & $AddonBuilderPath $addonSource.FullName $outputAddonsDirectory '-packonly' '-clear' $toolsDirectoryArgument $prefixArgument
    $builderExitCode = $LASTEXITCODE

    if ($builderExitCode -ne 0) {
        throw "AddonBuilder failed for '$($addonSource.Name)' with exit code $builderExitCode."
    }

    if (-not (Test-Path -LiteralPath $expectedPbo -PathType Leaf)) {
        throw "AddonBuilder reported success, but '$expectedPbo' was not created."
    }
}

foreach ($metadataFileName in @('mod.cpp', 'meta.cpp')) {
    $metadataSource = Join-Path $repositoryRoot $metadataFileName
    if (Test-Path -LiteralPath $metadataSource -PathType Leaf) {
        Copy-Item -LiteralPath $metadataSource -Destination $OutputDirectory -Force
    }
}

Write-Host "Built $($addonSources.Count) add-on(s) in '$OutputDirectory'."
