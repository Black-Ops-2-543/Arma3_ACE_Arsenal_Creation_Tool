[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ArmaDirectory,

    [Parameter()]
    [ValidatePattern('^[A-Za-z0-9_-]+$')]
    [string] $ProfileName = 'RACA_MP_Test',

    [Parameter()]
    [string] $CbaDirectory,

    [Parameter()]
    [string] $AceDirectory,

    [Parameter()]
    [string] $RacaModDirectory = 'build\@RestrictedArsenalCreationAssistant'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$ArmaDirectory = [System.IO.Path]::GetFullPath($ArmaDirectory)
$serverExe = Join-Path $ArmaDirectory 'arma3server_x64.exe'
$steamAppsDirectory = Split-Path -Parent (Split-Path -Parent $ArmaDirectory)

if ([string]::IsNullOrWhiteSpace($CbaDirectory)) {
    $CbaDirectory = Join-Path $steamAppsDirectory 'workshop\content\107410\450814997'
}
if ([string]::IsNullOrWhiteSpace($AceDirectory)) {
    $AceDirectory = Join-Path $steamAppsDirectory 'workshop\content\107410\463939057'
}
if (-not [System.IO.Path]::IsPathRooted($RacaModDirectory)) {
    $RacaModDirectory = Join-Path $repositoryRoot $RacaModDirectory
}

$CbaDirectory = [System.IO.Path]::GetFullPath($CbaDirectory)
$AceDirectory = [System.IO.Path]::GetFullPath($AceDirectory)
$RacaModDirectory = [System.IO.Path]::GetFullPath($RacaModDirectory)
$sourceMission = Join-Path $repositoryRoot 'tests\multiplayer\RACA_Rehearsal.VR'
$sourceServerConfig = Join-Path $repositoryRoot 'tests\multiplayer\server.cfg'

foreach ($requiredFile in @(
    $serverExe,
    $sourceServerConfig,
    (Join-Path $sourceMission 'mission.sqm'),
    (Join-Path $sourceMission 'description.ext'),
    (Join-Path $sourceMission 'initServer.sqf'),
    (Join-Path $sourceMission 'initPlayerLocal.sqf'),
    (Join-Path $RacaModDirectory 'addons\core.pbo'),
    (Join-Path $RacaModDirectory 'addons\eden.pbo')
)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required multiplayer smoke-test file was not found at '$requiredFile'."
    }
}
foreach ($requiredDirectory in @($CbaDirectory, $AceDirectory, $RacaModDirectory)) {
    if (-not (Test-Path -LiteralPath $requiredDirectory -PathType Container)) {
        throw "Required multiplayer smoke-test directory was not found at '$requiredDirectory'."
    }
}

$profileRoot = Join-Path $ArmaDirectory ("Profiles\" + $ProfileName)
$mpMissionsRoot = Join-Path $profileRoot 'MPMissions'
$stagedMission = Join-Path $mpMissionsRoot 'RACA_Rehearsal.VR'
$stagedServerConfig = Join-Path $profileRoot 'server.cfg'
$null = New-Item -ItemType Directory -Path $stagedMission -Force

foreach ($missionFile in @('mission.sqm', 'description.ext', 'initServer.sqf', 'initPlayerLocal.sqf')) {
    Copy-Item -LiteralPath (Join-Path $sourceMission $missionFile) -Destination (Join-Path $stagedMission $missionFile) -Force
}
Copy-Item -LiteralPath $sourceServerConfig -Destination $stagedServerConfig -Force

$modArgument = @($CbaDirectory, $AceDirectory, $RacaModDirectory) -join ';'
$relativeMissions = "Profiles\$ProfileName\MPMissions"
$serverArguments = @(
    '-port=2402',
    "-config=`"$stagedServerConfig`"",
    "-profiles=`"$profileRoot`"",
    "-name=$ProfileName",
    "-mod=`"$modArgument`"",
    "-mpmissions=$relativeMissions",
    '-autoInit',
    '-noSound'
)
$clientArguments = @(
    '-connect=127.0.0.1',
    '-port=2402',
    "-mod=`"$modArgument`"",
    '-noSplash',
    '-skipIntro',
    '-window'
)

Write-Host "Prepared the isolated multiplayer smoke mission in '$stagedMission'."
Write-Host "Server executable: $serverExe"
Write-Host 'Server arguments:'
$serverArguments | ForEach-Object {Write-Host "  $_"}
Write-Host 'Base client arguments:'
$clientArguments | ForEach-Object {Write-Host "  $_"}

[pscustomobject]@{
    WorkingDirectory = $ArmaDirectory
    ServerExecutable = $serverExe
    ServerArguments = $serverArguments
    ClientExecutable = (Join-Path $ArmaDirectory 'arma3_x64.exe')
    ClientArguments = $clientArguments
    ProfileRoot = $profileRoot
    MissionDirectory = $stagedMission
    ServerConfig = $stagedServerConfig
    ModArgument = $modArgument
}
