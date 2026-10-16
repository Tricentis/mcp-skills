# Execution orchestration — trial runs and result polling

Two execution paths (Tosca Cloud docs: trial runs vs playlist / E2G runs):

| Path | Read | Mutate | Agent | Use when |
|------|------|--------|-------|----------|
| Builder trial / debug run | `tosca_testrun` Get / List | `tosca_testrun_edit` Create / Delete | Personal agent only | Single test case, same as Builder Run |
| Playlist run | `tosca_playlistrun` Get / Search | `tosca_playlistrun_edit` Create / Cancel / Delete | Team/cloud (default) or personal | Batch / scheduled / unattended |

## Personal trial run — `tosca_testrun` / `_edit`

### Create — `tosca_testrun_edit`

Requires `testCaseId`; optional `testStepIds[]` for a subset.

1. If a personal agent is already online → returns `testRunId` (no agent link).
2. If none online → returns `needsAgent` + `agentLink` only. Open that link yourself without asking, wait a few seconds, call Create again.
3. After `testRunId`, poll **`tosca_testrun` Get** until terminal.

### Get — `tosca_testrun`

Poll with `testRunId`. While running, call Get again. When succeeded / failed / canceled: `portalUrl`, `testSteps` (per-step messages/details), `attachments[]` with download urls (logs, recording, TestSteps, …).

Optional: share `portalUrl` (results page `…/runs/{id}/results/{resultId}`) with the user instead of dumping download URLs. When diagnosing or fixing a failing test, fetch the relevant `attachments[]` / `logsUrl`.

### List — `tosca_testrun`

Portal Test Runs catalog (`POST api/v2/runInfo/search`). Newest first. Optional `name` (contains), `state`, `pageSize` / `pageToken` (default 50, max 200). Hits include `testRunId`, `runInfoId`, `personal` (true = Builder debug run), `state`, `createdAt`. Use `testRunId` with Get. Playlist-specific search stays on `tosca_playlistrun` Search.

`state` accepts ExecutionStateV1 names (`Succeeded`, `Failed`, `Canceled`, `Running`, `Pending`, `Canceling`). Hits display in-progress as `running`; `Running` / `Pending` / `Canceling` all match those rows.

### Delete — `tosca_testrun_edit`

Permanently delete run + results by `testRunId`; confirm unless the user asked to delete.

Cheap validation fixture: test case with Standard Objects **TBox Wait** Duration=1000 — finishes quickly.

## Playlist runs

Full orchestration: [playlist-orchestration.md](playlist-orchestration.md).

```
tosca_playlistrun_edit Create(playlistId, runOnAPersonalAgent?)
  → playlistRunId
tosca_playlistrun Get(playlistRunId)   # poll until terminal
```

- Default `runOnAPersonalAgent=false` uses team/cloud agents (characteristics / cloud agents as configured on the playlist).
- Personal gate mirrors testrun (`needsAgent` + link).
- Results: `playlistTestCaseRuns[]`, failed steps inline when Failed, log/`testStepsUri` as URIs.

## Rules

1. Prefer trial `tosca_testrun_edit` Create → `tosca_testrun` Get to prove a TC is executable before adding it to a playlist.
2. Never use `playlistTestCaseRuns[].id` as a `tosca_testrun` id (or the reverse).
3. Poll honestly — report Pending/Running; do not invent success.
4. Confirm before `tosca_testrun_edit` Delete or playlistrun hardCancel.

## Related

- [reference/workflows/trial-run-testcase.md](reference/workflows/trial-run-testcase.md)
- [reference/workflows/run-playlist.md](reference/workflows/run-playlist.md)
- [playlist-orchestration.md](playlist-orchestration.md)
