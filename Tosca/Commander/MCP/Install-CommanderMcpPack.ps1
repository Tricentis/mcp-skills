<#
.SYNOPSIS
    Installs the Commander MCP skill pack for Cursor, Claude, VS Code, or Windsurf.
    Does not configure MCP servers — users add tosca-commander in IDE Settings -> MCP.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Cursor", "Claude", "VSCode", "Windsurf")]
    [string]$Ide,

    [ValidateSet("User", "Project")]
    [string]$Scope = "User",

    [string]$ProjectPath = (Get-Location).Path,

    [switch]$VerifyManifest
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib/IntegrationCommon.ps1")

$repoRoot = Get-RepoRoot
$skillId = Get-SkillId
$packMap = Get-IdePackMap
$config = $packMap[$Ide]

if ($VerifyManifest) {
    Test-PackManifest -PackRoot $PSScriptRoot
}

function Install-CursorPack {
    param([string]$TargetSkill, [string]$TargetRules)
    $pack = $config.PackPath
    $srcSkill = Join-Path $pack "skills/$skillId"
    $srcRules = Join-Path $pack "rules/$skillId.mdc"
    Copy-DirectoryContents -Source $srcSkill -Destination $TargetSkill
    New-Item -ItemType Directory -Force -Path $TargetRules | Out-Null
    Copy-Item -Path $srcRules -Destination (Join-Path $TargetRules "$skillId.mdc") -Force
}

function Install-ClaudePack {
    param([string]$TargetSkill)
    $srcSkill = Join-Path $config.PackPath "skills/$skillId"
    Copy-DirectoryContents -Source $srcSkill -Destination $TargetSkill
}

function Install-VSCodePack {
    param([string]$TargetGithub)
    $srcDir = $config.PackPath
    New-Item -ItemType Directory -Force -Path $TargetGithub | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $TargetGithub "instructions") | Out-Null

    $copilotFragment = Join-Path $srcDir "copilot-instructions.md.fragment"
    $copilotDest = Join-Path $TargetGithub "copilot-instructions.md"
    if (Test-Path $copilotDest) {
        Write-Warning "Existing $copilotDest not overwritten. Merge content from $copilotFragment manually."
    } else {
        Copy-Item -Path $copilotFragment -Destination $copilotDest -Force
    }

    $mcpInstr = Join-Path $srcDir "instructions/commander-mcp.instructions.md"
    Copy-Item -Path $mcpInstr -Destination (Join-Path $TargetGithub "instructions/commander-mcp.instructions.md") -Force

    $agentsFragment = Join-Path $srcDir "AGENTS.md.fragment"
    if (-not (Test-Path $agentsFragment)) {
        $agentsFragment = Join-Path $repoRoot "packages/core/snippets/AGENTS.md.fragment"
    }
    $agentsDest = Join-Path (Split-Path $TargetGithub -Parent) "AGENTS.md"
    if (-not (Test-Path $agentsDest)) {
        if (Test-Path $agentsFragment) {
            Copy-Item -Path $agentsFragment -Destination $agentsDest -Force
        }
    } else {
        Write-Warning "AGENTS.md already exists at project root; merge fragment manually."
    }
}

function Install-WindsurfPack {
    param([string]$TargetSkill, [string]$TargetRules)
    $pack = $config.PackPath
    $srcSkill = Join-Path $pack "skills/$skillId"
    $srcRule = Join-Path $pack "rules/$skillId.md"
    Copy-DirectoryContents -Source $srcSkill -Destination $TargetSkill
    New-Item -ItemType Directory -Force -Path $TargetRules | Out-Null
    Copy-Item -Path $srcRule -Destination (Join-Path $TargetRules "$skillId.md") -Force
}

if ($Scope -eq "User") {
    switch ($Ide) {
        "Cursor"   {
            Install-CursorPack -TargetSkill $config.UserSkill -TargetRules $config.UserRules
        }
        "Claude"   { Install-ClaudePack -TargetSkill $config.UserSkill }
        "VSCode"   { throw "VSCode/Copilot user-scope install is not supported; use -Scope Project." }
        "Windsurf" { Install-WindsurfPack -TargetSkill $config.UserSkill -TargetRules $config.UserRules }
    }
    Write-Host "Installed $Ide MCP pack to user profile."
} else {
    switch ($Ide) {
        "Cursor"   {
            Install-CursorPack -TargetSkill (Join-Path $ProjectPath $config.ProjectSkill) `
                -TargetRules (Join-Path $ProjectPath $config.ProjectRules)
        }
        "Claude"   {
            Install-ClaudePack -TargetSkill (Join-Path $ProjectPath $config.ProjectSkill)
        }
        "VSCode"   {
            Install-VSCodePack -TargetGithub (Join-Path $ProjectPath $config.ProjectSkill)
        }
        "Windsurf" {
            Install-WindsurfPack -TargetSkill (Join-Path $ProjectPath $config.ProjectSkill) -TargetRules (Join-Path $ProjectPath $config.ProjectRules)
        }
    }
    Write-Host "Installed $Ide MCP pack to project: $ProjectPath"
}

Write-Host ""
Write-Host "Invoke skill: /$skillId (Cursor/Claude) or @$skillId (Windsurf)"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open Commander 26.1+ with a workspace"
if ($Ide -eq "Cursor") {
    Write-Host "  2. Cursor -> Settings -> MCP -> add server tosca-commander"
    Write-Host "  3. URL: http://127.0.0.1:46248/mcp (DEBUG builds: port 8080)"
    Write-Host "  4. Reload Cursor; confirm skills and rules are enabled"
} else {
    Write-Host "  2. Configure Commander MCP in your IDE (http://127.0.0.1:46248/mcp)"
}
Write-Host "  5. Verify: get_workspace_info"
