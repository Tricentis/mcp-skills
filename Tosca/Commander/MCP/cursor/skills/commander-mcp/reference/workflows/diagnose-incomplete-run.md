# Diagnose an incomplete run (aborted · NotExecuted · cancelled)

Explain why a run stopped early or produced no result, and separate genuinely-untested from
skipped-by-design. Read-only.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `(input)` | `ExecutionList` or run-log id | From [locate-execution-results.md](locate-execution-results.md) |
| 2 | `(input)` | did `execute_test_suite` return `ErrorMessage` and no job id? | Yes → the run **never started** (pre-validation failed, or another run still in progress) → report that and **stop**; no log exists to read |
| 3 | `get_attributes` | the `ExecutionList` | `NumberOfTestCasesNotExecuted` · `...WithUnknownState` · `...Failed` · `...Passed`. Both incomplete counters 0 → ordinary failure, not this workflow → **stop**, use [analyze-execution-results.md](analyze-execution-results.md) |
| 4 | `get_object_info` | list with `include_parent_and_children=true`, then the `references.ActualExecutionLog` id the same way, `offset=nextOffset` | `ExecutionTestCaseLog` children **in execution order** — preserve that order, it is the only timeline available |
| 5 | `get_attributes` | log ids, **≤5 per call, middle batch first** | Find the boundary: last terminal `Result` → first `NotExecuted`. Halve the remaining range each probe rather than scanning every log |
| 6 | `get_object_info` + `get_attributes` | boundary log → its `ExecutionXTestStepLog` children | Stopping step + `Result`, `AggregatedDescription`, `EndTime` |
| 7 | `(reason)` | — | Classify: manual/UI cancel · AUT or agent crash · `Condition` skipped the branch by design · disabled or non-`COMPLETED` test case · unresolved buffer → downstream skipped · timeout |
| 8 | `(ask user)` | Commander and AUT state during the run | `ExecutionCancelledException` with no step detail, or a boundary with no message → **dead end**: nothing reads the message window, the execution log file, or agent state. Ask; do not infer |

## Notes

- A `NotExecuted` **tail block** is normal after a stop; `NotExecuted` **scattered mid-list** is
  usually `Condition`/branching — read the step's `Condition` before calling it an abort.
- `WithUnknownState` is **not** a pass and **not** a failure — no result was recorded. Report it as
  unknown, not as a third kind of failure.
- There is no test-event execution tool, no log-archiving tool other than the context-menu task,
  and no message-window tool — anything outside the log object tree has to come from the user.
- Report: where it stopped (test + step) · why · untested vs skipped-by-design · confidence 0–10
  (0–3 speculative, 4–6 plausible, 7–8 strong, 9–10 near-certain). To fix and re-run, see
  [remediate-from-results.md](remediate-from-results.md).
