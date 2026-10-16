# Remediate from results (fix + validate)

Apply a **non-UI** fix to a test case / test data / non-UI module, then validate it.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | (input) | analyzed finding: target asset + change | From [analyze-execution-results.md](analyze-execution-results.md), or diagnose inline |
| 2 | `get_attributes` | target | `CheckOutState` / `IsCheckedOutByMe`; `get_workspace_info` for `mode` |
| 3 | `list_available_tasks` + `execute_task` | parent checkout (multi-user) | Edit tasks appear only once the owning checkout unit is checked out |
| 4 | dedicated tool first; `execute_task` only if none exists | the fix | `set_attribute`, `create_test_cases`, TCP tools, `delete_objects`, or `create_api_*` / `update_api_module`; tasks only for unsupported actions |
| 5 | `execute_test_suite` (`isValidationRun=true`) + `execute_test_suite_status` | `testCaseId` | Per-step pass/fail in the ScratchBook; iterate until green |
| 6 | `save_workspace` / `check_in_all` | — | Persist |

## Notes

- **Scope is non-UI only. Do NOT scan or rescan UI automation modules** — if the root cause is a changed UI locator/module, stop and report it as UI-module maintenance.
- Never call `set_object_selection` as setup. Resolve targets with `get_object_info` or `list_assets` and pass explicit IDs.
- `delete_objects` requires explicit user confirmation; inspect blocker details before considering `force=true`.
- Application defects → report them (optionally set the log's `IssueId`); don't edit the test to mask a real bug unless the expected value genuinely changed.
- `Name` / `Description` fixes → `set_attribute` only. The same-named **task** opens a native
  dialog and blocks the whole Commander UI — never `execute_task("Name")` or
  `execute_task("Description")`.
- Buffer/reuse: set the source value `ActionMode=Buffer`, reference `{B[name]}` on the consumer.
- Checkout and persistence details: read `workspace-orchestration.md` from the skill root. To
  validate outside the ScratchBook (an execution list, not just this test case), see
  [run-and-monitor-execution.md](run-and-monitor-execution.md).
