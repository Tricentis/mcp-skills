# Task orchestration — list, execute, drop

Commander tasks are the MCP equivalent of TCShell `Task <name>` and context-menu actions. **Always discover, then execute** — task names and parameters are context-sensitive.

**Progressive disclosure:** read when the user's goal involves Commander tasks; see [tool-orchestration.md](tool-orchestration.md) for the discover → execute loop.

```text
Task workflow:
- [ ] get_object_info — resolve target
- [ ] list_available_tasks — exact name + params
- [ ] Checkout if needed (workspace-orchestration.md)
- [ ] execute_task — loop on missing_param if needed
- [ ] save_workspace — if task mutated workspace
```

TCShell analog: `Task "Create Template Instance"`, `TaskOnEach` — see [reference/commands.md](../../../../CLI/cursor/skills/cli-api-commander/reference/commands.md).

## Contents

- [When to use tasks vs other tools](#when-to-use-tasks-vs-other-tools)
- [Standard task orchestration](#standard-task-orchestration)
- [Checkout tasks (multi-user)](#checkout-tasks-multi-user)
- [Multi-object tasks](#multi-object-tasks)
- [Drop task orchestration](#drop-task-orchestration)
- [Task vs TCShell orchestration (conceptual)](#task-vs-tcshell-orchestration-conceptual)
- [Anti-patterns](#anti-patterns)

## When to use tasks vs other tools

| Goal | Use | Not |
|------|-----|-----|
| Context-menu action (Create, Import, Checkout, …) | `execute_task` | Guessing CLI/TCShell |
| Simple property change | `set_attribute` | Task if attribute API suffices |
| New test case with steps | `create_test_case` | Manual task chain unless tool insufficient |
| Drag module onto test case | `execute_drop_task` | `execute_task` |
| Check in all checked-out | `check_in_all` | Checkout task on each object |

## Standard task orchestration

Implement this block as **code** ([code-mode.md](code-mode.md)) or as **plan rows** ([direct-tool-mode.md](direct-tool-mode.md)):

```
Step A  get_object_info([target path])              → surrogateId
Step B  list_available_tasks(objectIds=[id])    → task list + param schema
Step C  execute_task(name, parameters, objectIds=[id])
Step D  save_workspace                          → unless task auto-saves
```

### Step B — `list_available_tasks`

**When:** Before **every** `execute_task`, including repeat calls on the same object after checkout.

**How:**

- Pass `objectIds` — never rely on stale UI selection.
- Read returned task **names exactly** (case-sensitive).
- Read **parameter schema** — map user intent to parameter keys for step C.

**Signals:**

| List result | Meaning |
|-------------|---------|
| Edit/create/delete tasks absent | Owning checkout unit not checked out — see [Checkout granularity](workspace-orchestration.md#checkout-orchestration) for which object to check out |
| Empty list | Wrong object type or no tasks for context — verify `get_object_info` |
| Task with parameters | Supply `parameters` dict in `execute_task` |

### Step C — `execute_task`

**When:** Task name confirmed from step B.

**How:**

```json
{
  "taskName": "Exact Name From List",
  "objectIds": ["{surrogateId or node path}"],
  "parameters": { "ParamName": "value" }
}
```

- Parameter keys match schema from `list_available_tasks` (name or prompt text).
- Multiple objects: all must be valid task owners — check list was scoped correctly.

**After execution:**

- Read success/failure message in response.
- If the response has `"status": "missing_param"`, the task needs a value it wasn't given — read
  `paramKey`, `promptText`, `expectedType`, and `choices` from the response, then re-call
  `execute_task` with that parameter added. Repeat until the task returns a normal result.
- If task mutates workspace, include `save_workspace` in plan (or verify task auto-persisted).
- If follow-up task needed (e.g. Create then Configure), re-run **step B** — available tasks may change.
- `execute_task` with an unrecognized name returns `"Unknown task {name}. Available tasks: ..."`.
  This is also the signal for a checkout-gated task that hasn't appeared yet — it is not a distinct
  "not checked out" error. Re-run step B after checking out the correct object (see below).

## Checkout tasks (multi-user)

Edit/create/delete tasks are hidden until the owning checkout unit is checked out — **not always
the immediate parent**. See [workspace-orchestration.md § Checkout
orchestration](workspace-orchestration.md#checkout-orchestration) for the full rule (self vs.
parent vs. owning cluster) and the checkout sequence. That section is the single source of truth;
this doc only covers task discovery/execution mechanics.

## Multi-object tasks

When task applies to several objects:

```
list_available_tasks(objectIds=[id1, id2, ...])
execute_task(name, parameters, objectIds=[id1, id2, ...])
```

If list empty or partial, verify all ids resolve via `get_object_info` and share compatible type.

## Drop task orchestration

**When:** Operation is drag-and-drop (e.g. module → test case step, or moving an object between parents).

If this is a **move** (source's original parent loses the object), both the source's current
parent and the drop target must be checked out first — see [workspace-orchestration.md § Checkout
granularity](workspace-orchestration.md#checkout-orchestration).

```
get_object_info([target, source1, source2])
execute_drop_task(
  target=targetId,
  sources=[sourceIds],
  copy=false,           # optional
  taskName=...          # optional — if multiple drop tasks exist
)
save_workspace
```

Use when `list_available_tasks` does not expose the needed create/link action.

## Task vs TCShell orchestration (conceptual)

| TCShell (headless) | MCP (Commander open) |
|--------------------|----------------------|
| `JumpToNode "/path"` then `Task "X"` | `get_object_info` + `execute_task("X", objectIds=[...])` |
| Task prompts as subsequent `.tcs` lines | `parameters` dict in `execute_task` |
| `save` at script end | `save_workspace` at plan end |
| Batch non-interactive | Each task one MCP call — plan all prompts upfront |

MCP exposes task **names and schemas** via `list_available_tasks` — use that instead of memorizing TCShell samples.

## When to prompt the user

| Situation | Ask |
|-----------|-----|
| Multiple tasks match intent | Which task name from list? |
| Required parameters unclear | User must supply values for schema |
| Destructive task (Delete, Replace, …) | Confirm before `execute_task` |
| Plain `Checkout` at the correct object didn't surface the task, and only `Checkout Tree` (or a large/root-level object) would | Confirm before running `Checkout Tree` — see [workspace-orchestration.md](workspace-orchestration.md#checkout-vs-checkout-tree--default-to-the-narrower-one) |

## Anti-patterns

| Avoid | Why |
|-------|-----|
| Hard-coded task names from memory | Names vary by object type and checkout state |
| `execute_task` without step B | Failures and wrong task |
| Skip re-list after checkout | Edit tasks appear only after checking out the correct owning object |
| Assume "checkout the parent" always | Checkout unit varies by operation — see [workspace-orchestration.md](workspace-orchestration.md#checkout-orchestration) |
| Reach for `Checkout Tree` as the default escalation | Locks every descendant, not just the object needed — try plain `Checkout` at the correct owner first |
| Same task name across different object types | Always list per target |

## Related

- [tool-orchestration.md](tool-orchestration.md) — full tool ordering
- [reference/workflows/execute-task.md](reference/workflows/execute-task.md) — plan template
