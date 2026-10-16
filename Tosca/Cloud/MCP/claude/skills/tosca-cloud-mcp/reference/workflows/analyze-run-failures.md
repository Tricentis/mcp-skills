# Analyze run failures

Triage the latest playlist run (or a known `playlistRunId`).

```text
Analyze run failures:
- [ ] tosca_playlistrun Get (by playlistRunId | playlistId | exact playlistName)
- [ ] Read failedSteps / attachments / testStepsUri
- [ ] Optional: tosca_playlistrun Search for recent runs / trends
```

## Steps

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_playlistrun` Get | exactly one selector | Run + `playlistTestCaseRuns[]` + portal `url` |
| 2 | *(read)* | Failed facets | `failedStepsByTestCaseRunId`, log URLs, `testStepsUri*` |
| 3 | `tosca_playlistrun` Search | `playlistName?`, `state?` | Recent run summaries for trend context |

## Notes

- While Pending/Running/Canceling, keep polling — do not invent success.
- Prefer URI downloads over inlining full step trees.
- For personal Builder trial failures use `tosca_testrun` Get instead.

Journey skill: `tosca-analyzing-execution-results` (latest) or `tosca-analyzing-execution-history` (multi-run Search).
