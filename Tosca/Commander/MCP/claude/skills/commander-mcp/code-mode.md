# Code Mode — programmatic MCP orchestration

**Code Mode** (Anthropic / Cloudflare) means the agent **writes code** that calls Commander MCP tools as functions, instead of chaining one direct tool call per chat turn.

**Progressive disclosure:** read after [when-to-use-mcp.md](when-to-use-mcp.md) confirms MCP; use [tool-orchestration.md](tool-orchestration.md) for per-tool rules — not the full tools catalog upfront.

Copy and track progress:

```text
Code Mode workflow:
- [ ] 0. Read orchestration guides for intent
- [ ] 1. Restate goal in Commander terms
- [ ] 2. Write orchestration script (full sequence)
- [ ] 3. Review with user if destructive or wide-reaching
- [ ] 4. Execute in code sandbox; handle errors in code
- [ ] 5. Return summaries only — not full schema dumps
```

**MCP tool names:** `tosca-commander:tool_name` when multiple MCP servers are connected; bare names otherwise.

References:

- [Anthropic: Code execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)
- [Anthropic: Programmatic tool calling](https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling)
- Cloudflare uses the same term for MCP-as-code-API

## Contents

- [Why Code Mode for Commander MCP](#why-code-mode-for-commander-mcp)
- [When to use Code Mode](#when-to-use-code-mode)
- [IDE support](#ide-support)
- [Workflow](#workflow)
- [Code Mode vs direct tool mode](#code-mode-vs-direct-tool-mode)
- [Anti-patterns](#anti-patterns)

## Why Code Mode for Commander MCP

Commander workflows are multi-step (navigate → checkout → task → save; DI validate polling; paginated `get_object_info` children). Code Mode:

- Determines the **entire tool sequence upfront** in one script
- Keeps **intermediate results** (schema rows, surrogate IDs) in the execution environment
- Uses **loops** for pagination and `execute_test_suite_status` polling
- Uses **conditionals** for multi-user checkout branches

Direct one-tool-per-turn calling still works — see [direct-tool-mode.md](direct-tool-mode.md) when code execution is unavailable.

## When to use Code Mode

| Scenario | Code Mode? |
|----------|------------|
| Single read (`get_workspace_info`) | Optional — direct call is fine |
| Navigate + read attributes | **Yes** |
| Create or edit objects | **Yes** |
| Execute tasks | **Yes** |
| Pagination (`get_object_info` children, SQL) | **Yes** — loop in code |
| Data Integrity | **Required** — workflow read + sequential validate |
| Multi-user check-in flow | **Yes** |

## IDE support

| Environment | Code Mode | Fallback |
|-------------|-----------|----------|
| Claude Code + code execution / programmatic tool calling | **Primary** | [direct-tool-mode.md](direct-tool-mode.md) |
| Claude API with `code_execution` + `allowed_callers` | **Primary** | Direct tool use |
| Cloudflare Agents (Code Mode MCP) | **Primary** | — |
| Cursor (MCP tools in agent, no sandbox) | Often fallback only | [direct-tool-mode.md](direct-tool-mode.md) |
| VS Code Copilot / Windsurf | Usually fallback | [direct-tool-mode.md](direct-tool-mode.md) |

**Rule:** If the IDE exposes a **code execution** or **programmatic tool calling** path for MCP, use Code Mode. Otherwise use direct tool mode — same orchestration rules, different execution surface.

## Workflow

### 0. Read orchestration guides

Before writing code:

1. [when-to-use-mcp.md](when-to-use-mcp.md) — MCP vs headless; readiness
2. [tool-orchestration.md](tool-orchestration.md) — which tools, what order, preconditions
3. [workspace-orchestration.md](workspace-orchestration.md) — checkout / save / check-in
4. [task-orchestration.md](task-orchestration.md) — task discover → execute
5. [di-orchestration.md](di-orchestration.md) — DI phases

### 1. Understand the goal

Restate in Commander terms (object paths, task names, DI connections).

### 2. Write the orchestration script

Produce **runnable code** (or IDE-specific programmatic tool block) that implements the full sequence. Use the Commander MCP tool names from [reference/tools-catalog.md](reference/tools-catalog.md).

**Pattern — inspect and rename test case:**

```typescript
// Commander MCP — Code Mode orchestration
const ws = await mcp.call("get_workspace_info", {});
const multiUser = ws.isMultiUser; // field name from actual response

const [target] = await mcp.call("get_object_info", {
  identifiers: ["/TestCases/MyFolder/MyTestCase"],
});
if (target.error) throw new Error(target.error);

if (multiUser) {
  const tasks = await mcp.call("list_available_tasks", {
    objectIds: [target.surrogateId],
  });
  const checkout = tasks.find((t) => /checkout/i.test(t.name));
  if (checkout) {
    await mcp.call("execute_task", {
      taskName: checkout.name,
      objectIds: [target.surrogateId],
    });
  }
}

const attrs = await mcp.call("get_attributes", {
  identifiers: [target.surrogateId],
});
const nameAttr = attrs[0].attributes.find((a) => a.name === "Name" && !a.is_readonly);
if (!nameAttr) throw new Error("Name not writable");

await mcp.call("set_attribute", {
  identifier: target.surrogateId,
  attribute_name: "Name",
  value: "New Name",
});
await mcp.call("save_workspace", {});

if (multiUser) {
  await mcp.call("check_in_all", { comment: "Renamed via agent" });
}

console.log("Done:", target.surrogateId);
```

**Pattern — paginate children:**

```typescript
let offset = 0;
const all = [];
for (;;) {
  const [info] = await mcp.call("get_object_info", {
    identifiers: [rootId],
    include_parent_and_children: true,
    limit: 200,
    offset,
  });
  all.push(...info.children);
  if (info.nextOffset == null) break;
  offset = info.nextOffset;
}
console.log(`Found ${all.length} children`);
```

**Pattern — test suite execution poll** (after reading [di-orchestration.md](di-orchestration.md)):

```typescript
const { JobId } = await mcp.call("execute_test_suite", { identifier: testCaseId });
for (;;) {
  const status = await mcp.call("execute_test_suite_status", { jobId: JobId });
  if (!status.isRunning) {
    console.log(status.result);
    break;
  }
}
await mcp.call("save_workspace", {});
```

Adapt `mcp.call(...)` to your IDE's programmatic tool API (Claude code execution, generated TS stubs, `callMCPTool`, etc.).

### 3. Review with user

For destructive or wide-reaching scripts (check-in all, bulk DI validation), show the script or a step summary before execution.

### 4. Execute

Run the script in the IDE's code execution environment. Handle errors in code (try/catch, early exit) — do not blindly retry the whole script.

### 5. Return only what matters

Log or return **summaries** to the conversation — not full schema dumps unless the user needs them.

## Code Mode vs direct tool mode

| | **Code Mode** | **Direct tool mode** |
|---|---------------|----------------------|
| Surface | Script / programmatic calls | One MCP tool per agent turn |
| Sequence | Entire flow in code | Numbered plan, step-by-step |
| Loops | Native (`for`, `while`) | Repeated tool calls from agent |
| Large results | Stay in execution env | Pass through context each turn |
| IDE requirement | Code execution sandbox | Any MCP client |
| Doc | This file | [direct-tool-mode.md](direct-tool-mode.md) |

Both modes follow the same **orchestration rules** in [tool-orchestration.md](tool-orchestration.md).

## Anti-patterns

| Avoid | Why |
|-------|-----|
| Direct tool chains when code execution is available | Wastes context; Code Mode is preferred |
| Skip DI skill docs | Read [reference/di/index.md](reference/di/index.md) for orchestration |
| Parallel `execute_test_suite` in code | Still one at a time on Commander UI thread |
| Hard-coded task names without discover step | Call `list_available_tasks` in code first |
| Skipping save/check-in at end of script | Same as direct mode |

## Related

- [direct-tool-mode.md](direct-tool-mode.md) — fallback for Cursor and other IDEs without code execution
- [tool-orchestration.md](tool-orchestration.md) — when/how per tool (applies to both modes)
- [reference/workflows-index.md](reference/workflows-index.md) — scenario templates to implement as scripts
