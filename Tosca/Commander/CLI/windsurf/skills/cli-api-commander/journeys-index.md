# User journeys — intent router

Map user intent to the minimum doc chain. Load **one** workflow or orchestration doc per turn.

## Token budget

| Load | Max per session turn |
|------|----------------------|
| This file + one companion | 1 companion |
| One workflow template | 1 workflow |
| Generated reference | 1 file, **one `##` section** (never full output-patterns.md) |

## Session start (every automation)

| Step | Document | Why |
|------|----------|-----|
| 1 | [path-selection.md](path-selection.md) | Detect runtimes, Commander version, best path |
| 2 | [workspace-checkout.md](workspace-checkout.md) | Lock/checkout rules before edits |

## By user intent

| User says | Read first | Workflow / next |
|-----------|------------|-----------------|
| "What's in my workspace?" | [inspect-workspace.md](reference/workflows/inspect-workspace.md) | Read-only; no save |
| "Create a test case" | [create-test-case.md](reference/workflows/create-test-case.md) | Checkout gate if multi-user |
| "Add a step to my test case" | [add-manual-step.md](reference/workflows/add-manual-step.md) | Manual step via TCShell |
| "Run a task / checkout / import" | [execute-task.md](reference/workflows/execute-task.md) | [tasks.md](reference/tasks.md) for names |
| "Save / check in my changes" | [save-and-checkin.md](reference/workflows/save-and-checkin.md) | `save` always; `checkinall` multi-user |
| "Run execution list" | [run-execution-list.md](reference/workflows/run-execution-list.md) | Samples in Templates folder |
| "Create a new workspace" | [create-workspace.md](reference/workflows/create-workspace.md) | Commander must be closed |
| "Search test cases with .NET" | [tcapi.md](tcapi.md) | `examples/tcapi/` |
| "Automate what I see in GUI" | [remote-control.md](remote-control.md) | Last resort; user consent |
| "Commander is open — automate anyway" | [workspace-checkout.md](workspace-checkout.md) | Close Commander for headless, or Remote Control with consent |
| "Data Integrity comparison" | — | **Not supported** — DI is not available via TCShell, TCAPI, or Remote Control |
| "Complex / unfamiliar command" | [reference/examples-catalog.md](reference/examples-catalog.md) | Then **one** of scenarios-index or commands.md — not both in same turn |

## Execution path companions

| Path Id | Companion |
|---------|-----------|
| `HeadlessTCShell` | Workflow templates above + [output-parsing.md](output-parsing.md) |
| `TCAPI` | [tcapi.md](tcapi.md) + `examples/tcapi/` |
| `RemoteControl` | [remote-control.md](remote-control.md) |

## Verify before reporting success

1. [reference/scenarios-index.md](reference/scenarios-index.md) — pick matching scenario and fixture name
2. Search **only that fixture's** `##` section in [reference/output-patterns.md](reference/output-patterns.md) — do **not** load the entire file (1400+ lines)
3. [reference/commands.md](reference/commands.md) — full syntax if output mismatches

## Scope boundary

| Scenario | This skill |
|----------|------------|
| Commander closed, CI, batch | TCShell / TCAPI |
| Workspace locked, GUI-attended | Remote Control (with consent) |
| Data Integrity | **Not available** |
| Commander open, in-process automation | **Not available** — close Commander or use Remote Control |
