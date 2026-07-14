# Create test case

TCShell sequence for a new test case under an existing folder.

```text
Create test case:
- [ ] Path detection — path-selection.md
- [ ] JumpToNode — verify parent folder
- [ ] Checkout parent if multi-user (ChangesAllowed false)
- [ ] task "Create TestCase" → set Name
- [ ] print — verify creation
- [ ] save
```

## Plan

| Step | Command | Expected |
|------|---------|----------|
| 1 | `JumpToNode "/TestCases/MyArea"` | Parent folder is current object |
| 2 | `print` | Confirm `ChangesAllowed` (multi-user) |
| 3 | `task "Checkout"` | Only if step 2 shows read-only |
| 4 | `task "Create TestCase"` | New TC created with default name; jumps to it |
| 5 | `set Name "MyTestCaseName"` | Rename |
| 6 | `print` | Verify name and path |
| 7 | `save` | **Required** before exit in batch mode |

## Sample script (`script.tcs`)

```
JumpToNode "/TestCases"
task "Create TestCase"
set Name "MyTestCaseName"
print
save
```

## Invocation

```bat
"%COMMANDER_HOME%\TCShell\TCShell.exe" -workspace "C:\path\workspace.tws" -auth "<token>" script.tcs
```

## Verified output

See [scenarios-index.md](../scenarios-index.md) → one `CreateTestCase` `##` section in [output-patterns.md](../output-patterns.md).

## Notes

- `Create TestCase` applies only under a **TestCases** folder (`TCFolder`).
- Create tasks do not prompt — always `set Name` immediately after.
