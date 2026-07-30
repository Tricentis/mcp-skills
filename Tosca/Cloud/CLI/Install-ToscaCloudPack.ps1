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

# SIG # Begin signature block
# MIIqGAYJKoZIhvcNAQcCoIIqCTCCKgUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDdUHZFwJR4qOWU
# qFzLIkJ/yPkSp6ZRUNB1k9Rb+dF7tqCCDt8wggboMIIE0KADAgECAhB3vQ4Ft1kL
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
# +pqBNXtA2qQ0W8dyw0VBDJu4hOqp/xNnrgcBrm37WoxMZ10YDyA2nHkxghqPMIIa
# iwIBATBsMFwxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNh
# MTIwMAYDVQQDEylHbG9iYWxTaWduIEdDQyBSNDUgRVYgQ29kZVNpZ25pbmcgQ0Eg
# MjAyMAIMDYkOSCK3QR2bFmhSMA0GCWCGSAFlAwQCAQUAoHwwEAYKKwYBBAGCNwIB
# DDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIMrmcfpeVeyCNzjl8vL8Fnuf
# OQKS89/3XwmDxVAbpIKnMA0GCSqGSIb3DQEBAQUABIICAHH5AB0Tl5O2M3sdSaAu
# 0PJBNxAC40UtfVYJJihfOkxOIkVF1UFzpEFyleTcvB0XFJTXr23GrKwXd0CpNQAC
# CF3YgH5a02SSr6l4r0enR/u/FhFZdxvYS/fsudVvCL5WwAP8TJAiRkdG+cgJZmzZ
# UDZ6kkAoT/TuJVUCrRROXyw3xn7Rc2BCl6ENasddB0ExIhc1eE3itqDCrJ4uT+A6
# zNCLJz32z23pvSdEJyU23JWXLbn+d4wK4ccJEcpRbLD8dpHo9WTKmrjd8zTuCGtp
# 6U4GhmtblwMjGWzVbWk1E7C7jNIoC54N0Lx2AIbwg16ttiBdlCYylaK/uo1j9UfO
# CoSxykHLjMWP3shC/y2PVUgaJybnJ28x9iADOG7mGrxbNk27i4epw2J8Cuse2XFh
# r6sxPioxmonGZlYKUGfe0A/VcwC27rlpbTLa+ulEWBjOsZKcEiiVFCA9Wu4uVHY2
# 0of70IljpnLX978khYaCn5WrolJR8DK0RHu5XsX+YY8gVLuE7d1KFTGgRd19Onfa
# KCjS09+g1Bxb4GwSEOXr9ogvlJxQvSFGSIOr5Ezh6zfWm65ujd6/9dWpqUxjcBTX
# heerfO5XRyd/81jRWQ/dYi+xNq8F93k9vD+0ncNYbe1UB3GeLpFvb6UgWBa05P01
# v1kccJkSpKTdYUquXLhOwi+roYIXdjCCF3IGCisGAQQBgjcDAwExghdiMIIXXgYJ
# KoZIhvcNAQcCoIIXTzCCF0sCAQMxDzANBglghkgBZQMEAgEFADB3BgsqhkiG9w0B
# CRABBKBoBGYwZAIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEIMGi+Uhd
# b42HO/DNKN0f04BElYRLf/TkOqTT8e9y3f6UAhBhZgA4mApAi/tHakKghdNtGA8y
# MDI2MDczMDE4MDIxNFqgghM6MIIG7TCCBNWgAwIBAgIQCoDvGEuN8QWC0cR2p5V0
# aDANBgkqhkiG9w0BAQsFADBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNl
# cnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgVGltZVN0YW1w
# aW5nIFJTQTQwOTYgU0hBMjU2IDIwMjUgQ0ExMB4XDTI1MDYwNDAwMDAwMFoXDTM2
# MDkwMzIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMTswOQYDVQQDEzJEaWdpQ2VydCBTSEEyNTYgUlNBNDA5NiBUaW1lc3RhbXAg
# UmVzcG9uZGVyIDIwMjUgMTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# ANBGrC0Sxp7Q6q5gVrMrV7pvUf+GcAoB38o3zBlCMGMyqJnfFNZx+wvA69HFTBdw
# bHwBSOeLpvPnZ8ZN+vo8dE2/pPvOx/Vj8TchTySA2R4QKpVD7dvNZh6wW2R6kSu9
# RJt/4QhguSssp3qome7MrxVyfQO9sMx6ZAWjFDYOzDi8SOhPUWlLnh00Cll8pjrU
# cCV3K3E0zz09ldQ//nBZZREr4h/GI6Dxb2UoyrN0ijtUDVHRXdmncOOMA3CoB/iU
# SROUINDT98oksouTMYFOnHoRh6+86Ltc5zjPKHW5KqCvpSduSwhwUmotuQhcg9tw
# 2YD3w6ySSSu+3qU8DD+nigNJFmt6LAHvH3KSuNLoZLc1Hf2JNMVL4Q1OpbybpMe4
# 6YceNA0LfNsnqcnpJeItK/DhKbPxTTuGoX7wJNdoRORVbPR1VVnDuSeHVZlc4seA
# O+6d2sC26/PQPdP51ho1zBp+xUIZkpSFA8vWdoUoHLWnqWU3dCCyFG1roSrgHjSH
# lq8xymLnjCbSLZ49kPmk8iyyizNDIXj//cOgrY7rlRyTlaCCfw7aSUROwnu7zER6
# EaJ+AliL7ojTdS5PWPsWeupWs7NpChUk555K096V1hE0yZIXe+giAwW00aHzrDch
# Ic2bQhpp0IoKRR7YufAkprxMiXAJQ1XCmnCfgPf8+3mnAgMBAAGjggGVMIIBkTAM
# BgNVHRMBAf8EAjAAMB0GA1UdDgQWBBTkO/zyMe39/dfzkXFjGVBDz2GM6DAfBgNV
# HSMEGDAWgBTvb1NK6eQGfHrK4pBW9i/USezLTjAOBgNVHQ8BAf8EBAMCB4AwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwgZUGCCsGAQUFBwEBBIGIMIGFMCQGCCsGAQUF
# BzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wXQYIKwYBBQUHMAKGUWh0dHA6
# Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFRpbWVTdGFt
# cGluZ1JTQTQwOTZTSEEyNTYyMDI1Q0ExLmNydDBfBgNVHR8EWDBWMFSgUqBQhk5o
# dHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRUaW1lU3Rh
# bXBpbmdSU0E0MDk2U0hBMjU2MjAyNUNBMS5jcmwwIAYDVR0gBBkwFzAIBgZngQwB
# BAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQBlKq3xHCcEua5gQezR
# CESeY0ByIfjk9iJP2zWLpQq1b4URGnwWBdEZD9gBq9fNaNmFj6Eh8/YmRDfxT7C0
# k8FUFqNh+tshgb4O6Lgjg8K8elC4+oWCqnU/ML9lFfim8/9yJmZSe2F8AQ/UdKFO
# tj7YMTmqPO9mzskgiC3QYIUP2S3HQvHG1FDu+WUqW4daIqToXFE/JQ/EABgfZXLW
# U0ziTN6R3ygQBHMUBaB5bdrPbF6MRYs03h4obEMnxYOX8VBRKe1uNnzQVTeLni2n
# HkX/QqvXnNb+YkDFkxUGtMTaiLR9wjxUxu2hECZpqyU1d0IbX6Wq8/gVutDojBIF
# eRlqAcuEVT0cKsb+zJNEsuEB7O7/cuvTQasnM9AWcIQfVjnzrvwiCZ85EE8LUkqR
# hoS3Y50OHgaY7T/lwd6UArb+BOVAkg2oOvol/DJgddJ35XTxfUlQ+8Hggt8l2Yv7
# roancJIFcbojBcxlRcGG0LIhp6GvReQGgMgYxQbV1S3CrWqZzBt1R9xJgKf47Cdx
# VRd/ndUlQ05oxYy2zRWVFjF7mcr4C34Mj3ocCVccAvlKV9jEnstrniLvUxxVZE/r
# ptb7IRE2lskKPIJgbaP5t2nGj/ULLi49xTcBZU8atufk+EMF/cWuiC7POGT75qaL
# 6vdCvHlshtjdNXOCIUjsarfNZzCCBrQwggScoAMCAQICEA3HrFcF/yGZLkBDIgw6
# SYYwDQYJKoZIhvcNAQELBQAwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGln
# aUNlcnQgVHJ1c3RlZCBSb290IEc0MB4XDTI1MDUwNzAwMDAwMFoXDTM4MDExNDIz
# NTk1OVowaTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEw
# PwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IFRpbWVTdGFtcGluZyBSU0E0MDk2
# IFNIQTI1NiAyMDI1IENBMTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# ALR4MdMKmEFyvjxGwBysddujRmh0tFEXnU2tjQ2UtZmWgyxU7UNqEY81FzJsQqr5
# G7A6c+Gh/qm8Xi4aPCOo2N8S9SLrC6Kbltqn7SWCWgzbNfiR+2fkHUiljNOqnIVD
# /gG3SYDEAd4dg2dDGpeZGKe+42DFUF0mR/vtLa4+gKPsYfwEu7EEbkC9+0F2w4QJ
# LVSTEG8yAR2CQWIM1iI5PHg62IVwxKSpO0XaF9DPfNBKS7Zazch8NF5vp7eaZ2CV
# NxpqumzTCNSOxm+SAWSuIr21Qomb+zzQWKhxKTVVgtmUPAW35xUUFREmDrMxSNlr
# /NsJyUXzdtFUUt4aS4CEeIY8y9IaaGBpPNXKFifinT7zL2gdFpBP9qh8SdLnEut/
# GcalNeJQ55IuwnKCgs+nrpuQNfVmUB5KlCX3ZA4x5HHKS+rqBvKWxdCyQEEGcbLe
# 1b8Aw4wJkhU1JrPsFfxW1gaou30yZ46t4Y9F20HHfIY4/6vHespYMQmUiote8lad
# jS/nJ0+k6MvqzfpzPDOy5y6gqztiT96Fv/9bH7mQyogxG9QEPHrPV6/7umw052Ak
# yiLA6tQbZl1KhBtTasySkuJDpsZGKdlsjg4u70EwgWbVRSX1Wd4+zoFpp4Ra+MlK
# M2baoD6x0VR4RjSpWM8o5a6D8bpfm4CLKczsG7ZrIGNTAgMBAAGjggFdMIIBWTAS
# BgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBTvb1NK6eQGfHrK4pBW9i/USezL
# TjAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMC
# AYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUF
# BzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6
# Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3J0
# MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCG
# SAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAF877FoAc/gc9EXZxML2+C8i1NKZ/
# zdCHxYgaMH9Pw5tcBnPw6O6FTGNpoV2V4wzSUGvI9NAzaoQk97frPBtIj+ZLzdp+
# yXdhOP4hCFATuNT+ReOPK0mCefSG+tXqGpYZ3essBS3q8nL2UwM+NMvEuBd/2vmd
# YxDCvwzJv2sRUoKEfJ+nN57mQfQXwcAEGCvRR2qKtntujB71WPYAgwPyWLKu6Rna
# ID/B0ba2H3LUiwDRAXx1Neq9ydOal95CHfmTnM4I+ZI2rVQfjXQA1WSjjf4J2a7j
# LzWGNqNX+DF0SQzHU0pTi4dBwp9nEC8EAqoxW6q17r0z0noDjs6+BFo+z7bKSBwZ
# XTRNivYuve3L2oiKNqetRHdqfMTCW/NmKLJ9M+MtucVGyOxiDf06VXxyKkOirv6o
# 02OoXN4bFzK0vlNMsvhlqgF2puE6FndlENSmE+9JGYxOGLS/D284NHNboDGcmWXf
# wXRy4kbu4QFhOm0xJuF2EZAOk5eCkhSxZON3rGlHqhpB/8MluDezooIs8CVnrpHM
# iD2wL40mm53+/j7tFaxYKIqL0Q4ssd8xHZnIn/7GELH3IdvG2XlM9q7WP/UwgOkw
# /HQtyRN62JK4S1C8uw3PdBunvAZapsiI5YKdvlarEvf8EA+8hcpSM9LHJmyrxaFt
# oza2zNaQ9k+5t1wwggWNMIIEdaADAgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqG
# SIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFz
# c3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTla
# MGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsT
# EHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9v
# dCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8
# MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauy
# efLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKyunWZanMylNEQRBAu34Lz
# B4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+x
# embud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhA
# kHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1Lyu
# GwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2
# PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37A
# lLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD7
# 6GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5SUUd0viastkF13nqsX40/
# ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXA
# j6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTAD
# AQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF
# 66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEE
# bTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYB
# BQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3Vy
# ZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDARBgNVHSAECjAI
# MAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0NcVec4X6CjdBs9thbX979X
# B72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnovLbc47/T/gLn4offyct4k
# vFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU
# 53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pc
# VIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5v
# Iy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQxggN8
# MIIDeAIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNB
# NDA5NiBTSEEyNTYgMjAyNSBDQTECEAqA7xhLjfEFgtHEdqeVdGgwDQYJYIZIAWUD
# BAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJ
# BTEPFw0yNjA3MzAxODAyMTRaMCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFN1iMKyG
# Ci0wa9o4sWh5UjAH+0F+MC8GCSqGSIb3DQEJBDEiBCA2PsOdpmrnXGCR/r7kgaW4
# AJTmiBZlNJzTn7hwqd9l0zA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCBKoD+iLNdc
# hMVck4+CjmdrnK7Ksz/jbSaaozTxRhEKMzANBgkqhkiG9w0BAQEFAASCAgDLf1pq
# rVnhcMYIJHes1zCLFaF35lwzPOLNA5+rDF36Jp7B3ZdpeWIgZYHsLa5WXp+0MsoE
# qLFuJP3q4eJRJOccvCUSFiL6KI5sOHjLwe7vHt4HG9MiObY/f5PFPlNvCtcN6Y2W
# TkvLaogT/gfaRB/gDZOH5YLnlBlN69z+NjyEphabMOyi8DTYFPD/ITuH7XnyPYWW
# HQ6Ty+pK9yhB1x7Ua+8rpOeexTtFbSgIwzqslNwgY+bJuled12Ju5CKLgEHzVvZK
# balWiYJf/6RYkagAZLir2oZR64pnVns+m21HxT3MXkN3dcQyNcSkdhptxEkzAL6R
# GDVN6fLEmJWk13IPLp7IdkcE+WDjqd9+6I2Faf2W9SNdWSar9/FfR4jH0dvu082D
# AWZfVbqxmIi48Zb2NpT5ssVlORkDw8PKE/FUOJ6ZO83J+/YY/at47j2mV+MSdfNr
# QKpLNJkKLgWCPCPCaFk8MpwvUfMgpvkx1hAtB7IuVrwQKZUqJ9MhZj8zSfCKWkGf
# XSQsgFWNF63+tKs0X+zcy/YKxhqPVY+MHCpSM7D/roJCAICVjl71T41pKM3Ky99k
# Yr4OC4FjCShhCnMZ42isuRy+C6RX9i8lLeUZMZIZ3ZjuOIuIA0UdVnWHge+G/v2y
# hBYJD4cvZS2YR5/kr3nHCUbVKznR1V9oOD4cJA==
# SIG # End signature block
