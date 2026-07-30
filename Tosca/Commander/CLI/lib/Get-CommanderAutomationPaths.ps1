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
    if (-not $env:USERPROFILE) { return $result }
    $candidates = @(
        (Join-Path $env:USERPROFILE '.tricentis/tcshell-ide.env'),
        (Join-Path $env:USERPROFILE '.tricentis\tcshell-ide.env')
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
        $choices += [ordered]@{ Id = 'CloseCommanderHeadless'; Label = 'Close Commander → headless TCShell (cmd/batch, no PowerShell required)' }
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
            elseif ($guiRunning) { 'Commander is running but Remote Control is not started. Use project menu → Start Remote Control.' }
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
# MIIqGQYJKoZIhvcNAQcCoIIqCjCCKgYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDpNcwzbspGvPu+
# kEEvMz38swPvIgf40U5O8yBPLSfwcaCCDt8wggboMIIE0KADAgECAhB3vQ4Ft1kL
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIJltdHgPOeYFDdqB9w6f52dQ
# H6PltK2F3LPVYU5fEhebMA0GCSqGSIb3DQEBAQUABIICADIOJXDn5Ve/o+fN/TNL
# dilWWsiHl6xPC8koBLxbwfqVNSOmklvrlrvy6/HWBnkevG4jO7nOHNX/YV/6l5XU
# 7WyYr+9I2KufEMaSi9+awInq7ItpX8IBvHTvXnn5vHcaQGW7Kogi8qiyWkhiLgyt
# S2PzP9G+IZvL1hwRZK1HpypatjtbluCm2B5B3y0Enikn9SDBByb4eftUVJ0s9Nh7
# 4cGwq2QJqIXJsAcZ0lXkwY0IypHR/KX1V5D13AJ970rpWrKa7Hlv2XtjhuJaOKCI
# 9A29YXmGcoqrAfHWQifatFoXhhsRudg6grSGQEcahUMKmoi2b0NsBgbR7n7FkAY7
# lrNppl9JiQCqlcX1uW3klE82iUGKOWtldfGYCS8uzxIC7c41H+f2wGltpJB8Uy4K
# su07suIdJ6c4qpE12ttTnHzZVYFolHS67JN/0BY9Qb0RoDBcLLq96Idedst2itXj
# 5QGA/ZMezm20fccWeUtRmczGHXToE9GtGhFKsLYQE+u6x0dOKMtzVhjXgfltsdS1
# 70+dhQyois1kTykIKPNTMjbcbY0904mdyI5msRnIL0ZJx66fswN1hL6aZEhcXoZd
# 4FMYiLBfKzCg32f4t8W0dKT/Ry/NTUlXmnsHwRrpzQGdVDgxZ/MzkTOd94DD9xPD
# fnLheUnJ28f/lMey8Mc3lFukoYIXdzCCF3MGCisGAQQBgjcDAwExghdjMIIXXwYJ
# KoZIhvcNAQcCoIIXUDCCF0wCAQMxDzANBglghkgBZQMEAgEFADB4BgsqhkiG9w0B
# CRABBKBpBGcwZQIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEIPhKlzRP
# n8ufJAnajmkOC/Q2PfeCsX6jSGekdvYGGUiaAhEAkGG07FdYnjWL+kFxaEGDmRgP
# MjAyNjA3MzAyMTAyMTJaoIITOjCCBu0wggTVoAMCAQICEAqA7xhLjfEFgtHEdqeV
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
# CQUxDxcNMjYwNzMwMjEwMjEyWjArBgsqhkiG9w0BCRACDDEcMBowGDAWBBTdYjCs
# hgotMGvaOLFoeVIwB/tBfjAvBgkqhkiG9w0BCQQxIgQgIfaE5EXsVx4WCeFM9HA1
# mCug2is7ds+mwui93Clf25gwNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQgSqA/oizX
# XITFXJOPgo5na5yuyrM/420mmqM08UYRCjMwDQYJKoZIhvcNAQEBBQAEggIAoSy1
# 6sBifiPJ7WpC/S1zugyyVcGVTU6VygHWqoHiW/PR8ETRe0QG8Ia0O76Yalh4JYl3
# QFUrS15Oy6nYBrgLjnmANFDIMRz+h0QOoIuDKngR/HlBWdzxeNAoKkfSWxtRxOPO
# s7cqawOMnmmo4SaVNuCrRkpJFExag2MkJ/88ZS6B0SibgCRLZvOSwyTv4RaT4uKf
# AWt65sh1re3ryyLoU00WcAv68aMo168wogkEp6MhzAlfpdkOT1k0/B3+hEUEHhPg
# giDJR806hrBlGFKuEPoiSzB3zBURgV0ELorC6l2uxzbC3JcE/cey2rFjTmEVGSRl
# 5KSD2Z/uB8cpVDXIJBn5aACIQAs+o8eIElwOSP8F1t+4X/17M2BWJA/tS8Z7mB1C
# IoH2iZp2mugLrvx2kcYoify+6OVTF7D5pTaNLDD3Pm9MryqTjH4LgJruzlllJJIE
# SshSGEnHzAXsFKD15gktIHxHBqEOhXiozKnWAurazDH08pSKA/eXy8pXx6q6i0lL
# MkubbNKxoTVCcRLVZ+b8BIwrnd9zADnjA0q/7Gnh1hm9Dm9hgMDF641jIn/2mzMk
# 8Lm0tHXaZveAN/iogJGY2WK8q+TM2PuPfLqc3oPqVyHJJ3h/WmYz1LnkcrUBpmsQ
# ftXkg5jllUtrvYiMQtBwQVqJwO0wu5HDCkEDygg=
# SIG # End signature block
