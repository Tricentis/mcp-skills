# Compare two runs

Diff exactly two runs of the same execution list into regressions, fixes, and flake candidates.
Read-only.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `(input)` | two runs of the same `ExecutionList` | Both must be the same list — cross-list diffs compare different test sets |
| 2 | `get_object_info` | the `ExecutionList`, `include_parent_and_children=true` | `references.ActualExecutionLog` is the latest run. `ExecutionLog` children are archived runs. No archived `ExecutionLog` → **stop**: one run retained; recommend `Archive actual ExecutionLog` before the next run |
| 3 | `get_attributes` | both run-log roots (**one call, 2 ids**) | Headline counter delta. Identical → say so and stop before enumerating anything |
| 4 | `get_object_info` | each run log, `include_parent_and_children=true`, paginate | `ExecutionTestCaseLog` children → a name→id map per run; pair by `Name` |
| 5 | `get_attributes` | paired log ids, **≤5 per call** | `Result`, `Duration`, `Recovered` → newly-failing · newly-passing · still-failing · still-passing · unmatched · newly self-healed |
| 6 | `get_object_info` + `get_attributes` | **newly-failing logs only** → their `ExecutionXTestStepLog` children | The differing step + message. Never expand still-passing or still-failing tests |
| 7 | `(reason)` | — | One test flipping on the same step with no change → flake; a cluster of newly-failing tests sharing a step or message → one systemic cause (environment · data · build) |

## Notes

- Pair by `Name`; treat collision suffixes (`_1`, `_2`) as a warning — a suffix can move between
  runs, so call an unpaired log **unmatched** rather than asserting added/removed.
- Duration deltas only mean something on the same agent and environment — ask before reading a
  slowdown as a regression.
- Step 6 is the only expensive step: `get_attributes` has no projection, so every step-log id pulls
  its full `AggregatedDescription`. Budget it against the newly-failing count; above ~20, sample
  and **say you sampled**.
- Report: counter delta · regressions with step + message · fixes · flake candidates · unmatched —
  each with confidence 0–10 (0–3 speculative, 4–6 plausible, 7–8 strong, 9–10 near-certain). For
  more than two runs use [analyze-execution-history.md](analyze-execution-history.md).
