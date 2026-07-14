#Requires -Version 5.1
<#
.SYNOPSIS
  Report TCAPI runtime capabilities (PowerShell vs dotnet script), version-aware.
.EXAMPLE
  .\Get-TcApiRuntime.ps1
  .\Get-TcApiRuntime.ps1 -CommanderHome "C:\Program Files\Tricentis\Tosca Commander 25.1"
  .\Get-TcApiRuntime.ps1 -CommanderVersion 24.1
#>
param(
    [string]$CommanderHome = $env:COMMANDER_HOME,
    [string]$CommanderVersion = $env:COMMANDER_VERSION
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Get-TcApiRuntime.ps1')

$info = Get-TcApiRuntimeInfo -CommanderHome $CommanderHome -CommanderVersion $CommanderVersion
$info | ConvertTo-Json -Depth 6

if ($info.RecommendedMode -eq 'none') {
    Write-Error $info.Reason
    exit 1
}
