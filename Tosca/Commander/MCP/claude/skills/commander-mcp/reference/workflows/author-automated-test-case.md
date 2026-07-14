# Author an automated test case

Build an automated test from a description, reusing existing modules. Extends
[create-test-case.md](create-test-case.md) with module sourcing, action modes, buffering, and validation.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | (intent) | description or an existing manual test | Break into ordered actions + verifications |
| 2 | (ask user) | which module locations to source from | Allowed folders/subprojects under `Modules` — do NOT scan/create UI modules |
| 3 | `get_object_info` | recurse the allowed module folders | Match modules + `ModuleAttribute`s to steps; flag steps with no module (report the gap, don't scan) |
| 4 | `create_test_case` | `name`, `folderPath`, `steps=[{moduleId, action, values}]` | Resolve module ids first; unknown attrs/actions are skipped & reported |
| 5 | `set_attribute` | per value: `Value`, `ActionMode` (Input / Verify+`Operator` / WaitOn / Buffer), `DataType`, `Condition` | Refine; buffer where the scenario says reuse |
| 6 | `execute_task` / `create_api_module` | IF/DO/WHILE on the test case; API module for missing non-UI interactions | Control flow / non-UI steps |
| 7 | `execute_test_suite` (`isValidationRun=true`) + `execute_test_suite_status` | `testCaseId` | Validate in the ScratchBook; fix until green |
| 8 | `save_workspace` / `check_in_all` | — | Persist |

## Notes

- Reuse existing modules only; **never scan or rescan UI automation modules** — report missing-module gaps instead.
- Buffer/reuse: set the source value `ActionMode=Buffer`, then reference `{B[name]}` on consumer values.
