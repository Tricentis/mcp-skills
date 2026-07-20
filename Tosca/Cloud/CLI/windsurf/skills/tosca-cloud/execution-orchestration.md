# Execution orchestration — run logs and playlist resolution

Read-only execution comparison tools complement playlist run workflows.

## When to use

| User goal | Start with |
|-----------|------------|
| Run playlist and poll | [playlist-orchestration.md](playlist-orchestration.md) |
| Compare passed vs failed run logs | This doc |
| Resolve playlist id by name only | `tosca_execution_getPlaylistIdsByName` |

## Tool sequence

```
tosca_execution_getPlaylistIdsByName(name)
  → playlist id candidates

tosca_execution_getRecentRunLogs(playlistId)
  → sample failed + passed run log comparison
```

## Rules

1. Prefer `tosca_playlist_searchByName` when you also need playlist metadata for run/mutate flows.
2. `getRecentRunLogs` is **read-only** — use for triage before `tosca_playlist_getFailedTestSteps`.
3. Hand off failure diagnosis to [reference/workflows/analyze-run-failures.md](reference/workflows/analyze-run-failures.md) or journey skill `tosca-analyzing-execution-results`.

## Related

- [playlist-orchestration.md](playlist-orchestration.md)
- [reference/workflows/run-playlist.md](reference/workflows/run-playlist.md)
