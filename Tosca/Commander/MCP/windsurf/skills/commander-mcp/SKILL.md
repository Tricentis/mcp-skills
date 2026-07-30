---
name: commander-mcp
description: >-
  Automates Tosca Commander via in-process MCP when Commander is open with a
  workspace — checkout, tasks, test cases, and Data Integrity. Use for Tosca
  automation, /commander-mcp, tosca-commander, McpServerAddIn, or when Commander
  MCP tools connect. Does NOT cover headless TCShell, TCAPI, Remote Control, or
  CI when Commander is closed (use Commander CLI pack).
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

See [reference/workflows-index.md](reference/workflows-index.md) — load **one** template matching the user's goal; do not read all workflow files at session start.

## Data Integrity (router + one file)

1. Read [di-orchestration.md](di-orchestration.md) (phases and gates).
2. Pick **one** supplemental file from [reference/di/index.md](reference/di/index.md).

Do not load multiple DI reference files unless the scenario requires it (e.g. SAP workflow + [reference/di/sap-endpoints.md](reference/di/sap-endpoints.md)).

## Tool reference (load only when needed)

Do **not** open the catalog at session start.

| Resource | When to load |
|----------|--------------|
| [reference/tools-catalog.md](reference/tools-catalog.md) | Parameter details for a **specific** tool in your plan |
| [reference/tools-index.md](reference/tools-index.md) | Quick name lookup |
| [reference/workflows-index.md](reference/workflows-index.md) | Choosing a workflow template |
| [tool-planning.md](tool-planning.md) | Drafting a multi-step plan |

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| Commander 26.1+ | MCP add-in |
| Workspace open | Active workspace |
| MCP connected | Port from Commander MCP settings (default **46248**; DEBUG often **8080**) |
| DI license | For Data Integrity tools |

## When MCP is unavailable

Use the **[Commander CLI pack](../../../../CLI/README.md)** skill (TCShell / TCAPI / Remote Control).
