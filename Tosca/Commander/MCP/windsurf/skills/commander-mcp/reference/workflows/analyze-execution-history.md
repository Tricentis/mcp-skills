# Analyze execution history (across runs)

Surface trends, flakiness, recurring errors, and anomalies across many runs over time. Read-only.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `get_object_info` | list / event + time window | Resolve; collect descendant `ExecutionList`s |
| 2 | `get_object_info` | each `ExecutionList` | Collect `ActualLog` + archived `ExecutionLog`s. If only `ActualLog` → history limited to one run; recommend archiving, stop |
| 3 | `get_attributes` | `ExecutionTestCaseLog` ids, **≤5 per call** | Read `Result`, `StartTime`, `Duration`, `Recovered`, `Name`, `ExecutionSessionId` (skip the heavy `AggregatedDescription`); group into runs by `ExecutionSessionId` |
| 4 | (reason) | — | Per test: runs, failure rate, self-heal rate, duration trend; flaky = result flips ÷ runs; cluster recurring error signatures; outage window = a run where many fail at the same early step |

## Notes

- Filter runs to the window by `StartTime`; paginate big trees with `offset`/`nextOffset`.
- Only pull the full `AggregatedDescription` for failures you're clustering, never for every run.
- Archived logs come from the `Archive actual ExecutionLog` task on the list.
- Report: health trend, top recurring errors, flaky tests, anomalies/outage windows — each with a confidence 0–10. For a single latest run use [analyze-execution-results.md](analyze-execution-results.md).
