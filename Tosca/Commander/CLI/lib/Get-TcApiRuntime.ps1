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
    $path = Join-Path (Get-RepoRoot) 'packages/core/reference/tcapi-compatibility.json'
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
