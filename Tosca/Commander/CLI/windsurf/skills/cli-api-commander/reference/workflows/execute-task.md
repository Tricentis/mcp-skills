# Execute Commander task

TCShell sequence for context-menu tasks (create, run, import, lifecycle).

```text
Execute task:
- [ ] JumpToNode — resolve target object
- [ ] print — confirm object type and ChangesAllowed
- [ ] Checkout if edit tasks would fail (multi-user)
- [ ] task "<ExactName>" — supply prompt lines if needed
- [ ] save
```

## Plan

| Step | Command | Expected |
|------|---------|----------|
| 1 | `JumpToNode "/path/to/object"` | Target is current object |
| 2 | `print` | Object type, `ChangesAllowed`, checkout state |
| 3 | `task "Checkout"` | Multi-user edit gate (plain `Checkout`, not tree unless needed) |
| 4 | `task "Run"` | Example: run execution list |
| 5 | `save` | **Always** after mutating tasks |

## Checkout gate (multi-user)

| Operation | Check out |
|-----------|-----------|
| Edit object's own attributes | That object |
| Create/delete child | Parent folder |
| Sub-object in library | Owning cluster/library |

Prefer plain `task "Checkout"`. Use `task "Checkout Tree"` only as last resort on large folders — confirm with user.

## Task input patterns

**No prompt (create, run):**

```
task "Create TestCase"
set Name "MyTC"
```

**Prompted (import, backup):**

```
task "Import Subset"
"C:\path\subset.tce"
<EOL>
```

Discover task names: interactive `task` with no argument lists available tasks for the current object. Full catalog: [tasks.md](../tasks.md).

## Notes

- Task names are case-insensitive; spaces in the argument are stripped during resolution.
- If task fails, read stderr and compare to one matching `##` section in [output-patterns.md](../output-patterns.md) via [scenarios-index.md](../scenarios-index.md).
