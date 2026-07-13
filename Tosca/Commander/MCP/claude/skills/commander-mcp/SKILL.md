---
name: commander-mcp
description: >-
  Automates Tosca Commander via in-process MCP when Commander is open with a
  workspace — checkout, tasks, test cases, and Data Integrity. Use for Tosca
  automation, /commander-mcp, McpServerAddIn, or when Commander MCP tools
  connect. Does NOT cover headless TCShell, TCAPI, Remote Control, or CI when
  Commander is closed (use Tosca.Commander.IDE.integration).
---

# Commander MCP — workspace automation

Automate Tosca Commander through the **HTTP MCP server** (`McpServerAddIn`, Commander 26.1+). Commander must be **running** with a workspace open.

**MCP tool names:** bare names (`get_workspace_info`) when Commander is the only MCP server; `tosca-commander:tool_name` when multiple servers are connected.

## Session checklist

Copy and track progress:

```text
Commander MCP session:
- [ ] Readiness — when-to-use-mcp.md; get_workspace_info succeeds
- [ ] Mode — code-mode.md OR direct-tool-mode.md
- [ ] Intent doc — tool / workspace / task / di orchestration (one only)
- [ ] Plan — script or numbered tool table before first mutation
- [ ] Execute — discover before mutate; explicit objectIds
- [ ] Persist — save_workspace / check_in_all at end
```

## Conditional routing

| User goal | Read first | Then |
|-----------|------------|------|
| Is MCP appropriate? | [when-to-use-mcp.md](when-to-use-mcp.md) | Classify intent below |
| Read-only / audit | [tool-orchestration.md](tool-orchestration.md) | `get_workspace_info` → navigate |
| Edit attributes / checkout | [workspace-orchestration.md](workspace-orchestration.md) | Checkout → mutate → save |
| Context-menu task | [task-orchestration.md](task-orchestration.md) | `list_available_tasks` → `execute_task` |
| Data Integrity | [di-orchestration.md](di-orchestration.md) | One DI reference file below |

## Execution modes

| Mode | When | Document |
|------|------|----------|
| **Code Mode** (preferred) | IDE has code execution / programmatic MCP | [code-mode.md](code-mode.md) |
| **Direct tool mode** (fallback) | MCP tools only, one call per turn | [direct-tool-mode.md](direct-tool-mode.md) |

## Workflow templates (pick one)

| Workflow | File |
|----------|------|
| Inspect workspace | [reference/workflows/inspect-workspace.md](reference/workflows/inspect-workspace.md) |
| Create test case | [reference/workflows/create-test-case.md](reference/workflows/create-test-case.md) |
| Add step to test case | [reference/workflows/add-step-to-existing-test-case.md](reference/workflows/add-step-to-existing-test-case.md) |
| Run Commander task | [reference/workflows/execute-task.md](reference/workflows/execute-task.md) |
| Persist changes | [reference/workflows/save-and-checkin.md](reference/workflows/save-and-checkin.md) |
| Data Integrity intro | [reference/workflows/di-getting-started.md](reference/workflows/di-getting-started.md) |

## Data Integrity reference (pick one)

Load [di-orchestration.md](di-orchestration.md) first, then **one** file:

| Scenario | File |
|----------|------|
| Index / router | [reference/di/index.md](reference/di/index.md) |
| Overview | [reference/di/overview.md](reference/di/overview.md) |
| Conventions | [reference/di/conventions.md](reference/di/conventions.md) |
| SAP endpoints | [reference/di/sap-endpoints.md](reference/di/sap-endpoints.md) |
| Options / reports | [reference/di/comparison-options-and-reports.md](reference/di/comparison-options-and-reports.md) |
| SQL Server vs SQLite | [reference/di/workflows/01-sql-server-vs-sqlite.md](reference/di/workflows/01-sql-server-vs-sqlite.md) |
| SAP vs database | [reference/di/workflows/02-sap-vs-sql-server.md](reference/di/workflows/02-sap-vs-sql-server.md) |
| Database vs CSV | [reference/di/workflows/03-database-vs-csv.md](reference/di/workflows/03-database-vs-csv.md) |
| JDBC vs ODBC | [reference/di/workflows/04-jdbc-vs-odbc.md](reference/di/workflows/04-jdbc-vs-odbc.md) |
| Column renames | [reference/di/workflows/05-column-renames.md](reference/di/workflows/05-column-renames.md) |
| Lineage CSV | [reference/di/workflows/06-lineage-csv.md](reference/di/workflows/06-lineage-csv.md) |
| DB Expert / data quality | [reference/di/workflows/07-db-expert-data-quality.md](reference/di/workflows/07-db-expert-data-quality.md) |

## Tool reference (on demand)

| Resource | Purpose |
|----------|---------|
| [reference/tools-catalog.md](reference/tools-catalog.md) | Tool names and parameters (generated) |
| [reference/tools-index.md](reference/tools-index.md) | Quick tool lookup |
| [reference/workflows-index.md](reference/workflows-index.md) | Workflow template index |
| [tool-planning.md](tool-planning.md) | Planning primitives |

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| Commander 26.1+ | MCP add-in |
| Workspace open | Active workspace |
| MCP connected | Port **46248** (8080 DEBUG) |
| DI license | For Data Integrity tools |

## When MCP is unavailable

Use **Tosca.Commander.IDE.integration** (TCShell / TCAPI / Remote Control).
