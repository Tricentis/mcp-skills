# Execute Commander task

Code Mode sequence for context-menu tasks via MCP.

```text
Execute task:
- [ ] get_object_info — resolve objectIds
- [ ] list_available_tasks — exact task name + param schema
- [ ] Checkout if edit tasks missing (see Checkout gate below)
- [ ] execute_task — supply missing_param values in a loop if needed
- [ ] save_workspace — if task mutated workspace
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `get_object_info` | target path or id | Resolve `objectIds` |
| 2 | `list_available_tasks` | `objectIds` | Task list with parameter schemas |
| 3 | `execute_task` | task name + params + `objectIds` | Task result |
| 4 | `save_workspace` | — | If task mutated workspace |

## Checkout gate

Edit/create/delete tasks are hidden until the owning checkout unit is checked out (not always the immediate parent).

| Operation | Check out |
|-----------|-----------|
| Edit object's own attributes | That object |
| Create/delete child | Parent/owner |
| Move between parents | Source and destination parents |
| Sub-object (e.g. RTSB in library) | Owning cluster/library |

**Default to plain `Checkout`** (exact name from `list_available_tasks`). Re-run `list_available_tasks` after checkout. Use `Checkout Tree` only as a last resort and confirm with the user on large folders.

An unrecognized task name — including a checkout-gated task not visible yet — returns `"Unknown task {name}. Available tasks: ..."`; there is no separate not-checked-out error.

## Notes

- Task names must match `list_available_tasks` exactly (case-sensitive).
- Tasks with parameters: supply values per the schema from step 2.
- If `execute_task` returns `"status": "missing_param"`, read `paramKey` / `promptText` / `expectedType` / `choices` from the response and re-call `execute_task` with that parameter supplied; repeat until a normal result is returned.
- For drag-and-drop scenarios, consider `execute_drop_task` instead.
