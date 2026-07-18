# Shared helpers for Tosca Cloud MCP install scripts in Tricentis/mcp-skills (Tosca/Cloud/MCP layout).

$script:RepoRoot = Split-Path $PSScriptRoot -Parent
$script:SkillPrefix = "tosca-"
$script:PackageName = "tosca-cloud-mcp"

function Get-RepoRoot {
    return $script:RepoRoot
}

function Get-CloudSkillIds {
    $skillsDir = Join-Path $script:RepoRoot "cursor/skills"
    if (-not (Test-Path $skillsDir)) {
        throw "cursor/skills not found under pack root: $skillsDir"
    }
    return @(Get-ChildItem -Path $skillsDir -Directory -Filter "$($script:SkillPrefix)*" | ForEach-Object { $_.Name })
}

function Test-PackManifest {
    param(
        [string]$PackRoot,
        [string]$ExpectedPackageName = $script:PackageName
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

function Get-IdePackMap {
    $root = $script:RepoRoot
    return [ordered]@{
        Cursor = @{
            PackPath      = Join-Path $root "cursor"
            UserSkills    = Join-Path $env:USERPROFILE ".cursor/skills"
            UserRules     = Join-Path $env:USERPROFILE ".cursor/rules"
            ProjectSkills = ".cursor/skills"
            ProjectRules  = ".cursor/rules"
        }
    }
}
