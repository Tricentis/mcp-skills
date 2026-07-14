# Shared PowerShell helpers for Tosca Commander IDE integration scripts.

$_libParent = Split-Path $PSScriptRoot -Parent
if ((Split-Path $_libParent -Leaf) -eq "scripts") {
    # Running from repo: PSScriptRoot is scripts/lib, so go up two levels
    $script:RepoRoot = Split-Path $_libParent -Parent
} else {
    # Running from distribution zip: PSScriptRoot is <root>/lib, go up one level
    $script:RepoRoot = $_libParent
}

function Get-RepoRoot {
    return $script:RepoRoot
}

function Get-CoreSkillPath {
    return Join-Path $script:RepoRoot "packages/core/skills/cli-api-commander"
}

function Get-CoreRulesPath {
    return Join-Path $script:RepoRoot "packages/core/rules"
}

function Copy-DirectoryContents {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination,
        [string[]]$ExcludeDirNames = @()
    )
    if (-not (Test-Path $Source)) {
        throw "Source not found: $Source"
    }
    if ($ExcludeDirNames.Count -gt 0) {
        . (Join-Path $PSScriptRoot "ConsumerExport.ps1")
        Copy-TreeExcluding -Source $Source -Destination $Destination -ExcludeDirNames $ExcludeDirNames
        return
    }
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
}

function Get-SkillVersion {
    $metaPath = Join-Path (Get-CoreSkillPath) "metadata.json"
    if (-not (Test-Path $metaPath)) {
        throw "Skill metadata not found: $metaPath"
    }
    $meta = Get-Content -Path $metaPath -Raw -Encoding UTF8 | ConvertFrom-Json
    return [string]$meta.version
}

function Remove-ConsumerSkillSections {
    param([string]$SkillMdPath)
    if (-not (Test-Path $SkillMdPath)) { return }
    $content = Get-Content -Path $SkillMdPath -Raw -Encoding UTF8
    $content = $content -replace '(?ms)\r?\n## Activation testing\r?\n\r?\n\[evaluations/activation\.md\][^\r\n]*\r?\n?', ''
    Set-Content -Path $SkillMdPath -Value $content.TrimEnd() -Encoding UTF8 -NoNewline
    Add-Content -Path $SkillMdPath -Value "`n" -Encoding UTF8
}

function Get-SkillId {
    return "cli-api-commander"
}

function Get-LegacySkillIds {
    return @("tcshell-commander")
}

function Get-LegacySkillPaths {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Cursor", "Claude", "VSCode", "Windsurf")]
        [string]$Ide,

        [ValidateSet("User", "Project")]
        [string]$Scope = "User",

        [string]$ProjectPath = (Get-Location).Path
    )

    $packMap = Get-IdePackMap
    $config = $packMap[$Ide]
    $paths = @()

    foreach ($legacyId in Get-LegacySkillIds) {
        switch ($Ide) {
            "Cursor" {
                if ($Scope -eq "User") {
                    if ($config.UserSkill) {
                        $paths += ($config.UserSkill -replace [regex]::Escape((Get-SkillId)), $legacyId)
                    }
                    if ($config.UserRules) {
                        $paths += (Join-Path $config.UserRules "$legacyId.mdc")
                    }
                } else {
                    $paths += (Join-Path $ProjectPath ".cursor/skills/$legacyId")
                    $paths += (Join-Path $ProjectPath ".cursor/rules/$legacyId.mdc")
                }
            }
            "Claude" {
                if ($Scope -eq "User") {
                    if ($config.UserSkill) {
                        $paths += ($config.UserSkill -replace [regex]::Escape((Get-SkillId)), $legacyId)
                    }
                } else {
                    $paths += (Join-Path $ProjectPath ".claude/skills/$legacyId")
                }
            }
            "Windsurf" {
                if ($Scope -eq "User") {
                    if ($config.UserSkill) {
                        $paths += ($config.UserSkill -replace [regex]::Escape((Get-SkillId)), $legacyId)
                    }
                    if ($config.UserRules) {
                        $paths += (Join-Path $config.UserRules "$legacyId.md")
                    }
                } else {
                    $paths += (Join-Path $ProjectPath ".windsurf/skills/$legacyId")
                    $paths += (Join-Path $ProjectPath ".windsurf/rules/$legacyId.md")
                }
            }
        }
    }

    return $paths | Select-Object -Unique
}

function Remove-LegacySkillInstall {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Cursor", "Claude", "VSCode", "Windsurf")]
        [string]$Ide,

        [ValidateSet("User", "Project")]
        [string]$Scope = "User",

        [string]$ProjectPath = (Get-Location).Path
    )

    foreach ($path in (Get-LegacySkillPaths -Ide $Ide -Scope $Scope -ProjectPath $ProjectPath)) {
        if (-not (Test-Path $path)) { continue }
        Remove-Item -Path $path -Recurse -Force
        Write-Host "Removed legacy skill install: $path"
    }
}

function Remove-StalePackEntries {
    param(
        [Parameter(Mandatory = $true)][string]$PackRoot,
        [string]$SkillId = (Get-SkillId)
    )

    foreach ($staleFile in @('install.ps1', 'Install-CliApiCommanderPack.ps1', 'Install-CliApiCommanderPack.bat')) {
        $path = Join-Path $PackRoot $staleFile
        if (Test-Path $path) { Remove-Item -Path $path -Force }
    }

    $skillsDir = Join-Path $PackRoot "skills"
    if (Test-Path $skillsDir) {
        Get-ChildItem -Path $skillsDir -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne $SkillId } |
            ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force }
    }

    $rulesDir = Join-Path $PackRoot "rules"
    if (Test-Path $rulesDir) {
        Get-ChildItem -Path $rulesDir -File -ErrorAction SilentlyContinue |
            Where-Object { $_.BaseName -ne $SkillId } |
            ForEach-Object { Remove-Item -Path $_.FullName -Force }
    }
}

function Resolve-IdePackPath {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("cursor", "claude", "vscode", "windsurf")]
        [string]$FolderName
    )
    $short = Join-Path $script:RepoRoot $FolderName
    if (Test-Path $short) {
        return $short
    }
    $long = Join-Path $script:RepoRoot "packages/$FolderName-pack"
    if (Test-Path $long) {
        return $long
    }
    throw "IDE pack not found for '$FolderName' under $($script:RepoRoot) (expected '$FolderName/' or 'packages/$FolderName-pack/')"
}

function Get-CommanderVersionsManifest {
    foreach ($path in @(
        (Join-Path $script:RepoRoot "commander-versions.json"),
        (Join-Path $script:RepoRoot "packages/core/reference/commander-versions.json")
    )) {
        if (Test-Path $path) {
            return Get-Content $path -Raw | ConvertFrom-Json
        }
    }
    throw "Commander versions manifest not found under $($script:RepoRoot)"
}

function Resolve-CommanderVersionKey {
    param(
        [string]$CommanderHome,
        [string]$ExplicitVersion = $env:COMMANDER_VERSION
    )

    $manifest = Get-CommanderVersionsManifest
    if ($ExplicitVersion -and $manifest.versions.$ExplicitVersion) {
        return $ExplicitVersion
    }

    if (-not $CommanderHome) {
        if ($env:USERPROFILE) {
            foreach ($file in @(
                (Join-Path $env:USERPROFILE '.tricentis/tcshell-ide.env'),
                (Join-Path $env:USERPROFILE '.tricentis\tcshell-ide.env')
            )) {
                if (-not (Test-Path $file)) { continue }
                foreach ($line in Get-Content $file) {
                    if ($line -match '^COMMANDER_VERSION=(.+)$') {
                        $fromIde = $Matches[1].Trim()
                        if ($manifest.versions.$fromIde) { return $fromIde }
                    }
                }
            }
        }
        return $manifest.defaultVersion
    }

    $normalized = $CommanderHome.ToLowerInvariant().Replace('\', '/')

    $patterns = [ordered]@{
        "24.1" = @("24.1", "241", ".241")
        "24.2" = @("24.2", "242", ".242")
        "25.1" = @("25.1", "251", ".251")
        "26.1" = @("26.1", "261", ".261")
        "master" = @("master")
    }
    foreach ($key in $patterns.Keys) {
        if ($key -eq 'master') { continue }
        foreach ($token in $patterns[$key]) {
            if ($normalized.Contains($token)) { return $key }
        }
    }
    if ($normalized.Contains('master')) { return 'master' }
    if ($normalized -match 'toscacommander/?$' -and $normalized -notmatch '24\.|25\.|26\.|241|242|251|261') {
        return 'master'
    }
    return $manifest.defaultVersion
}

function Get-UserProfileRoot {
    if ($env:USERPROFILE) { return $env:USERPROFILE }
    if ($env:HOME) { return $env:HOME }
    return $null
}

function Get-IdePackMap {
    $id = Get-SkillId
    $userHome = Get-UserProfileRoot
    return [ordered]@{
        Cursor   = @{
            PackPath      = Resolve-IdePackPath "cursor"
            UserSkill     = if ($userHome) { Join-Path $userHome ".cursor/skills/$id" } else { $null }
            UserRules     = if ($userHome) { Join-Path $userHome ".cursor/rules" } else { $null }
            ProjectSkill  = ".cursor/skills/$id"
            ProjectRules  = ".cursor/rules"
        }
        Claude   = @{
            PackPath      = Resolve-IdePackPath "claude"
            UserSkill     = if ($userHome) { Join-Path $userHome ".claude/skills/$id" } else { $null }
            UserRules     = $null
            ProjectSkill  = ".claude/skills/$id"
            ProjectRules  = $null
        }
        VSCode   = @{
            PackPath      = Resolve-IdePackPath "vscode"
            UserSkill     = $null
            UserRules     = $null
            ProjectSkill  = ".github"
            ProjectRules  = $null
        }
        Windsurf = @{
            PackPath      = Resolve-IdePackPath "windsurf"
            UserSkill     = if ($userHome) { Join-Path $userHome ".codeium/windsurf/skills/$id" } else { $null }
            UserRules     = if ($userHome) { Join-Path $userHome ".codeium/windsurf/rules" } else { $null }
            ProjectSkill  = ".windsurf/skills/$id"
            ProjectRules  = ".windsurf/rules"
        }
    }
}
