#Requires -Version 5.1
<#
.SYNOPSIS
  Copy IDE integration AI bundle into a Commander install (Phase 3 MSI/post-build step).
.DESCRIPTION
  Targets %COMMANDER_HOME%\TCShell\AI\ with read-only skill reference and install docs.
  Requires write access to Commander install (typically admin / build agent).
.PARAMETER CommanderHome
  Commander install root (contains TCShell\).
.PARAMETER SourceRoot
  Tosca.Commander.IDE.integration repo root. Defaults to parent of scripts/.
.EXAMPLE
  .\Copy-CommanderAiBundle.ps1 -CommanderHome "C:\Program Files\Tricentis\Tosca Commander"
#>
param(
    [Parameter(Mandatory)]
    [string]$CommanderHome,
    [string]$SourceRoot
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib/IntegrationCommon.ps1')

if (-not $SourceRoot) { $SourceRoot = Get-RepoRoot }

$coreSkill = Get-CoreSkillPath
$reference = Join-Path $coreSkill 'reference'
$skillMd = Join-Path $coreSkill 'SKILL.md'
$installDoc = Join-Path $SourceRoot 'docs/installation.md'
$tcapiCompat = Join-Path $SourceRoot 'packages/core/reference/tcapi-compatibility.json'
$commanderVersions = Join-Path $SourceRoot 'packages/core/reference/commander-versions.json'

$destRoot = Join-Path $CommanderHome 'TCShell\AI'
$destRef = Join-Path $destRoot 'reference'

if (-not (Test-Path (Join-Path $CommanderHome 'TCShell'))) {
    throw "TCShell folder not found under CommanderHome: $CommanderHome"
}

New-Item -ItemType Directory -Force -Path $destRoot | Out-Null
New-Item -ItemType Directory -Force -Path $destRef | Out-Null

Copy-DirectoryContents -Source $reference -Destination $destRef
Copy-Item -Path $skillMd -Destination (Join-Path $destRoot 'README.md') -Force
Copy-Item -Path $installDoc -Destination (Join-Path $destRoot 'INSTALL.md') -Force
Copy-Item -Path $tcapiCompat -Destination (Join-Path $destRoot 'tcapi-compatibility.json') -Force
Copy-Item -Path $commanderVersions -Destination (Join-Path $destRoot 'commander-versions.json') -Force

$versionKey = Resolve-CommanderVersionKey -CommanderHome $CommanderHome
$manifest = [ordered]@{
    bundledAt        = (Get-Date -Format o)
    commanderVersion = $versionKey
    sourceRepo       = 'Tricentis-Tosca/Tosca.Commander.IDE.integration'
    contents         = @('reference/', 'README.md', 'INSTALL.md', 'tcapi-compatibility.json')
}
$manifest | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $destRoot 'bundle-manifest.json') -Encoding UTF8

Write-Host "Copied AI bundle to $destRoot"
Write-Host "Commander version detected: $versionKey"
