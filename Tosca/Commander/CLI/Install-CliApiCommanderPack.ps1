<#
.SYNOPSIS
    Installs the Tosca Commander IDE integration pack (user scope by default, no admin).

.PARAMETER Ide
    Target IDE: Cursor, Claude, VSCode, or Windsurf.

.PARAMETER Scope
    User (default) or Project.

.PARAMETER ProjectPath
    Project root when Scope is Project. Defaults to current directory.

.PARAMETER CommanderHome
    Optional read-only path to Commander install for TCShell discovery.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Cursor", "Claude", "VSCode", "Windsurf")]
    [string]$Ide,

    [ValidateSet("User", "Project")]
    [string]$Scope = "User",

    [string]$ProjectPath = (Get-Location).Path,

    [string]$CommanderHome
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib/IntegrationCommon.ps1")

$repoRoot = Get-RepoRoot
$skillId = Get-SkillId
$packMap = Get-IdePackMap
$config = $packMap[$Ide]

Remove-LegacySkillInstall -Ide $Ide -Scope $Scope -ProjectPath $ProjectPath

function Install-CursorPack {
    param([string]$PackPath, [string]$TargetSkill, [string]$TargetRules)
    $srcSkill = Join-Path $PackPath "skills/$skillId"
    $srcRules = Join-Path $PackPath "rules/$skillId.mdc"
    Copy-DirectoryContents -Source $srcSkill -Destination $TargetSkill
    New-Item -ItemType Directory -Force -Path $TargetRules | Out-Null
    Copy-Item -Path $srcRules -Destination (Join-Path $TargetRules "$skillId.mdc") -Force
}

function Install-ClaudePack {
    param([string]$PackPath, [string]$TargetSkill)
    $srcSkill = Join-Path $PackPath "skills/$skillId"
    Copy-DirectoryContents -Source $srcSkill -Destination $TargetSkill
}

function Install-VSCodePack {
    param([string]$PackPath, [string]$TargetGithub)
    New-Item -ItemType Directory -Force -Path $TargetGithub | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $TargetGithub "instructions") | Out-Null

    $copilotFragment = Join-Path $PackPath "copilot-instructions.md.fragment"
    $copilotDest = Join-Path $TargetGithub "copilot-instructions.md"
    if (Test-Path $copilotDest) {
        Write-Warning "Existing $copilotDest not overwritten. Merge content from $copilotFragment manually."
    } else {
        Copy-Item -Path $copilotFragment -Destination $copilotDest -Force
    }

    $tcshellInstr = Join-Path $PackPath "instructions/cli-api-commander.instructions.md"
    Copy-Item -Path $tcshellInstr -Destination (Join-Path $TargetGithub "instructions/cli-api-commander.instructions.md") -Force

    $agentsFragment = Join-Path $repoRoot "AGENTS.md.fragment"
    if (Test-Path $agentsFragment) {
        $agentsDest = Join-Path (Split-Path $TargetGithub -Parent) "AGENTS.md"
        if (-not (Test-Path $agentsDest)) {
            Copy-Item -Path $agentsFragment -Destination $agentsDest -Force
        } else {
            Write-Warning "AGENTS.md already exists at project root; merge fragment manually."
        }
    }
}

function Install-WindsurfPack {
    param([string]$PackPath, [string]$TargetSkill, [string]$TargetRules)
    $srcSkill = Join-Path $PackPath "skills/$skillId"
    $srcRule = Join-Path $PackPath "rules/$skillId.md"
    Copy-DirectoryContents -Source $srcSkill -Destination $TargetSkill
    New-Item -ItemType Directory -Force -Path $TargetRules | Out-Null
    Copy-Item -Path $srcRule -Destination (Join-Path $TargetRules "$skillId.md") -Force
}

if ($Scope -eq "User") {
    switch ($Ide) {
        "Cursor"   { Install-CursorPack -PackPath $config.PackPath -TargetSkill $config.UserSkill -TargetRules $config.UserRules }
        "Claude"   { Install-ClaudePack -PackPath $config.PackPath -TargetSkill $config.UserSkill }
        "VSCode"   { throw "VSCode/Copilot user-scope install is not supported; use -Scope Project." }
        "Windsurf" { Install-WindsurfPack -PackPath $config.PackPath -TargetSkill $config.UserSkill -TargetRules $config.UserRules }
    }
    Write-Host "Installed $Ide pack to user profile (no admin required)."
} else {
    switch ($Ide) {
        "Cursor"   {
            Install-CursorPack -PackPath $config.PackPath `
                -TargetSkill (Join-Path $ProjectPath $config.ProjectSkill) `
                -TargetRules (Join-Path $ProjectPath $config.ProjectRules)
        }
        "Claude"   {
            Install-ClaudePack -PackPath $config.PackPath -TargetSkill (Join-Path $ProjectPath $config.ProjectSkill)
        }
        "VSCode"   {
            Install-VSCodePack -PackPath $config.PackPath -TargetGithub (Join-Path $ProjectPath $config.ProjectSkill)
        }
        "Windsurf" {
            Install-WindsurfPack -PackPath $config.PackPath `
                -TargetSkill (Join-Path $ProjectPath $config.ProjectSkill) `
                -TargetRules (Join-Path $ProjectPath $config.ProjectRules)
        }
    }
    Write-Host "Installed $Ide pack to project: $ProjectPath"
}

if ($CommanderHome) {
    $envFile = if ($Scope -eq "User") {
        Join-Path $env:USERPROFILE ".tricentis/tcshell-ide.env"
    } else {
        Join-Path $ProjectPath ".tricentis/tcshell-ide.env"
    }
    New-Item -ItemType Directory -Force -Path (Split-Path $envFile -Parent) | Out-Null
    $versionKey = Resolve-CommanderVersionKey -CommanderHome $CommanderHome
    $referenceHint = if ($versionKey) { "reference/versions/$versionKey/" } else { "reference/" }
    @"
COMMANDER_HOME=$CommanderHome
TCSHELL_PATH=$CommanderHome\TCShell\TCShell.exe
COMMANDER_VERSION=$versionKey
SKILL_REFERENCE_PATH=$referenceHint
"@ | Set-Content -Path $envFile -Encoding UTF8
    Write-Host "Wrote Commander discovery hints to $envFile (read-only reference)."
    if ($versionKey) {
        Write-Host "Detected Commander version: $versionKey — use skill reference at $referenceHint"
    }
}

Write-Host "Invoke skill: /$skillId (Cursor/Claude) or @$skillId (Windsurf)"
if ($Ide -eq "Cursor") {
    Write-Host "Cursor: open Customize (sidebar) and confirm skills and rules are enabled."
}
