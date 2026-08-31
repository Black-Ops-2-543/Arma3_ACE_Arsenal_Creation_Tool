[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $OutputDirectory = 'dist',

    [Parameter()]
    [switch] $SkipBuild,

    [Parameter()]
    [switch] $AllowDevelopmentVersion
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$modMetadataPath = Join-Path $repositoryRoot 'mod.cpp'
$coreConfigPath = Join-Path $repositoryRoot 'addons\core\config.cpp'
$licensePath = Join-Path $repositoryRoot 'LICENSE'
$changelogPath = Join-Path $repositoryRoot 'CHANGELOG.md'
$buildRoot = Join-Path $repositoryRoot 'build\@RestrictedArsenalCreationAssistant'

if (-not [System.IO.Path]::IsPathRooted($OutputDirectory)) {
    $OutputDirectory = Join-Path $repositoryRoot $OutputDirectory
}
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)

foreach ($requiredFile in @($modMetadataPath, $coreConfigPath, $licensePath, $changelogPath)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required release file '$requiredFile' is missing."
    }
}

$modMetadata = Get-Content -Raw -LiteralPath $modMetadataPath
$coreConfig = Get-Content -Raw -LiteralPath $coreConfigPath
$modVersionMatch = [regex]::Match($modMetadata, '(?m)^\s*version\s*=\s*"([^"]+)"\s*;')
$coreVersionMatch = [regex]::Match($coreConfig, '(?m)^\s*versionStr\s*=\s*"([^"]+)"\s*;')
if (-not $modVersionMatch.Success -or -not $coreVersionMatch.Success) {
    throw 'Could not read the human-readable version from mod.cpp and addons/core/config.cpp.'
}
$version = $modVersionMatch.Groups[1].Value
if ($version -ne $coreVersionMatch.Groups[1].Value) {
    throw "Version mismatch: mod.cpp is '$version' while RACA_Core/versionStr is '$($coreVersionMatch.Groups[1].Value)'."
}
if ($version -notmatch '^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?$') {
    throw "Version '$version' is not a supported semantic version."
}
$major = [int] $Matches[1]
$minor = [int] $Matches[2]
$patch = [int] $Matches[3]
$prerelease = $Matches[4]
if (-not [string]::IsNullOrWhiteSpace($prerelease) -and -not $AllowDevelopmentVersion) {
    throw "Version '$version' is a development version. Pass -AllowDevelopmentVersion only for an internal package."
}

$numericVersionPattern = 'version\[\]\s*=\s*\{\s*' + $major + '\s*,\s*' + $minor + '\s*,\s*' + $patch + '\s*\}'
$numericVersionArPattern = 'versionAr\[\]\s*=\s*\{\s*' + $major + '\s*,\s*' + $minor + '\s*,\s*' + $patch + '\s*\}'
if ($coreConfig -notmatch $numericVersionPattern -or $coreConfig -notmatch $numericVersionArPattern) {
    throw "RACA_Core numeric version arrays do not match '$major.$minor.$patch'."
}

$changelog = Get-Content -Raw -LiteralPath $changelogPath
if ([string]::IsNullOrWhiteSpace($prerelease)) {
    if ($changelog -notmatch ('(?m)^## \[' + [regex]::Escape($version) + '\](?:\s+-\s+\d{4}-\d{2}-\d{2})?\s*$')) {
        throw "CHANGELOG.md has no release heading for '$version'."
    }
}
elseif ($changelog -notmatch '(?m)^## \[Unreleased\]\s*$') {
    throw 'Development packaging requires an Unreleased changelog section.'
}

$license = Get-Content -Raw -LiteralPath $licensePath
if ($license -notmatch '(?m)^MIT License\s*$' -or $license -notmatch 'Copyright \(c\) 2026 Connor Walsh') {
    throw 'The expected project license and copyright notice were not found.'
}

$dirty = @(& git -C $repositoryRoot status --porcelain)
if ($LASTEXITCODE -ne 0) { throw 'Could not inspect the Git working tree.' }
if ($dirty.Count -gt 0) {
    throw 'Refusing to create a release package from a dirty working tree. Commit or stash every change first.'
}
$commit = (& git -C $repositoryRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($commit)) {
    throw 'Could not resolve the release commit.'
}

& (Join-Path $PSScriptRoot 'validate.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Static validation failed; no release package was created.' }

if (-not $SkipBuild) {
    & (Join-Path $PSScriptRoot 'build.ps1') -Clean
    if ($LASTEXITCODE -ne 0) { throw 'PBO build failed; no release package was created.' }
}

$checksumPath = Join-Path $buildRoot 'checksums.sha256'
$buildAddons = Join-Path $buildRoot 'addons'
if (-not (Test-Path -LiteralPath $checksumPath -PathType Leaf) -or
    -not (Test-Path -LiteralPath $buildAddons -PathType Container)) {
    throw "The expected built mod and checksum manifest were not found in '$buildRoot'."
}

$expectedPbos = Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'addons') -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'config.cpp') -PathType Leaf } |
    Sort-Object Name |
    ForEach-Object { $_.Name + '.pbo' }
$manifestEntries = @()
foreach ($line in Get-Content -LiteralPath $checksumPath) {
    if ($line -notmatch '^([0-9a-fA-F]{64})\s{2}addons/(.+\.pbo)$') {
        throw "Malformed checksum manifest line: '$line'."
    }
    $fileName = $Matches[2]
    $pboPath = Join-Path $buildAddons $fileName
    if (-not (Test-Path -LiteralPath $pboPath -PathType Leaf)) {
        throw "Checksum manifest references missing PBO '$fileName'."
    }
    $actualHash = (Get-FileHash -LiteralPath $pboPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne $Matches[1].ToLowerInvariant()) {
        throw "Checksum mismatch for '$fileName'."
    }
    $manifestEntries += [ordered]@{ file = "addons/$fileName"; sha256 = $actualHash }
}
$manifestNames = @($manifestEntries | ForEach-Object { Split-Path -Leaf $_.file } | Sort-Object)
if (@(Compare-Object -ReferenceObject $expectedPbos -DifferenceObject $manifestNames).Count -gt 0) {
    throw 'The built PBO set does not match the source add-on set.'
}

$null = New-Item -ItemType Directory -Path $OutputDirectory -Force
$archiveName = "RestrictedArsenalCreationAssistant-$version.zip"
$archivePath = Join-Path $OutputDirectory $archiveName
if (Test-Path -LiteralPath $archivePath -PathType Leaf) {
    Remove-Item -LiteralPath $archivePath -Force
}
Compress-Archive -LiteralPath $buildRoot -DestinationPath $archivePath -CompressionLevel Optimal
$archiveHash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()

$report = [ordered]@{
    signature = 'RACA_RELEASE_REPORT'
    schemaVersion = 1
    version = $version
    commit = $commit
    createdUtc = [DateTime]::UtcNow.ToString('o')
    development = -not [string]::IsNullOrWhiteSpace($prerelease)
    archive = $archiveName
    archiveSha256 = $archiveHash
    pboChecksums = $manifestEntries
}
$reportPath = Join-Path $OutputDirectory 'release-report.json'
[System.IO.File]::WriteAllText(
    $reportPath,
    ($report | ConvertTo-Json -Depth 8),
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host "Release package created: $archivePath" -ForegroundColor Green
Write-Host "Release report created: $reportPath" -ForegroundColor Green
Write-Host "Archive SHA-256: $archiveHash"
