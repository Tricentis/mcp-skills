# When to use MCP — readiness and path selection

Before any Commander automation via MCP: **confirm MCP is the right path**, verify connectivity, then enter **Code Mode** or **direct tool mode**. Do not call tools until readiness checks pass.

Copy and track progress:

```text
MCP readiness:
- [ ] Step 1 — MCP is the right path (Commander open, not headless CI)
- [ ] Step 2 — get_workspace_info succeeds
- [ ] Step 3 — Intent classified (read / mutate / task / DI)
- [ ] Step 4 — Mode picked (code-mode.md or direct-tool-mode.md)
- [ ] Step 5 — Plan drafted before first mutation
- [ ] Step 6 — Selection rules applied (explicit objectIds, checkout, persist)
```

**Progressive disclosure:** read this file for routing; open companion docs only for the current intent.

## Contents

- [Step 1 — Is MCP the right path?](#step-1--is-mcp-the-right-path)
- [Step 2 — Verify MCP connectivity](#step-2--verify-mcp-connectivity)
- [Step 3 — Classify user intent](#step-3--classify-user-intent)
- [Step 4 — Pick execution mode](#step-4--pick-execution-mode)
- [Step 5 — Orchestrate](#step-5--orchestrate)
- [Step 6 — Selection rules](#step-6--selection-rules)
- [When to prompt the user](#when-to-prompt-the-user)
- [Agent workflow (mandatory)](#agent-workflow-mandatory)

For Commander **closed**, batch/CI, or workspace file locked by a headless process, use the **[Commander CLI pack](../../../../CLI/README.md)** (TCShell / TCAPI / Remote Control) instead.

## Step 1 — Is MCP the right path?

| Situation | Use MCP? | Alternative |
|-----------|----------|-------------|
| Commander **open**, workspace loaded, MCP connected | **Yes** | — |
| Commander **closed** | **No** | Headless TCShell or TCAPI |
| User wants CI/unattended with no GUI | **No** | Headless TCShell |
| Commander open but MCP not configured | **No** | Close Commander → TCShell, or configure MCP |
| "Automate what I see" without MCP | **No** | Remote Control (last resort — [Commander CLI](../../../../CLI/claude/skills/cli-api-commander/remote-control.md)) |
| Data Integrity comparison/validation | **Yes** (if licensed) | No TCShell equivalent — MCP-only |

MCP runs **in-process** in the open Commander GUI. It shares the workspace with the user — no second workspace lock, no separate `TCShell.exe` process.

## Step 2 — Verify MCP connectivity

Call once at the start of a session or after Commander restart:

```
get_workspace_info
```

| Field / signal | Agent action |
|----------------|--------------|
| Workspace path returned | Proceed — workspace is active |
| Error / connection refused | Stop — ask user to open Commander, load workspace, check MCP port in Commander settings (default **46248**; DEBUG often **8080**) |
| `IsMultiUser` (or equivalent) | Read [workspace-orchestration.md](workspace-orchestration.md) — checkout/check-in rules apply |

Optional context read:

```
get_current_selection
```

Use when the user refers to "what I have selected" — but still pass explicit `objectIds` in later steps.

## Step 3 — Classify user intent

| Intent | Tool category | Code Mode? | Start with |
|--------|---------------|------------|------------|
| "What's open?" / audit | Read-only workspace | Optional | `get_workspace_info` → navigate |
| Read properties | Attributes | Yes | `get_object_info` → `get_attributes` |
| Edit property | Mutation | Yes | checkout? → `get_attributes` → `set_attribute` → save |
| Context-menu action | Tasks | Yes | `list_available_tasks` → `execute_task` |
| Drag-and-drop | Drop task | Yes | resolve IDs → `execute_drop_task` |
| New test case | Create | Yes | `create_test_case` (handles save/check-in internally) |
| Sync with repository | Multi-user | Yes | `update_all` before edit; `check_in_all` after |
| Data Integrity | DI | **Required** | [di-orchestration.md](di-orchestration.md) + one [reference/di/](reference/di/index.md) file |

## Step 4 — Pick execution mode

| IDE capability | Mode | Document |
|----------------|------|----------|
| Code execution / programmatic MCP (Claude, Cloudflare, API) | **Code Mode** — write orchestration script | [code-mode.md](code-mode.md) |
| MCP tools only (Cursor, Windsurf, Copilot, …) | **Direct tool mode** — numbered plan, one tool per step | [direct-tool-mode.md](direct-tool-mode.md) |

Both modes use the same tool ordering from [tool-orchestration.md](tool-orchestration.md).

## Step 5 — Orchestrate

**Code Mode:** Implement the full sequence as code (loops for pagination, `execute_test_suite_status` polling).

**Direct tool mode:** Draft a numbered plan table, then execute step-by-step.

## Step 6 — Selection rules

1. **Always plan multi-step work** before the first mutation tool.
2. **Pass explicit `objectIds` / `identifiers`** — do not assume UI selection persists between MCP calls.
3. **Discover before mutate** — `get_object_info`, `get_attributes`, `list_available_tasks` before writes/tasks.
4. **Checkout before edit** in multi-user workspaces — see [workspace-orchestration.md](workspace-orchestration.md).
5. **Persist last** — `save_workspace` / `check_in_all` after all mutations in the plan.
6. **DI gate** — read [di-orchestration.md](di-orchestration.md) before any DI tool.
7. **One `execute_test_suite` at a time** — poll `execute_test_suite_status` until complete.

## When to prompt the user

| Situation | Ask |
|-----------|-----|
| MCP not connected | Open Commander, load workspace, configure MCP endpoint? |
| Commander closed | Use MCP (open Commander) vs headless TCShell (close/switch)? |
| Multi-user, object not checked out | Proceed with checkout on parent? |
| `check_in_all` warning threshold | Many objects checked out — proceed with `forceLargeCheckin=true`? |
| Bulk DI validation | N test cases — confirm sequential `execute_test_suite` plan? |
| Ambiguous target object | Which node path / test case name? |
| Destructive task | Confirm task name and target before `execute_task`? |

## Agent workflow (mandatory)

```
1. get_workspace_info          → MCP ready? multi-user?
2. Classify intent             → read / mutate / task / DI
3. If not MCP-appropriate      → point to Commander CLI pack (TCShell/TCAPI)
4. Draft Code Mode script OR direct-tool plan  → code-mode.md / direct-tool-mode.md
5. If UserPromptRequired       → ask user
6. Execute plan step-by-step
7. Persist + verify            → save / check_in; re-read if user needs proof
```

## Quick readiness checklist (no scripts)

1. **Commander running** with workspace open.
2. **MCP client connected** (IDE shows Commander MCP tools).
3. **`get_workspace_info` succeeds**.
4. **Code Mode plan** drafted for multi-step work.
5. **DI work** → [di-orchestration.md](di-orchestration.md) + scenario file from [reference/di/](reference/di/index.md).

If any of 1–3 fail, do not proceed with MCP automation — fix connectivity or switch to headless path.

## Related

| Topic | Document |
|-------|----------|
| Code Mode template | [code-mode.md](code-mode.md) |
| Per-tool when/how | [tool-orchestration.md](tool-orchestration.md) |
| Checkout, save, check-in | [workspace-orchestration.md](workspace-orchestration.md) |
| DI sequencing | [di-orchestration.md](di-orchestration.md) |
| Headless automation | [Commander CLI](../../../../CLI/README.md): [path-selection.md](../../../../CLI/claude/skills/cli-api-commander/path-selection.md) |
