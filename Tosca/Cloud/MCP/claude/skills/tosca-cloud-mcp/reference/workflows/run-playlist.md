# Run playlist

Start a playlist run and poll until terminal (Tosca Cloud: run tests / check results).

```text
Run playlist:
- [ ] tosca_playlist Search / Get
- [ ] tosca_playlistrun_edit Create
- [ ] Handle needsAgent if personal
- [ ] tosca_playlistrun Get until terminal
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_playlist` Search | `name` | Playlist id |
| 2 | `tosca_playlistrun_edit` Create | `playlistId`, `runOnAPersonalAgent?`, optional partial `testCaseIds[]` (playlist **item** ids) | `playlistRunId` + `url` **or** `needsAgent` |
| 3 | `tosca_playlistrun` Get | `playlistRunId` | Poll Pending/Running → Succeeded/Failed/Canceled |

## Notes

- Optional: share portal `url` (run results page) with the user. Fetch attachments/logs/`testStepsUri*` when diagnosing or fixing failures.
- Default `runOnAPersonalAgent=false` → team/cloud agents.
- Partial run: pass playlist item ids, not raw inventory test case ids if the tool expects item ids from the playlist tree (Get playlist first).
- Failed: use inline `failedStepsByTestCaseRunId` and `testStepsUri*` — do not expect megabyte step JSON.
- `playlistTestCaseRuns[].id` is **not** a `tosca_testrun` id.
- Cancel: `tosca_playlistrun_edit` Cancel; hardCancel needs confirmation.

If Failed → [analyze-run-failures.md](analyze-run-failures.md).
