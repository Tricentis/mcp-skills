# Explain a test case

Produce a plain-language summary of what a test case does. Read-only.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `get_object_info` | test case path/id with children | Confirm `TestCase`; get the step tree |
| 2 | `get_attributes` | `identifiers=[testCaseId]` | `Description`, `TestCaseWorkState`, `AutomationDegree`, `IsTemplate` |
| 3 | `get_object_info` | paginate step children and module references where exposed | Prefer model data for target applications/interfaces |
| 4 | `list_available_tasks` + `execute_task` | `objectIds=[testCaseId]`; `used Modules` / `used XModules` only if model data is insufficient | Additional module usage |
| 5 | `get_attributes` | explicit step/value ids, **batch small** | `ActionMode` (Input/Verify/WaitOn/Buffer), `Operator`, `Value`, `Condition` |

## Notes

- Summarize: purpose · target application(s) · preconditions/data · step-by-step narrative · notable logic (buffers, conditions, loops, recovery, disabled steps) · data-driven coverage (template + instances) · automation status.
- Large test cases: read the step tree first (light via `get_object_info`), then sample the notable values rather than pulling every value's full attributes.
