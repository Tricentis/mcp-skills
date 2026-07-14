# Remediate from results (fix + validate)

Apply a **non-UI** fix to a test case / test data / non-UI module, then validate it.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | (input) | analyzed finding: target asset + change | From [analyze-execution-results.md](analyze-execution-results.md), or diagnose inline |
| 2 | `get_attributes` | target | `CheckOutState` / `IsCheckedOutByMe`; `get_workspace_info` for `mode` |
| 3 | `list_available_tasks` + `execute_task` | parent checkout (multi-user) | Edit tasks appear only once the owning checkout unit is checked out |
| 4 | `set_attribute` / `execute_task` / `create_api_module` | the fix | `Value`, `ActionMode`, `Operator`, `Condition`; add/disable/reorder steps; non-UI/API module |
| 5 | `execute_test_suite` (`isValidationRun=true`) + `execute_test_suite_status` | `testCaseId` | Per-step pass/fail in the ScratchBook; iterate until green |
| 6 | `save_workspace` / `check_in_all` | — | Persist |

## Notes

- **Scope is non-UI only. Do NOT scan or rescan UI automation modules** — if the root cause is a changed UI locator/module, stop and report it as UI-module maintenance.
- Application defects → report them (optionally set the log's `IssueId`); don't edit the test to mask a real bug unless the expected value genuinely changed.
- Buffer/reuse: set the source value `ActionMode=Buffer`, reference `{B[name]}` on the consumer.
- Checkout and persistence details: read `workspace-orchestration.md` from the skill root.
