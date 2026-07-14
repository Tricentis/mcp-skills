#Requires -Version 5.1
<#
.SYNOPSIS
  Run TCAPI via PowerShell or dotnet script — mode and host chosen automatically.
.PARAMETER DetectOnly
  Output runtime JSON and exit (agent should run this first).
.PARAMETER CommanderVersion
  Override Commander version key (24.1, 24.2, 25.1, 26.1, master).
#>
param(
    [string]$CommanderHome = $env:COMMANDER_HOME,
    [string]$CommanderVersion = $env:COMMANDER_VERSION,
    [string]$Workspace,
    [string]$User = 'Admin',
    [string]$Password = '',
    [string]$ScriptPath,
    [ValidateSet('Auto', 'PowerShell', 'DotNetScript')]
    [string]$Prefer = 'Auto',
    [switch]$DetectOnly,
    [switch]$NoSave
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Get-TcApiRuntime.ps1')

$runtime = Get-TcApiRuntimeInfo -CommanderHome $CommanderHome -CommanderVersion $CommanderVersion

if ($DetectOnly) {
    $runtime | ConvertTo-Json -Depth 6
    if ($runtime.RecommendedMode -eq 'none') { exit 1 }
    return
}

if (-not $ScriptPath) {
    throw 'Pass -ScriptPath (.ps1 or .csx), or use -DetectOnly to inspect the runtime.'
}
if (-not (Test-Path $ScriptPath)) {
    throw "Script not found: $ScriptPath"
}
if ($runtime.RecommendedMode -eq 'none') {
    throw $runtime.Reason
}

$mode = Resolve-TcApiExecutionMode -Runtime $runtime -Prefer $Prefer -ScriptPath $ScriptPath

if ($Workspace) { $env:TOSCA_WORKSPACE = $Workspace }
$env:TOSCA_USER = $User
if ($Password) { $env:TOSCA_PASSWORD = $Password }
$env:COMMANDER_HOME = $CommanderHome
$env:COMMANDER_VERSION = $runtime.CommanderVersion

switch ($mode) {
    'DotNetScript' {
        $args = @()
        if ($Workspace) { $args += $Workspace }
        Invoke-TcApiDotNetScript -CsxPath $ScriptPath -CommanderHome $CommanderHome -Arguments $args
        return
    }
    'PowerShell' {
        if (Test-ShouldReLaunchTcApiInRecommendedHost -Runtime $runtime) {
            Invoke-TcApiInRecommendedHost -ScriptPath $PSCommandPath -Runtime $runtime -BoundParameters $PSBoundParameters
        }

        $sessionPath = Join-Path $PSScriptRoot 'lib\TcApiSession.ps1'
        if (-not (Test-Path $sessionPath)) { throw "Missing: $sessionPath" }
        . $sessionPath
        Connect-TcApi -CommanderHome $CommanderHome -CommanderVersion $runtime.CommanderVersion | Out-Null
        try {
            if ($Workspace) {
                Open-TcApiWorkspace -Path $Workspace -User $User -Password $Password | Out-Null
            }
            . $ScriptPath
            if (-not $NoSave -and (Get-TcApiActiveWorkspace)) {
                Save-TcApiWorkspace
            }
        }
        finally {
            Close-TcApiWorkspace
        }
    }
}
