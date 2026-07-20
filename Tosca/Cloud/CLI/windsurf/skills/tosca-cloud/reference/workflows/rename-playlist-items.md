# Rename playlist items

Semantic rename of test case items in a playlist.

```text
Rename playlist items:
- [ ] tosca_playlist_searchByName
- [ ] tosca_playlist_analyzeTestCaseItems
- [ ] user confirms renames
- [ ] tosca_playlist_applyTestCaseItemRenames
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_playlist_searchByName` | playlist name | Playlist id |
| 2 | `tosca_playlist_analyzeTestCaseItems` | playlist id | Suggested renames (read-only) |
| 3 | *(user)* | Review suggestions | Confirmed rename map |
| 4 | `tosca_playlist_applyTestCaseItemRenames` | confirmed renames | Applied |

Journey handoff: `tosca-remediating-from-results` when fixing names after failed runs.
