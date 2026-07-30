# Workspace orchestration — checkout, save, check-in

MCP shares the **same workspace** as the Commander GUI. Multi-user checkout rules apply. Orchestrate persistence **after** all planned mutations — not after every single tool call unless the plan says so.

**Progressive disclosure:** read when planning workspace mutations; pair with [tool-orchestration.md](tool-orchestration.md) for tool order.

Analog in Commander CLI skill: [workspace-checkout.md](../../../../CLI/windsurf/skills/cli-api-commander/workspace-checkout.md) (TCShell `checkouttree` / `checkinall`).

## Contents

- [Single-user vs multi-user](#single-user-vs-multi-user)
- [Checkout orchestration](#checkout-orchestration)
- [Save vs check-in vs update](#save-vs-check-in-vs-update)
- [create_test_case persistence](#create_test_case-persistence)
- [Selection vs explicit IDs](#selection-vs-explicit-ids)
- [Decision tree](#decision-tree)

## Single-user vs multi-user

Detect at plan time:

```
get_workspace_info  →  note multi-user flag
```

| Workspace | Before edit | After edit (orchestration end) |
|-------------|-------------|--------------------------------|
| **Single-user** | Usually no checkout task | `save_workspace` |
| **Multi-user** | Checkout task on editable parent | `save_workspace` then `check_in_all` when publishing |

`check_in_all` **only works in multi-user** workspaces — it returns an error in single-user mode.

## Checkout orchestration

Objects must be checked out before modification in multi-user workspaces. **This section is the
single source of truth for checkout-gated tasks** — [task-orchestration.md](task-orchestration.md)
and [reference/workflows/execute-task.md](reference/workflows/execute-task.md) link back here.

### Checkout granularity — pick the right object, not always "the parent"

Checkout state lives on individual objects — specifically the nearest ancestor that is an
independently checkout-able `OwnedItem` (module, folder, test case, library, …) — not uniformly on
"the parent." An object that isn't its own `OwnedItem` resolves to whichever ancestor is. Which
object to check out depends on the operation:

| Operation | Check out |
|-----------|-----------|
| Editing an object's own attributes (e.g. renaming a module) | **That object itself** — modules, folders, and test cases are their own checkout unit; the parent does not need checkout |
| Create/delete a child in place | **The parent/owner** — its child collection is what changes |
| **Move** a child to a different parent | **Both owners** — the **source** parent (losing the child) and the **destination** parent (gaining the child); each one's child collection changes |
| Sub-object that is not its own checkout unit (e.g. a Reusable Test Step Block, which is part of its library's cluster) | **The owning cluster/library** — you cannot check out the sub-object directly |

For a move, check out source and destination parents *before* the move task/drop — if either is
missing checkout, the move task won't appear (or the drop target will reject it).

### `Checkout` vs `Checkout Tree` — default to the narrower one

`Checkout` locks a single object. `Checkout Tree` recursively locks that object **and every
descendant** — on a folder near the project root this can lock a large fraction of the project.
Official Tosca docs describe both operations but do not give scope guidance, so treat this as
project practice, not a documented Tricentis recommendation:

- **Default to plain `Checkout`** on the object picked from the table above. Don't reach for
  `Checkout Tree` just because it's "more likely to work."
- Reserve `Checkout Tree` for when the operation genuinely needs a subtree checked out (e.g.
  bulk-editing many descendants), or as a last resort after plain `Checkout` at the correct level
  still doesn't surface the task.
- **Confirm with the user before running `Checkout Tree` on a large or root-level object** — it
  can lock far more than the task at hand requires, is expensive to undo, and increases conflict
  risk for other users. This is the same "Checkout affects many objects" prompt already listed in
  [task-orchestration.md](task-orchestration.md#when-to-prompt-the-user).
- If a plain `Checkout` at the object from the table doesn't surface the needed task:
  1. Use this walk-up **only** when the operation type is unclear from the table (e.g. an unfamiliar
     object type). Don't check out the target "just to try it" when the table already answers it —
     an unneeded checkout just leaves a stray checked-out object to clean up.
  2. Walk up one level via `get_object_info(id, include_parent_and_children=true)`, read the returned
     `parent`, and try plain `Checkout` there. Repeat until the task appears — don't jump straight to
     `Checkout Tree`.
  3. If `parent` is `null` (workspace root) before the task appears, stop and ask the user — don't
     call `get_object_info` on a null parent.

### Detect checkout need

```
list_available_tasks(objectIds=[target or owning object])
```

| Signal | Action |
|--------|--------|
| Edit/create/delete tasks **missing** from list | Owning checkout unit not checked out — see walk-up guidance above; only use `Checkout Tree` as a last resort |
| `execute_task` returns `"Unknown task {name}. Available tasks: ..."` | **Not a distinct checkout error** — the task name simply isn't in the current (pre-checkout) list. Re-run `list_available_tasks` after checking out the correct object |
| `get_attributes` shows read-only unexpectedly | Check out the object (or its owner) before `set_attribute` |

There is no separate "not checked out" error from `execute_task` — a checkout-gated task that
isn't visible yet just looks like an unknown task name.

### Checkout sequence (insert into plan)

```
get_object_info(target path)                   → target surrogateId
# Pick the checkout unit from the table above (self / parent / owning cluster):
checkoutUnit = target  or  get_object_info(target, include_parent_and_children=true).parent → owner surrogateId
list_available_tasks(objectIds=[checkoutUnit])
execute_task("Checkout", objectIds=[checkoutUnit])   # plain Checkout first — exact name from list
list_available_tasks(objectIds=[target])              # re-discover — edit tasks should now appear
# Still missing? Repeat the walk-up-and-retry from the guidance above (bounded at the workspace
# root) before escalating to "Checkout Tree".
# ... mutation steps ...
save_workspace
check_in_all                       # multi-user only, when ready to publish
```

Checkout task display names are **localized** — `Checkout` and `Checkout Tree` are the English
examples (classes `CheckOutTask` / `CheckOutTreeTask`), but always read the **exact name** from
`list_available_tasks` rather than hardcoding it. Names are matched exactly and case-sensitively.

## Save vs check-in vs update

| Tool | When to call | Orchestration position |
|------|--------------|------------------------|
| `update_all` | Pull latest from common repo **before** a long edit session | **Start** of plan (multi-user), optional |
| `save_workspace` | Persist in-memory changes to local workspace | **End** of mutation plan (always) |
| `check_in_all` | Publish checked-out objects to common repository | **After** `save_workspace`, when user wants check-in |

### Ordering rules

```
# Multi-user edit session (typical)
1. get_workspace_info
2. update_all                    # optional — reduce conflicts
3. checkout (via execute_task)
4. mutate (set_attribute, execute_task, create_test_case, …)
5. save_workspace
6. check_in_all                  # when publishing; not after every tiny edit
```

**Do not** call `check_in_all` before mutations are complete. **Do not** skip `save_workspace` — in-memory writes from `set_attribute` are lost on close.

### `check_in_all` warnings

Large check-ins may:

- Return a **warning** when checked-out object count exceeds threshold — re-run with `forceLargeCheckin=true` after user confirms.
- **Run long** — MCP client may timeout while Commander continues; warn user.

Pass optional `comment` for audit trail.

## `create_test_case` persistence

`create_test_case` handles persistence internally:

- **Multi-user:** checks in created folders/test case (and checked-out requirements) on success.
- **Single-user:** saves workspace on success.

Still verify with `get_object_info` after creation. On failure mid-way, the tool rolls back partial test case — no extra save needed.

## Selection vs explicit IDs

MCP calls are stateless from the agent's perspective — **UI selection may change** between calls.

| Always prefer | Why |
|---------------|-----|
| `objectIds=[surrogateId]` on tasks | User may click elsewhere in Commander |
| `identifiers=[path or id]` on attributes | Same |
| `set_object_selection` only when driving UI for user visibility | Not a substitute for passing IDs |

## Decision tree

```
Mutation planned?
├─ get_workspace_info → multi-user?
│  ├─ yes → plan checkout step before edit
│  └─ no  → skip checkout; plan save_workspace at end
├─ list_available_tasks before execute_task
├─ get_attributes before set_attribute (writable check)
├─ execute mutations
├─ save_workspace
└─ multi-user + user wants publish? → check_in_all
```

## Comparison to TCShell orchestration

| TCShell (headless) | MCP (Commander open) |
|--------------------|----------------------|
| `checkouttree` after open | `execute_task(Checkout*)` on parent |
| `save` before exit | `save_workspace` at plan end |
| `checkinall` | `check_in_all` |
| Workspace file lock blocks second process | Same GUI workspace — no lock conflict |
| Must close Commander for headless | Commander must stay open |

When the user cannot keep Commander open, switch to the [Commander CLI pack](../../../../CLI/README.md) headless path — MCP cannot run.

## Related

| Topic | Document |
|-------|----------|
| Task checkout discovery | [task-orchestration.md](task-orchestration.md) |
| Save/check-in workflow | [reference/workflows/save-and-checkin.md](reference/workflows/save-and-checkin.md) |
| Full tool ordering | [tool-orchestration.md](tool-orchestration.md) |
