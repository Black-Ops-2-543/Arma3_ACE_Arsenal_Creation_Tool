[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({Test-Path -LiteralPath $_ -PathType Leaf})]
    [string] $RptPath,

    [Parameter()]
    [ValidateRange(1, [int]::MaxValue)]
    [int] $CopyId,

    [Parameter()]
    [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$jobs = @{}

foreach ($line in [System.IO.File]::ReadLines((Resolve-Path -LiteralPath $RptPath))) {
    if ($line -match '\[RACA\]\[COPY:(\d+)\] BEGIN version=2 .* units=(\d+) chunks=(\d+) encoding=CODEPOINTS digest=(P24X2-\d+-\d+)') {
        $id = [int] $Matches[1]
        if ($jobs.ContainsKey($id)) { $jobs[$id].Ambiguous = $true; continue }
        $jobs[$id] = [ordered]@{ Id=$id; Version=2; Units=[int]$Matches[2]; ChunkCount=[int]$Matches[3]; Digest=$Matches[4]; Chunks=@{}; Duplicate=$false; Ambiguous=$false; Complete=$false }
        continue
    }
    if ($line -match '\[RACA\]\[COPY:(\d+)\] BEGIN .* units=(\d+) chunks=(\d+) encoding=CODEPOINTS checksum=(\d+)') {
        $id = [int] $Matches[1]
        if ($jobs.ContainsKey($id)) { $jobs[$id].Ambiguous = $true; continue }
        $jobs[$id] = [ordered]@{
            Id = $id
            Version = 1
            Units = [int] $Matches[2]
            ChunkCount = [int] $Matches[3]
            Checksum = [int] $Matches[4]
            Chunks = @{}
            Duplicate = $false
            Ambiguous = $false
            Complete = $false
        }
        continue
    }
    if ($line -match '\[RACA\]\[COPY:(\d+)\] CHUNK (\d+)/(\d+) (\[.*\])') {
        $id = [int] $Matches[1]
        if ($jobs.ContainsKey($id)) {
            $chunkNumber = [int] $Matches[2]
            if ($jobs[$id].Chunks.ContainsKey($chunkNumber) -or [int]$Matches[3] -ne $jobs[$id].ChunkCount) {
                $jobs[$id].Duplicate = $true
            } else {
                $jobs[$id].Chunks[$chunkNumber] = @($Matches[4] | ConvertFrom-Json)
            }
        }
        continue
    }
    if ($line -match '\[RACA\]\[COPY:(\d+)\] END version=2 units=(\d+) chunks=(\d+) digest=(P24X2-\d+-\d+)') {
        $id = [int] $Matches[1]
        if ($jobs.ContainsKey($id)) {
            $jobs[$id].Complete = $true
            if ([int]$Matches[2] -ne $jobs[$id].Units -or [int]$Matches[3] -ne $jobs[$id].ChunkCount -or $Matches[4] -ne $jobs[$id].Digest) { $jobs[$id].Ambiguous = $true }
        }
        continue
    }
    if ($line -match '\[RACA\]\[COPY:(\d+)\] END units=(\d+) chunks=(\d+) checksum=(\d+)') {
        $id = [int] $Matches[1]
        if ($jobs.ContainsKey($id)) {
            $jobs[$id].Complete = $true
        }
    }
}

$selected = if ($PSBoundParameters.ContainsKey('CopyId')) {
    $jobs[$CopyId]
} else {
    $jobs.Values | Where-Object Complete | Sort-Object Id | Select-Object -Last 1
}
if ($null -eq $selected -or -not $selected.Complete) {
    throw 'No completed RACA copy job matched the request.'
}
if ($selected.Ambiguous -or $selected.Duplicate) {
    throw "Copy $($selected.Id) contains duplicate, conflicting, or ambiguous envelope/chunk records."
}
if ($selected.Chunks.Count -ne $selected.ChunkCount) {
    throw "Copy $($selected.Id) is incomplete: expected $($selected.ChunkCount) chunks, found $($selected.Chunks.Count)."
}

$builder = [System.Text.StringBuilder]::new()
$unitCount = 0
$checksum = 0
$digestA = 104729
$digestB = 130363
for ($chunkNumber = 1; $chunkNumber -le $selected.ChunkCount; $chunkNumber++) {
    if (-not $selected.Chunks.ContainsKey($chunkNumber)) {
        throw "Copy $($selected.Id) is missing chunk $chunkNumber."
    }
    foreach ($codePoint in $selected.Chunks[$chunkNumber]) {
        $value = [int] $codePoint
        [void] $builder.Append([char]::ConvertFromUtf32($value))
        $unitCount++
        $checksum = ($checksum + $value) % 16777213
        $position = $unitCount - 1
        $digestA = (($digestA * 257) + $value + $position) % 16777213
        $digestB = (($digestB * 263) + $value + ($position * 3)) % 16777199
    }
}
if ($selected.Version -eq 2) {
    $digest = "P24X2-$digestA-$digestB"
    if ($unitCount -ne $selected.Units -or $digest -ne $selected.Digest) {
        throw "Copy $($selected.Id) failed v2 integrity validation (units $unitCount/$($selected.Units), digest $digest/$($selected.Digest))."
    }
} elseif ($unitCount -ne $selected.Units -or $checksum -ne $selected.Checksum) {
    throw "Copy $($selected.Id) failed legacy integrity validation (units $unitCount/$($selected.Units), checksum $checksum/$($selected.Checksum))."
} else {
    Write-Warning "Copy $($selected.Id) uses the legacy additive checksum; integrity is weaker and ambiguous collisions cannot be excluded."
}

$text = $builder.ToString()
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
    [System.IO.File]::WriteAllText($resolvedOutput, $text, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Recovered copy $($selected.Id) to '$resolvedOutput' ($unitCount code points)."
} else {
    $text
}
