# Explain a test case

Produce a plain-language summary of what a test case does. Read-only.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `get_object_info` | test case path/selection (with children) | Confirm `TestCase`; get the step tree |
| 2 | `get_attributes` | test case | `Description`, `TestCaseWorkState`, `AutomationDegree`, `IsTemplate` |
| 3 | `execute_task` | `used Modules` / `used XModules` | Target application(s) / interfaces |
| 4 | `get_attributes` | steps + values, **batch small** | `ActionMode` (Input/Verify/WaitOn/Buffer), `Operator`, `Value`, `Condition` |

## Notes

- Summarize: purpose · target application(s) · preconditions/data · step-by-step narrative · notable logic (buffers, conditions, loops, recovery, disabled steps) · data-driven coverage (template + instances) · automation status.
- Large test cases: read the step tree first (light via `get_object_info`), then sample the notable values rather than pulling every value's full attributes.
