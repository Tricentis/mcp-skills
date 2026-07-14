# Analyze run failures

Diagnose failed test steps from recent playlist runs.

```text
Analyze failures:
- [ ] tosca_playlist_getRecentRuns (identify failed runIds)
- [ ] tosca_playlist_getFailedTestSteps
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_playlist_getRecentRuns` | `playlistId` | Runs with Failed state |
| 2 | `tosca_playlist_getFailedTestSteps` | `runIds` (failed only) | Step-level failure detail |

Hand off to `tosca-analyzing-execution-results` journey skill for confidence-rated diagnosis.
