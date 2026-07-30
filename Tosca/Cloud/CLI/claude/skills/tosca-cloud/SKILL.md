---
name: tosca-cloud
description: >-
  Automates Tosca Cloud via toscactl (default) and tn for CLI gaps. Use for Tosca Cloud CLI,
  toscactl commands, or tn --loop for Builder/DI/mobile gaps. Does NOT cover on-prem Commander
  (use Commander CLI pack in this repository — ../../../../../Commander/CLI/README.md).
---

# Tosca Cloud — hybrid CLI automation

**Default runtime:** **`toscactl`**. **Gap runtime:** **`tn`** (`/tosca` MCP, `--loop`, `--robot`) for Builder, DI, mobile, loop, and robot — see [runtime-routing.md](runtime-routing.md).

**Prerequisite:** `toscactl login` + workspace set. For gap workflows: `configure_tn_connection.py` + `tn --setup`.

## Session checklist

```text
Tosca Cloud session:
- [ ] python3 verify_toscactl.py (default path)
- [ ] runtime-routing.md — pick toscactl vs tn
- [ ] Intent — journeys-index.md OR one workflow
- [ ] Execute — toscactl --json --silent OR tn per routing
- [ ] Verify — re-read artifact or run state
```

## Execution modes

| Runtime | When | Doc |
|---------|------|-----|
| **toscactl** | Connect, search, run, diagnose, history, agents, datasets | [toscactl-invocation.md](toscactl-invocation.md) |
| **tn** | Builder, DI, mobile, loop, robot (CLI gaps) | [tn-invocation.md](tn-invocation.md) |

## Conditional routing

| User goal | Read first | Runtime |
|-----------|------------|---------|
| Pick runtime | [runtime-routing.md](runtime-routing.md) | — |
| Pick path / detect CLIs | [path-selection.md](path-selection.md) | both |
| Map intent to docs | [journeys-index.md](journeys-index.md) | per skill |
| toscactl commands | [toscactl-invocation.md](toscactl-invocation.md) · vendored `tosca-commands/*` | toscactl |
| tn gap workflows | [tn-invocation.md](tn-invocation.md) | tn |
| Playlist / execution | [playlist-orchestration.md](playlist-orchestration.md) | toscactl |
| Builder / test cases | [builder-orchestration.md](builder-orchestration.md) | tn |
| Data Integrity | [di-orchestration.md](di-orchestration.md) | tn (+ toscactl datasets for TDM) |
| Mobile / API execution / simulation | respective orchestration | tn |
| Tester journey | [journeys-index.md](journeys-index.md) | per skill |

## Workflow templates

| Workflow | File | Runtime |
|----------|------|---------|
| Connect tenant | [connect-tenant.md](reference/workflows/connect-tenant.md) | toscactl |
| Inspect space | [inspect-space.md](reference/workflows/inspect-space.md) | toscactl |
| Search artifacts | [search-artifacts.md](reference/workflows/search-artifacts.md) | toscactl |
| Run playlist | [run-playlist.md](reference/workflows/run-playlist.md) | toscactl |
| Analyze run failures | [analyze-run-failures.md](reference/workflows/analyze-run-failures.md) | toscactl |
| Create playlist | [create-playlist.md](reference/workflows/create-playlist.md) | toscactl |
| Manage folder | [manage-folder.md](reference/workflows/manage-folder.md) | tn |
| Rename playlist items | [rename-playlist-items.md](reference/workflows/rename-playlist-items.md) | tn |
| Scaffold test case | [scaffold-test-case.md](reference/workflows/scaffold-test-case.md) | tn |
| Manage API message | [manage-api-message.md](reference/workflows/manage-api-message.md) | tn |
| Data Integrity | [di-getting-started.md](reference/workflows/di-getting-started.md) | tn |
| Loop / robot | [loop-autonomous.md](reference/workflows/loop-autonomous.md), [robot-monitoring.md](reference/workflows/robot-monitoring.md) | tn |

Full index: [reference/workflows-index.md](reference/workflows-index.md)

## Vendored toscactl command skills

Command skills in this pack include `tosca-find`, `tosca-run`, `tosca-setup`, `toscactl-reference`, `tosca-agents`, `tosca-datasets`, and others (sibling folders in this IDE tree).

## Journey skills

See [journeys-index.md](journeys-index.md). Consumer packs include `AGENTS.md.fragment` for routing.

## Out of scope

| Capability | Use instead |
|------------|-------------|
| On-prem Commander | [Commander CLI](../../../../../Commander/CLI/README.md) |
| Direct IDE MCP (no CLI) | [Tosca Cloud MCP](../../../../MCP/README.md) |
