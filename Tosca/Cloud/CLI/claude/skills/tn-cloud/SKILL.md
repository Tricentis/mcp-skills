---
name: tn-cloud
description: >-
  Automates Tosca Cloud via the Tricentis TN CLI — /tosca mode, native MCP OAuth, loop and robot
  agents. Use for /tn-cloud, Tosca Cloud CLI, tn --loop, or when IDE agents should delegate to tn
  instead of direct MCP. Does NOT cover tester journey workflows (use journey skills via journeys-index.md).
---

# TN Cloud — CLI automation

Automate Tosca Cloud through **`tn`** (Tricentis TN CLI). TN connects to hosted MCP with **native OAuth** (no `mcp-remote`), scopes tools via **`/tosca`**, and supports **REPL**, **piped**, **`--loop`**, and **`--robot`** execution.

**Prerequisite:** `tn` on PATH and `~/.tn/mcp.json` configured for the tenant. Not set up → **`tn-cloud-connect`**.

## Session checklist

```text
TN Cloud session:
- [ ] Path detection — path-selection.md; tn --version succeeds
- [ ] /tosca mode — activate before Cloud tool use
- [ ] Intent — journeys-index.md OR one orchestration doc
- [ ] Plan — tn command or loop prompt before first mutation
- [ ] Execute — search before mutate via tn tool surface
- [ ] Verify — re-read artifact or run status after mutations
```

## Execution modes

| Mode | When | Command pattern |
|------|------|-----------------|
| **REPL** (default) | Interactive, tool approval, multi-turn | `tn` then `/tosca` |
| **Piped** | Single task, CI, IDE one-shot | `echo "prompt" \| tn` |
| **Loop** | Autonomous multi-step (≤25 turns) | `tn --loop "prompt with /tosca context"` |
| **Robot** | Long-running, resumable monitoring | `tn --robot <agent-id> "task"` |

Load [tn-invocation.md](tn-invocation.md) for full patterns. Prefer **loop** for journeys needing >3 tool rounds without IDE round-trips.

## Conditional routing

| User goal | Read first | Then |
|-----------|------------|------|
| Pick execution path | [path-selection.md](path-selection.md) | Run detector |
| Map intent to docs | [journeys-index.md](journeys-index.md) | One workflow or journey skill |
| Invoke tn correctly | [tn-invocation.md](tn-invocation.md) | REPL / piped / loop / robot |
| Read-only / audit | [tool-orchestration.md](tool-orchestration.md) | `/tosca` → inventory search |
| Edit artifacts / folders | [inventory-orchestration.md](inventory-orchestration.md) | Search → mutate |
| Playlist / execution | [playlist-orchestration.md](playlist-orchestration.md) | Search → run → poll |
| Execution logs | [execution-orchestration.md](execution-orchestration.md) | Recent runs → log tools |
| Builder / test cases | [builder-orchestration.md](builder-orchestration.md) | Search → scaffold/edit |
| Mobile connections | [mobile-orchestration.md](mobile-orchestration.md) | List → create/update |
| API execution | [apiexecution-orchestration.md](apiexecution-orchestration.md) | List → create/update |
| API simulation | [simulation-orchestration.md](simulation-orchestration.md) | Deploy → verify |
| Data Integrity | [di-orchestration.md](di-orchestration.md) | One DI reference file |
| Tester journey | [journeys-index.md](journeys-index.md) journey skills table | Pick one journey skill |

## Workflow templates (pick one)

| Workflow | File |
|----------|------|
| Connect tenant | [reference/workflows/connect-tenant.md](reference/workflows/connect-tenant.md) |
| Inspect space | [reference/workflows/inspect-space.md](reference/workflows/inspect-space.md) |
| Search artifacts | [reference/workflows/search-artifacts.md](reference/workflows/search-artifacts.md) |
| Manage folder | [reference/workflows/manage-folder.md](reference/workflows/manage-folder.md) |
| Create playlist | [reference/workflows/create-playlist.md](reference/workflows/create-playlist.md) |
| Run playlist | [reference/workflows/run-playlist.md](reference/workflows/run-playlist.md) |
| Analyze run failures | [reference/workflows/analyze-run-failures.md](reference/workflows/analyze-run-failures.md) |
| Rename playlist items | [reference/workflows/rename-playlist-items.md](reference/workflows/rename-playlist-items.md) |
| Scaffold test case | [reference/workflows/scaffold-test-case.md](reference/workflows/scaffold-test-case.md) |
| Manage API message | [reference/workflows/manage-api-message.md](reference/workflows/manage-api-message.md) |
| Data Integrity intro | [reference/workflows/di-getting-started.md](reference/workflows/di-getting-started.md) |
| DI DB Expert testcase | [reference/workflows/di-db-expert-testcase.md](reference/workflows/di-db-expert-testcase.md) |
| Mobile connection | [reference/workflows/mobile-connection.md](reference/workflows/mobile-connection.md) |
| API execution connection | [reference/workflows/api-execution-connection.md](reference/workflows/api-execution-connection.md) |
| Deploy simulation | [reference/workflows/deploy-simulation.md](reference/workflows/deploy-simulation.md) |
| Autonomous loop workflow | [reference/workflows/loop-autonomous.md](reference/workflows/loop-autonomous.md) |
| Robot monitoring | [reference/workflows/robot-monitoring.md](reference/workflows/robot-monitoring.md) |

Full index: [reference/workflows-index.md](reference/workflows-index.md)

## TN vs direct MCP (Tosca.Cloud.MCP.integration)

| Concern | Direct MCP (Cursor) | TN CLI (this pack) |
|---------|---------------------|-------------------|
| OAuth | `mcp-remote` + npx | Native HTTP OAuth in tn |
| Tool surface | IDE MCP panel | `/tosca` mode in tn |
| Multi-step autonomy | One tool per IDE turn | `--loop` up to 25 turns |
| Long-running tasks | Not supported | `--robot` with yield/resume |
| File write-back | IDE tools | tn `write_file` / `edit_file` |
| Provider choice | IDE model only | tn multi-provider (AI Hub, Azure, etc.) |

Use **this pack** when tn is the preferred runtime. Use **Tosca.Cloud.MCP.integration** when IDE-native MCP (Code Mode) is required.

## Journey skills (tester workflows)

For analyze / remediate / author / explain journeys, use journey skills — see [journeys-index.md](journeys-index.md). Consumer packs include `AGENTS.md.fragment` for routing.

## Out of scope

| Capability | Status |
|------------|--------|
| On-prem Commander (TCShell) | Use **Tosca.Commander.IDE.integration** |
| Direct IDE MCP without tn | Use **Tosca.Cloud.MCP.integration** |
| In-process Commander automation | Not available |
