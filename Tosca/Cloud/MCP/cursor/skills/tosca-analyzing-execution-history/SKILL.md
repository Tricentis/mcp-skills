---
name: tosca-analyzing-execution-history
description: >-
  Analyzes Tosca Cloud execution trends over multiple playlist runs — flakiness, recurring failures,
  and pass-rate changes. Use when the user asks about trends, flaky tests, historical failures, or
  whether a failure is new or recurring across runs. Read-only. Does NOT cover single-run diagnosis
  (use tosca-analyzing-execution-results).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Henry Fieglein | Fractal
  version: "1.16.0"
---

# Analyze Tosca Cloud execution history

Compare **multiple runs** of a playlist to detect flakiness, regressions, and recurring error signatures. **Read-only.**

**Prerequisite:** `tosca-cloud-basics`.

## Session checklist

```text
Analyze Cloud execution history:
- [ ] Resolve playlist
- [ ] tosca_playlistrun Search (playlistName / state, page)
- [ ] Get several recent runs for failed-step detail as needed
- [ ] Report trends with confidence; hand off if fix needed
```

## Fast path

1. **Resolve playlist** — `tosca_playlist` Search/Get (confirm name).
2. **List runs** — `tosca_playlistrun` Search with `playlistName` (and optional `state`); newest-first summaries.
3. **Sample detail** — `tosca_playlistrun` Get on selected `playlistRunId`s for failed steps / URIs.
4. **Report** — pass/fail trend, recurring signatures, flaky candidates with confidence.

## Flakiness signals

- Same test case Succeeded then Failed across adjacent runs with similar environment
- Intermittent failureRate for one signature
- Failures correlate with run time / load (timing category)

See [references/trend-and-anomaly.md](references/trend-and-anomaly.md).

## Hand off

- Single latest run diagnosis → `tosca-analyzing-execution-results`
- Apply fix → `tosca-remediating-from-results`
