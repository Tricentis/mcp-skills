---
name: tosca-analyzing-execution-history
description: >-
  Analyzes Tosca Cloud execution trends over multiple playlist runs — flakiness, recurring failures,
  and pass-rate changes. Use when the user asks about trends, flaky tests, historical failures, or
  whether a failure is new or recurring across runs. Read-only. Does NOT cover single-run diagnosis
  (use tosca-analyzing-execution-results).
license: Apache-2.0
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Analyze Tosca Cloud execution history

Compare **multiple runs** of a playlist to detect flakiness, regressions, and recurring error signatures. **Read-only.**

**Prerequisite:** `tosca-cloud-basics`. Wire names: `tosca_{domain}_{action}`.

## Session checklist

```text
Analyze Cloud execution history:
- [ ] Resolve playlist
- [ ] getRecentRuns (limit 20+)
- [ ] Classify Passed/Failed trend
- [ ] getFailedTestSteps for failed runs only
- [ ] Compare signatures across runs (flaky vs recurring)
- [ ] Report with confidence; hand off if fix needed
```

## Fast path

1. **Resolve playlist** — `tosca_playlist_searchByName`.
2. **Fetch run history** — `tosca_playlist_getRecentRuns(playlistId, limit: 20)` (or more if needed).
3. **Classify runs** — count Passed/Failed over window; note state transitions.
4. **Deep dive failures** — `tosca_playlist_getFailedTestSteps` for failed runs only; compare signatures across runs.
5. **Optional comparison** — `tosca_execution_getRecentRunLogs` for log-level diff.
6. **Report** — trend summary, flaky tests, new vs recurring failures with confidence.

## Flakiness signals

- Same test passes on run N, fails on N+1 with same environment
- Failure signature changes but same test case ID
- Failures correlate with run time / load (timing category)

See [references/trend-and-anomaly.md](references/trend-and-anomaly.md).

## Hand off

- Single latest run diagnosis → `tosca-analyzing-execution-results`
- Apply fix → `tosca-remediating-from-results`
