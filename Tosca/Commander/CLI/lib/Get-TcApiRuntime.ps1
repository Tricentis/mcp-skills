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
    foreach ($path in @(
        (Join-Path (Get-RepoRoot) 'tcapi-compatibility.json'),
        (Join-Path (Get-RepoRoot) 'packages/core/reference/tcapi-compatibility.json')
    )) {
        if (Test-Path $path) {
            return Get-Content $path -Raw | ConvertFrom-Json
        }
    }
    throw "TCAPI compatibility manifest not found under $(Get-RepoRoot)"
}

function Read-CommanderVersionFromIdeEnv {
    $userHome = Get-UserProfileRoot
    if (-not $userHome) { return $null }
    $candidates = @(
        (Join-Path $userHome '.tricentis/tcshell-ide.env'),
        (Join-Path $userHome '.tricentis\tcshell-ide.env')
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
# MIIqGAYJKoZIhvcNAQcCoIIqCTCCKgUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAUqwtahqplyHpZ
# ptEhlSmDEuEb1jHlMNMb1YnwzTW7JaCCDt8wggboMIIE0KADAgECAhB3vQ4Ft1kL
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIO1T3Q46A6aUnk3c4OwQYbuE
# ZCnYYBYDTobpU8rRe20PMA0GCSqGSIb3DQEBAQUABIICAAmrFODjofHwqYy4ekUK
# tSg3L6yHE7OSX0n3d1JuH42AdbLOfdhycnKaC85EsEPbiJqJ/vZ2PN+jZMuU6NFl
# Nc+/ZBhLFM7MQGR+0Sohj7ds9qijuW94SlxqKU4uwG5pA+p0pJENgzbL/IZPeRqY
# xo8IdE1ckvm4Ys6OrE1O7irpQJZHfDDALDhrPJkCQTE8xKJ1/Br/qnUd9EjrkXB7
# sKP0KEC8NwOZQ2lmYvMQJJNhqIPV78SwaAXfnZnPAwVc6+pgrj+aJ+F7RQs71w4a
# fLjtSDbrfZsc1/YXA0pyULLprjwQjhONN02QaFtT5186kI4rsg1mseOFyBi55mRr
# permrqxC8ICbNZY1Gy9mk1sSJ/IO+D4Q2AHw1IxEwvhZn+t98FGv7AUAF30Bta84
# OhPCxaOz+ojCQOEBjH4Udeo0BUEZcngN9xFXictCf2fBY0RVZeUic8aqgqJaraXx
# LZvOuv+1b2DbjeW7OCM77Gt6tk5Db4nEh44c65+EQuL1/3cPYs5bufDm7HH361xD
# 2lGjzDJvwO4RYd33Qboi3gbQW4/GRtId4CvSvy6XoSQadeGjxqB4PAlPN0HD1VB4
# TYOHBM1YCBbUQzurqRvJkp2iJ3TnEQucuGwERY0TVAvFFgj3IgD3f9E8oTVMO2bL
# NQ4n1YxQs7en4IHrzFxa8FPFoYIXdjCCF3IGCisGAQQBgjcDAwExghdiMIIXXgYJ
# KoZIhvcNAQcCoIIXTzCCF0sCAQMxDzANBglghkgBZQMEAgEFADB3BgsqhkiG9w0B
# CRABBKBoBGYwZAIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEIBboluta
# f9meAY/w3h2g3RXwAA3RQomMgDT1k5Y8V5GvAhAOMWCEBKFfXhnluzBrqVsAGA8y
# MDI2MTAxNTIyMTc1OFqgghM6MIIG7TCCBNWgAwIBAgIQCE/cM09+RU7bww+P+ZIY
# NTANBgkqhkiG9w0BAQsFADBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNl
# cnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgVGltZVN0YW1w
# aW5nIFJTQTQwOTYgU0hBMjU2IDIwMjUgQ0ExMB4XDTI2MDgwNTAwMDAwMFoXDTM3
# MTEwNDIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMTswOQYDVQQDEzJEaWdpQ2VydCBTSEEyNTYgUlNBNDA5NiBUaW1lc3RhbXAg
# UmVzcG9uZGVyIDIwMjYgMTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# ALZ7pvLJ/s1K+NSbTGWz/TjGMPh8CQ6RucZCLv5anHzWJjF/NWJrFIhy24fcpKXl
# gRiky4WAawDfU3YP0BMxt9l3Dm5oCG5Z69AqEN1kgHg2epx+l+lZBcmJCcN0ASUR
# ML5uFIS80sZsDwO3BSkUxDjLJhBI+qiZP3aixAC/qEGLjsBNlLol9VZ7pfGEXiMl
# neJIC5/YKuizVzNFKZZEeoy/0B8Zm+nzKBgSWG52lCO1w+nCg6XpCtklTJXeIg28
# 3hw7TmmsZXR+SMbjbrEOvZ3fP2VxIgeR28Y90ZStd3F9VuA5RVynb/whITPAo9b7
# 5Zr4Ta6Mj3URm26QZYMn/FnbuTegcoRcFEZ9FOqM5T6MTdtr/n74lIT/ug0eeOzm
# Z6QTFg33otX+bFRsIolvykE1jive4PuESaT8zzVeFWDAMDtozNgLctkGD1ZjkEyZ
# tJrLl5ya0m5doH/ScpaZCZVl6pNUOCybMc/kxC6EAmSJY24L0yYKD1Nkddsnb/It
# VKi/2nXpQNMu1PT5prW83vV8d67WowuUs0HdY4H8AMLGvdL/WHEj3ZnqMqAQQP9u
# 3Ai9t+5eQ02GDwy0ODjdzi0xlp70W+ow63/0++YDEX1M0iwgUHwbrJvfpklkZQvw
# 3+kv3vUPItdwroczk9icflf55W1zOEKAcJVAIXpcMCU9AgMBAAGjggGVMIIBkTAM
# BgNVHRMBAf8EAjAAMB0GA1UdDgQWBBQUyWOKMC7USvtulPPm40B+9ezN4jAfBgNV
# HSMEGDAWgBTvb1NK6eQGfHrK4pBW9i/USezLTjAOBgNVHQ8BAf8EBAMCB4AwFgYD
# VR0lAQH/BAwwCgYIKwYBBQUHAwgwgZUGCCsGAQUFBwEBBIGIMIGFMCQGCCsGAQUF
# BzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wXQYIKwYBBQUHMAKGUWh0dHA6
# Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFRpbWVTdGFt
# cGluZ1JTQTQwOTZTSEEyNTYyMDI1Q0ExLmNydDBfBgNVHR8EWDBWMFSgUqBQhk5o
# dHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRUaW1lU3Rh
# bXBpbmdSU0E0MDk2U0hBMjU2MjAyNUNBMS5jcmwwIAYDVR0gBBkwFzAIBgZngQwB
# BAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQCNxTphHp1SCt+ZrAmA
# fn0oQLFr0mLywSLaDXQIENoyKqxrFbJblzCVP/pkXmwXOdrOpWygLzlT12os5ipD
# Cy35RBCg2UMeApEtrfGhz45F4Wt4WGdNdIbRWt3YTYJmpR+b7lr4d7Uwn+H600u4
# D7RnOGf8Wj4UNgAdZkfHhHv1mx9EVh71SJelcEN/oORSjXzdjfw1iZH9d8Nh/thn
# 6hH23d+VsPAr6GAYyzSA02nXD1nYLI7Ijmiv+xLCiYC41DSFYL3GhTiy0PxpawPt
# GRyaBVGzq+UiTfM8pD7KVyF5aQyWP4KhVGUUTnmm/RlYJoW3TiXA/+t0YcT2oRVB
# m3JETjajHug2AL+v5jhtKVnd3D0rbHXEu27o+Q8p4sEWPMqKDB+qbceb6T/6WcwT
# wXmQ9lOCLLYcsQeSWmvKqzpAec9etE14jOQAzLKWdE3w/TCaKtLRaRT7LCkRYVnh
# A2D73FLje1O5b3HR5eHs0NzU/+xX7NbEdcofy0W3Wdwd1XOqtlpg/JgwtKfZM5dq
# O94lbUveOiJBI+xZEbGRsMNbXmMREUTgu+Oca7Y73MPWcslIx2VhkSKSXjDbD6rg
# g39H5Mh7QfieAIjWagkJNt68Yfim6cjEzVSiLSeZfdkr5dtFPTW6jATlWJdYeeDR
# GCyatf8R1hSjzSvdN8yWQPT9gzCCBrQwggScoAMCAQICEA3HrFcF/yGZLkBDIgw6
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
# NDA5NiBTSEEyNTYgMjAyNSBDQTECEAhP3DNPfkVO28MPj/mSGDUwDQYJYIZIAWUD
# BAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJ
# BTEPFw0yNjEwMTUyMjE3NThaMCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFFHZq9oD
# SXPYT0JmrKSCSOazacQ5MC8GCSqGSIb3DQEJBDEiBCDzbbWXssYMkSGesV8upqD+
# LCjNMAr3av+W/rJqV9zJCzA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCAtoJ2n9BMf
# n+cttsXm6cllZ1WvBD8ep0LMDSEg4UHr/DANBgkqhkiG9w0BAQEFAASCAgAGykmT
# q3OBtvvRRR7YaaeMkPXaLUMak3cZCZlVtLeKc+jRhFpyCgSvTN151GaXujf+D8zR
# 5K4CdDGdzzm/lTFmcXjRpuzNmlvXhFEEwW8mTf4iWUZKySKaMrZjDYJJQ3DMMAV0
# pA38vYFKHrDm+r32I4AzRqMehujbp9DVd1k7pGO05IKHLjV50TtjZ/GJMi3tMjvO
# X4f6JpR8aAe9PnZ66tk5Zg9tY3SVIPX7DzjnjLb9viK/CHL4/wB3U+nJoJvPtoHV
# 2NwRzYgoWFXTUAppUHo+XWR7976J4mtAvcyTT84hv3knYSSa/nNtEGjwzHFYMkI/
# lLse4CEH1ewjr/S4Zc1f9Q25Ddu22t1K299Nd3zO7b2vgHzBenbuRdO3mOlhiiJd
# foSYfPYQpHDvqVZmSJ7bl2c+0rN6z05BS+G4HAKWWnzWREO9YUh3NlfSMP8XNtou
# rRb0ZDT1LBaqX0dc/bgf4vPlp4Z7B6fWru1MKBzWAMI1F6VWa0R9D1+XmwyLW+Ta
# +XLHZvwuxwq1GguuByNZERnNWzFceBxIRqjsCFI2WR+2Pw9Bx8+nKzkTn+GCrF2/
# PDDIbA9/wRUdC+yv5DCBhwdBnOjp6sVKgwqKhe5eb78DNv+WV320TDEItydkfMLr
# Ab56f2OCogZGmN4nwDFX4pCEAQiV2WlHo8dSmw==
# SIG # End signature block
