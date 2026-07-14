# Shared helpers for Tosca Cloud MCP skill packaging scripts.

$script:RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$script:SkillPrefix = "tosca-"

function Get-RepoRoot {
    return $script:RepoRoot
}

function Get-CloudSkillIds {
    $skillsDir = Join-Path $script:RepoRoot "skills"
    return @(Get-ChildItem -Path $skillsDir -Directory -Filter "$($script:SkillPrefix)*" | ForEach-Object { $_.Name })
}

function Get-CoreRulesPath {
    return Join-Path $script:RepoRoot "packages/core/rules"
}

function Copy-DirectoryContents {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination,
        [string[]]$ExcludeDirNames = @("evaluations")
    )
    if (-not (Test-Path $Source)) {
        throw "Source not found: $Source"
    }
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Get-ChildItem -Path $Source -Force | ForEach-Object {
        if ($_.PSIsContainer -and ($ExcludeDirNames -contains $_.Name)) {
            return
        }
        $destItem = Join-Path $Destination $_.Name
        if ($_.PSIsContainer) {
            Copy-DirectoryContents -Source $_.FullName -Destination $destItem -ExcludeDirNames $ExcludeDirNames
        } else {
            Copy-Item -Path $_.FullName -Destination $destItem -Force
        }
    }
}

function Merge-CursorMcpConfig {
    param(
        [Parameter(Mandatory = $true)][string]$SourceMcpJson,
        [Parameter(Mandatory = $true)][string]$TargetMcpJson
    )
    if (-not (Test-Path $SourceMcpJson)) {
        throw "MCP config not found: $SourceMcpJson"
    }

    $source = Get-Content -Path $SourceMcpJson -Raw -Encoding UTF8 | ConvertFrom-Json
    $targetDir = Split-Path $TargetMcpJson -Parent
    if ($targetDir -and -not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    }

    if (Test-Path $TargetMcpJson) {
        $target = Get-Content -Path $TargetMcpJson -Raw -Encoding UTF8 | ConvertFrom-Json
    } else {
        $target = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} }
    }

    if (-not $target.PSObject.Properties['mcpServers']) {
        $target | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([PSCustomObject]@{})
    }

    foreach ($name in $source.mcpServers.PSObject.Properties.Name) {
        $target.mcpServers | Add-Member -NotePropertyName $name -NotePropertyValue $source.mcpServers.$name -Force
    }

    $target | ConvertTo-Json -Depth 10 | Set-Content -Path $TargetMcpJson -Encoding UTF8
}

function Get-IdePackMap {
    return [ordered]@{
        Cursor = @{
            PackPath     = Join-Path $script:RepoRoot "packages/cursor-pack"
            UserSkills   = Join-Path $env:USERPROFILE ".cursor/skills"
            UserRules    = Join-Path $env:USERPROFILE ".cursor/rules"
            ProjectSkills = ".cursor/skills"
            ProjectRules  = ".cursor/rules"
        }
    }
}
