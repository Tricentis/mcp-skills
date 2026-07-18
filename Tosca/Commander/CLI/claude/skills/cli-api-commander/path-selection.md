# Path selection — detect runtimes, rank paths, prompt

Before any Commander automation: **discover what is installed and what shell hosts are available**, pick the best path, **ask the user** when ambiguous.

Do **not** assume PowerShell **or Python** is available. Use **whatever runs** on the user's machine, then match automation to detected `Runtimes`.

## Contents

- [Step 1 — Run detection](#step-1--run-detection)
- [Step 2 — Commander version](#step-2--read-runtimes-and-commander-version)
- [Step 3 — Runtimes](#step-3--read-runtimes-what-the-machine-can-use)
- [Step 4 — Paths](#step-4--read-paths-commander-automation-routes)
- [Step 5 — Selection rules](#step-5--selection-rules)
- [Step 6 — Execute](#step-6--execute-match-host-to-path)
- [Agent workflow](#agent-workflow-mandatory)
- [When to prompt](#when-to-prompt-the-user)
- [Manual checklist](#manual-checklist-no-scripts)

## Step 1 — Run detection

Use **whichever detector executes** in the IDE terminal (same JSON shape). Try one; if it fails to start, try the other; if both fail, use the [manual checklist](#manual-checklist-no-scripts).

```powershell
# When PowerShell is available — includes Remote Control session probe
.\Get-CommanderAutomationPaths.ps1 -Workspace "C:\Projects\Demo.tws"
```

```bash
# When Python is available and allowed to run
python3 Get-CommanderAutomationPaths.py --workspace "C:/Projects/Demo.tws"
```

On Windows, try `python` if `python3` is not on PATH. **Neither script is required** — headless TCShell via cmd always works when Commander is installed and the workspace is unlocked.

Optional context (env or `%USERPROFILE%\.tricentis\tcshell-ide.env`):

```
COMMANDER_HOME=C:\Program Files\Tricentis\Tosca Commander 26.1
TOSCA_WORKSPACE=C:\Projects\Demo.tws
COMMANDER_VERSION=26.1
```

Exit codes: `0` = recommendation clear · `1` = nothing available · `2` = **ask the user** (`Selection.UserPromptRequired`).

## Step 2 — Read `Runtimes` and Commander version

Every detection result includes:

| Field | Use |
|-------|-----|
| `CommanderVersion` | `24.1`, `24.2`, `25.1`, `26.1`, or `master` |
| `VersionProfile` | TCAPI .NET target, required desktop runtime, DevCorner doc URL |
| `SkillReferencePath` | e.g. `reference/versions/25.1/` — open version-matched TCShell docs |
| `SupportedCommanderVersions` | All keys the pack supports |

Override version when path detection is ambiguous (use whichever detector runs):

```powershell
.\Get-CommanderAutomationPaths.ps1 -CommanderVersion 25.1
```

```bash
python3 Get-CommanderAutomationPaths.py --commander-version 24.1
```

Or read `COMMANDER_VERSION` from `%USERPROFILE%\.tricentis\tcshell-ide.env` and [commander-versions.json](reference/commander-versions.json) when no detector runs.

### TCAPI host by Commander version

| Version | TCAPI target | Typical host |
|---------|--------------|--------------|
| **24.1** | net48 + net8 | Windows PowerShell 5.1 or pwsh |
| **24.2** / **25.1** | net8 | pwsh or dotnet script + .NET 8 desktop |
| **26.1** / **master** | net10 | pwsh or dotnet script + .NET 10 desktop |

See [reference/versions/index.md](reference/versions/index.md) and [tcapi.md](tcapi.md).

## Step 3 — Read `Runtimes` (what the machine can use)

Every detection result includes a **`Runtimes`** block. Check this **before** choosing TCAPI or Remote Control.

| Runtime | Used for | Required for automation? |
|---------|----------|--------------------------|
| `Cmd` | **Headless TCShell** — invoke `TCShell.exe` + `.tcs` via batch/cmd | **No** — only needs Windows + Commander |
| `PowerShellCore` / `WindowsPowerShell` | TCAPI `.ps1`, RC client script, `.ps1` detector | Optional |
| `AnyPowerShell` | Shipped `.ps1` helpers | Optional |
| `DotNet` + `DotNetScript` | TCAPI via `.csx` | Optional (needs `dotnet script`) |
| `Python` | `.py` path detector, reference doc generation (dev) | Optional |

**If `AnyPowerShell.Available` is false and `Python.Available` is false:**

- **Still automate** with **Headless TCShell** via cmd/batch (recommended).
- TCAPI only if `DotNetScript.Available` is true.
- Remote Control session probe may be unavailable — DLL may exist but client needs PowerShell or a custom .NET host.

## Step 4 — Read `Paths` (Commander automation routes)

Each path includes:

| Field | Meaning |
|-------|---------|
| `Available` | Can use this route now |
| `HostRequired` | `CmdOrBatch`, `PowerShellOrDotNetScript`, or `PowerShellOrDotNet` |
| `PowerShellRequired` | If true, path cannot run without PowerShell (or equivalent .NET host) |
| `Reason` | Why available or blocked |

| Path Id | Host | PowerShell? | Use when |
|---------|------|-------------|----------|
| `HeadlessTCShell` | cmd/batch | **No** | Batch, `.tcs`, CI, workspace **unlocked** |
| `TCAPI` | PowerShell **or** dotnet script | **Optional** | Typed .NET, workspace **unlocked** |
| `RemoteControl` | PowerShell or .NET client | **Yes** (today) | Workspace **locked**, RC started, GUI-attended |

## Step 5 — Selection rules

1. **Discover runtimes first** — from detector JSON or manual checklist; never assume Python or PowerShell.
2. **Do not invoke `.ps1` helpers** unless `AnyPowerShell.Available` is true.
3. **Do not require Python** — if `.py` fails, use `.ps1` or manual checklist + headless TCShell.
4. **Workspace unlocked** → prefer **Headless TCShell** via cmd (works with only Windows + Commander); TCAPI if a .NET host exists.
5. **Workspace locked** → headless blocked; Remote Control only if available **and** user accepts GUI sync.
6. **No PowerShell** → default to **TCShell.exe + .tcs** via cmd; never fail silently trying `Invoke-TcApi.ps1`.
7. **`Selection.UserPromptRequired`** → stop and ask using `UserPrompt` + `Choices`.

### Intent (`--intent` / `-Intent`)

| Signal | Intent |
|--------|--------|
| `.tcs`, batch, CI | `HeadlessScript` |
| Typed TCAPI / `.csx` | `TypedApi` |
| "what I see", GUI selection | `GuiAttended` |
| Unclear | `Auto` |

## Step 6 — Execute (match host to path)

### Headless TCShell — **no PowerShell required**

Write a `.tcs` file, run once via **cmd** or the IDE terminal:

```bat
"%COMMANDER_HOME%\TCShell\TCShell.exe" -workspace "C:\Projects\Demo.tws" -auth "<token>" "C:\temp\work.tcs"
```

Always `save` before exit. See [workspace-checkout.md](workspace-checkout.md).

### TCAPI — needs a .NET host

Check `Paths[TCAPI].Details.AvailableHosts`:

| Host available | Run |
|----------------|-----|
| `PowerShell` | `Invoke-TcApi.ps1` or inline `Add-Type` — [tcapi.md](tcapi.md) |
| `DotNetScript` only | `dotnet script` + `.csx` — [tcapi.md](tcapi.md) |
| Neither | Use Headless TCShell instead, or ask user to install pwsh / dotnet-script |

### Remote Control — needs PowerShell (or custom .NET client)

Only when `Paths[RemoteControl].Available` is true **and** `AnyPowerShell` is true:

```powershell
. .\lib\TcShellRemoteControl.ps1
$rc = Connect-TcShellRemoteControl -CommanderHome $env:COMMANDER_HOME
Invoke-TcShellRemoteCommand -RemoteControl $rc -Command 'print Name'
Close-TcShellRemoteControl -Session $rc
```

See [remote-control.md](remote-control.md).

## Agent workflow (mandatory)

```
1. Try Get-CommanderAutomationPaths.ps1 OR .py — whichever executes; else manual checklist
2. Read Runtimes — note Cmd, AnyPowerShell, DotNetScript, Python (all optional except Cmd on Windows)
3. Read Paths — note Available, HostRequired, PowerShellRequired
4. If Selection.UserPromptRequired → ask user
5. Execute using a host that matches the chosen path and available runtimes
6. Multi-user edits → checkout rules (workspace-checkout.md)
```

## When to prompt the user

| Situation | Ask |
|-----------|-----|
| No detector script runs | Proceed with manual checklist + headless TCShell? |
| No PowerShell, TCAPI needs host | Use TCShell (cmd) or install pwsh/dotnet-script? |
| Workspace locked | Close Commander vs start Remote Control? |
| TCShell + TCAPI both available | Script vs typed API? |
| No workspace path | Which `.tws`? |
| RC needed but no PowerShell | Cannot probe/use RC — close Commander for headless? |

## Manual checklist (no scripts)

If **neither** `.ps1` nor `.py` detector runs (blocked, absent, or sandboxed), the agent checks manually — this is a **valid** path, not a failure:

1. **OS** — Commander automation requires **Windows**.
2. **COMMANDER_HOME** — folder contains `TCShell\TCShell.exe` and/or `TCAPI.dll` (or read from `.tricentis\tcshell-ide.env`).
3. **Commander version** — from install path, env, or `commander-versions.json` in the IDE pack.
4. **Workspace** — path to `.tws`; read `{workspace}.tws.txt` if present (holder = locked).
5. **cmd** — `%SystemRoot%\System32\cmd.exe` exists → can run TCShell directly.
6. **PowerShell** — `where pwsh` / `where powershell` → enables `.ps1` helpers and RC script.
7. **Python** — `where python` / `where python3` → enables `.py` detector only (optional).
8. **dotnet** — `dotnet --version` and `dotnet script --version` → TCAPI without PowerShell.
9. **Commander GUI** — `tasklist /FI "IMAGENAME eq ToscaCommander.exe"` → workspace may be locked.
10. **Remote Control** — only if user started it in Commander; requires PowerShell client today.

If steps 1–5 pass and workspace is unlocked → use **Headless TCShell via cmd/batch** (no Python, no PowerShell required).
