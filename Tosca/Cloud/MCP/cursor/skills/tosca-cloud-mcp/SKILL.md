---
name: tosca-cloud-mcp
description: >-
  Automates Tosca Cloud via the cloud MCP server — inventory search, playlists, execution
  runs, Builder test cases, and Data Integrity. Use for Tosca Cloud automation, /tosca-cloud-mcp,
  hosted Tosca Cloud MCP, or when Tosca Cloud MCP tools connect. Does NOT cover tester journey workflows (see
  AGENTS.md journey skills).
---

# Tosca Cloud MCP — space automation

Automate Tosca Cloud through the **hosted HTTP MCP server** at `https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp`. Requires a connected tenant with valid Okta bearer token and configured `spaceId`.

**MCP tool names:** bare names (`tosca_inventory_search`) when Tosca Cloud is the only MCP server; `tosca-cloud:tosca_inventory_search` when multiple servers are connected.

## Session checklist

Copy and track progress:

```text
Tosca Cloud MCP session:
- [ ] Readiness — when-to-use-mcp.md; tosca_organization_listWorkspaces succeeds
- [ ] Mode — code-mode.md OR direct-tool-mode.md
- [ ] Intent doc — tool / space / playlist / builder / di orchestration (one only)
- [ ] Plan — script or numbered tool table before first mutation
- [ ] Execute — search before mutate; explicit entityIds
- [ ] Verify — re-read artifact or run status after mutations
```

## Conditional routing

| User goal | Read first | Then |
|-----------|------------|------|
| Is MCP appropriate? | [when-to-use-mcp.md](when-to-use-mcp.md) | Classify intent below |
| Read-only / audit | [tool-orchestration.md](tool-orchestration.md) | `tosca_inventory_search` → inspect |
| Edit artifacts / folders | [inventory-orchestration.md](inventory-orchestration.md) | Search → mutate |
| Playlist / execution | [playlist-orchestration.md](playlist-orchestration.md) | Search → run → poll |
| Execution logs / run detail | [execution-orchestration.md](execution-orchestration.md) | Recent runs → log tools |
| Builder / test cases | [builder-orchestration.md](builder-orchestration.md) | Search → scaffold/edit |
| Mobile connections | [mobile-orchestration.md](mobile-orchestration.md) | List → create/update |
| API execution connections | [apiexecution-orchestration.md](apiexecution-orchestration.md) | List → create/update |
| API simulation deploy | [simulation-orchestration.md](simulation-orchestration.md) | Deploy → verify agent |
| Data Integrity | [di-orchestration.md](di-orchestration.md) | One DI reference file below |
| Tester journey (analyze, author, explain) | Journey skills — see repo `AGENTS.md` | Pick one journey skill |

## Execution modes

| Mode | When | Document |
|------|------|----------|
| **Code Mode** (preferred) | IDE has code execution / programmatic MCP | [code-mode.md](code-mode.md) |
| **Direct tool mode** (fallback) | MCP tools only, one call per turn | [direct-tool-mode.md](direct-tool-mode.md) |

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

## Data Integrity reference (pick one)

Load [di-orchestration.md](di-orchestration.md) first, then **one** file:

| Scenario | File |
|----------|------|
| Index / router | [reference/di/index.md](reference/di/index.md) |
| Overview | [reference/di/overview.md](reference/di/overview.md) |
| Conventions | [reference/di/conventions.md](reference/di/conventions.md) |
| Row-by-row comparison | [reference/di/workflows/01-row-by-row-comparison.md](reference/di/workflows/01-row-by-row-comparison.md) |
| File comparison | [reference/di/workflows/02-file-comparison.md](reference/di/workflows/02-file-comparison.md) |
| DB Expert testcase | [reference/workflows/di-db-expert-testcase.md](reference/workflows/di-db-expert-testcase.md) |

## Tool reference (on demand)

| Resource | Purpose |
|----------|---------|
| [reference/tools-catalog.md](reference/tools-catalog.md) | Tool names and parameters (generated) |
| [reference/tools-index.md](reference/tools-index.md) | Quick tool lookup by domain |
| [reference/workflows-index.md](reference/workflows-index.md) | Workflow template index |
| [tool-planning.md](tool-planning.md) | Planning primitives |

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| Tosca Cloud tenant | `https://{tenant}.my.tricentis.com` (production) |
| MCP connected | User configured tenant in IDE Settings → MCP |
| Space configured | `spaceId` in MCP URL path |
| Entitlements | Some tools require product entitlements |

## When MCP is unavailable

Use the Tosca Cloud portal UI or REST APIs directly.

## Journey skills (tester workflows)

For analyze / remediate / author / explain journeys, use the PM journey skills in this repo — see root [AGENTS.md](../../AGENTS.md). Engineering skill handles tool orchestration; journey skills handle user-story workflows.
