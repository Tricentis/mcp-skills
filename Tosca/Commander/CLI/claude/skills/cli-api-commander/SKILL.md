---
name: cli-api-commander
description: >-
  Automates Tosca Commander via TCShell.exe, .tcs batch scripts, TCAPI (.NET), or
  Remote Control. Use for /cli-api-commander, JumpToNode, checkout/checkinall,
  workspace locked, batch mode, .tws workspaces, execution lists, or GUI RC.
  Detects runtimes first. Does NOT cover Data Integrity or in-process Commander automation.
---

# CLI & API Commander

Automate Tosca Commander through **shell/stdio** (TCShell CLI, TCAPI, Remote Control) — **no MCP**.

## Session checklist

Copy and track progress:

```text
CLI/API session:
- [ ] Path detection — path-selection.md; read CommanderVersion + SkillReferencePath
- [ ] Checkout rules — workspace-checkout.md if editing
- [ ] Intent — journeys-index.md → one workflow template
- [ ] Plan — full .tcs script or TCAPI chain before first mutation
- [ ] Execute — scenarios-index.md → one fixture section in output-patterns.md (do not load whole file)
- [ ] Persist — save (and checkinall if multi-user)
```

## Token budget (load on demand)

| Tier | File | ~Lines | When |
|------|------|--------|------|
| L2 | `SKILL.md` | ~100 | Every activation |
| L3 companion | `path-selection.md`, `workspace-checkout.md`, `journeys-index.md` | 50–200 | Session start / intent |
| L3 workflow | `reference/workflows/*.md` | 40–80 | One per task |
| L3 generated | `output-patterns.md`, `commands.md`, `examples-index.md` | 400–1400 | **One section only** — use agent navigation notices |

**Rules:** One doc per turn for workflows. Never load full `output-patterns.md`. Follow [journeys-index.md](journeys-index.md) — do not chain catalog → index → patterns in one turn.

## Conditional routing

| User goal | Read first | Then |
|-----------|------------|------|
| Pick automation path | [path-selection.md](path-selection.md) | Run detector; prompt if ambiguous |
| Map intent to docs | [journeys-index.md](journeys-index.md) | One workflow below |
| Workspace lock / checkout | [workspace-checkout.md](workspace-checkout.md) | Headless vs Remote Control |
| TCAPI (.NET) | [tcapi.md](tcapi.md) | Check `AvailableHosts` from detection |
| GUI-attended (last resort) | [remote-control.md](remote-control.md) | User starts RC; PowerShell required |
| Parse stdout/stderr | [output-parsing.md](output-parsing.md) | Plain text only — no JSON |

## Execution paths

| Path Id | Host needed | PowerShell? | When |
|---------|-------------|-------------|------|
| `HeadlessTCShell` | cmd/batch | **No** | Workspace unlocked — default |
| `TCAPI` | PowerShell or dotnet script | Optional | Typed .NET; needs `AvailableHosts` |
| `RemoteControl` | PowerShell | **Yes** (today) | Workspace locked + RC started + user consent |

**Do not default to Remote Control.** **Module blueprints:** XScan/API Scan in Commander UI only.

## Out of scope (this skill)

| Capability | Status |
|------------|--------|
| **Data Integrity** (comparisons, DI connections, validation runs) | **Not available** via TCShell, TCAPI, or Remote Control |
| In-process Commander automation | **Not available** — shell/stdio only |
| Commander GUI wizard tasks (DI create wizards) | **Not automatable** headless |

## Workflow templates (pick one)

| Workflow | File |
|----------|------|
| Inspect workspace | [reference/workflows/inspect-workspace.md](reference/workflows/inspect-workspace.md) |
| Create test case | [reference/workflows/create-test-case.md](reference/workflows/create-test-case.md) |
| Add manual step | [reference/workflows/add-manual-step.md](reference/workflows/add-manual-step.md) |
| Execute task | [reference/workflows/execute-task.md](reference/workflows/execute-task.md) |
| Persist changes | [reference/workflows/save-and-checkin.md](reference/workflows/save-and-checkin.md) |
| Run execution list | [reference/workflows/run-execution-list.md](reference/workflows/run-execution-list.md) |
| Create workspace | [reference/workflows/create-workspace.md](reference/workflows/create-workspace.md) |

Full index: [reference/workflows-index.md](reference/workflows-index.md)

## Path detection (always first)

Run detectors and read JSON — full commands in [path-selection.md](path-selection.md#step-1--run-detection).

Read `CommanderVersion`, `VersionProfile`, `SkillReferencePath`, `Runtimes`, `Paths`. If `Selection.UserPromptRequired` → present choices; do not proceed until user picks.

## Headless TCShell (minimum path)

`TCShell.exe -workspace "<.tws>" [-auth | -login] script.tcs` via cmd — see [path-selection.md](path-selection.md#step-6--execute-match-host-to-path). **Batch mode:** always `save` before exit.

## When Commander is open

Headless TCShell and TCAPI **cannot open a locked workspace**. Options within this skill:

- Ask user to **close Commander**, then run headless TCShell / TCAPI
- **Remote Control** only with explicit user consent (GUI sync side effects)
- **Data Integrity** — not supported; inform user

## Commander version (24.1–master)

Use `SkillReferencePath` from detection. Index: [reference/versions/index.md](reference/versions/index.md). Root `reference/` defaults to **26.1**.

## Complex workflows (on demand)

Load **one reference file per turn** — routing table in [journeys-index.md](journeys-index.md#verify-before-reporting-success).

## Architecture

[reference/architecture.md](reference/architecture.md) — hub doc; do not follow nested links in the same turn.
