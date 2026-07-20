# Run result schema — Tosca Cloud

## Run states

Runs from `tosca_playlist_getRecentRuns` include execution state (e.g. Passed, Failed, Running).

## Failed test steps

`tosca_playlist_getFailedTestSteps` returns per-run:

- Failed test case units
- Test step attachments with step name, action, expected/actual where available

## Comparison across runs

`tosca_execution_getRecentRunLogs` — compare log patterns across recent executions for the same playlist.
