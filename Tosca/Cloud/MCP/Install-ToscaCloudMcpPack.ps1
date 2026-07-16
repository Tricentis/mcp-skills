<#
.SYNOPSIS
    Installs Tosca Cloud MCP skills and rules for Cursor (consumer layout).
    Does not configure MCP servers — users add their tenant in IDE Settings -> MCP.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Cursor")]
    [string]$Ide,

    [ValidateSet("User", "Project")]
    [string]$Scope = "User",

    [string]$ProjectPath = (Get-Location).Path,

    [switch]$VerifyManifest
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib/IntegrationCommon.ps1")

$packMap = Get-IdePackMap
$config = $packMap[$Ide]
$skillIds = Get-CloudSkillIds

if ($VerifyManifest) {
    Test-PackManifest -PackRoot $PSScriptRoot
}

if ($skillIds.Count -eq 0) {
    throw "No tosca-* skills found under $(Join-Path $config.PackPath 'skills')"
}

$srcSkillsRoot = Join-Path $config.PackPath "skills"
$srcRules = Join-Path $config.PackPath "rules/tosca-cloud-mcp.mdc"

function Install-CursorPack {
    param([string]$TargetSkillsRoot, [string]$TargetRules)

    foreach ($skillId in $skillIds) {
        $src = Join-Path $srcSkillsRoot $skillId
        Copy-DirectoryContents -Source $src -Destination (Join-Path $TargetSkillsRoot $skillId)
    }

    New-Item -ItemType Directory -Force -Path $TargetRules | Out-Null
    Copy-Item -Path $srcRules -Destination (Join-Path $TargetRules "tosca-cloud-mcp.mdc") -Force
}

if ($Scope -eq "User") {
    Install-CursorPack -TargetSkillsRoot $config.UserSkills -TargetRules $config.UserRules
    Write-Host "Installed Cursor Cloud MCP skills to user profile."
} else {
    Install-CursorPack -TargetSkillsRoot (Join-Path $ProjectPath $config.ProjectSkills) `
        -TargetRules (Join-Path $ProjectPath $config.ProjectRules)
    Write-Host "Installed Cursor Cloud MCP skills to project: $ProjectPath"
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Cursor -> Settings -> MCP -> add your Tosca Cloud tenant server"
Write-Host "  2. Use URL: https://{tenant}.my.tricentis.com/{space}/_mcp/api/mcp"
Write-Host "  3. Reload Cursor; complete sign-in when the IDE prompts"
Write-Host "  4. Verify: tosca_organization_listWorkspaces"
Write-Host "  5. Skills: /tosca-cloud-connect then /tosca-cloud-basics"
