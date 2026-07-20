<#
.SYNOPSIS
    Installs Tosca Cloud tosca-cli hybrid skills from mcp-skills consumer layout (Tosca/Cloud/CLI).

.PARAMETER Ide
    Target IDE: Cursor, Claude, VSCode, or Windsurf.

.PARAMETER Tenant
    Tosca Cloud tenant name (optional — prompts configure_tn_connection.py).

.PARAMETER Space
    Space id (default: default).

.PARAMETER SkipTnConfig
    Skip writing ~/.tn/mcp.json.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Cursor", "Claude", "VSCode", "Windsurf")]
    [string]$Ide,

    [ValidateSet("User", "Project")]
    [string]$Scope = "User",

    [string]$ProjectPath = (Get-Location).Path,

    [string]$Tenant,
    [string]$Space = "default",
    [ValidateSet("prod", "staging", "dev")]
    [string]$Env = "prod",

    [switch]$SkipTnConfig,
    [switch]$VerifyManifest
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib/IntegrationCommon.ps1")

$packMap = Get-IdePackMap
$config = $packMap[$Ide]
$srcSkillsRoot = Join-Path $config.PackPath "skills"

if ($VerifyManifest) {
    Test-PackManifest -PackRoot $PSScriptRoot
}

$skillIds = Get-ToscaSkillIds -SkillsRoot $srcSkillsRoot
if ($skillIds.Count -eq 0) {
    throw "No tosca-* skills found under $srcSkillsRoot"
}

function Install-SkillTree {
    param([string]$Source, [string]$Destination)
    Copy-DirectoryContents -Source $Source -Destination $Destination
}

function Write-TnConfig {
    param([string]$OutputPath)
    if ($SkipTnConfig -or -not $OutputPath) { return }
    $configure = Join-Path $PSScriptRoot "configure_tn_connection.py"
    if (-not (Test-Path $configure)) {
        throw "configure_tn_connection.py not found beside installer: $configure"
    }
    $args = @($configure, "--env", $Env, "--space", $Space, "--output", $OutputPath)
    if ($Tenant) { $args += @("--tenant", $Tenant) }
    & python @args
    if ($LASTEXITCODE -ne 0) { throw "configure_tn_connection.py failed ($LASTEXITCODE)" }
}

function Install-CursorPack {
    param([string]$TargetSkillsRoot, [string]$TargetRules, [string]$TnConfigPath)
    foreach ($skillId in $skillIds) {
        $src = Join-Path $srcSkillsRoot $skillId
        Install-SkillTree -Source $src -Destination (Join-Path $TargetSkillsRoot $skillId)
    }
    $ruleSrc = Join-Path $config.PackPath "rules/$($script:EngineeringSkillId).mdc"
    New-Item -ItemType Directory -Force -Path $TargetRules | Out-Null
    Copy-Item -Path $ruleSrc -Destination (Join-Path $TargetRules "$($script:EngineeringSkillId).mdc") -Force
    Write-TnConfig -OutputPath $TnConfigPath
}

function Install-ClaudePack {
    param([string]$TargetSkillsRoot, [string]$TnConfigPath)
    foreach ($skillId in $skillIds) {
        $src = Join-Path $srcSkillsRoot $skillId
        Install-SkillTree -Source $src -Destination (Join-Path $TargetSkillsRoot $skillId)
    }
    Write-TnConfig -OutputPath $TnConfigPath
}

function Install-WindsurfPack {
    param([string]$TargetSkillsRoot, [string]$TargetRules)
    foreach ($skillId in $skillIds) {
        $src = Join-Path $srcSkillsRoot $skillId
        Install-SkillTree -Source $src -Destination (Join-Path $TargetSkillsRoot $skillId)
    }
    $ruleSrc = Join-Path $config.PackPath "rules/$($script:EngineeringSkillId).md"
    New-Item -ItemType Directory -Force -Path $TargetRules | Out-Null
    Copy-Item -Path $ruleSrc -Destination (Join-Path $TargetRules "$($script:EngineeringSkillId).md") -Force
}

function Install-VSCodePack {
    param([string]$TargetGithub)
    New-Item -ItemType Directory -Force -Path $TargetGithub | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $TargetGithub "instructions") | Out-Null
    $fragment = Join-Path $config.PackPath "copilot-instructions.md.fragment"
    $dest = Join-Path $TargetGithub "copilot-instructions.md"
    if (-not (Test-Path $dest)) {
        Copy-Item $fragment $dest -Force
    } else {
        Write-Warning "Merge $fragment into existing $dest manually."
    }
    $agentsSrc = Join-Path $PSScriptRoot "AGENTS.md.fragment"
    $agentsDest = Join-Path (Split-Path $TargetGithub -Parent) "AGENTS.md"
    if ((Test-Path $agentsSrc) -and -not (Test-Path $agentsDest)) {
        Copy-Item $agentsSrc $agentsDest -Force
    }
}

switch ($Ide) {
    "Cursor" {
        if ($Scope -eq "User") {
            Install-CursorPack -TargetSkillsRoot $config.UserSkillsRoot `
                -TargetRules $config.UserRules -TnConfigPath $config.TnConfig
        } else {
            Install-CursorPack -TargetSkillsRoot (Join-Path $ProjectPath $config.ProjectSkills) `
                -TargetRules (Join-Path $ProjectPath $config.ProjectRules) `
                -TnConfigPath (Join-Path $ProjectPath ".tn/mcp.json")
        }
    }
    "Claude" {
        $target = if ($Scope -eq "User") { $config.UserSkillsRoot } else { Join-Path $ProjectPath $config.ProjectSkills }
        $tnPath = if ($Scope -eq "User") { $config.TnConfig } else { Join-Path $ProjectPath ".tn/mcp.json" }
        Install-ClaudePack -TargetSkillsRoot $target -TnConfigPath $tnPath
    }
    "Windsurf" {
        $skillsTarget = if ($Scope -eq "User") { $config.UserSkillsRoot } else { Join-Path $ProjectPath $config.ProjectSkills }
        $rulesTarget = if ($Scope -eq "User") { $config.UserRules } else { Join-Path $ProjectPath $config.ProjectRules }
        Install-WindsurfPack -TargetSkillsRoot $skillsTarget -TargetRules $rulesTarget
    }
    "VSCode" {
        $github = if ($Scope -eq "User") { Join-Path $env:USERPROFILE ".github" } else { Join-Path $ProjectPath ".github" }
        Install-VSCodePack -TargetGithub $github
    }
}

Write-Host "Installed Tosca Cloud pack ($($skillIds.Count) skills) for $Ide ($Scope scope)."
Write-Host "Next: toscactl login --url <tenant>.my.tricentis.com"
Write-Host "Verify: python3 verify_toscactl.py"
Write-Host "Gap workflows: python3 configure_tn_connection.py + tn --setup"
