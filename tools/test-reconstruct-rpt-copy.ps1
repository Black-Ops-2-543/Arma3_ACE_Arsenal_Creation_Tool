[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$reconstructor = Join-Path $PSScriptRoot 'reconstruct-rpt-copy.ps1'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("raca-rpt-copy-tests-" + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $testRoot

function Write-Fixture {
    param([string] $Name, [string[]] $Lines)
    $path = Join-Path $testRoot ($Name + '.rpt')
    [System.IO.File]::WriteAllLines($path, $Lines, [System.Text.UTF8Encoding]::new($false))
    $path
}

function Assert-Rejected {
    param([string] $Name, [string[]] $Lines, [string] $Expected)
    $path = Write-Fixture -Name $Name -Lines $Lines
    try {
        $null = & $reconstructor -RptPath $path -CopyId 42
        throw "Fixture '$Name' was accepted."
    } catch {
        if ($_.Exception.Message -eq "Fixture '$Name' was accepted." -or $_.Exception.Message -notmatch $Expected) {
            throw "Fixture '$Name' did not fail with '$Expected': $($_.Exception.Message)"
        }
    }
}

try {
$begin = '[RACA][COPY:42] BEGIN version=2 context="fixture" units=4 chunks=2 encoding=CODEPOINTS digest=P24X2-5225729-9989239'
$chunk1 = '[RACA][COPY:42] CHUNK 1/2 [65,937]'
$chunk2 = '[RACA][COPY:42] CHUNK 2/2 [13,10]'
$end = '[RACA][COPY:42] END version=2 units=4 chunks=2 digest=P24X2-5225729-9989239'

$validPath = Write-Fixture -Name 'valid' -Lines @($begin, $chunk1, $chunk2, $end)
$valid = & $reconstructor -RptPath $validPath -CopyId 42
if ($valid -ne "A$([char]0x03A9)`r`n") {
    throw 'Valid v2 fixture did not reconstruct exactly.'
}

Assert-Rejected -Name 'tampered' -Lines @($begin, $chunk1, '[RACA][COPY:42] CHUNK 2/2 [14,10]', $end) -Expected 'integrity validation'
Assert-Rejected -Name 'reordered' -Lines @($begin, $chunk2, $chunk1, $end) -Expected 'reordered'
Assert-Rejected -Name 'duplicate' -Lines @($begin, $chunk1, $chunk1, $chunk2, $end) -Expected 'duplicate'
Assert-Rejected -Name 'missing' -Lines @($begin, $chunk1, $end) -Expected 'incomplete'
Assert-Rejected -Name 'cross-copy-substitution' -Lines @($begin, $chunk1, '[RACA][COPY:42] CHUNK 2/2 [66,937]', $end) -Expected 'integrity validation'
Assert-Rejected -Name 'duplicate-end' -Lines @($begin, $chunk1, $chunk2, $end, $end) -Expected 'ambiguous'
Assert-Rejected -Name 'chunk-after-end' -Lines @($begin, $chunk1, $end, $chunk2) -Expected 'ambiguous'

$legacy = @(
    '[RACA][COPY:42] BEGIN context="legacy" units=4 chunks=2 encoding=CODEPOINTS checksum=1025',
    $chunk1,
    $chunk2,
    '[RACA][COPY:42] END units=4 chunks=2 checksum=1025'
)
$legacyPath = Write-Fixture -Name 'legacy' -Lines $legacy
$legacyResult = @(& $reconstructor -RptPath $legacyPath -CopyId 42 3>&1)
$legacyWarnings = @($legacyResult | Where-Object {$_ -is [System.Management.Automation.WarningRecord] -and $_.Message -match 'legacy additive checksum'})
if ($legacyWarnings.Count -ne 1) {
    throw 'Legacy fixture did not emit exactly one weaker-integrity warning.'
}
$legacyText = @($legacyResult | Where-Object {$_ -is [string]})
if ($legacyText.Count -ne 1 -or $legacyText[0] -cne "A$([char]0x03A9)`r`n") {
    throw 'Valid legacy fixture did not reconstruct exactly.'
}
} finally {
    $resolvedTestRoot = [System.IO.Path]::GetFullPath($testRoot)
    $resolvedTempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    if (-not $resolvedTestRoot.StartsWith($resolvedTempRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove unexpected test directory '$resolvedTestRoot'."
    }
    if (Test-Path -LiteralPath $resolvedTestRoot -PathType Container) {
        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
    }
}
Write-Host 'RPT copy reconstruction tests passed (valid, tampered, reordered, duplicate, missing, substitution, envelope, and legacy cases).'
