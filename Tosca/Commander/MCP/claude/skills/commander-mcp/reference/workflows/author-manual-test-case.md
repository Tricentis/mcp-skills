# Author a manual test case

Turn a written manual test definition into a Tosca manual test case.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | (parse) | written steps → name, objective/preconditions, ordered (instruction + expected result) | Confirm structure with the user if the source is loose |
| 2 | `create_test_cases` | `test_cases=[{name, path}]` (a Manual folder), no module steps | Shell test case |
| 3 | `set_attribute` | test case `Description` | Objective / preconditions |
| 4 | `list_available_tasks` + `execute_task` | `"Manual XTestStep"`, `objectIds=[testCaseId]` (per step) | Adds a `ManualXTestStep` without UI selection |
| 5 | `set_attribute` | step `Name` + `Description` (instruction); add `ManualXTestStepValue` for expected results | Populated step |
| 6 | `set_attribute` | `TestCaseWorkState` (`PLANNED`/`IN_WORK`/`COMPLETED`) | Metadata |
| 7 | `save_workspace` / `check_in_all` | — | Persist |

## Notes

- Manual steps aren't module-bound, so `create_test_cases` module steps don't apply — add each step via the `Manual XTestStep` task with `objectIds=[testCaseId]`, then set the step `Description` (the instruction).
- Attribute/task names vary slightly by Commander version — if a `set_attribute` is rejected, `get_attributes` the newly created step to discover the exact writable instruction/expected-result field.
- `TestCaseWorkState` is a `set_attribute` write only — `get_attributes` first to confirm it's
  writable, and never `execute_task("TestCaseWorkState")`; that task opens a native dialog and
  blocks the whole Commander UI.
- To automate it next, see [author-automated-test-case.md](author-automated-test-case.md).
