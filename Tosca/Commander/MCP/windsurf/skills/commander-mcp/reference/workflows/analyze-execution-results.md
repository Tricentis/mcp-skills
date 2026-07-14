# Analyze execution results (latest run)

Diagnose why a completed run failed and propose ranked, confidence-rated fixes. Read-only.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `get_object_info` | test event / execution list path or selection | Resolve type; if a grouping folder/event, collect descendant `ExecutionList`s |
| 2 | `get_attributes` | ExecutionList id | Aggregates `NumberOfTestCasesFailed/Passed/NotExecuted/WithUnknownState`. If 0 failed & 0 unknown → report all-passed, stop |
| 3 | `get_object_info` | `ActualLog` (child of the list) | Children are `ExecutionTestCaseLog` (one per test case) |
| 4 | `get_attributes` | log ids, **≤5 per call** | Keep `Result` in {Failed, Error}; note `Recovered=True` (self-heal = brittle) |
| 5 | `get_object_info` + `get_attributes` | failing log → `ExecutionXTestStepLog` children | Isolate failing step + message (`AggregatedDescription`, `Detail`/`LogInfo`) |

## Notes

- Execution logs carry a large `AggregatedDescription`; batch `get_attributes` at **≤5 ids** or you may exceed the response limit. If a big result spills to a file, extract `Result` with a script rather than loading it.
- Do NOT use the `ExecutionEntries: Failed`/`Passed`/`Self-healed` context tasks or `Generate TQL` — TQL search is unsupported via MCP; iterate the log children and filter by `Result`.
- Classify each failure: application defect · test-data · timing/sync · environment/infra · locator/module mismatch (UI — out of scope to fix) · assertion mismatch. Group failures sharing a step/message → one systemic cause; diagnose once.
- Report per finding: failing step + message · root-cause hypothesis · ranked remediation · where the fix lands · confidence 0–10 (0–3 speculative, 4–6 plausible, 7–8 strong, 9–10 near-certain). Read-only — to apply a fix, see [remediate-from-results.md](remediate-from-results.md).
