#Requires -Version 5.1
<#
.SYNOPSIS
  Detect whether TCAPI should run via PowerShell or dotnet script.
.DESCRIPTION
  Dot-source this file, then call Get-TcApiRuntimeInfo.
  Version-aware across Commander 24.1, 24.2, 25.1, 26.1, and master.
#>

. (Join-Path $PSScriptRoot 'IntegrationCommon.ps1')

function Test-CommandAvailable {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Test-DotNetScriptAvailable {
    if (-not (Test-CommandAvailable 'dotnet')) { return $false }
    try {
        $null = & dotnet script --version 2>&1
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

function Get-WindowsPowerShellInfo {
    if (-not $env:WINDIR) {
        return [ordered]@{
            Available  = $false
            Executable = $null
            Version    = $null
            Edition    = 'Desktop'
        }
    }
    $system32 = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
    if ($env:OS -eq 'Windows_NT' -and (Test-Path $system32)) {
        try {
            $version = & $system32 -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>$null
        }
        catch {
            $version = $null
        }
        return [ordered]@{
            Available  = $true
            Executable = $system32
            Version    = ($version | Out-String).Trim()
            Edition    = 'Desktop'
        }
    }
    return [ordered]@{
        Available  = $false
        Executable = $null
        Version    = $null
        Edition    = 'Desktop'
    }
}

function Get-PowerShellRuntimeInfo {
    foreach ($name in @('pwsh', 'powershell')) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) {
            try {
                $version = & $cmd.Source -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>$null
                $edition = & $cmd.Source -NoProfile -Command '$PSVersionTable.PSEdition' 2>$null
            }
            catch {
                $version = $null
                $edition = $null
            }
            return [ordered]@{
                Available  = $true
                Executable = $cmd.Source
                Version    = ($version | Out-String).Trim()
                Edition    = ($edition | Out-String).Trim()
            }
        }
    }
    return [ordered]@{
        Available  = $false
        Executable = $null
        Version    = $null
        Edition    = $null
    }
}

function Get-DotNetScriptRuntimeInfo {
    $available = Test-DotNetScriptAvailable
    $version = $null
    if ($available) {
        try {
            $version = (& dotnet script --version 2>&1 | Out-String).Trim()
        }
        catch {
            $version = $null
        }
    }
    return [ordered]@{
        Available = $available
        Version   = $version
    }
}

function Get-TcApiCompatibilityManifest {
    $path = Join-Path (Get-RepoRoot) 'tcapi-compatibility.json'
    if (-not (Test-Path $path)) {
        throw "TCAPI compatibility manifest not found: $path"
    }
    return Get-Content $path -Raw | ConvertFrom-Json
}

function Read-CommanderVersionFromIdeEnv {
    if (-not $env:USERPROFILE) { return $null }
    $candidates = @(
        (Join-Path $env:USERPROFILE '.tricentis/tcshell-ide.env'),
        (Join-Path $env:USERPROFILE '.tricentis\tcshell-ide.env')
    )
    foreach ($file in $candidates) {
        if (-not (Test-Path $file)) { continue }
        foreach ($line in Get-Content $file) {
            if ($line -match '^COMMANDER_VERSION=(.+)$') {
                return $Matches[1].Trim()
            }
        }
    }
    return $null
}

function Resolve-CommanderVersionForTcApi {
    param(
        [string]$CommanderHome = $env:COMMANDER_HOME,
        [string]$ExplicitVersion = $env:COMMANDER_VERSION
    )
    if ($ExplicitVersion) { return $ExplicitVersion }

    $fromEnv = Read-CommanderVersionFromIdeEnv
    if ($fromEnv) { return $fromEnv }

    if ($CommanderHome) {
        $fromPath = Resolve-CommanderVersionKey -CommanderHome $CommanderHome
        if ($fromPath) { return $fromPath }
    }

    $manifest = Get-TcApiCompatibilityManifest
    return $manifest.defaultVersion
}

function Get-TcApiDllFileInfo {
    param([string]$CommanderHome)
    if (-not $CommanderHome) { return $null }
    $apiPath = Join-Path ($CommanderHome.TrimEnd('\', '/')) 'TCAPI.dll'
    if (-not (Test-Path $apiPath)) { return $null }
    $info = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($apiPath)
    return [ordered]@{
        FileVersion    = $info.FileVersion
        ProductVersion = $info.ProductVersion
        Path           = $apiPath
    }
}

function Get-InstalledDotNetDesktopRuntimes {
    if (-not (Test-CommandAvailable 'dotnet')) { return @() }
    try {
        $lines = & dotnet --list-runtimes 2>$null
    }
    catch {
        return @()
    }
    $desktop = @()
    foreach ($line in $lines) {
        if ($line -match '^Microsoft\.WindowsDesktop\.App\s+(\d+\.\d+)') {
            $desktop += $Matches[1]
        }
    }
    return $desktop | Select-Object -Unique
}

function Test-TcApiDllsPresent {
    param([string]$CommanderHome)
    if (-not $CommanderHome) { return $false }
    $home = $CommanderHome.TrimEnd('\', '/')
    return (Test-Path (Join-Path $home 'TCAPI.dll')) -and (Test-Path (Join-Path $home 'TCAPIObjects.dll'))
}

function Get-TcApiVersionProfile {
    param([string]$VersionKey)
    $manifest = Get-TcApiCompatibilityManifest
    $profile = $manifest.versions.$VersionKey
    if (-not $profile) {
        $profile = $manifest.versions.($manifest.defaultVersion)
        $VersionKey = $manifest.defaultVersion
    }
    return [ordered]@{
        VersionKey           = $VersionKey
        Label                = $profile.label
        TcApiTargets         = @($profile.tcApiTargets)
        DotNetDesktopRuntime = $profile.dotnetDesktopRuntime
        DevCornerDocVersion  = $profile.devCornerDocVersion
        HostGuidance         = $profile.hostGuidance
        DocBaseUrl           = "https://documentation.tricentis.com/devcorner/$($profile.devCornerDocVersion)/tcapi/webindex.html"
    }
}

function Get-RecommendedPowerShellHost {
    param(
        [Parameter(Mandatory)]
        $VersionProfile,
        [Parameter(Mandatory)]
        $PowerShell,
        [Parameter(Mandatory)]
        $WindowsPowerShell
    )
    $targets = @($VersionProfile.TcApiTargets)
    $needsNetFx = $targets -contains 'net48'
    $needsModern = ($targets | Where-Object { $_ -match '^net[89]|^net10' }).Count -gt 0

    if ($needsNetFx -and -not $needsModern) {
        if ($WindowsPowerShell.Available) { return 'windows-powershell' }
        if ($PowerShell.Available -and $PowerShell.Edition -eq 'Desktop') { return 'powershell' }
        return 'windows-powershell'
    }

    if ($needsNetFx -and $needsModern) {
        if ($PowerShell.Available -and $PowerShell.Edition -eq 'Core') { return 'pwsh' }
        if ($WindowsPowerShell.Available) { return 'windows-powershell' }
        if ($PowerShell.Available) { return 'pwsh' }
        return 'windows-powershell'
    }

    if ($PowerShell.Available -and $PowerShell.Edition -eq 'Core') { return 'pwsh' }
    if ($WindowsPowerShell.Available) { return 'windows-powershell' }
    if ($PowerShell.Available) { return 'pwsh' }
    return 'none'
}

function Resolve-TcApiExecutionMode {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Runtime,
        [ValidateSet('Auto', 'PowerShell', 'DotNetScript')]
        [string]$Prefer = 'Auto',
        [string]$ScriptPath
    )

    if ($Prefer -eq 'PowerShell') {
        if (-not $Runtime.PowerShell.Available -and -not $Runtime.WindowsPowerShell.Available) {
            throw 'PowerShell requested but not found on PATH.'
        }
        return 'PowerShell'
    }
    if ($Prefer -eq 'DotNetScript') {
        if (-not $Runtime.DotNetScript.Available) {
            throw 'dotnet script requested but not available. Run: dotnet tool install -g dotnet-script'
        }
        if (-not $Runtime.DotNetDesktopRuntimeInstalled) {
            throw "dotnet script requires Microsoft.WindowsDesktop.App $($Runtime.VersionProfile.DotNetDesktopRuntime)."
        }
        return 'DotNetScript'
    }

    if ($ScriptPath) {
        $ext = [System.IO.Path]::GetExtension($ScriptPath).ToLowerInvariant()
        if ($ext -eq '.csx') {
            if ($Runtime.DotNetScript.Available -and $Runtime.DotNetDesktopRuntimeInstalled) { return 'DotNetScript' }
            throw "Script is .csx but dotnet script or .NET $($Runtime.VersionProfile.DotNetDesktopRuntime) desktop runtime is missing."
        }
        if ($ext -eq '.ps1' -and ($Runtime.PowerShell.Available -or $Runtime.WindowsPowerShell.Available)) {
            return 'PowerShell'
        }
    }

    if ($Runtime.RecommendedMode -eq 'powershell') { return 'PowerShell' }
    if ($Runtime.RecommendedMode -eq 'dotnet-script') { return 'DotNetScript' }
    throw $Runtime.Reason
}

function Get-TcApiRuntimeInfo {
    param(
        [string]$CommanderHome = $env:COMMANDER_HOME,
        [string]$CommanderVersion
    )

    $onWindows = $IsWindows
    if (-not $onWindows -and $env:OS -eq 'Windows_NT') { $onWindows = $true }

    $ps = Get-PowerShellRuntimeInfo
    $winPs = Get-WindowsPowerShellInfo
    $dotnetScript = Get-DotNetScriptRuntimeInfo
    $dllsPresent = Test-TcApiDllsPresent -CommanderHome $CommanderHome
    $versionKey = Resolve-CommanderVersionForTcApi -CommanderHome $CommanderHome -ExplicitVersion $CommanderVersion
    $versionProfile = Get-TcApiVersionProfile -VersionKey $versionKey
    $dllInfo = Get-TcApiDllFileInfo -CommanderHome $CommanderHome
    $installedRuntimes = Get-InstalledDotNetDesktopRuntimes
    $requiredRuntime = [string]$versionProfile.DotNetDesktopRuntime
    $desktopRuntimeInstalled = $installedRuntimes -contains $requiredRuntime
    $recommendedPsHost = Get-RecommendedPowerShellHost -VersionProfile $versionProfile -PowerShell $ps -WindowsPowerShell $winPs

    $recommended = 'none'
    $reason = ''

    if (-not $onWindows) {
        $reason = 'TCAPI requires Windows and a local Commander install.'
    }
    elseif (-not $dllsPresent) {
        $reason = 'Set COMMANDER_HOME to the folder containing TCAPI.dll and TCAPIObjects.dll.'
    }
    elseif ($recommendedPsHost -ne 'none' -and ($ps.Available -or $winPs.Available)) {
        $recommended = 'powershell'
        $reason = "Commander $versionKey ($($versionProfile.Label)): use $recommendedPsHost to load TCAPI.dll. $($versionProfile.HostGuidance)"
    }
    elseif ($dotnetScript.Available -and $desktopRuntimeInstalled) {
        $recommended = 'dotnet-script'
        $reason = "Commander ${versionKey}: use dotnet script with .NET $requiredRuntime desktop runtime."
    }
    elseif ($dotnetScript.Available -and -not $desktopRuntimeInstalled) {
        $reason = "Install .NET $requiredRuntime Windows desktop runtime for Commander $versionKey (dotnet --list-runtimes)."
    }
    elseif (Test-CommandAvailable 'dotnet') {
        $reason = "Install dotnet-script and .NET $requiredRuntime desktop runtime for Commander $versionKey."
    }
    else {
        $reason = 'Need PowerShell or dotnet SDK + dotnet-script on PATH.'
    }

    return [ordered]@{
        IsWindows                      = $onWindows
        CommanderHome                  = $CommanderHome
        CommanderVersion               = $versionKey
        VersionProfile                 = $versionProfile
        TcApiDllsPresent               = $dllsPresent
        TcApiDllInfo                   = $dllInfo
        InstalledDotNetDesktopRuntimes = @($installedRuntimes)
        DotNetDesktopRuntimeInstalled  = $desktopRuntimeInstalled
        PowerShell                     = $ps
        WindowsPowerShell              = $winPs
        RecommendedPowerShellHost      = $recommendedPsHost
        DotNetScript                   = $dotnetScript
        RecommendedMode                = $recommended
        Reason                         = $reason
    }
}

function Initialize-TcApiCsx {
    param(
        [Parameter(Mandatory)]
        [string]$CsxPath,
        [string]$CommanderHome = $env:COMMANDER_HOME
    )
    if (-not $CommanderHome) { throw 'COMMANDER_HOME required for .csx execution' }
    $home = $CommanderHome.TrimEnd('\', '/')
    $content = Get-Content -Path $CsxPath -Raw -Encoding UTF8
    $objects = Join-Path $home 'TCAPIObjects.dll'
    $api = Join-Path $home 'TCAPI.dll'
    $content = $content -replace '#r\s+"[^"]*TCAPIObjects\.dll"', "#r `"$objects`""
    $content = $content -replace '#r\s+"[^"]*\\TCAPI\.dll"', "#r `"$api`""
    $temp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "tcapi-$(New-Guid).csx")
    Set-Content -Path $temp -Value $content -Encoding UTF8
    return $temp
}

function Invoke-TcApiDotNetScript {
    param(
        [Parameter(Mandatory)]
        [string]$CsxPath,
        [string]$CommanderHome = $env:COMMANDER_HOME,
        [string[]]$Arguments = @()
    )
    if (-not (Test-DotNetScriptAvailable)) {
        throw 'dotnet script not available. Run: dotnet tool install -g dotnet-script'
    }
    $env:COMMANDER_HOME = $CommanderHome
    $prepared = Initialize-TcApiCsx -CsxPath $CsxPath -CommanderHome $CommanderHome
    try {
        & dotnet script $prepared @Arguments
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    finally {
        Remove-Item -Path $prepared -Force -ErrorAction SilentlyContinue
    }
}

function Resolve-TcApiPowerShellExecutable {
    param(
        [Parameter(Mandatory)]
        $Runtime
    )
    switch ($Runtime.RecommendedPowerShellHost) {
        'windows-powershell' {
            if ($Runtime.WindowsPowerShell.Available) { return $Runtime.WindowsPowerShell.Executable }
        }
        'pwsh' {
            if ($Runtime.PowerShell.Available -and $Runtime.PowerShell.Edition -eq 'Core') {
                return $Runtime.PowerShell.Executable
            }
        }
    }
    if ($Runtime.PowerShell.Available) { return $Runtime.PowerShell.Executable }
    if ($Runtime.WindowsPowerShell.Available) { return $Runtime.WindowsPowerShell.Executable }
    return $null
}

function Test-ShouldReLaunchTcApiInRecommendedHost {
    param(
        [Parameter(Mandatory)]
        $Runtime
    )
    if ($Runtime.RecommendedPowerShellHost -eq 'windows-powershell') {
        return $PSVersionTable.PSEdition -eq 'Core' -and $Runtime.WindowsPowerShell.Available
    }
    if ($Runtime.RecommendedPowerShellHost -eq 'pwsh') {
        return $PSVersionTable.PSEdition -eq 'Desktop' -and $Runtime.PowerShell.Available -and $Runtime.PowerShell.Edition -eq 'Core'
    }
    return $false
}

function Invoke-TcApiInRecommendedHost {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptPath,
        [Parameter(Mandatory)]
        $Runtime,
        [hashtable]$BoundParameters
    )
    $exe = Resolve-TcApiPowerShellExecutable -Runtime $Runtime
    if (-not $exe) { throw 'No suitable PowerShell host found for this Commander version.' }

    $argList = @('-NoProfile', '-File', $ScriptPath)
    foreach ($key in $BoundParameters.Keys) {
        if ($key -in @('DetectOnly', 'Prefer')) { continue }
        $val = $BoundParameters[$key]
        if ($val -is [switch]) {
            if ($val) { $argList += "-$key" }
        }
        elseif ($null -ne $val -and "$val" -ne '') {
            $argList += "-$key"
            $argList += "$val"
        }
    }
    & $exe @argList
    exit $LASTEXITCODE
}

# SIG # Begin signature block
# MIIqGQYJKoZIhvcNAQcCoIIqCjCCKgYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA96mDyJxHj7flj
# pgmT5YUE+J6P3PEfFLtIwbfbH0hEnKCCDt8wggboMIIE0KADAgECAhB3vQ4Ft1kL
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIA1iCxzgaAzn+On4aqNZRTuB
# 1rBFG2pVkNJ+BrEn89nsMA0GCSqGSIb3DQEBAQUABIICALhrNkC/vn267pZ2mzH/
# n9Si/nfGgw86z34l1MsY2bonCCEEVNb+wBdNihTzrKPEKuroyQLgBGEDzXsnw3vj
# N6ZMfhRlaezSTxGcyNSwpTJtE0ZbylyJgyN0Rv890zlnnVvBD0E3/NkngTWTVGYg
# Qt2yXQb2hrgieDWJPAgNrcaQ96UXa/01/UHyQ6pN5p3ZHX9bTC7OSCz0iMJZ18t7
# TgwI5io/sdaeMO+SpSxmxNKzwa5ggDNo39wqCtO/vIjLXg3M34+RkN1SfxVwX07/
# +jnnUWdZCWIJsmSZjRxK0qPJkcvTzFH6ViUOyqG7dGlssclh71+IKaZcQXP3vUvo
# zpwZPzkTELW7lrjF80hB1iZIqZMF/fzzgDADUCREk21c+lzIHczfRVlMz7J5wUdt
# prCIod1ZUg5rC8LCyocpC7reoTFy6DHalBh0lAvX+PZMYbUcGxL15xvfGWstiNym
# JFPxuDG4fVgBHxOSYWa1Jw8WzOSc7R7Uf8hj8smfk958y6bVj77vReMC2UFV4nWO
# IfFHm5g1Z/3e0mdXiv406FdsOwfCMTLUYLbNixCZn3fdLZssMJL0BPETn0nn5BnK
# eEKte668do8I62wFE8Fl4LnvPHCVac50FAQS9GYuQt48a9wbDj01D8FiwrHgKcT6
# VqCPS+vWS2PBDQOI0biQDHmkoYIXdzCCF3MGCisGAQQBgjcDAwExghdjMIIXXwYJ
# KoZIhvcNAQcCoIIXUDCCF0wCAQMxDzANBglghkgBZQMEAgEFADB4BgsqhkiG9w0B
# CRABBKBpBGcwZQIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEICuepH2q
# Xyl3q9d/WZgisF/hv4l43exa2Dky7OR58T9xAhEAgOJvhNOACmSgURjWgJMEXRgP
# MjAyNjA3MzAyMTAyMTRaoIITOjCCBu0wggTVoAMCAQICEAqA7xhLjfEFgtHEdqeV
# dGgwDQYJKoZIhvcNAQELBQAwaTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lD
# ZXJ0LCBJbmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IFRpbWVTdGFt
# cGluZyBSU0E0MDk2IFNIQTI1NiAyMDI1IENBMTAeFw0yNTA2MDQwMDAwMDBaFw0z
# NjA5MDMyMzU5NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgU0hBMjU2IFJTQTQwOTYgVGltZXN0YW1w
# IFJlc3BvbmRlciAyMDI1IDEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDQRqwtEsae0OquYFazK1e6b1H/hnAKAd/KN8wZQjBjMqiZ3xTWcfsLwOvRxUwX
# cGx8AUjni6bz52fGTfr6PHRNv6T7zsf1Y/E3IU8kgNkeECqVQ+3bzWYesFtkepEr
# vUSbf+EIYLkrLKd6qJnuzK8Vcn0DvbDMemQFoxQ2Dsw4vEjoT1FpS54dNApZfKY6
# 1HAldytxNM89PZXUP/5wWWURK+IfxiOg8W9lKMqzdIo7VA1R0V3Zp3DjjANwqAf4
# lEkTlCDQ0/fKJLKLkzGBTpx6EYevvOi7XOc4zyh1uSqgr6UnbksIcFJqLbkIXIPb
# cNmA98Oskkkrvt6lPAw/p4oDSRZreiwB7x9ykrjS6GS3NR39iTTFS+ENTqW8m6TH
# uOmHHjQNC3zbJ6nJ6SXiLSvw4Smz8U07hqF+8CTXaETkVWz0dVVZw7knh1WZXOLH
# gDvundrAtuvz0D3T+dYaNcwafsVCGZKUhQPL1naFKBy1p6llN3QgshRta6Eq4B40
# h5avMcpi54wm0i2ePZD5pPIssoszQyF4//3DoK2O65Uck5Wggn8O2klETsJ7u8xE
# ehGifgJYi+6I03UuT1j7FnrqVrOzaQoVJOeeStPeldYRNMmSF3voIgMFtNGh86w3
# ISHNm0IaadCKCkUe2LnwJKa8TIlwCUNVwppwn4D3/Pt5pwIDAQABo4IBlTCCAZEw
# DAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQU5Dv88jHt/f3X85FxYxlQQ89hjOgwHwYD
# VR0jBBgwFoAU729TSunkBnx6yuKQVvYv1Ensy04wDgYDVR0PAQH/BAQDAgeAMBYG
# A1UdJQEB/wQMMAoGCCsGAQUFBwMIMIGVBggrBgEFBQcBAQSBiDCBhTAkBggrBgEF
# BQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMF0GCCsGAQUFBzAChlFodHRw
# Oi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRUaW1lU3Rh
# bXBpbmdSU0E0MDk2U0hBMjU2MjAyNUNBMS5jcnQwXwYDVR0fBFgwVjBUoFKgUIZO
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0VGltZVN0
# YW1waW5nUlNBNDA5NlNIQTI1NjIwMjVDQTEuY3JsMCAGA1UdIAQZMBcwCAYGZ4EM
# AQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAZSqt8RwnBLmuYEHs
# 0QhEnmNAciH45PYiT9s1i6UKtW+FERp8FgXRGQ/YAavXzWjZhY+hIfP2JkQ38U+w
# tJPBVBajYfrbIYG+Dui4I4PCvHpQuPqFgqp1PzC/ZRX4pvP/ciZmUnthfAEP1HSh
# TrY+2DE5qjzvZs7JIIgt0GCFD9ktx0LxxtRQ7vllKluHWiKk6FxRPyUPxAAYH2Vy
# 1lNM4kzekd8oEARzFAWgeW3az2xejEWLNN4eKGxDJ8WDl/FQUSntbjZ80FU3i54t
# px5F/0Kr15zW/mJAxZMVBrTE2oi0fcI8VMbtoRAmaaslNXdCG1+lqvP4FbrQ6IwS
# BXkZagHLhFU9HCrG/syTRLLhAezu/3Lr00GrJzPQFnCEH1Y58678IgmfORBPC1JK
# kYaEt2OdDh4GmO0/5cHelAK2/gTlQJINqDr6JfwyYHXSd+V08X1JUPvB4ILfJdmL
# +66Gp3CSBXG6IwXMZUXBhtCyIaehr0XkBoDIGMUG1dUtwq1qmcwbdUfcSYCn+Own
# cVUXf53VJUNOaMWMts0VlRYxe5nK+At+DI96HAlXHAL5SlfYxJ7La54i71McVWRP
# 66bW+yERNpbJCjyCYG2j+bdpxo/1Cy4uPcU3AWVPGrbn5PhDBf3Froguzzhk++am
# i+r3Qrx5bIbY3TVzgiFI7Gq3zWcwgga0MIIEnKADAgECAhANx6xXBf8hmS5AQyIM
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
# QTQwOTYgU0hBMjU2IDIwMjUgQ0ExAhAKgO8YS43xBYLRxHanlXRoMA0GCWCGSAFl
# AwQCAQUAoIHRMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0B
# CQUxDxcNMjYwNzMwMjEwMjE0WjArBgsqhkiG9w0BCRACDDEcMBowGDAWBBTdYjCs
# hgotMGvaOLFoeVIwB/tBfjAvBgkqhkiG9w0BCQQxIgQgZlaOR2yqV/FEO6XVfQ+S
# RCEeAYOz71kgUNBwawLlUb0wNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQgSqA/oizX
# XITFXJOPgo5na5yuyrM/420mmqM08UYRCjMwDQYJKoZIhvcNAQEBBQAEggIAdFhy
# zlHp9ABeBMFn3CS6iBKjQon7Ww3BhiUknPgVrfBDGTWGHr/IFfxmXeKh1kMzE1jH
# HNvt3sNz3nOi6A3tCQe/Sn1MM92AZm/512DVG70EXkaxoJOZdsld+kvwFGJXJZ74
# oMzBRSA3PUV2xJbELu46Nc2yvIYmioAzMMrUVnk9D3SMGk9tk6LWLz5CNotMX38Y
# 1bkQth8wmQPZohz9v3rj9vPAgU9ZWil0xQGk0GR/El8gTojrs0pm4oj+9O9898Zw
# W1ZhKwdlJ4+1L8yrXPvzqKz8YzyXDlvHjJVMwswRP6fZcENm3sP+IDT4phlefZjo
# cMazZAUYXOw5HIjh4bq1OEq0i1I8WHqCYyVuxcaf07AvKbUEMhGGaWDzHw/uwdBc
# fyJmWoPqKepfP0VzHE3UeQBEfpk4ef7hG+HigSkZ5Dl/DJxQ3XF5JonP8ALe+jJs
# wwaYh5VtR+B1yadD+om11IIUoFbIhJCUkkJ286RHzbAWWQVrNN2tPgYtfGx7qzja
# XZX6pLAq0GWuMNoTn1WMrESmubQdGCPCwGcXN6/MPa4JXqnIiH8juv+m27ajiaWY
# Ef6utxa5EhNCZ3mss/Jl1zTY8wBFJ56Nw25+JbM92TG+sM1gwOsQwyaaZr8+AwlH
# 8jEnXPSsTXePLn7BgR/dLnIaUEQTSPVnvFpQ0/4=
# SIG # End signature block
