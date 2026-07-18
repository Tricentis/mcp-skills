# TCAPI — use the DLL directly from the command line

**TCAPI is a .NET library, not an executable.** Load `TCAPI.dll` from `%COMMANDER_HOME%` in-process via **PowerShell** or **dotnet script** — no separate wrapper executable.

## Contents

- [Step 0 — check runtimes](#step-0--check-runtimes-and-path-required)
- [Commander version → host](#commander-version--tcapi-host)
- [PowerShell path](#powershell-path-when-available)
- [dotnet script path](#dotnet-script-path-when-powershell-unavailable-or-agent-prefers-c)
- [TCAPI vs TCShell](#when-to-use-tcapi-vs-tcshell)
- [Agent workflow](#agent-workflow)
- [Official docs](#official-docs)
- [Troubleshooting](#troubleshooting)

## Step 0 — check runtimes and path (required)

Run path detection with **whichever detector executes** — `.ps1` or `.py` (same JSON). If neither runs, use the manual checklist in [path-selection.md](path-selection.md) and read `commander-versions.json` / `tcapi-compatibility.json` from the pack.

```powershell
.\Get-CommanderAutomationPaths.ps1
```

```bash
python3 Get-CommanderAutomationPaths.py
```

Read `Runtimes` and `Paths[TCAPI].Details.AvailableHosts` before choosing TCAPI.

If PowerShell **is** available, optional detail:

```powershell
.\Get-TcApiRuntime.ps1
# or
.\Invoke-TcApi.ps1 -DetectOnly
```

Detection is **version-aware** for Commander **24.1, 24.2, 25.1, 26.1, and master**. It reads:

- `COMMANDER_VERSION` or `%USERPROFILE%\.tricentis\tcshell-ide.env` (from installer)
- Commander install path (e.g. `...\Tosca Commander 25.1\`)
- [commander-versions.json](reference/commander-versions.json)
- [tcapi-compatibility.json](reference/tcapi-compatibility.json)

Example output:

```json
{
  "CommanderVersion": "25.1",
  "VersionProfile": {
    "TcApiTargets": ["net8.0-windows"],
    "DotNetDesktopRuntime": "8.0",
    "DocBaseUrl": "https://documentation.tricentis.com/devcorner/2025.1/tcapi/webindex.html"
  },
  "RecommendedPowerShellHost": "pwsh",
  "RecommendedMode": "powershell",
  "Reason": "Commander 25.1 ... use pwsh to load TCAPI.dll."
}
```

| Field | Agent action |
|-------|--------------|
| `RecommendedMode` | `powershell` → `.ps1` · `dotnet-script` → `.csx` · `none` → fix `Reason` |
| `RecommendedPowerShellHost` | `pwsh` vs `windows-powershell` (24.1 net48 fallback) |
| `VersionProfile.DocBaseUrl` | Use version-matched TCAPI docs, not always 26.1 |
| `DotNetDesktopRuntimeInstalled` | Required for `.csx` on that Commander version |

### Commander version → TCAPI host

| Version | TCAPI target | Preferred host | .NET desktop runtime |
|---------|--------------|----------------|----------------------|
| **24.1** | net48 + net8 | pwsh, fallback **Windows PowerShell 5.1** | 8.0 for net8 / dotnet script |
| **24.2** | net8 | pwsh | 8.0 |
| **25.1** | net8 | pwsh | 8.0 |
| **26.1** | net10 | pwsh | 10.0 |
| **master** | net10 | pwsh | 10.0 |

`Invoke-TcApi.ps1` **re-launches in the recommended PowerShell host** when the current shell is wrong (e.g. pwsh on 24.1 net48 → Windows PowerShell 5.1).

## PowerShell path (when available)

```powershell
$env:COMMANDER_HOME = "C:\Program Files\Tricentis\Tosca\Commander"
Add-Type -Path "$env:COMMANDER_HOME\TCAPIObjects.dll"
Add-Type -Path "$env:COMMANDER_HOME\TCAPI.dll"

$api = [Tricentis.TCAPI.TCAPI]::CreateInstance()
$ws  = $api.OpenWorkspace("C:\Projects\Demo.tws", "Admin", "")
$ws.GetProject().Search('=>SUBPARTS:TestCase') | ForEach-Object { $_.Name }
$ws.Save(); $api.CloseWorkspace()
```

Helpers: dot-source `lib/TcApiSession.ps1` (Add-Type + reflection fallback).

```powershell
.\Invoke-TcApi.ps1 -Workspace C:\Projects\Demo.tws -ScriptPath .\search-testcases.ps1
```

## dotnet script path (when PowerShell unavailable or agent prefers C#)

Install once if detection reports missing:

```powershell
dotnet tool install -g dotnet-script
```

Write `.csx` with placeholder paths (patched at run time):

```csharp
#r "COMMANDER_HOME\TCAPIObjects.dll"
#r "COMMANDER_HOME\TCAPI.dll"
```

Run:

```powershell
.\Invoke-TcApi.ps1 -Workspace C:\Projects\Demo.tws -ScriptPath .\search-testcases.csx
```

`Invoke-TcApi.ps1` replaces `COMMANDER_HOME` in `#r` lines before calling `dotnet script`.

## When to use TCAPI vs TCShell

| Scenario | Tool |
|----------|------|
| Typed object access (search, create TC/EL) | **TCAPI** via `.ps1` or `.csx` |
| Headless batch, `.tcs` scripts, CI | **TCShell** |
| GUI-attended | **Remote Control** + TCShell |
| Module blueprints | **XScan in Commander UI** — not TCAPI |

## Agent workflow

1. Run path detection (`.ps1`, `.py`, or manual checklist) — read `VersionProfile` and `AvailableHosts`.
2. If using PowerShell helpers: `Get-TcApiRuntime.ps1` or `Invoke-TcApi.ps1 -DetectOnly` for host detail.
3. Author `.ps1` or `.csx` matching an **available** host from detection.
4. Run via `Invoke-TcApi.ps1`, `dotnet script`, or inline PowerShell — only if that host is available.
5. Always save and close the workspace when done.

Examples: [examples/tcapi/](examples/tcapi/)

## Official docs

- [TCAPI overview](https://documentation.tricentis.com/devcorner/2026.1/tcapi/topic2.html)
- [TCAPI web index](https://documentation.tricentis.com/devcorner/2026.1/tcapi/webindex.html)

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `RecommendedMode: none` | Read `Reason`; set `COMMANDER_HOME`, use Windows |
| `Add-Type` fails on 24.1 | Use detected `RecommendedPowerShellHost`; try Windows PowerShell 5.1 |
| Wrong TCAPI docs | Use `VersionProfile.DocBaseUrl` from detection output |
| .NET runtime missing | Install `Microsoft.WindowsDesktop.App` version from `VersionProfile.DotNetDesktopRuntime` |
| `.csx` but no dotnet script | `dotnet tool install -g dotnet-script` |
| Wrong host chosen | Pass `-Prefer PowerShell` or `-Prefer DotNetScript` |
