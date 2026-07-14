#Requires -Version 5.1
<#
.SYNOPSIS
  Detect available Commander automation paths and recommend the best one.
.EXAMPLE
  .\Get-CommanderAutomationPaths.ps1
  .\Get-CommanderAutomationPaths.ps1 -Workspace "C:\Projects\Demo.tws"
  .\Get-CommanderAutomationPaths.ps1 -Intent HeadlessScript
  .\Get-CommanderAutomationPaths.ps1 -Intent GuiAttended -CommanderHome "C:\Program Files\Tricentis\Tosca Commander 26.1"
#>
param(
    [string]$CommanderHome = $env:COMMANDER_HOME,
    [string]$CommanderVersion = $env:COMMANDER_VERSION,
    [string]$Workspace = $env:TOSCA_WORKSPACE,
    [ValidateSet('Auto', 'HeadlessScript', 'TypedApi', 'GuiAttended')]
    [string]$Intent = 'Auto'
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\Get-CommanderAutomationPaths.ps1')

$result = Get-CommanderAutomationPaths -CommanderHome $CommanderHome -CommanderVersion $CommanderVersion -Workspace $Workspace -Intent $Intent
$result | ConvertTo-Json -Depth 8

if (-not $result.Selection.Recommended -and $result.Selection.UserPromptRequired) {
    exit 2
}
if (@($result.Paths | Where-Object { $_.Available }).Count -eq 0) {
    exit 1
}
exit 0
