# Inspect workspace

Read-only Code Mode sequence to understand what is open in Commander.

```text
Inspect workspace:
- [ ] get_workspace_info
- [ ] get_current_selection (optional)
- [ ] get_object_info — paginate children until done
- [ ] get_object_info / get_attributes (if user named targets)
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `get_workspace_info` | — | Workspace path, repository type, multi-user flag |
| 2 | `get_current_selection` | — | Selected objects (may be empty) |
| 3 | `get_object_info` | root/top folder id or path, `include_parent_and_children=true` | Object plus first page of direct children |
| 4+ | `get_object_info` | same id, `offset=nextOffset` | Remaining pages if needed |

## Optional deep dive

| Step | Tool | When |
|------|------|------|
| | `get_object_info` | Resolve a named path the user mentioned (omit `include_parent_and_children` for a plain lookup) |
| | `get_attributes` | Inspect properties of selected or named objects |
| | `get_object_info` (`include_parent_and_children=true`) | Walk up the tree via the returned parent |

## Notes

- `include_parent_and_children` requires exactly one identifier; batch-resolve without it, then re-call per object to expand.
- Summarize results for the user in tree terms (names, paths, types) — not raw surrogate IDs unless debugging.
