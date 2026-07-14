# Add manual step to test case

TCShell sequence to append a manual test step to an existing test case.

```text
Add manual step:
- [ ] JumpToNode — open test case
- [ ] Checkout if multi-user
- [ ] task "Create Manual XTestStep" → set Name
- [ ] print — verify step
- [ ] save
```

## Plan

| Step | Command | Expected |
|------|---------|----------|
| 1 | `JumpToNode "/TestCases/MyTestCase"` | Test case is current object |
| 2 | `task "Checkout"` | Only if `ChangesAllowed` is false |
| 3 | `task "Create Manual XTestStep"` | New step created; jumps to it |
| 4 | `set Name "MyStepName"` | Rename step |
| 5 | `print` | Step visible under test case |
| 6 | `save` | Persist |

## Sample script

```
JumpToNode "/TestCases/MyTestCase"
task "Create Manual XTestStep"
set Name "Verify login"
print
save
```

## Notes

- Applies to `TestCase` or `TestStepFolder` current objects.
- Module-based steps (drag module onto TC) require Commander GUI — not automatable headless via TCShell.
- XScan/API Scan modules require Commander UI — TCShell can only create empty module shells.
