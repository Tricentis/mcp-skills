---
description: >-
  Automates Tosca Commander via in-process MCP when Commander is open with a
  workspace. Prefer Code Mode when the IDE supports code execution; otherwise
  direct tool mode. Load commander-mcp on /commander-mcp, tosca-commander, Tosca
  automation, or when Commander MCP tools connect. Does NOT cover headless
  TCShell, TCAPI, Remote Control, or CI when Commander is closed (use
  Commander CLI pack).
globs:
alwaysApply: false
---

# Commander MCP

When MCP tools such as `get_workspace_info`, `execute_task`, or `di_connection` are connected (use `tosca-commander:tool_name` when multiple MCP servers are active):

1. Load the **commander-mcp** skill.
2. **Code Mode** (preferred): write code orchestrating MCP tools (Anthropic/Cloudflare pattern).
3. **Direct tool mode** (fallback): numbered plan, one MCP call per step when no code execution.
4. **Data Integrity** — read [di-orchestration.md](di-orchestration.md) and one `reference/di/` file before DI tools.
5. Persist: `save_workspace` / `check_in_all`; pass explicit `objectIds`.

Requires Commander open (MCP on localhost; default port **46248** — use Commander MCP settings). Headless: [Commander CLI](../../CLI/README.md).
