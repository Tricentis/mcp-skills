---
name: tosca-analyzing-execution-history
description: >-
  Analyzes Tosca Cloud execution trends over multiple playlist runs — flakiness, recurring failures,
  and pass-rate changes via toscactl. Use for trends, flaky tests, or historical failures. Read-only.
  Does NOT cover single-run diagnosis (use tosca-analyzing-execution-results).
license: Apache-2.0
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Analyze Tosca Cloud execution history

Compare **multiple runs** to detect flakiness, regressions, and recurring signatures. **Read-only** — use **`toscactl`**.

**Prerequisite:** `tosca-cloud-basics`.

## Session checklist

```text
Analyze Cloud execution history:
- [ ] Resolve playlist [toscactl]
- [ ] Fetch run history (20+ runs) [toscactl]
- [ ] Classify Passed/Failed trend
- [ ] Deep dive failures via run view + attachments [toscactl]
- [ ] Report with confidence
```

## toscactl (default)

```bash
toscactl playlists find --name "<name>" --results --json --silent
toscactl playlists history "<playlist_id>" --page-size 20 --all --json --silent
# For each failed run:
toscactl playlists run view <run_id> --json --silent
toscactl executions attachments --type test-steps --run <run_id> --test-case <builder_id> --json --silent
```

IDE agent aggregates pass/fail trends from JSON output.

## Fast path [toscactl]

1. **Resolve playlist** — `playlists find --name`
2. **Fetch history** — `playlists history --page-size 20 --all`
3. **Classify runs** — count Passed/Failed; note transitions
4. **Deep dive** — `run view` + `executions attachments` for failed runs only
5. **Compare signatures** — flaky vs recurring across runs
6. **Report** — trend summary with confidence

## Flakiness signals

- Same test passes run N, fails N+1
- Failure signature changes but same test case
- Failures correlate with timing/load

See [references/trend-and-anomaly.md](references/trend-and-anomaly.md).

## Hand off

- Latest run only → `tosca-analyzing-execution-results`
- Apply fix → `tosca-remediating-from-results`
