# Shared helpers for Tosca Cloud CLI install scripts (mcp-skills consumer layout).

$_libParent = Split-Path $PSScriptRoot -Parent
if ((Split-Path $_libParent -Leaf) -eq "lib") {
    $script:RepoRoot = Split-Path $_libParent -Parent
} else {
    $script:RepoRoot = $_libParent
}

$script:EngineeringSkillId = "tn-cloud"
$script:PackageName = "tn-cloud-IDE"

function Get-RepoRoot { return $script:RepoRoot }

function Get-EngineeringSkillId { return $script:EngineeringSkillId }

function Get-TnSkillIds {
    param([Parameter(Mandatory = $true)][string]$SkillsRoot)
    if (-not (Test-Path $SkillsRoot)) {
        throw "Skills directory not found: $SkillsRoot"
    }
    $ids = @()
    foreach ($dir in Get-ChildItem -Path $SkillsRoot -Directory) {
        if ($dir.Name -eq $script:EngineeringSkillId -or $dir.Name -like "tn-*") {
            $ids += $dir.Name
        }
    }
    return $ids | Select-Object -Unique | Sort-Object
}

function Test-PackManifest {
    param(
        [string]$PackRoot = $script:RepoRoot,
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
    if (-not (Test-Path $Source)) { throw "Source not found: $Source" }
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Get-ChildItem -Path $Source -Force | ForEach-Object {
        if ($_.PSIsContainer -and ($ExcludeDirNames -contains $_.Name)) { return }
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
    $userHome = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { $null }
    return [ordered]@{
        Cursor = @{
            PackPath       = Join-Path $root "cursor"
            UserSkillsRoot = if ($userHome) { Join-Path $userHome ".cursor/skills" } else { $null }
            UserRules      = if ($userHome) { Join-Path $userHome ".cursor/rules" } else { $null }
            ProjectSkills  = ".cursor/skills"
            ProjectRules   = ".cursor/rules"
            TnConfig       = if ($userHome) { Join-Path $userHome ".tn/mcp.json" } else { $null }
        }
        Claude = @{
            PackPath       = Join-Path $root "claude"
            UserSkillsRoot = if ($userHome) { Join-Path $userHome ".claude/skills" } else { $null }
            UserRules      = $null
            ProjectSkills  = ".claude/skills"
            ProjectRules   = $null
            TnConfig       = if ($userHome) { Join-Path $userHome ".tn/mcp.json" } else { $null }
        }
        VSCode = @{
            PackPath       = Join-Path $root "vscode"
            UserSkillsRoot = $null
            UserRules      = $null
            ProjectSkills  = ".github"
            ProjectRules   = $null
            TnConfig       = if ($userHome) { Join-Path $userHome ".tn/mcp.json" } else { $null }
        }
        Windsurf = @{
            PackPath       = Join-Path $root "windsurf"
            UserSkillsRoot = if ($userHome) { Join-Path $userHome ".codeium/windsurf/skills" } else { $null }
            UserRules      = if ($userHome) { Join-Path $userHome ".codeium/windsurf/rules" } else { $null }
            ProjectSkills  = ".windsurf/skills"
            ProjectRules   = ".windsurf/rules"
            TnConfig       = if ($userHome) { Join-Path $userHome ".tn/mcp.json" } else { $null }
        }
    }
}
