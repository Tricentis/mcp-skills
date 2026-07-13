# Direct tool mode — plan-then-act fallback

Use **direct tool mode** when the IDE connects to Commander MCP but does **not** provide code execution or programmatic tool calling (typical for Cursor, Windsurf, and many Copilot setups).

This is the **fallback** for [Code Mode](code-mode.md) (Anthropic / Cloudflare: orchestrate MCP via a script). The orchestration rules are the same; only the **execution surface** differs.

**Progressive disclosure:** read after [when-to-use-mcp.md](when-to-use-mcp.md); use companion orchestration docs on demand — do not load all reference files at once.

Copy and track progress:

```text
Direct tool mode:
- [ ] 1. Read orchestration guides for intent
- [ ] 2. Draft numbered tool plan table
- [ ] 3. Execute one step per turn; stop on error
- [ ] 4. Persist and verify (save / check_in; re-read if needed)
```

## When to use direct tool mode

| Signal | Use direct tool mode |
|--------|----------------------|
| MCP tools appear in the agent tool list | Yes |
| No code execution / sandbox for MCP | Yes |
| No programmatic `allowed_callers` / `callMCPTool` API | Yes |
| Claude Code with code execution enabled | **No** — use [code-mode.md](code-mode.md) |

## Workflow

### 1. Read orchestration guides

Same prerequisites as Code Mode:

1. [when-to-use-mcp.md](when-to-use-mcp.md)
2. [tool-orchestration.md](tool-orchestration.md)
3. [workspace-orchestration.md](workspace-orchestration.md) — if mutating
4. [task-orchestration.md](task-orchestration.md) — if tasks
5. [di-orchestration.md](di-orchestration.md) — if DI

### 2. Draft a numbered tool plan

Before the first mutation or task tool, output a plan table:

```markdown
## MCP plan: <title>

**Mode:** direct tool (no code execution)

| Step | Tool | Args (summary) | Expected |
|------|------|----------------|----------|
| 1 | get_workspace_info | — | multi-user flag |
| 2 | get_object_info | path | surrogateId |
| 3 | list_available_tasks | objectIds | Checkout task |
| 4 | execute_task | Checkout | checked out |
| 5 | set_attribute | Name, value | updated |
| 6 | save_workspace | — | persisted |
```

### 3. Execute one step per turn

- One MCP tool call per logical step (batch independent reads if the plan says so).
- On error: **stop**, revise plan — no blind retries.
- Capture surrogate IDs from responses for later steps.

### 4. Persist and verify

- End mutation plans with `save_workspace` / `check_in_all` per [workspace-orchestration.md](workspace-orchestration.md).
- Re-read with `get_attributes` when the user needs confirmation.

## Pagination and polling in direct mode

Without code loops, express repetition explicitly in the plan:

```
Step 4a  get_object_info(parent, include_parent_and_children=true, offset=0)
Step 4b  get_object_info(parent, include_parent_and_children=true, offset=nextOffset)   # repeat until done

Step 7a  execute_test_suite(identifier)
Step 7b  execute_test_suite_status(jobId)            # repeat until !isRunning
```

The agent executes each row in sequence across turns.

## Same rules as Code Mode

| Rule | Applies |
|------|---------|
| `list_available_tasks` before `execute_task` | Yes |
| Read [di-orchestration.md](di-orchestration.md) before DI tools | Yes |
| Explicit `objectIds` / `identifiers` | Yes |
| One `execute_test_suite` at a time | Yes |
| Checkout before edit (multi-user) | Yes |

See [tool-orchestration.md](tool-orchestration.md) for the full when/how reference.

## Upgrading to Code Mode

When the IDE gains code execution (e.g. Claude programmatic tool calling, Cloudflare Code Mode, future Cursor sandbox):

1. Translate the proven direct-tool plan into a script per [code-mode.md](code-mode.md).
2. Replace pagination/polling plan rows with loops in code.
3. Keep large intermediate results out of chat context.

## Related

- [code-mode.md](code-mode.md) — primary mode when code execution is available
- [reference/workflows-index.md](reference/workflows-index.md) — plan templates
