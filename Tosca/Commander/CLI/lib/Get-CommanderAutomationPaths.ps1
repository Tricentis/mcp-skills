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
            PowerShellScript  = 'scripts/lib/TcShellRemoteControl.ps1'
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
