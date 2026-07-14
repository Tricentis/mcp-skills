# Architecture — CLI & API Commander

> **Agent navigation:** Hub doc — read for overview only; **do not follow nested links in the same turn**. Return to [journeys-index.md](../journeys-index.md) for the next doc.

How local IDE agents automate Tosca Commander through **shell/stdio** (no MCP server in this pack).

## Design principles

1. **Shell/stdio execution** — TCShell, TCAPI, or Remote Control via the IDE terminal and this skill.
2. **Do not assume PowerShell or Python** — run path detection (`.ps1` or `.py`); if neither runs, use the manual checklist in [path-selection.md](../path-selection.md). Headless TCShell uses **cmd/batch** only.
3. **Plain-text output** — TCShell emits human-readable stdout/stderr; agents parse in context ([output-parsing.md](../output-parsing.md)).
4. **Progressive disclosure** — `SKILL.md` routes; command syntax and golden outputs live in `reference/` (load on demand).
5. **Always detect first** — run path detection before choosing Headless, TCAPI, or Remote Control.

## Execution modes

| Mode | Binary / surface | When | PowerShell? |
|------|------------------|------|-------------|
| **Headless TCShell** | `TCShell.exe` + `.tcs` | Workspace **unlocked** — default | **No** |
| **TCAPI** | `TCAPI.dll` via `.ps1` or `.csx` | Typed .NET; workspace unlocked | Optional |
| **Remote Control** | `TOSCARemoteControl` IPC | Workspace **locked**, RC started, user consent | Yes (today) |

Shared command language for TCShell and Remote Control: `CommandInterpreter` syntax (`JumpToNode`, `task`, `save`, `checkinall`, …).

### Headless TCShell

```bat
"%COMMANDER_HOME%\TCShell\TCShell.exe" -workspace "C:\path\workspace.tws" -auth "<token>" script.tcs
```

- Separate process — no Commander GUI required.
- Batch `.tcs` is non-interactive; **call `save` before `exit`** or changes are lost.
- See [workspace-checkout.md](../workspace-checkout.md) for lock rules.

### TCAPI

Load `%COMMANDER_HOME%\TCAPI.dll` in-process. Host selection is version-aware — see [tcapi.md](../tcapi.md) and [tcapi-compatibility.json](tcapi-compatibility.json).

### Remote Control

Last resort when workspace is locked and user accepts GUI-attended work. User must start Remote Control in Commander. See [remote-control.md](../remote-control.md).

## Workspace lock

`{workspace}.tws.txt` holds an exclusive lock. If Commander GUI has the workspace open, headless TCShell and TCAPI fail with **workspace locked**.

| State | Paths |
|-------|-------|
| Unlocked | Headless TCShell (preferred), TCAPI |
| Locked | Remote Control, or close Commander for headless |

## Path detection output

| Field | Use |
|-------|-----|
| `Runtimes` | cmd, PowerShell, dotnet-script, Python availability |
| `CommanderVersion` | `24.1` … `26.1`, `master` |
| `SkillReferencePath` | e.g. `reference/versions/25.1/` |
| `Paths[]` | `HeadlessTCShell`, `TCAPI`, `RemoteControl` availability |
| `Selection.UserPromptRequired` | Stop and ask the user |

Exit codes: `0` = clear · `1` = nothing available · `2` = prompt required.

## Out of scope (this skill)

- **Data Integrity** — not available via TCShell, TCAPI, or Remote Control
- **In-process Commander automation** — shell/stdio only; Commander-open task APIs are a different surface

## Reference bundle

Version-matched TCShell docs: [versions/index.md](versions/index.md). Commander compatibility matrix: [commander-compatibility.md](commander-compatibility.md).
