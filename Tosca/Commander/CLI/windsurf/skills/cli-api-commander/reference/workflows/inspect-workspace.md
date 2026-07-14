# Inspect workspace

Read-only TCShell sequence to understand workspace structure and current object state.

```text
Inspect workspace:
- [ ] Path detection — path-selection.md
- [ ] Open workspace (headless) or connect RC/TCAPI
- [ ] JumpToNode or TQL to target
- [ ] print / get — verify via scenarios-index → one output-patterns section
```

## Headless TCShell plan

| Step | Command | Expected |
|------|---------|----------|
| 1 | `JumpToNode "/TestCases"` | Navigate to folder; prompt shows current object |
| 2 | `print` | Object tree / attributes in plain text |
| 3 | `JumpTo "=>Items:TestCase[Name==\"MyTest\"]"` | TQL navigation (optional) |
| 4 | `print` | Named object details |

## TCAPI plan

| Step | API | Expected |
|------|-----|----------|
| 1 | `Open-TcApiWorkspace` | Workspace connected |
| 2 | `Get-TcApiProject` | Project root |
| 3 | `Search-TcApi -Tql '=>SUBPARTS:TestCase'` | List test cases |

## Remote Control plan

Use only when path detection selects `RemoteControl` and user consented to GUI sync.

| Step | RC command | Expected |
|------|------------|----------|
| 1 | `JumpToNode "/TestCases"` | GUI navigates |
| 2 | `print` | Current selection echoed |

## Notes

- Read-only — no `task`, `set`, or `save` unless user asks to persist.
- Match output shape via [scenarios-index.md](../scenarios-index.md) → one `##` section in [output-patterns.md](../output-patterns.md).
- If workspace is locked by Commander GUI, read `workspace-checkout.md` (skill root) — close Commander for headless, or Remote Control with user consent.
