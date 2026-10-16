#Requires -Version 5.1
<#
.SYNOPSIS
  Detect available Commander automation paths and recommend the best one.
.DESCRIPTION
  Dot-source this file, then call Get-CommanderAutomationPaths or
  Select-CommanderAutomationPath. Used by IDE agents before automation.
#>

. (Join-Path $PSScriptRoot 'IntegrationCommon.ps1')
. (Join-Path $PSScriptRoot 'Get-TcApiRuntime.ps1')
. (Join-Path $PSScriptRoot 'TcShellRemoteControl.ps1')

function Read-CliApiCommanderEnv {
    $result = [ordered]@{}
    $userHome = Get-UserProfileRoot
    if (-not $userHome) { return $result }
    $candidates = @(
        (Join-Path $userHome '.tricentis/tcshell-ide.env'),
        (Join-Path $userHome '.tricentis\tcshell-ide.env')
    )
    foreach ($file in $candidates) {
        if (-not (Test-Path $file)) { continue }
        foreach ($line in Get-Content $file) {
            if ($line -match '^COMMANDER_HOME=(.+)$') { $result['CommanderHome'] = $Matches[1].Trim() }
            if ($line -match '^COMMANDER_VERSION=(.+)$') { $result['CommanderVersion'] = $Matches[1].Trim() }
            if ($line -match '^TOSCA_WORKSPACE=(.+)$') { $result['Workspace'] = $Matches[1].Trim() }
        }
    }
    return $result
}

function Resolve-CommanderHomePath {
    param(
        [string]$CommanderHome = $env:COMMANDER_HOME,
        [string[]]$ExtraCandidates = @()
    )
    if ($CommanderHome -and (Test-Path $CommanderHome)) {
        return $CommanderHome.TrimEnd('\', '/')
    }

    $ideEnv = Read-CliApiCommanderEnv
    if ($ideEnv.CommanderHome -and (Test-Path $ideEnv.CommanderHome)) {
        return $ideEnv.CommanderHome.TrimEnd('\', '/')
    }

    $candidates = @($ExtraCandidates)
    if ($env:ProgramFiles) {
        $candidates += Get-ChildItem -Path (Join-Path $env:ProgramFiles 'Tricentis') -Directory -ErrorAction SilentlyContinue |
            ForEach-Object { $_.FullName }
    }
    if (${env:ProgramFiles(x86)}) {
        $candidates += Get-ChildItem -Path (Join-Path ${env:ProgramFiles(x86)} 'Tricentis') -Directory -ErrorAction SilentlyContinue |
            ForEach-Object { $_.FullName }
    }
    $candidates += @(
        "$env:ProgramFiles\Tricentis\Tosca Commander",
        "$env:ProgramFiles\Tricentis\ToscaCommander",
        "${env:ProgramFiles(x86)}\Tricentis\ToscaCommander"
    )

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        if (-not $candidate) { continue }
        $installRoot = $candidate.TrimEnd('\', '/')
        if ((Test-Path (Join-Path $installRoot 'TCShell\TCShell.exe')) -or (Test-Path (Join-Path $installRoot 'TCAPI.dll'))) {
            return $installRoot
        }
    }
    return $null
}

function Resolve-ToscaWorkspacePath {
    param([string]$Workspace = $env:TOSCA_WORKSPACE)
    if ($Workspace) { return $Workspace.Trim() }
    $ideEnv = Read-CliApiCommanderEnv
    if ($ideEnv.Workspace) { return $ideEnv.Workspace.Trim() }
    return $null
}

function Get-TcShellExecutablePath {
    param([string]$CommanderHome)
    if (-not $CommanderHome) { return $null }
    $fromHome = Join-Path $CommanderHome 'TCShell\TCShell.exe'
    if (Test-Path $fromHome) { return $fromHome }
    foreach ($candidate in @(
        "$env:ProgramFiles\Tricentis\Tosca Commander\TCShell\TCShell.exe",
        "$env:ProgramFiles\Tricentis\ToscaCommander\TCShell\TCShell.exe",
        "${env:ProgramFiles(x86)}\Tricentis\ToscaCommander\TCShell\TCShell.exe"
    )) {
        if (Test-Path $candidate) { return $candidate }
    }
    return $null
}

function Get-WorkspaceLockStatus {
    param([string]$WorkspacePath)
    if (-not $WorkspacePath) {
        return [ordered]@{
            Checked = $false
            Locked  = $false
            Holder  = $null
            LockFile = $null
        }
    }
    if (-not (Test-Path $WorkspacePath)) {
        return [ordered]@{
            Checked = $true
            Locked  = $false
            Holder  = $null
            LockFile = $null
            Reason  = "Workspace file not found: $WorkspacePath"
        }
    }
    $lockFile = "$WorkspacePath.txt"
    if (-not (Test-Path $lockFile)) {
        return [ordered]@{
            Checked  = $true
            Locked   = $false
            Holder   = $null
            LockFile = $lockFile
        }
    }
    try {
        $holder = (Get-Content -Path $lockFile -Raw -ErrorAction Stop).Trim()
    }
    catch {
        $holder = $null
    }
    return [ordered]@{
        Checked  = $true
        Locked   = -not [string]::IsNullOrWhiteSpace($holder)
        Holder   = $holder
        LockFile = $lockFile
    }
}

function Test-CommanderGuiProcessRunning {
    $names = @('ToscaCommander', 'Tosca Commander')
    foreach ($name in $names) {
        if (Get-Process -Name $name -ErrorAction SilentlyContinue) { return $true }
    }
    return $false
}

function Test-RemoteControlSessionAvailable {
    param([string]$CommanderHome)
    if (-not $CommanderHome) { return $false }
    if (-not (Test-TcShellRemoteControlActive)) { return $false }
    $rc = $null
    try {
        $rc = Connect-TcShellRemoteControl -CommanderHome $CommanderHome
        return $null -ne $rc
    }
    catch {
        return $false
    }
    finally {
        if ($rc) { Close-TcShellRemoteControl -Session $rc }
    }
}

function Get-ShellRuntimeInfo {
    $cmdExe = $null
    if ($env:OS -eq 'Windows_NT' -and $env:SystemRoot) {
        $candidate = Join-Path $env:SystemRoot 'System32\cmd.exe'
        if (Test-Path $candidate) { $cmdExe = $candidate }
    }
    if (-not $cmdExe) {
        $cmdCmd = Get-Command cmd -ErrorAction SilentlyContinue
        if ($cmdCmd) { $cmdExe = $cmdCmd.Source }
    }

    $psCore = Get-PowerShellRuntimeInfo
    $winPs = Get-WindowsPowerShellInfo
    $dotnetScript = Get-DotNetScriptRuntimeInfo
    $dotnetCmd = Get-Command dotnet -ErrorAction SilentlyContinue
    $dotnetExe = if ($dotnetCmd) { $dotnetCmd.Source } else { $null }
    $dotnetVersion = $null
    if ($dotnetExe) {
        try { $dotnetVersion = (& $dotnetExe --version 2>$null | Out-String).Trim() } catch { }
    }
    $desktopRuntimes = @(Get-InstalledDotNetDesktopRuntimes)
    $anyPs = [bool]($psCore.Available -or $winPs.Available)

    return [ordered]@{
        Cmd = [ordered]@{
            Available    = [bool]$cmdExe
            Executable   = $cmdExe
            RequiredFor  = @('HeadlessTCShell batch files', 'Direct TCShell.exe invocation')
        }
        PowerShellCore = [ordered]@{
            Available   = $psCore.Available
            Executable  = $psCore.Executable
            Version     = $psCore.Version
            Edition     = $psCore.Edition
            RequiredFor = @('TCAPI via .ps1', 'Remote Control client script', 'Full detection .ps1')
        }
        WindowsPowerShell = [ordered]@{
            Available   = $winPs.Available
            Executable  = $winPs.Executable
            Version     = $winPs.Version
            Edition     = $winPs.Edition
            RequiredFor = @('TCAPI on Commander 24.1 (net48)', 'Remote Control when pwsh unavailable')
        }
        AnyPowerShell = [ordered]@{
            Available   = $anyPs
            RequiredFor = @('Invoke-TcApi.ps1', 'TcShellRemoteControl.ps1', 'Get-CommanderAutomationPaths.ps1')
        }
        DotNet = [ordered]@{
            Available        = [bool]$dotnetExe
            Executable       = $dotnetExe
            Version          = $dotnetVersion
            DesktopRuntimes  = $desktopRuntimes
            RequiredFor      = @('TCAPI via dotnet script (.csx)')
        }
        DotNetScript = [ordered]@{
            Available   = $dotnetScript.Available
            Version     = $dotnetScript.Version
            RequiredFor = @('TCAPI via .csx without PowerShell')
        }
        Python = [ordered]@{
            Available   = [bool](Get-Command python -ErrorAction SilentlyContinue) -or [bool](Get-Command python3 -ErrorAction SilentlyContinue)
            RequiredFor = @('Get-CommanderAutomationPaths.py (optional)', 'Reference doc generation (dev)')
        }
    }
}

function Get-TcApiHostAvailability {
    param(
        [string]$CommanderHome,
        $Runtimes,
        $TcApiRuntime
    )
    $dllPresent = Test-TcApiDllsPresent -CommanderHome $CommanderHome
    $psHost = $Runtimes.PowerShellCore.Executable
    if (-not $psHost) { $psHost = $Runtimes.WindowsPowerShell.Executable }
    $dotnetScript = $Runtimes.DotNetScript.Available
    $hosts = [ordered]@{
        PowerShell   = [bool]($dllPresent -and $psHost -and $TcApiRuntime -and $TcApiRuntime.RecommendedMode -ne 'none')
        DotNetScript = [bool]($dllPresent -and $dotnetScript -and $TcApiRuntime -and $TcApiRuntime.DotNetDesktopRuntimeInstalled)
        DllPresent   = $dllPresent
    }
    $preferred = $null
    if ($hosts.PowerShell) { $preferred = 'PowerShell' }
    elseif ($hosts.DotNetScript) { $preferred = 'DotNetScript' }
    return [ordered]@{ AvailableHosts = $hosts; PreferredHost = $preferred }
}

function New-AutomationPathInfo {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Label,
        [bool]$Available = $false,
        [int]$Score = 0,
        [string]$Reason = '',
        [string]$HostRequired = '',
        [bool]$PowerShellRequired = $false,
        [hashtable]$Details = @{}
    )
    return [ordered]@{
        Id                 = $Id
        Label              = $Label
        Available          = $Available
        Score              = $Score
        Reason             = $Reason
        HostRequired       = $HostRequired
        PowerShellRequired = $PowerShellRequired
        Details            = $Details
    }
}

function Select-CommanderAutomationPath {
    param(
        [Parameter(Mandatory)]
        $Discovery,
        [ValidateSet('Auto', 'HeadlessScript', 'TypedApi', 'GuiAttended')]
        [string]$Intent = 'Auto'
    )

    $paths = @($Discovery.Paths | Where-Object { $_.Available })
    $locked = $Discovery.WorkspaceLock.Locked
    $choices = @()
    $prompt = $null

    foreach ($path in $Discovery.Paths) {
        $path.Score = 0
    }

    $headless = $Discovery.Paths | Where-Object { $_.Id -eq 'HeadlessTCShell' } | Select-Object -First 1
    $tcapi = $Discovery.Paths | Where-Object { $_.Id -eq 'TCAPI' } | Select-Object -First 1
    $rc = $Discovery.Paths | Where-Object { $_.Id -eq 'RemoteControl' } | Select-Object -First 1

    if ($Intent -eq 'GuiAttended') {
        if ($rc.Available) { $rc.Score = 100 }
        elseif ($locked) { $rc.Score = 10 }
    }
    elseif ($Intent -eq 'TypedApi') {
        if (-not $locked -and $tcapi.Available) { $tcapi.Score = 100 }
        elseif ($locked) { $tcapi.Score = 0 }
    }
    elseif ($Intent -eq 'HeadlessScript') {
        if (-not $locked -and $headless.Available) { $headless.Score = 100 }
        elseif ($locked) { $headless.Score = 0 }
    }
    else {
        if (-not $locked) {
            if ($headless.Available) { $headless.Score += 80 }
            if ($tcapi.Available) { $tcapi.Score += 70 }
            if ($rc.Available) { $rc.Score += 20 }
        }
        else {
            if ($rc.Available) { $rc.Score += 60 }
            if ($headless.Available) { $headless.Score += 5 }
            if ($tcapi.Available) { $tcapi.Score += 5 }
        }
    }

    $ranked = @($Discovery.Paths | Where-Object { $_.Available } | Sort-Object Score -Descending)
    $bestScore = if ($ranked.Count -gt 0) { $ranked[0].Score } else { -1 }
    $top = @($ranked | Where-Object { $_.Score -eq $bestScore -and $bestScore -ge 0 })
    $runtimes = $Discovery.Runtimes

    if (-not $runtimes.AnyPowerShell.Available -and $headless.Available) {
        $headless.Score += 15
    }

    if ($locked -and $headless.Details.WouldBeAvailableWithoutLock) {
        $prompt = @(
            'The workspace is locked (Commander or another process holds it). Headless TCShell/TCAPI cannot open the same .tws while locked.'
            'Choose one: (1) Close Commander and use headless automation, (2) Start Remote Control in Commander for in-process access, or (3) Continue with GUI-attended Remote Control if already started.'
        ) -join ' '
        $choices += [ordered]@{ Id = 'CloseCommanderHeadless'; Label = 'Close Commander -> headless TCShell (cmd/batch, no PowerShell required)' }
        if ($rc.Available) {
            $choices += [ordered]@{ Id = 'RemoteControl'; Label = 'Remote Control (GUI-attended, UI sync)' }
        }
        else {
            $choices += [ordered]@{ Id = 'StartRemoteControl'; Label = 'Start Remote Control in Commander, then retry' }
        }
    }

    if (-not $locked -and $headless.Available -and $tcapi.Available -and $Intent -eq 'Auto' -and $top.Count -gt 1) {
        $prompt = 'Both headless TCShell (cmd/batch, no PowerShell) and TCAPI are available. Prefer TCShell for .tcs scripts; prefer TCAPI only when a .NET host is available.'
        $choices += [ordered]@{ Id = 'HeadlessTCShell'; Label = 'Headless TCShell (.tcs via cmd/batch)' }
        $choices += [ordered]@{ Id = 'TCAPI'; Label = "TCAPI via $($tcapi.Details.PreferredHost)" }
    }

    if (-not $runtimes.AnyPowerShell.Available) {
        $hosts = $tcapi.Details.AvailableHosts
        if ($hosts.DllPresent -and -not $hosts.PowerShell -and -not $hosts.DotNetScript) {
            if (-not $prompt) {
                $prompt = 'PowerShell is not available. Use headless TCShell via cmd/batch (no PowerShell), or install pwsh / dotnet-script for TCAPI.'
            }
            if ($headless.Available) {
                $choices += [ordered]@{ Id = 'HeadlessTCShell'; Label = 'Use TCShell.exe + .tcs (recommended without PowerShell)' }
            }
        }
    }

    if (-not $Discovery.Workspace -and ($headless.Available -or $tcapi.Available)) {
        $prompt = 'Set the workspace path (.tws) via -Workspace, TOSCA_WORKSPACE, or ~/.tricentis/tcshell-ide.env before running automation.'
        $choices += [ordered]@{ Id = 'ProvideWorkspace'; Label = 'Provide workspace .tws path' }
    }

    if ($ranked.Count -eq 0) {
        return [ordered]@{
            Recommended         = $null
            Alternatives        = @()
            UserPromptRequired  = $true
            UserPrompt          = 'No Commander automation path is available. Install Commander on Windows, set COMMANDER_HOME, and ensure TCShell.exe or TCAPI.dll exist.'
            Choices             = @()
        }
    }

    $userPromptRequired = ($choices.Count -gt 0) -and ($Intent -eq 'Auto' -or ($locked -and $Intent -in @('HeadlessScript', 'TypedApi')))

    if ($userPromptRequired -and $top.Count -gt 1 -and -not $prompt) {
        $prompt = "Multiple paths scored equally ($($top.Id -join ', ')). Ask the user which to use."
        foreach ($item in $top) {
            $choices += [ordered]@{ Id = $item.Id; Label = $item.Label }
        }
    }

    $recommended = if ($top.Count -eq 1 -and -not $userPromptRequired) { $top[0] } elseif ($top.Count -ge 1 -and $Intent -ne 'Auto') { $top[0] } else { $null }
    $alternatives = @($ranked | Where-Object { -not $recommended -or $_.Id -ne $recommended.Id })

    return [ordered]@{
        Recommended        = $recommended
        Alternatives       = $alternatives
        UserPromptRequired = [bool]$userPromptRequired
        UserPrompt         = $prompt
        Choices            = $choices
        Ranked             = $ranked
    }
}

function Get-CommanderAutomationPaths {
    param(
        [string]$CommanderHome = $env:COMMANDER_HOME,
        [string]$CommanderVersion = $env:COMMANDER_VERSION,
        [string]$Workspace = $env:TOSCA_WORKSPACE,
        [ValidateSet('Auto', 'HeadlessScript', 'TypedApi', 'GuiAttended')]
        [string]$Intent = 'Auto',
        [switch]$SelectOnly
    )

    $onWindows = $IsWindows
    if (-not $onWindows -and $env:OS -eq 'Windows_NT') { $onWindows = $true }

    $runtimes = Get-ShellRuntimeInfo
    $resolvedHome = Resolve-CommanderHomePath -CommanderHome $CommanderHome
    $resolvedWorkspace = Resolve-ToscaWorkspacePath -Workspace $Workspace
    $tcShellPath = Get-TcShellExecutablePath -CommanderHome $resolvedHome
    $lockStatus = Get-WorkspaceLockStatus -WorkspacePath $resolvedWorkspace
    $guiRunning = if ($onWindows) { Test-CommanderGuiProcessRunning } else { $false }

    $versionKey = if ($resolvedHome) {
        Resolve-CommanderVersionForTcApi -CommanderHome $resolvedHome -ExplicitVersion $CommanderVersion
    } else { $null }

    $tcapiRuntime = $null
    if ($resolvedHome) {
        try { $tcapiRuntime = Get-TcApiRuntimeInfo -CommanderHome $resolvedHome -CommanderVersion $CommanderVersion }
        catch { $tcapiRuntime = $null }
    }

    $rcAvailable = $false
    $rcReason = if (-not $onWindows) { 'Requires Windows.' }
        elseif (-not $resolvedHome) { 'COMMANDER_HOME not found.' }
        elseif (-not (Test-Path (Join-Path $resolvedHome 'RemoteControlObjects.dll'))) {
            'RemoteControlObjects.dll not found under COMMANDER_HOME.'
        }
        elseif (-not $runtimes.AnyPowerShell.Available) {
            'RemoteControlObjects.dll present; session probe requires PowerShell or a .NET client. Headless TCShell via cmd/batch does not require PowerShell.'
        }
        else { $null }
    if ($rcReason -eq $null -and $onWindows -and $resolvedHome) {
        $rcAvailable = Test-RemoteControlSessionAvailable -CommanderHome $resolvedHome
        $rcReason = if ($rcAvailable) { 'Remote Control session active (Start Remote Control was used in Commander).' }
            elseif ($guiRunning) { 'Commander is running but Remote Control is not started. Use project menu -> Start Remote Control.' }
            else { 'Remote Control not active. Open Commander, load workspace, start Remote Control.' }
    }

    $headlessBase = [bool]($onWindows -and $tcShellPath -and $resolvedHome)
    $headlessAvailable = $headlessBase -and -not $lockStatus.Locked
    $headlessReason = if (-not $onWindows) { 'Requires Windows.' }
        elseif (-not $resolvedHome) { 'COMMANDER_HOME not found.' }
        elseif (-not $tcShellPath) { 'TCShell.exe not found under Commander install.' }
        elseif ($lockStatus.Locked) { "Workspace locked by $($lockStatus.Holder). Close Commander or use Remote Control." }
        elseif (-not $resolvedWorkspace) { 'Available; set workspace path before running. Host: cmd/batch (PowerShell not required).' }
        else { "Ready via cmd/batch: $tcShellPath" }

    $tcapiHosts = Get-TcApiHostAvailability -CommanderHome $resolvedHome -Runtimes $runtimes -TcApiRuntime $tcapiRuntime
    $tcapiAvailable = [bool](
        -not $lockStatus.Locked -and
        $tcapiHosts.AvailableHosts.DllPresent -and
        ($tcapiHosts.AvailableHosts.PowerShell -or $tcapiHosts.AvailableHosts.DotNetScript)
    )
    $tcapiReason = if (-not $tcapiHosts.AvailableHosts.DllPresent) { 'TCAPI DLLs not found under COMMANDER_HOME.' }
        elseif ($lockStatus.Locked) { "Workspace locked by $($lockStatus.Holder). TCAPI cannot open the same .tws." }
        elseif (-not $tcapiHosts.AvailableHosts.PowerShell -and -not $tcapiHosts.AvailableHosts.DotNetScript) {
            $vp = if ($tcapiRuntime) { $tcapiRuntime.VersionProfile } else { Get-TcApiVersionProfile -VersionKey $versionKey }
            "TCAPI.dll present for Commander $versionKey but no suitable host. $($vp.HostGuidance) Required .NET desktop runtime: $($vp.DotNetDesktopRuntime)."
        }
        elseif ($tcapiAvailable) { "Ready via $($tcapiHosts.PreferredHost)." }
        else { 'TCAPI runtime not detected.' }

    $paths = @(
        (New-AutomationPathInfo -Id 'HeadlessTCShell' -Label 'Headless TCShell' -Available $headlessAvailable -Reason $headlessReason -HostRequired 'CmdOrBatch' -PowerShellRequired:$false -Details @{
            TcShellPath                   = $tcShellPath
            CommanderHome                 = $resolvedHome
            CommanderVersion              = $versionKey
            WouldBeAvailableWithoutLock   = $headlessBase
            ExampleHost                   = $runtimes.Cmd.Executable
            SkillReferencePath            = "reference/versions/$versionKey/"
        }),
        (New-AutomationPathInfo -Id 'TCAPI' -Label 'TCAPI (.NET)' -Available $tcapiAvailable -Reason $tcapiReason -HostRequired 'PowerShellOrDotNetScript' -PowerShellRequired:$false -Details @{
            CommanderHome        = $resolvedHome
            CommanderVersion     = $versionKey
            AvailableHosts       = $tcapiHosts.AvailableHosts
            PreferredHost        = $tcapiHosts.PreferredHost
            VersionProfile       = if ($tcapiRuntime) { $tcapiRuntime.VersionProfile } else { Get-TcApiVersionProfile -VersionKey $versionKey }
            SkillReferencePath   = "reference/versions/$versionKey/"
            RecommendedMode      = if ($tcapiRuntime) { $tcapiRuntime.RecommendedMode } else { $null }
            RecommendedPsHost    = if ($tcapiRuntime) { $tcapiRuntime.RecommendedPowerShellHost } else { $null }
        }),
        (New-AutomationPathInfo -Id 'RemoteControl' -Label 'Remote Control (GUI-attended)' -Available $rcAvailable -Reason $rcReason -HostRequired 'PowerShellOrDotNet' -PowerShellRequired:$true -Details @{
            CommanderHome     = $resolvedHome
            DllPresent        = [bool]($resolvedHome -and (Test-Path (Join-Path $resolvedHome 'RemoteControlObjects.dll')))
            Channel           = if ($onWindows) { Get-TcShellRemoteChannelName } else { $null }
            PowerShellScript  = $(if ($PSScriptRoot -match '[\\/]scripts[\\/]lib$') { 'lib/TcShellRemoteControl.ps1' } else { 'lib/TcShellRemoteControl.ps1' })
        })
    )

    $discovery = [ordered]@{
        DetectionMethod = 'powershell'
        IsWindows       = $onWindows
        CommanderHome   = $resolvedHome
        CommanderVersion = $versionKey
        VersionProfile  = if ($tcapiRuntime) { $tcapiRuntime.VersionProfile } else { Get-TcApiVersionProfile -VersionKey $versionKey }
        SkillReferencePath = "reference/versions/$versionKey/"
        SupportedCommanderVersions = @('24.1', '24.2', '25.1', '26.1', 'master')
        Workspace       = $resolvedWorkspace
        WorkspaceLock   = $lockStatus
        CommanderGuiRunning = $guiRunning
        Intent          = $Intent
        Runtimes        = $runtimes
        Paths           = $paths
    }

    $selection = Select-CommanderAutomationPath -Discovery $discovery -Intent $Intent
    $discovery['Selection'] = $selection

    if ($SelectOnly) { return $selection }
    return $discovery
}

# SIG # Begin signature block
# MIIqGAYJKoZIhvcNAQcCoIIqCTCCKgUCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDyT1mH7dpOOWOl
# gz4yTqNmYF+NgIU6qlrtv3Ebb1cw9qCCDt8wggboMIIE0KADAgECAhB3vQ4Ft1kL
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEpvC5ABCRjbD7Wq8xnWnvKS
# Hc3nAY9uKqJYw2EfwRgfMA0GCSqGSIb3DQEBAQUABIICADy6U8+FcsQlQL7rLubm
# ZOXX7AmfPSKaqRgJz4NdPL0lKADHvk2WrEOwm9B84BG+OV86Mh7LWLJ2WWrzfyBe
# zG+0sq3pfzDUQgw0Lv3wlP1GHuV6RGfi8tpDGKuM653dZkufqNgZV6aDnd/Q1xw5
# D1dc100wm58pr6BUMVDTb81FBK2j9bdwwZWNBglIffE1GgW89Rz5oP/b0V5LCba3
# deoMfit2f8DkquUS8pKnUM84z2rDOew7a0hRkg+eH5NvYmqzT76hqutcWtV8uKlp
# hy9RORRs1cvbd96FY8sUJnnN+4xXyMTEqi8k0h0k+aXmZeYQk+Gy2B98+TcxZUt3
# vUHGaH4S0R1vGT3Plv56WzogxPAkqNOJ9Y2+R7VrgXk/ZukI90RvozVn9/3KOK9V
# oU9PHfoWfmhQbP//1GLWXeutM+p9tP4h4dVoP/s10fJG3FybiXrhLSaG725IG+UJ
# 3HFtFyoniyM7HneIlSCQnWYyOckSYefDBwaSwAFhISsCLQ9p4OTe7W4djFjO2LQX
# YI5NWpFAJIH5YptBQrtBvP8ifANHi9ie4j+dhk+Bgz8uNqtqVLQ3uTSVnCQhi/d5
# 79cRgdwqjE4qmFB8x0i9LkT0I6S3mL40A/B8q8HtGKX0Q8fxYSFwxF8NLw9ssHd4
# dwnfb1ZXFklsW4dR9KxOn4EOoYIXdjCCF3IGCisGAQQBgjcDAwExghdiMIIXXgYJ
# KoZIhvcNAQcCoIIXTzCCF0sCAQMxDzANBglghkgBZQMEAgEFADB3BgsqhkiG9w0B
# CRABBKBoBGYwZAIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEIDeLBzfe
# 3yC5vSIPBkRKZkgyh8u9DGpd3vLc5zYCMGOaAhAB95MjIRw0PsWGCK5Sid/pGA8y
# MDI2MTAxNTIyMTc1N1qgghM6MIIG7TCCBNWgAwIBAgIQCE/cM09+RU7bww+P+ZIY
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
# BTEPFw0yNjEwMTUyMjE3NTdaMCsGCyqGSIb3DQEJEAIMMRwwGjAYMBYEFFHZq9oD
# SXPYT0JmrKSCSOazacQ5MC8GCSqGSIb3DQEJBDEiBCA2q2CjjMupSA+ZJ25iytV/
# ffKK/EfUcWlFo7f7u6zJBjA3BgsqhkiG9w0BCRACLzEoMCYwJDAiBCAtoJ2n9BMf
# n+cttsXm6cllZ1WvBD8ep0LMDSEg4UHr/DANBgkqhkiG9w0BAQEFAASCAgCkiSyn
# IHyp/Do78dkvs6jymrIcYUi54hsFTecw2bM4anY16NbFVjNQ0tOTi6yz4mqC25Be
# zIyMIRJQFExApeT6I4UQ4J8CQkRHf3ceT/iaEKU5XFi/stCKVjL0eolxpg1kZd+6
# cHlBL17LABDHE2qj0cTRb07WxAqh0ha8H5HiGX8el/N55hyUCDbbNYxbXVcXvgFW
# FMusJ3WGplo6a0POepqVQ8ACqjQdX2bGZGt3DqRgoIAqvmFzX2/3MwfjOX3LfPmQ
# LDPXudbihgjxetETUkeeTW7QjAW7AQl8e3mK3xXW4i0I/N+pxpYOA9BxexdNT7AL
# 4q3QA3OdqDDywfSf73zieOIl3X3YX3iaNi1sVgi+3rs5R0/2iy55aBzrjp15RauM
# IwqsgeAmb7P9VmqoKgB3K/Qh1zSfzVw/at8mZTcLEmdz4D9MAZY6cmWgAVD3BnIr
# +QWjtW8iJnygHIwrqWlJpFsVwN3Yo5MEkPQW9dEK5NMDDebFgPtokqZ585Y6fGYr
# JA65C80sY4CJ1mAOKt9jn/0wZ26gNvA5R9TCgoVxyTaOdH9I+KQHnSArvvAmGXE4
# raWtcfY11kW3z/xHvwjLmTUq1AseY1ZwIbs6RMwJWc2NeZy3JeNludqMVNyNAcvg
# saZboYDsXQ9pSxOwOHWGW8B3hhq4jiw2TTfGqA==
# SIG # End signature block
