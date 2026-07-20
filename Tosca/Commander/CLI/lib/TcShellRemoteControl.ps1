#Requires -Version 5.1
param(
    [switch]$ProbeSession,
    [string]$CommanderHome
)
<#
.SYNOPSIS
  Connect to Commander Remote Control via named-pipe IPC (RemoteControlObjects.dll).

.DESCRIPTION
  Probes \\.\pipe\TOSCARemoteChannel\TOSCARemoteControl, calls InitializeRemoteControl for a
  clientId, routes SendCommand/GetInfos/GetErrors through IpcFactory, and ends with
  ReturnControlToUserNonBlocking + DisconnectRemoteControl.
#>

$script:TcShellRemoteSession = $null
$script:RcPipeName = 'TOSCARemoteChannel\TOSCARemoteControl'
$script:RcPipePath = "\\.\pipe\$script:RcPipeName"

function Test-TcShellRemoteControlActive {
    if ($env:OS -ne 'Windows_NT') { return $false }
    try {
        return [System.IO.Directory]::GetFiles('\\.\pipe\') -contains $script:RcPipePath
    }
    catch {
        return $false
    }
}

function Import-TcShellRemoteDependencies {
    param([Parameter(Mandatory)][string]$CommanderHome)
    foreach ($dep in @('Tricentis.Automation.Remoting.dll', 'RemoteControlObjects.dll')) {
        $path = Join-Path $CommanderHome $dep
        if (-not (Test-Path $path)) {
            throw "Missing $dep under $CommanderHome"
        }
        Add-Type -Path $path -ErrorAction Stop
    }
}

function Connect-TcShellRemoteControl {
    param([string]$CommanderHome = $env:COMMANDER_HOME)

    if (-not $CommanderHome) { return $null }
    if (-not (Test-TcShellRemoteControlActive)) { return $null }

    $home = $CommanderHome.TrimEnd('\', '/')
    $env:COMMANDER_HOME = $home

    try {
        Import-TcShellRemoteDependencies -CommanderHome $home
        $factory = [Tricentis.TCCore.RemoteControlObjects.IpcFactory]::CreateFactory()
        $client = $factory.CreateClient($script:RcPipeName, [TimeSpan]::FromSeconds(10))
        $clientId = $client.InvokeRemoteMethod('InitializeRemoteControl', [Type[]]@(), [Object[]]@())
        if ([string]::IsNullOrWhiteSpace($clientId)) { return $null }

        $script:TcShellRemoteSession = [PSCustomObject]@{
            Client        = $client
            ClientId      = $clientId
            CommanderHome = $home
        }
        return $script:TcShellRemoteSession
    }
    catch {
        $script:TcShellRemoteSession = $null
        return $null
    }
}

function Invoke-TcShellRemoteCommand {
    param(
        [Parameter(Mandatory)]
        $RemoteControl,
        [Parameter(Mandatory)]
        [string]$Command
    )

    $session = $RemoteControl
    if (-not $session.Client) {
        $session = $script:TcShellRemoteSession
    }
    if (-not $session -or -not $session.Client) {
        throw 'Remote Control session is not connected. Call Connect-TcShellRemoteControl first.'
    }

    $session.Client.InvokeRemoteMethod(
        'SendCommand',
        [Type[]]@([string], [string]),
        [Object[]]@($Command, $session.ClientId)
    ) | Out-Null

    $info = $session.Client.InvokeRemoteMethod('GetInfos', [Type[]]@([string]), [Object[]]@($session.ClientId))
    $err = $session.Client.InvokeRemoteMethod('GetErrors', [Type[]]@([string]), [Object[]]@($session.ClientId))
    if ($info) { Write-Output $info }
    if ($err) { Write-Error $err }
}

function Close-TcShellRemoteControl {
    param($Session)

    if (-not $Session) { $Session = $script:TcShellRemoteSession }
    if (-not $Session -or -not $Session.Client) {
        $script:TcShellRemoteSession = $null
        return
    }

    try {
        $Session.Client.InvokeRemoteMethod(
            'ReturnControlToUserNonBlocking',
            [Type[]]@([string], [string], [System.Collections.Generic.IEnumerable[string]]),
            [Object[]]@('', $Session.ClientId, [string[]]@())
        ) | Out-Null
    }
    catch { }

    try {
        $Session.Client.InvokeRemoteMethod('DisconnectRemoteControl', [Type[]]@(), [Object[]]@()) | Out-Null
    }
    catch { }

    $script:TcShellRemoteSession = $null
}

function Get-TcShellRemoteChannelName {
    return $script:RcPipeName
}

if ($ProbeSession) {
    $ErrorActionPreference = 'Stop'
    if ($CommanderHome) { $env:COMMANDER_HOME = $CommanderHome }
    try {
        $rc = Connect-TcShellRemoteControl -CommanderHome $env:COMMANDER_HOME
        if ($rc) { Write-Output 'OK'; exit 0 }
        exit 1
    }
    catch {
        exit 1
    }
    finally {
        Close-TcShellRemoteControl
    }
}
