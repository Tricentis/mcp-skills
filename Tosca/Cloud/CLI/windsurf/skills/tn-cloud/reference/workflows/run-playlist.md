# Run playlist

Execute a playlist and verify run state.

```text
Run playlist:
- [ ] tosca_playlist_searchByName
- [ ] tosca_playlist_run
- [ ] tosca_playlist_getRecentRuns
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_playlist_searchByName` | name fragment | Playlist ID |
| 2 | `tosca_playlist_run` | `playlistId` | `runId` |
| 3 | `tosca_playlist_getRecentRuns` | `playlistId`, `limit` | Run state (Passed/Failed/Running) |

If Failed → continue to [analyze-run-failures.md](analyze-run-failures.md).
