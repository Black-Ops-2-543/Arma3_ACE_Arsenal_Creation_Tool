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
    if ($line -match '\[RACA\]\[COPY:(\d+)\] BEGIN .* units=(\d+) chunks=(\d+) encoding=CODEPOINTS checksum=(\d+)') {
        $id = [int] $Matches[1]
        $jobs[$id] = [ordered]@{
            Id = $id
            Units = [int] $Matches[2]
            ChunkCount = [int] $Matches[3]
            Checksum = [int] $Matches[4]
            Chunks = @{}
            Complete = $false
        }
        continue
    }
    if ($line -match '\[RACA\]\[COPY:(\d+)\] CHUNK (\d+)/(\d+) (\[.*\])') {
        $id = [int] $Matches[1]
        if ($jobs.ContainsKey($id)) {
            $jobs[$id].Chunks[[int] $Matches[2]] = @($Matches[4] | ConvertFrom-Json)
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
if ($selected.Chunks.Count -ne $selected.ChunkCount) {
    throw "Copy $($selected.Id) is incomplete: expected $($selected.ChunkCount) chunks, found $($selected.Chunks.Count)."
}

$builder = [System.Text.StringBuilder]::new()
$unitCount = 0
$checksum = 0
for ($chunkNumber = 1; $chunkNumber -le $selected.ChunkCount; $chunkNumber++) {
    if (-not $selected.Chunks.ContainsKey($chunkNumber)) {
        throw "Copy $($selected.Id) is missing chunk $chunkNumber."
    }
    foreach ($codePoint in $selected.Chunks[$chunkNumber]) {
        $value = [int] $codePoint
        [void] $builder.Append([char]::ConvertFromUtf32($value))
        $unitCount++
        $checksum = ($checksum + $value) % 16777213
    }
}
if ($unitCount -ne $selected.Units -or $checksum -ne $selected.Checksum) {
    throw "Copy $($selected.Id) failed integrity validation (units $unitCount/$($selected.Units), checksum $checksum/$($selected.Checksum))."
}

$text = $builder.ToString()
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
    [System.IO.File]::WriteAllText($resolvedOutput, $text, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Recovered copy $($selected.Id) to '$resolvedOutput' ($unitCount code points)."
} else {
    $text
}
