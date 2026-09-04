[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ArmaDirectory,

    [Parameter()]
    [ValidatePattern('^[A-Za-z0-9_-]+$')]
    [string] $ProfileName = 'RACA_Autotest',

    [Parameter()]
    [string] $CbaDirectory,

    [Parameter()]
    [string] $AceDirectory,

    [Parameter()]
    [string] $RacaModDirectory = 'build\@RestrictedArsenalCreationAssistant',

    [Parameter()]
    [ValidateRange(-1, 16)]
    [int] $Adapter = -1
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$ArmaDirectory = [System.IO.Path]::GetFullPath($ArmaDirectory)
$clientExe = Join-Path $ArmaDirectory 'arma3_x64.exe'
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
$sourceMission = Join-Path $repositoryRoot 'tests\autotest\RACA_Automated.VR'

foreach ($requiredFile in @(
    $clientExe,
    (Join-Path $sourceMission 'mission.sqm'),
    (Join-Path $sourceMission 'description.ext'),
    (Join-Path $sourceMission 'initPlayerLocal.sqf'),
    (Join-Path $RacaModDirectory 'addons\core.pbo'),
    (Join-Path $RacaModDirectory 'addons\eden.pbo')
)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required automated acceptance file was not found at '$requiredFile'."
    }
}
foreach ($requiredDirectory in @($CbaDirectory, $AceDirectory, $RacaModDirectory)) {
    if (-not (Test-Path -LiteralPath $requiredDirectory -PathType Container)) {
        throw "Required automated acceptance directory was not found at '$requiredDirectory'."
    }
}

$profileRoot = Join-Path $ArmaDirectory ("Profiles\" + $ProfileName)
$autotestRoot = Join-Path $profileRoot 'autotest'
$stagedMission = Join-Path $autotestRoot 'RACA_Automated.VR'
$autotestConfig = Join-Path $profileRoot 'autotest.cfg'
$safeAutotestRoot = [System.IO.Path]::GetFullPath($autotestRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
$resolvedStagedMission = [System.IO.Path]::GetFullPath($stagedMission)
if (-not $resolvedStagedMission.StartsWith($safeAutotestRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to replace staged mission '$resolvedStagedMission' because it is outside '$safeAutotestRoot'."
}
if (Test-Path -LiteralPath $resolvedStagedMission -PathType Container) {
    Remove-Item -LiteralPath $resolvedStagedMission -Recurse -Force
}
$null = New-Item -ItemType Directory -Path $stagedMission -Force

foreach ($missionFile in Get-ChildItem -LiteralPath $sourceMission -Recurse -File) {
    $relativeMissionFile = $missionFile.FullName.Substring($sourceMission.TrimEnd([System.IO.Path]::DirectorySeparatorChar).Length).TrimStart([System.IO.Path]::DirectorySeparatorChar)
    $destination = Join-Path $stagedMission $relativeMissionFile
    $null = New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force
    Copy-Item -LiteralPath $missionFile.FullName -Destination $destination -Force
}

$autotestConfigText = @"
class TestMissions
{
    class RACA_Automated
    {
        campaign = "";
        mission = "$stagedMission";
    };
};
"@
[System.IO.File]::WriteAllText($autotestConfig, $autotestConfigText, [System.Text.UTF8Encoding]::new($false))
$armaPrefix = $ArmaDirectory.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $autotestConfig.StartsWith($armaPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Autotest configuration '$autotestConfig' must remain below the Arma directory so Arma can resolve it reliably."
}
$autotestConfigArgument = $autotestConfig.Substring($armaPrefix.Length)

$modArgument = @($CbaDirectory, $AceDirectory, $RacaModDirectory) -join ';'
$clientArguments = @(
    '-noLauncher',
    '-noSplash',
    '-skipIntro',
    '-world=empty',
    '-window',
    '-showScriptErrors',
    "-profiles=`"$profileRoot`"",
    "-autotest=`"$autotestConfigArgument`"",
    "-mod=`"$modArgument`""
)
if ($Adapter -ge 0) {
    $clientArguments = @("-adapter=$Adapter") + $clientArguments
}

Write-Host "Prepared the isolated automated acceptance mission in '$stagedMission'."
Write-Host "Autotest configuration: $autotestConfig"
Write-Host "Client executable: $clientExe"
Write-Host 'Client arguments:'
$clientArguments | ForEach-Object {Write-Host "  $_"}

[pscustomobject]@{
    WorkingDirectory = $ArmaDirectory
    ClientExecutable = $clientExe
    ClientArguments = $clientArguments
    ProfileRoot = $profileRoot
    MissionDirectory = $stagedMission
    AutotestConfig = $autotestConfig
    AutotestConfigArgument = $autotestConfigArgument
    ModArgument = $modArgument
}
