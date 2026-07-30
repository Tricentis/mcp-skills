# Remote Control — GUI-attended automation (last resort)

> **Warning:** Remote Control is **not recommended as the default IDE agent path**. It drives the **Commander GUI** (`JumpTo` on navigation, optional `TakeControllFromUser` grey-out). Prefer **headless TCShell/TCAPI** when Commander is closed. See [workspace-checkout.md](workspace-checkout.md).

Use Remote Control only when:

1. The user **explicitly** wants automation tied to the visible UI ("what I'm looking at"), and
2. The user accepts UI navigation side effects and possible contention.

## Contents

- [Startup](#startup-user-action-required)
- [Client script](#client-script-powershell)
- [IPC connection](#ipc-connection)
- [GUI sync behaviour](#gui-sync-behaviour)
- [Command sequence](#command-sequence-pattern)
- [When unavailable](#when-remote-control-is-unavailable)
- [Source references](#source-references-tricentistoscacommander)

## Startup (user action required)

1. Open workspace in Commander.
2. Right-click **project root** → **Start Remote Control** (status bar confirms when ready).
3. External client connects while RC session is active.

Start Remote Control on the **project root** — starting on a sub-folder can hang.

## Client script (PowerShell)

Use `lib/TcShellRemoteControl.ps1` after path detection selects Remote Control:

```powershell
. .\lib\TcShellRemoteControl.ps1
$session = Connect-TcShellRemoteControl -CommanderHome $env:COMMANDER_HOME
Invoke-TcShellRemoteCommand -RemoteControl $session -Command 'print Name'
Close-TcShellRemoteControl -Session $session
```

The script handles `InitializeRemoteControl`, `clientId` threading, and session teardown.

## IPC connection

**Pipe:** `\\.\pipe\TOSCARemoteChannel\TOSCARemoteControl`  
(Backslash separator, **no** Windows session ID suffix.)

Detect with `Test-TcShellRemoteControlActive` or:

```powershell
[System.IO.Directory]::GetFiles('\\.\pipe\') -contains '\\.\pipe\TOSCARemoteChannel\TOSCARemoteControl'
```

Connect via `IpcFactory.CreateClient("TOSCARemoteChannel\TOSCARemoteControl", …)` loading from `%COMMANDER_HOME%`:

- `Tricentis.Automation.Remoting.dll`
- `RemoteControlObjects.dll`

**All methods after init require the `clientId` from `InitializeRemoteControl()`:**

| Method | Signature |
|--------|-----------|
| Init | `InitializeRemoteControl() → string clientId` |
| Send | `SendCommand(string command, string clientId)` |
| Read | `GetInfos(string clientId) → string` |
| Errors | `GetErrors(string clientId) → string` |
| Grey out UI | `TakeControllFromUser(string clientId)` |
| Restore UI | `ReturnControlToUserNonBlocking(string message, string clientId, IEnumerable<string> decisions)` |
| End session | `DisconnectRemoteControl()` |

> Use **`ReturnControlToUserNonBlocking`** — `ReturnControlToUser` opens a modal dialog and blocks until the user clicks.

## GUI sync behaviour

When a command changes the current object (`JumpToNode`, `JumpTo`, `cn`, etc.), Commander **navigates the UI** to that object automatically.

Remote Control operates on the **same open workspace** in the Commander process — GUI, interpreter, and object scope are shared.

Use this path when the user says:

- "Work on what I'm looking at"
- "Add a step to this test case"
- "Run what I have selected"

## Command sequence pattern

```
print
JumpToNode "/TestCases/MyFolder"
task "Create TestCase"
set Name "FirstTest"
JumpToNode "/TestCases/MyFolder/FirstTest"
task "Create Manual XTestStep"
set Name "MyStep"
save
```

See [reference/tasks.md](reference/tasks.md) for verified task names by object type.

## When Remote Control is unavailable

Re-run path detection (`Get-CommanderAutomationPaths.ps1` or `.py`). If `RemoteControl.Available` is false:

- **Workspace locked:** headless open fails with **"Workspace locked by another process"** — close Commander or start Remote Control.
- **Workspace unlocked:** use headless TCShell:

```bat
TCShell.exe -workspace "path.tws" -auth "token" script.tcs
```

See [path-selection.md](path-selection.md).

## Implementation references

- `commander/TCAddIns/RemoteControlAddIn/Remoting/RemoteControl.cs`
- `commander/TCAddIns/RemoteControlAddIn/CommandHandling/RemoteCommandInterpreter.cs`
- `commander/TCCore/RemoteControlObjects/TOSCARemoteControl.cs`
