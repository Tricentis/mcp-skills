<#
.SYNOPSIS
    Installs Tosca Cloud MCP skills and rules for Cursor; merges MCP config when configured.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Cursor")]
    [string]$Ide,

    [ValidateSet("User", "Project")]
    [string]$Scope = "User",

    [string]$ProjectPath = (Get-Location).Path,

    [string]$Tenant,
    [string]$Space = "default",
    [ValidateSet("prod", "staging", "dev")]
    [string]$Env = "prod",

    [switch]$SkipMcpConfig
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib/IntegrationCommon.ps1")

$repoRoot = Get-RepoRoot
& (Join-Path $PSScriptRoot "sync_mcp_packs.ps1")

$packMap = Get-IdePackMap
$config = $packMap[$Ide]
$skillIds = Get-CloudSkillIds
$srcSkillsRoot = Join-Path $repoRoot "packages/cursor-pack/skills"
$srcRules = Join-Path $repoRoot "packages/cursor-pack/rules/tosca-cloud-mcp.mdc"

function Install-CursorPack {
    param([string]$TargetSkillsRoot, [string]$TargetRules, [string]$TargetMcpJson)

    foreach ($skillId in $skillIds) {
        $src = Join-Path $srcSkillsRoot $skillId
        Copy-DirectoryContents -Source $src -Destination (Join-Path $TargetSkillsRoot $skillId)
    }

    New-Item -ItemType Directory -Force -Path $TargetRules | Out-Null
    Copy-Item -Path $srcRules -Destination (Join-Path $TargetRules "tosca-cloud-mcp.mdc") -Force

    if (-not $SkipMcpConfig) {
        $configure = Join-Path $repoRoot "scripts/configure_mcp_connection.py"
        if (-not (Test-Path $configure)) {
            throw "configure_mcp_connection.py not found"
        }
        $args = @($configure, "--env", $Env, "--space", $Space, "--output", $TargetMcpJson)
        if ($Tenant) {
            $args += @("--tenant", $Tenant)
        }
        & python @args
        if ($LASTEXITCODE -ne 0) {
            throw "configure_mcp_connection.py failed ($LASTEXITCODE)"
        }
    }
}

if ($Scope -eq "User") {
    Install-CursorPack -TargetSkillsRoot $config.UserSkills -TargetRules $config.UserRules `
        -TargetMcpJson (Join-Path $env:USERPROFILE ".cursor/mcp.json")
    Write-Host "Installed Cursor Cloud MCP pack to user profile."
} else {
    Install-CursorPack -TargetSkillsRoot (Join-Path $ProjectPath $config.ProjectSkills) `
        -TargetRules (Join-Path $ProjectPath $config.ProjectRules) `
        -TargetMcpJson (Join-Path $ProjectPath ".cursor/mcp.json")
    Write-Host "Installed Cursor Cloud MCP pack to project: $ProjectPath"
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Reload Cursor"
Write-Host "  2. Settings -> MCP -> enable tosca-cloud"
Write-Host "  3. Complete Okta login on first connection"
Write-Host "  4. Verify: tosca_organization_listWorkspaces"
Write-Host "  5. Skills: /tosca-cloud-connect then /tosca-cloud-basics"
