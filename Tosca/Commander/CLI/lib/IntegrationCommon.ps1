# Shared PowerShell helpers for Commander CLI pack install scripts.

$_libParent = Split-Path $PSScriptRoot -Parent
if ((Split-Path $_libParent -Leaf) -eq "scripts") {
    # Repository layout: PSScriptRoot is scripts/lib; go up two levels.
    $script:RepoRoot = Split-Path $_libParent -Parent
} else {
    # Running from distribution zip: PSScriptRoot is <root>/lib, go up one level
    $script:RepoRoot = $_libParent
}

function Get-RepoRoot {
    return $script:RepoRoot
}

function Get-CoreSkillPath {
    foreach ($ide in @("cursor", "claude", "windsurf")) {
        $path = Join-Path $script:RepoRoot "$ide/skills/$(Get-SkillId)"
        if (Test-Path $path) { return $path }
    }
    $path = Join-Path $script:RepoRoot "packages/core/skills/$(Get-SkillId)"
    if (Test-Path $path) { return $path }
    throw "Skill path not found under $($script:RepoRoot)"
}

function Get-CoreRulesPath {
    foreach ($ide in @("cursor", "claude", "windsurf")) {
        $path = Join-Path $script:RepoRoot "$ide/rules"
        if (Test-Path $path) { return $path }
    }
    $path = Join-Path $script:RepoRoot "packages/core/rules"
    if (Test-Path $path) { return $path }
    throw "Rules path not found under $($script:RepoRoot)"
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

function Get-SkillVersion {
    $metaPath = Join-Path (Get-CoreSkillPath) "metadata.json"
    if (-not (Test-Path $metaPath)) {
        throw "Skill metadata not found: $metaPath"
    }
    $meta = Get-Content -Path $metaPath -Raw -Encoding UTF8 | ConvertFrom-Json
    return [string]$meta.version
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
    throw "IDE pack not found for '$FolderName' under $($script:RepoRoot)"
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
        $userHome = Get-UserProfileRoot
        if ($userHome) {
            foreach ($file in @(
                (Join-Path $userHome '.tricentis/tcshell-ide.env'),
                (Join-Path $userHome '.tricentis\tcshell-ide.env')
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
    if ($HOME) { return $HOME }
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

# SIG # Begin signature block
# MIIqGQYJKoZIhvcNAQcCoIIqCjCCKgYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDGmpS4vhr4WYim
# tDfQWwEiOPN+oWhH9CLMDdTMwfEPIKCCDt8wggboMIIE0KADAgECAhB3vQ4Ft1kL
# th1HYVMeP3XtMA0GCSqGSIb3DQEBCwUAMFMxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSkwJwYDVQQDEyBHbG9iYWxTaWduIENvZGUgU2ln
# bmluZyBSb290IFI0NTAeFw0yMDA3MjgwMDAwMDBaFw0zMDA3MjgwMDAwMDBaMFwx
# CzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTIwMAYDVQQD
# EylHbG9iYWxTaWduIEdDQyBSNDUgRVYgQ29kZVNpZ25pbmcgQ0EgMjAyMDCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMsg75ceuQEyQ6BbqYoj/SBerjgS
# i8os1P9B2BpV1BlTt/2jF+d6OVzA984Ro/ml7QH6tbqT76+T3PjisxlMg7BKRFAE
# eIQQaqTWlpCOgfh8qy+1o1cz0lh7lA5tD6WRJiqzg09ysYp7ZJLQ8LRVX5YLEeWa
# tSyyEc8lG31RK5gfSaNf+BOeNbgDAtqkEy+FSu/EL3AOwdTMMxLsvUCV0xHK5s2z
# BZzIU+tS13hMUQGSgt4T8weOdLqEgJ/SpBUO6K/r94n233Hw0b6nskEzIHXMsdXt
# HQcZxOsmd/KrbReTSam35sOQnMa47MzJe5pexcUkk2NvfhCLYc+YVaMkoog28vmf
# vpMusgafJsAMAVYS4bKKnw4e3JiLLs/a4ok0ph8moKiueG3soYgVPMLq7rfYrWGl
# r3A2onmO3A1zwPHkLKuU7FgGOTZI1jta6CLOdA6vLPEV2tG0leis1Ult5a/dm2tj
# IF2OfjuyQ9hiOpTlzbSYszcZJBJyc6sEsAnchebUIgTvQCodLm3HadNutwFsDeCX
# pxbmJouI9wNEhl9iZ0y1pzeoVdwDNoxuz202JvEOj7A9ccDhMqeC5LYyAjIwfLWT
# yCH9PIjmaWP47nXJi8Kr77o6/elev7YR8b7wPcoyPm593g9+m5XEEofnGrhO7izB
# 36Fl6CSDySrC/blTAgMBAAGjggGtMIIBqTAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0l
# BAwwCgYIKwYBBQUHAwMwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUJZ3Q
# /FkJhmPF7POxEztXHAOSNhEwHwYDVR0jBBgwFoAUHwC/RoAK/Hg5t6W0Q9lWULvO
# ljswgZMGCCsGAQUFBwEBBIGGMIGDMDkGCCsGAQUFBzABhi1odHRwOi8vb2NzcC5n
# bG9iYWxzaWduLmNvbS9jb2Rlc2lnbmluZ3Jvb3RyNDUwRgYIKwYBBQUHMAKGOmh0
# dHA6Ly9zZWN1cmUuZ2xvYmFsc2lnbi5jb20vY2FjZXJ0L2NvZGVzaWduaW5ncm9v
# dHI0NS5jcnQwQQYDVR0fBDowODA2oDSgMoYwaHR0cDovL2NybC5nbG9iYWxzaWdu
# LmNvbS9jb2Rlc2lnbmluZ3Jvb3RyNDUuY3JsMFUGA1UdIAROMEwwQQYJKwYBBAGg
# MgECMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
# cG9zaXRvcnkvMAcGBWeBDAEDMA0GCSqGSIb3DQEBCwUAA4ICAQAldaAJyTm6t6E5
# iS8Yn6vW6x1L6JR8DQdomxyd73G2F2prAk+zP4ZFh8xlm0zjWAYCImbVYQLFY4/U
# ovG2XiULd5bpzXFAM4gp7O7zom28TbU+BkvJczPKCBQtPUzosLp1pnQtpFg6bBNJ
# +KUVChSWhbFqaDQlQq+WVvQQ+iR98StywRbha+vmqZjHPlr00Bid/XSXhndGKj0j
# fShziq7vKxuav2xTpxSePIdxwF6OyPvTKpIz6ldNXgdeysEYrIEtGiH6bs+XYXvf
# cXo6ymP31TBENzL+u0OF3Lr8psozGSt3bdvLBfB+X3Uuora/Nao2Y8nOZNm9/Lws
# 80lWAMgSK8YnuzevV+/Ezx4pxPTiLc4qYc9X7fUKQOL1GNYe6ZAvytOHX5OKSBoR
# HeU3hZ8uZmKaXoFOlaxVV0PcU4slfjxhD4oLuvU/pteO9wRWXiG7n9dqcYC/lt5y
# A9jYIivzJxZPOOhRQAyuku++PX33gMZMNleElaeEFUgwDlInCI2Oor0ixxnJpsoO
# qHo222q6YV8RJJWk4o5o7hmpSZle0LQ0vdb5QMcQlzFSOTUpEYck08T7qWPLd0jV
# +mL8JOAEek7Q5G7ezp44UCb0IXFl1wkl1MkHAHq4x/N36MXU4lXQ0x72f1LiSY25
# EXIMiEQmM2YBRN/kMw4h3mKJSAfa9TCCB+8wggXXoAMCAQICDA2JDkgit0EdmxZo
# UjANBgkqhkiG9w0BAQsFADBcMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFs
# U2lnbiBudi1zYTEyMDAGA1UEAxMpR2xvYmFsU2lnbiBHQ0MgUjQ1IEVWIENvZGVT
# aWduaW5nIENBIDIwMjAwHhcNMjQwNjE4MTI1NzUzWhcNMjcwNjE5MTI1NzUzWjCC
# ATIxHTAbBgNVBA8MFFByaXZhdGUgT3JnYW5pemF0aW9uMRAwDgYDVQQFEwc0OTg4
# Mjh4MRMwEQYLKwYBBAGCNzwCAQMTAkFUMRcwFQYLKwYBBAGCNzwCAQITBlZpZW5u
# YTEXMBUGCysGAQQBgjc8AgEBEwZWaWVubmExCzAJBgNVBAYTAkFUMQ8wDQYDVQQI
# EwZWaWVubmExDzANBgNVBAcTBlZpZW5uYTElMCMGA1UECQwcTGVvbmFyZC1CZXJu
# c3RlaW4tU3RyYcOfZSAxMDEXMBUGA1UEChMOVHJpY2VudGlzIEdtYkgxCzAJBgNV
# BAsTAklUMRcwFQYDVQQDEw5UcmljZW50aXMgR21iSDEjMCEGCSqGSIb3DQEJARYU
# b2ZmaWNlQHRyaWNlbnRpcy5jb20wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
# AoICAQDYpZD1E9EFceZ45ObN+ppKcKN8I3FT3UVkf0RFSvryUP9iHPqZEN/Z9g6X
# oEo0/P74aG6Pu7QELy0hyWvSMPRiATrx9Pku9bCv8Kk9x2EPO6/nYTDhR0JY56t8
# zh3Q8QZT9J/MvSCgA9cYVQMy8A619SHmUGDOEELhLlLwZ+pwI1YSCLztKA6znSF5
# BJd5aGSVUw6rWZmPCvqo3f3w3o0ErQv+dvZ562NPPWy17FlvP/iUTvGtrKedBZNB
# NzL2GpYVjY0GM0LmnrZAP3ymItreQi2OIU/0D4I1GT6tpFkO4ppd1MlEwsldChfd
# j/JhP3jX/Pz2IusVwVyAXXCT5N71bA2GZ/GmFPzNhaMaIV7dFMU8nfhuz8B2PDLK
# p5fWDUnNA3ZrHAFADW4rpWMbuJxdlOA9wMVkglCsABJ+lyLr7A4RHdUJLRVuVE5t
# sDN3nMPC+EJvgwGOAm/3gd0PFblLREDIfYA3M0UpbwmJADu8Dhpzp91Uj/AjA2Ff
# P703kjD9C1oMIM3dzuul57c5Rn1a2ce2O0Qk+asc/p56tNxS4cM6Oi5ZTXKVoRCX
# oL72QsCpXNybrdp0B9OvU15ZcnFeE5I2/PFVRJOoWWv8FJL164yU5emt9Gne5qVe
# uMEI7o5b91XLiQLoC/5vlPWceQ2SS/oEy5/0ElujKDmpCb6R+wIDAQABo4IB1zCC
# AdMwDgYDVR0PAQH/BAQDAgeAMIGfBggrBgEFBQcBAQSBkjCBjzBMBggrBgEFBQcw
# AoZAaHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvZ3NnY2NyNDVl
# dmNvZGVzaWduY2EyMDIwLmNydDA/BggrBgEFBQcwAYYzaHR0cDovL29jc3AuZ2xv
# YmFsc2lnbi5jb20vZ3NnY2NyNDVldmNvZGVzaWduY2EyMDIwMFUGA1UdIAROMEww
# QQYJKwYBBAGgMgECMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNp
# Z24uY29tL3JlcG9zaXRvcnkvMAcGBWeBDAEDMAkGA1UdEwQCMAAwRwYDVR0fBEAw
# PjA8oDqgOIY2aHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9nc2djY3I0NWV2Y29k
# ZXNpZ25jYTIwMjAuY3JsMB8GA1UdEQQYMBaBFG9mZmljZUB0cmljZW50aXMuY29t
# MBMGA1UdJQQMMAoGCCsGAQUFBwMDMB8GA1UdIwQYMBaAFCWd0PxZCYZjxezzsRM7
# VxwDkjYRMB0GA1UdDgQWBBT60sNHuJcuh47lqkQjcZw7CxdnYDANBgkqhkiG9w0B
# AQsFAAOCAgEAEGmVnuYJYk7WfBHW5lJGKyQa19ETsd3Q+BCAdg8YNMZaFIVH+8u2
# NDKtFzvJmy/6+vZGY/gyZzcp+l5VdWZAaG/jb4Rv4p8geAogvcXq5JFefMHjZ2KB
# m6QD/w6TZ2vtJZsEIC3hU8JkQxfj/zhC4Q9lJlZTbSFH0p3IEUEH2uo/6H99jIWl
# V7owj9NIIZxsfX786Fkw7pRLKHC2K16Mx+oCJgom8E8Z5aVI4oclrYiRD7RROu9o
# HGsXbnpaM39mvZ0WYuP+6SRrMZIo/cj1dUisxW+0izDRWkSI29XipVN4vbqvNfPs
# r8D7UejSjuu9xTHfNfXiSCuxO2SXo4ACDcEAH9AsfzxNtPIffh0ToHfjnAU4v7bR
# MT7O+XZN7FD2gjalBjXICukY9v9lL+VZCmtZyDXCH/f89qp45SnVI9d2lUC4vDk3
# 26siEPWjhc13MD3ymcm1XkXDzMpx+KhDkfDdhJQzYBIFZQ1kf+dmoYCNN6DfRucx
# 7P3PzgxBf5X5H0J0IHDiO8o7EF0CUffEXtmsqXAA+iX0prQr5pXY6fI/JDPSQhGY
# M+3b5MZcY3BmW6aX2zMzsK1bwYN5pChPsvHlKi0kwXzwx5iG2zmATWQe5Hl1oMhW
# +pqBNXtA2qQ0W8dyw0VBDJu4hOqp/xNnrgcBrm37WoxMZ10YDyA2nHkxghqQMIIa
# jAIBATBsMFwxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNh
# MTIwMAYDVQQDEylHbG9iYWxTaWduIEdDQyBSNDUgRVYgQ29kZVNpZ25pbmcgQ0Eg
# MjAyMAIMDYkOSCK3QR2bFmhSMA0GCWCGSAFlAwQCAQUAoHwwEAYKKwYBBAGCNwIB
# DDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIF+WDN6TEA+jlToZ956hkU48
# koCD8mUuWHcMSTDLh6uDMA0GCSqGSIb3DQEBAQUABIICACopTLqZnYYx4BzDMlp8
# zRtfGQmIPgLr3jTnpODllgH3J8m20rxgA+YRnx04b4Vusrre3+etUL+rEo8IE2oL
# t8YwDVDbXMif/Kdzzk5qZ9+ntmOUxePXOCkMRH/A/P9HS7Ujd6qpMPrujXbjw/F7
# CHFPg1lZl8S/zu44Kxp29oTSzWMseWno8f1Xu2TPpUlzhnAXB5HMaVrkshmHeG/l
# Lb88vlI5SXgJxaNDoxLJsepfXHHemiQTJ1EMmOv4kgelDg6CtBJNKskXww8r+ZSQ
# +Ol07+CVKySvnCKe3swkC0z9aO6TBPYvilF6VBlB4XX7jY/AqWKacIkBm/f5DzaC
# kRixrE2XJMLhqZ9KpNQc63eIApmdxIyHhLLNruepRdlCATqaf8em4mJMYUM0KbOK
# zEoFPAqeUraeqhOfiUw31+VjwN7M02pan22jBBR9N7Rm6EG1sembum4nRAfBKOz/
# 93HiZZtuVof/L6uVhE+hWiJOMf/3KW2TfSfx3vxtV/ed600RA0zRRQKPfHrcYG85
# gJqDTs18slEklRK/yc0RoFdQFtfXe6I+c8MqfrZapGGPLOBf9GDVcK5h5rHvAdX+
# 2w+L787rHrtYeevCfyTxLatcs17ej9bIVD1RtrK6IVffly0o2bAvD72rnC/o4yX7
# dA6foBFML3n6CHloQOmmsrjgoYIXdzCCF3MGCisGAQQBgjcDAwExghdjMIIXXwYJ
# KoZIhvcNAQcCoIIXUDCCF0wCAQMxDzANBglghkgBZQMEAgEFADB4BgsqhkiG9w0B
# CRABBKBpBGcwZQIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEIBll/D57
# VBPff2ZQIpqG8w3lFuFyi5oDLQPRA7CNOVkPAhEAuZ1f9OtNCFSuTWcF4AuKHBgP
# MjAyNjEwMTUyMjE4MDBaoIITOjCCBu0wggTVoAMCAQICEAhP3DNPfkVO28MPj/mS
# GDUwDQYJKoZIhvcNAQELBQAwaTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lD
# ZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IFRpbWVTdGFt
# cGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1IENBMTAeFw0yNjA4MDUwMDAwMDBaFw0z
# NzExMDQyMzU5NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgU0hBMjU2IFJTQTQwOTYgVGltZXN0YW1w
# IFJlc3BvbmRlciAyMDI2IDEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQC2e6byyf7NSvjUm0xls/04xjD4fAkOkbnGQi7+Wpx81iYxfzViaxSIctuH3KSl
# 5YEYpMuFgGsA31N2D9ATMbfZdw5uaAhuWevQKhDdZIB4NnqcfpfpWQXJiQnDdAEl
# ETC+bhSEvNLGbA8DtwUpFMQ4yyYQSPqomT92osQAv6hBi47ATZS6JfVWe6XxhF4j
# JZ3iSAuf2Cros1czRSmWRHqMv9AfGZvp8ygYElhudpQjtcPpwoOl6QrZJUyV3iIN
# vN4cO05prGV0fkjG426xDr2d3z9lcSIHkdvGPdGUrXdxfVbgOUVcp2/8ISEzwKPW
# ++Wa+E2ujI91EZtukGWDJ/xZ27k3oHKEXBRGfRTqjOU+jE3ba/5++JSE/7oNHnjs
# 5mekExYN96LV/mxUbCKJb8pBNY4r3uD7hEmk/M81XhVgwDA7aMzYC3LZBg9WY5BM
# mbSay5ecmtJuXaB/0nKWmQmVZeqTVDgsmzHP5MQuhAJkiWNuC9MmCg9TZHXbJ2/y
# LVSov9p16UDTLtT0+aa1vN71fHeu1qMLlLNB3WOB/ADCxr3S/1hxI92Z6jKgEED/
# btwIvbfuXkNNhg8MtDg43c4tMZae9FvqMOt/9PvmAxF9TNIsIFB8G6yb36ZJZGUL
# 8N/pL971DyLXcK6HM5PYnH5X+eVtczhCgHCVQCF6XDAlPQIDAQABo4IBlTCCAZEw
# DAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQUFMljijAu1Er7bpTz5uNAfvXszeIwHwYD
# VR0jBBgwFoAU729TSunkBnx6yuKQVvYv1Ensy04wDgYDVR0PAQH/BAQDAgeAMBYG
# A1UdJQEB/wQMMAoGCCsGAQUFBwMIMIGVBggrBgEFBQcBAQSBiDCBhTAkBggrBgEF
# BQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMF0GCCsGAQUFBzAChlFodHRw
# Oi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRUaW1lU3Rh
# bXBpbmdSU0E0MDk2U0hBMjU2MjAyNUNBMS5jcnQwXwYDVR0fBFgwVjBUoFKgUIZO
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0VGltZVN0
# YW1waW5nUlNBNDA5NlNIQTI1NjIwMjVDQTEuY3JsMCAGA1UdIAQZMBcwCAYGZ4EM
# AQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAjcU6YR6dUgrfmawJ
# gH59KECxa9Ji8sEi2g10CBDaMiqsaxWyW5cwlT/6ZF5sFznazqVsoC85U9dqLOYq
# Qwst+UQQoNlDHgKRLa3xoc+OReFreFhnTXSG0Vrd2E2CZqUfm+5a+He1MJ/h+tNL
# uA+0Zzhn/Fo+FDYAHWZHx4R79ZsfRFYe9UiXpXBDf6DkUo183Y38NYmR/XfDYf7Y
# Z+oR9t3flbDwK+hgGMs0gNNp1w9Z2CyOyI5or/sSwomAuNQ0hWC9xoU4stD8aWsD
# 7RkcmgVRs6vlIk3zPKQ+ylcheWkMlj+CoVRlFE55pv0ZWCaFt04lwP/rdGHE9qEV
# QZtyRE42ox7oNgC/r+Y4bSlZ3dw9K2x1xLtu6PkPKeLBFjzKigwfqm3Hm+k/+lnM
# E8F5kPZTgiy2HLEHklpryqs6QHnPXrRNeIzkAMyylnRN8P0wmirS0WkU+ywpEWFZ
# 4QNg+9xS43tTuW9x0eXh7NDc1P/sV+zWxHXKH8tFt1ncHdVzqrZaYPyYMLSn2TOX
# ajveJW1L3joiQSPsWRGxkbDDW15jERFE4LvjnGu2O9zD1nLJSMdlYZEikl4w2w+q
# 4IN/R+TIe0H4ngCI1moJCTbevGH4punIxM1Uoi0nmX3ZK+XbRT01uowE5ViXWHng
# 0RgsmrX/EdYUo80r3TfMlkD0/YMwgga0MIIEnKADAgECAhANx6xXBf8hmS5AQyIM
# OkmGMA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERp
# Z2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yNTA1MDcwMDAwMDBaFw0zODAxMTQy
# MzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFB
# MD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5
# NiBTSEEyNTYgMjAyNSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQC0eDHTCphBcr48RsAcrHXbo0ZodLRRF51NrY0NlLWZloMsVO1DahGPNRcybEKq
# +RuwOnPhof6pvF4uGjwjqNjfEvUi6wuim5bap+0lgloM2zX4kftn5B1IpYzTqpyF
# Q/4Bt0mAxAHeHYNnQxqXmRinvuNgxVBdJkf77S2uPoCj7GH8BLuxBG5AvftBdsOE
# CS1UkxBvMgEdgkFiDNYiOTx4OtiFcMSkqTtF2hfQz3zQSku2Ws3IfDReb6e3mmdg
# lTcaarps0wjUjsZvkgFkriK9tUKJm/s80FiocSk1VYLZlDwFt+cVFBURJg6zMUjZ
# a/zbCclF83bRVFLeGkuAhHiGPMvSGmhgaTzVyhYn4p0+8y9oHRaQT/aofEnS5xLr
# fxnGpTXiUOeSLsJygoLPp66bkDX1ZlAeSpQl92QOMeRxykvq6gbylsXQskBBBnGy
# 3tW/AMOMCZIVNSaz7BX8VtYGqLt9MmeOreGPRdtBx3yGOP+rx3rKWDEJlIqLXvJW
# nY0v5ydPpOjL6s36czwzsucuoKs7Yk/ehb//Wx+5kMqIMRvUBDx6z1ev+7psNOdg
# JMoiwOrUG2ZdSoQbU2rMkpLiQ6bGRinZbI4OLu9BMIFm1UUl9VnePs6BaaeEWvjJ
# SjNm2qA+sdFUeEY0qVjPKOWug/G6X5uAiynM7Bu2ayBjUwIDAQABo4IBXTCCAVkw
# EgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQU729TSunkBnx6yuKQVvYv1Ens
# y04wHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQD
# AgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEF
# BQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRw
# Oi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNy
# dDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRUcnVzdGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglg
# hkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggIBABfO+xaAHP4HPRF2cTC9vgvItTSm
# f83Qh8WIGjB/T8ObXAZz8OjuhUxjaaFdleMM0lBryPTQM2qEJPe36zwbSI/mS83a
# fsl3YTj+IQhQE7jU/kXjjytJgnn0hvrV6hqWGd3rLAUt6vJy9lMDPjTLxLgXf9r5
# nWMQwr8Myb9rEVKChHyfpzee5kH0F8HABBgr0UdqirZ7bowe9Vj2AIMD8liyrukZ
# 2iA/wdG2th9y1IsA0QF8dTXqvcnTmpfeQh35k5zOCPmSNq1UH410ANVko43+Cdmu
# 4y81hjajV/gxdEkMx1NKU4uHQcKfZxAvBAKqMVuqte69M9J6A47OvgRaPs+2ykgc
# GV00TYr2Lr3ty9qIijanrUR3anzEwlvzZiiyfTPjLbnFRsjsYg39OlV8cipDoq7+
# qNNjqFzeGxcytL5TTLL4ZaoBdqbhOhZ3ZRDUphPvSRmMThi0vw9vODRzW6AxnJll
# 38F0cuJG7uEBYTptMSbhdhGQDpOXgpIUsWTjd6xpR6oaQf/DJbg3s6KCLPAlZ66R
# zIg9sC+NJpud/v4+7RWsWCiKi9EOLLHfMR2ZyJ/+xhCx9yHbxtl5TPau1j/1MIDp
# MPx0LckTetiSuEtQvLsNz3Qbp7wGWqbIiOWCnb5WqxL3/BAPvIXKUjPSxyZsq8Wh
# baM2tszWkPZPubdcMIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkq
# hkiG9w0BAQwFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBB
# c3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5
# WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJv
# b3QgRzQwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1K
# PDAiMGkz7MKnJS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2r
# snnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C
# 8weE5nQ7bXHiLQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBf
# sXpm7nfISKhmV1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGY
# QJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8
# rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaY
# dj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+
# wJS00mFt6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw
# ++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+N
# P8m800ERElvlEFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7F
# wI+isX4KJpn15GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUw
# AwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAU
# Reuir/SSy4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEB
# BG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsG
# AQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1
# cmVkSURSb290Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAow
# CDAGBgRVHSAAMA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/
# Vwe9mqyhhyzshV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLe
# JLxSA8hO0Cre+i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE
# 1Od/6Fmo8L8vC6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9Hda
# XFSMb++hUD38dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbO
# byMt9H5xaiNrIv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMYID
# fDCCA3gCAQEwfTBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgVGltZVN0YW1waW5nIFJT
# QTQwOTYgU0hBMjU2IDIwMjUgQ0ExAhAIT9wzT35FTtvDD4/5khg1MA0GCWCGSAFl
# AwQCAQUAoIHRMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0B
# CQUxDxcNMjYxMDE1MjIxODAwWjArBgsqhkiG9w0BCRACDDEcMBowGDAWBBRR2ava
# A0lz2E9CZqykgkjms2nEOTAvBgkqhkiG9w0BCQQxIgQgAfmXVhaClHI+022A4Zqj
# Hobd5WaAzRxt4lwIJpRC/ZowNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQgLaCdp/QT
# H5/nLbbF5unJZWdVrwQ/HqdCzA0hIOFB6/wwDQYJKoZIhvcNAQEBBQAEggIAWq8m
# HQe7igI7kfPWRMDuW38nFk3fqWqDhcIgGdVxMHtckho67qnk5FNikqU3ro9tbaFv
# SeY9qYl7tBdd8+AthbRhDfQkXj/q1oQP7B26XrikDR4pbaUFYvBK0G1yDnf93/Yt
# t+/GWF8BlkugH1BKTydDHsFzpMVPWz7QtsaU2K8D1WAv2GeY7GjO1xd9rmrmgz6T
# Ox5+grzosKaAsIOlv5DV6U4CGSGBpamwD0m/v25GlEO7/AwGiQtJJUrZ61rm94es
# Sq4oXgcAT34oB9JoNrU3AU0eOmNSKuh0SE2dzj00qwhRkstGTBdRwsm28HFCQmnB
# LGdm+QKqfFEB7AD+uRZ8FopHUF62NMWHX+AS2Kqlpm5Br6gB+x626rXeGfAZd4Mq
# Y3u9dx8w0kLZiaJHRKkk0pUKXdNhWyj5C8E1Kk0/QPFvtDnn13t7YQOKkOWMKK3J
# gPEYRUH7WjL+cpXWtE9FKt5NIpuDHisMPCw+9D9rwSNjYGYyG/2IVOqokZBcXmcK
# MQVNyVeASZgDhPsvJcGrnIbFjv2ROg4VVkMWCSjsFaKcUPkuS9wpfzmqDE0ZJ0oP
# 6Mp/n1W9VMelpm+kBfH//WrSIm89k6ZPrwvBCILhyj22pbNBLQrFUw1mdFmlYKEL
# Z9DaU5vlDz5x6rphmCuVFOgL6fyjJKEqvRlL1hU=
# SIG # End signature block
