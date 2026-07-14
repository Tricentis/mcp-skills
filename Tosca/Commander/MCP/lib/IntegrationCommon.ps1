# Shared helpers for Commander MCP install scripts in Tricentis/mcp-skills (Tosca/Commander/MCP layout).

$script:RepoRoot = Split-Path $PSScriptRoot -Parent
$script:SkillId = "commander-mcp"

function Get-RepoRoot {
    return $script:RepoRoot
}

function Get-SkillId {
    return $script:SkillId
}

function Test-PackManifest {
    param(
        [string]$PackRoot,
        [string]$ExpectedPackageName = "commander-mcp"
    )
    $manifestPath = Join-Path $PackRoot "manifest.json"
    if (-not (Test-Path $manifestPath)) {
        throw "manifest.json not found beside installer: $manifestPath"
    }
    $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($manifest.packageName -ne $ExpectedPackageName) {
        throw "Unexpected packageName in manifest.json: $($manifest.packageName)"
    }
    if (-not $manifest.version) {
        throw "manifest.json missing version"
    }
    Write-Host "Verified manifest: $($manifest.packageName) $($manifest.version)"
}

function Copy-DirectoryContents {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )
    if (-not (Test-Path $Source)) {
        throw "Source not found: $Source"
    }
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
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
    $id = $script:SkillId
    $root = $script:RepoRoot
    return [ordered]@{
        Cursor   = @{
            PackPath     = Join-Path $root "cursor"
            UserSkill    = Join-Path $env:USERPROFILE ".cursor/skills/$id"
            UserRules    = Join-Path $env:USERPROFILE ".cursor/rules"
            ProjectSkill = ".cursor/skills/$id"
            ProjectRules = ".cursor/rules"
        }
        Claude   = @{
            PackPath     = Join-Path $root "claude"
            UserSkill    = Join-Path $env:USERPROFILE ".claude/skills/$id"
            UserRules    = $null
            ProjectSkill = ".claude/skills/$id"
            ProjectRules = $null
        }
        VSCode   = @{
            PackPath     = Join-Path $root "vscode"
            UserSkill    = $null
            UserRules    = $null
            ProjectSkill = ".github"
            ProjectRules = $null
        }
        Windsurf = @{
            PackPath     = Join-Path $root "windsurf"
            UserSkill    = Join-Path $env:USERPROFILE ".codeium/windsurf/skills/$id"
            UserRules    = Join-Path $env:USERPROFILE ".codeium/windsurf/rules"
            ProjectSkill = ".codeium/windsurf/skills/$id"
            ProjectRules = ".codeium/windsurf/rules"
        }
    }
}
