# Data Integrity orchestration — Cloud DI tools

DI tools have **strict ordering**, **entitlement gating**, and **async polling**. There is no separate DI journey skill — route all DI user stories through **`tosca-cloud`** (this file + one reference doc).

**Gate:** call `tosca_dataintegrity_workflow` first. Read the **full** output (inline or from a saved file) before any other DI tool.

Copy and track progress:

```text
DI workflow:
- [ ] Phase 1 — This file + one reference/di/*.md or workflow
- [ ] Phase 2 — listConnections; test/schema (async poll)
- [ ] Phase 3 — createRowByRowComparison or createDiDbExpertTestcase
- [ ] Phase 4 — Verify test case via inventory search
```

## Contents

- [Step 0 — Route before any DI tool](#step-0--route-before-any-di-tool)
- [DI orchestration phases](#di-orchestration-phases)
- [Async polling](#async-polling)
- [Scenario → reference file](#scenario--reference-file)
- [When to prompt the user](#when-to-prompt-the-user)
- [Anti-patterns](#anti-patterns)

## Step 0 — Route before any DI tool

1. Confirm MCP readiness ([when-to-use-mcp.md](when-to-use-mcp.md) — `tosca_organization_listWorkspaces`).
2. Read this file (phases + gates).
3. Open [reference/di/index.md](reference/di/index.md) and pick **one** supplemental doc or workflow.

**Do not call** `tosca_dataintegrity_listConnections`, `tosca_dataintegrity_getConnectionSchema`, `tosca_dataintegrity_createRowByRowComparison`, or other DI tools until you have read the routing doc(s) for your scenario.

## DI orchestration phases

```
Phase 1  Read skill docs           → this file + one reference/di/*.md
Phase 2  Connections / schema     → listConnections; testConnection or getConnectionSchema (async)
Phase 3  Build test artifacts     → createRowByRowComparison | createDiDbExpertTestcase
Phase 4  Verify                   → tosca_inventory_search for created test case
```

Cloud mutations persist immediately — there is no save/check-in step.

## Phase 2 — Connections and schema

| Tool | When | Orchestration note |
|------|------|-------------------|
| `tosca_dataintegrity_listConnections` | Start of every DI flow | Present list; user picks source/target |
| `tosca_dataintegrity_connection` | Get or delete by id | **Delete is destructive** — confirm first |
| `tosca_dataintegrity_testConnection` | Validate connectivity | Async — poll `checkTestConnectionResult` |
| `tosca_dataintegrity_getConnectionSchema` | Column metadata for SQL/RowKey | Async — poll `checkSchemaResult`; open `launcherLink` on user machine |

> **Connections are managed in the Tosca Cloud UI.** MCP cannot create or update DI connections.

## Phase 3 — Create comparison artifacts

| Tool | When |
|------|------|
| `tosca_dataintegrity_createRowByRowComparison` | Row-by-row or file comparison test case |
| `tosca_dataintegrity_createDiDbExpertTestcase` | DB Expert test case with prefilled connection |

Confirm SQL, RowKey, and connection names with the user before create.

## Async polling

Schema and test-connection tools are **async**:

1. Start tool returns `notificationId` (and often `launcherLink` for schema)
2. Poll `tosca_dataintegrity_checkSchemaResult` or `tosca_dataintegrity_checkTestConnectionResult`
3. Proceed when complete

## Scenario → reference file

| User goal | Read |
|-----------|------|
| Row-by-row DB comparison | [workflows/01-row-by-row-comparison.md](reference/di/workflows/01-row-by-row-comparison.md) |
| File vs DB or file vs file | [workflows/02-file-comparison.md](reference/di/workflows/02-file-comparison.md) |
| DB Expert testcase | [workflows/di-db-expert-testcase.md](reference/workflows/di-db-expert-testcase.md) |
| Tool list + connection notes | [overview.md](reference/di/overview.md) |
| RowKey rules | [conventions.md](reference/di/conventions.md) |
| Short tn loop or REPL plan | [workflows/di-getting-started.md](reference/workflows/di-getting-started.md) |

## When to prompt the user

| Situation | Ask |
|-----------|-----|
| Entitlement error | User may need DI license — report and stop |
| Custom ODBC / schema fails | Ask user to describe tables/columns manually |
| RowKey unclear | Which column(s) uniquely identify a row? |
| Connection create/update needed | Direct user to Cloud UI — MCP cannot create connections |
| Destructive connection delete | Confirm before `tosca_dataintegrity_connection` delete |

## Anti-patterns

| Avoid | Why |
|-------|-----|
| Load all `reference/di/` files | Progressive disclosure — one scenario at a time |
| Skip `tosca_dataintegrity_workflow` | Mandatory gate; embeds full agent guide |
| Assume schema poll is instant | Must poll check tools after launcher steps |
| DI tools before reading scenario doc | Wrong SQL, wrong RowKey, failed comparisons |

## Related

- [reference/di/index.md](reference/di/index.md)
- [reference/workflows/di-getting-started.md](reference/workflows/di-getting-started.md)
- [tool-orchestration.md](tool-orchestration.md)
