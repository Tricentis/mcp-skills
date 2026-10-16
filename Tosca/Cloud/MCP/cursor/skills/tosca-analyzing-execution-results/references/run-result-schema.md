# Run result schema — Tosca Cloud

## Playlist run Get

`tosca_playlistrun` Get (by `playlistRunId` | latest `playlistId` | exact `playlistName`) returns:

- Playlist run state and portal `url`
- `playlistTestCaseRuns[]` (progress / terminal states)
- When Failed: `failedStepsByTestCaseRunId` (inline)
- When Failed/Succeeded: `testStepsUriByTestCaseRunId` (URI only — not full trees)
- `attachments[]` / `logsUrl` when available

While Pending/Running/Canceling, keep polling — do not invent success.

## Playlist run Search

Summaries only (id, playlist, state, timestamps) — **no** portal `url`. Use for multi-run history; Get selected ids for detail.

## Trial run Get

`tosca_testrun` Get returns state, `portalUrl`, `testSteps` (messages/details), and `attachments[]` for personal Builder runs. Use List (`name` / `state`) when the user has no `testRunId`.

## Identity rule

`playlistTestCaseRuns[].id` ≠ `tosca_testrun` id.
