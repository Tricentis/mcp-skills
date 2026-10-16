# Execution log object model and cost rules

Shared reference for the six execution workflows below. There is no search/TQL tool, no
attribute-name projection, and no pagination on `get_attributes` — every analysis is a tree walk
that returns each object's full attribute set. Read this once per session before the first
execution-analysis call; don't re-derive these rules per workflow.

## Log object tree

| Type | Reached from | Carries |
|------|--------------|---------|
| `ExecutionList` (or a grouping `TestEvent`/folder) | Resolved by path/selection ([locate-execution-results.md](workflows/locate-execution-results.md)) | `NumberOfTestCasesFailed/Passed/NotExecuted/WithUnknownState` aggregate counters |
| `ActualExecutionLog` | `references.ActualExecutionLog` on the `ExecutionList` from `get_object_info` (`include_parent_and_children=true`). Not a child | The `ExecutionLog` for the **latest** run |
| `ExecutionLog` (archived) | Child of `ExecutionList` (`ExecutionLogs`). The `Archive actual ExecutionLog` task adds a past run here | Same log shape, for a past run |
| `ExecutionEntry` | Child of `ExecutionList` (the list's static membership, not a run) | `references.testCase` — the only run→test-case hop; no reverse lookup exists |
| `ExecutionTestCaseLog` | Child of an `ExecutionLog`, in execution order | `Result` (Failed/Error/Passed/NotExecuted/unknown), `Recovered`, `StartTime`, `Duration`, `Name`, `ExecutionSessionId`, `AggregatedDescription` (heavy) |
| `ExecutionXTestStepLog` | Child of a failing/incomplete `ExecutionTestCaseLog` | Per-step `Result`, `AggregatedDescription`, `Detail`/`LogInfo` |

## Attribute cost rules

`get_attributes` always returns **every** attribute for **every** id, including
`AggregatedDescription` — there is no field filter and no pagination on this tool.
`get_object_info` is the cheap counterpart: id/type/name/nodePath only, paginated at `limit` 200,
never carries `AggregatedDescription`.

- **Aggregates before enumeration, always.** One `get_attributes` on the `ExecutionList` can end
  the workflow outright (all-passed → stop; 0 incomplete → wrong workflow).
- **Walk structure with `get_object_info`, never `get_attributes`.** Shortlist candidates by
  `name`/`type` from the children listing before spending a single `get_attributes` call.
- **Attributes breadth-first, one level at a time, ≤5 ids per call.** Read
  `ExecutionTestCaseLog.Result` before ever descending to step logs; descend only for logs whose
  `Result` ∈ {Failed, Error, NotExecuted}.
- **Batch size is adaptive, not fixed.** Drop to 1 id per call the moment a response truncates or
  spills to a file, and stay there.
- **Bisect ordered scans.** `ExecutionLog` children are in execution order, so a
  pass→NotExecuted boundary is monotonic — probe the middle batch, then the half containing the
  boundary. `~log2(N)/5` calls instead of `N/5`.
- **Never re-fetch.** Cache `id → (name, type, Result)` for the session; there is no delta read.
- **Budget from the aggregates, then say so.** Convert `NumberOfTestCases*` into a call estimate
  before the first enumeration. Above roughly 50 failing test cases, full enumeration is not
  implementable without projection — sample, cluster by message signature, and **tell the user you
  sampled** instead of silently truncating.
- **In Code Mode, extract before returning.** If a response spills to a file, parse `Result` with a
  script rather than loading the payload into context.

## Hard gaps — stop and report these limits

| Capability | Reality |
|------------|---------|
| Search / TQL for execution results | No search tool. A TQL search runs in Commander but its results never return to the assistant — walk the tree instead |
| Reverse lookup: `TestCase` → its `ExecutionEntry`/runs | Does not exist. The only hop is `ExecutionEntry.references.testCase`, one direction only |
| Test-event completion | `execute_test_suite` with `is_validation_run=false` and `execution_list_id` accepts an `ExecutionList`, `ExecutionEntryFolder`, `ExecutionEntry`, or `TestEvent`. A `TestEvent` is only enqueued; per-entry rows are the last known logs, not the remote run |
| Log archiving | No dedicated tool — only the `Archive actual ExecutionLog` context-menu task, discovered via `list_available_tasks` |
| Defect / issue linking | No tool. `IssueId` is an attribute some logs expose — set it with `set_attribute` if writable, otherwise ask the user |
| Message window, agent state, screenshots during a run | Nothing reads these. If a boundary or `ExecutionCancelledException` has no step detail, ask the user rather than inferring |

## Which workflow

| Goal | Workflow |
|------|----------|
| Find the run/list the user means | [locate-execution-results.md](workflows/locate-execution-results.md) |
| Diagnose why the latest run failed | [analyze-execution-results.md](workflows/analyze-execution-results.md) |
| Diagnose a run that stopped early / has NotExecuted or unknown-state entries | [diagnose-incomplete-run.md](workflows/diagnose-incomplete-run.md) |
| Trends, flakiness, recurring errors across many runs | [analyze-execution-history.md](workflows/analyze-execution-history.md) |
| Diff exactly two runs | [compare-two-runs.md](workflows/compare-two-runs.md) |
| Start a run and wait for its result | [run-and-monitor-execution.md](workflows/run-and-monitor-execution.md) |
| Apply a fix and validate it | [remediate-from-results.md](workflows/remediate-from-results.md) |
