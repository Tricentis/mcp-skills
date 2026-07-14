# Playlist orchestration — search, run, diagnose

Playlists are the primary execution vehicle in Tosca Cloud. This doc covers discover → run → analyze flows.

Copy and track progress:

```text
Playlist workflow:
- [ ] tosca_playlist_searchByName (or inventory search type=playlist)
- [ ] tosca_playlist_run → capture runId
- [ ] tosca_playlist_getRecentRuns (verify state)
- [ ] tosca_playlist_getFailedTestSteps (if failures)
```

## Find a playlist

| Tool | When |
|------|------|
| `tosca_playlist_searchByName` | User gave a name fragment |
| `tosca_inventory_search` (`artifactType: playlist`) | Broader criteria (dates, tags, folder) |
| `tosca_execution_getPlaylistIdsByName` | Need IDs for execution comparison |

## Run a playlist

```
tosca_playlist_run(playlistId, runOnPersonalAgent?)
  → runId
```

- Default runs on team/cloud agents; set `runOnPersonalAgent=true` for personal agent.
- Capture `runId` for failure analysis.

## Analyze results

| Tool | Purpose |
|------|---------|
| `tosca_playlist_getRecentRuns` | Recent runs with state |
| `tosca_playlist_getFailedTestSteps` | Failed step detail for failed runs |
| `tosca_execution_getRecentRunLogs` | Log comparison across runs |

**Rule:** `tosca_playlist_getFailedTestSteps` only returns data for runs in **Failed** state.

## Schedule management

`tosca_playlist_updateRunSchedule` — UTC cron expression. Pass `null` cron to remove schedule.

## Hand off to journey skills

For confidence-rated diagnosis and remediation proposals, use `tosca-analyzing-execution-results` then `tosca-remediating-from-results`.

## Related

- [reference/workflows/run-playlist.md](reference/workflows/run-playlist.md)
- [reference/workflows/analyze-run-failures.md](reference/workflows/analyze-run-failures.md)
