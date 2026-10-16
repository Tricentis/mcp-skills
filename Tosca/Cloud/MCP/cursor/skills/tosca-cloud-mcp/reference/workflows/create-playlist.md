# Create playlist

Create a playlist and optionally set folders, TCPs, test cases, or schedule (Tosca Cloud: create playlists).

**TCP / folders:** [playlist-structure.md](../playlist-structure.md).

```text
Create playlist:
- [ ] Resolve testCaseIds (tosca_asset Search or known ids)
- [ ] tosca_playlist_edit Upsert (optional root tcp[])
- [ ] Optional FolderUpsert → SetTestCases (addToFolderPath) / tcpScope Upsert / SetSchedule
- [ ] tosca_playlist Get (verify tcp[] + paths)
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_asset` Search | `artifactType: testCase` (optional) | Test case ids |
| 2 | `tosca_playlist_edit` Upsert | `name`, optional `testCaseIds[]`, `runMode`, `tcp[]` | `playlistId` |
| 3 | `tosca_playlist_edit` FolderUpsert | `folderName`, optional `parentPath` | Folder + `path` on Get |
| 4 | `tosca_playlist_edit` SetTestCases | add/remove ids, optional `addToFolderPath` | Items updated (folder must exist) |
| 5 | `tosca_playlist_edit` Upsert | `tcp` + `tcpScope` (folder or `…/sourceId`) | Scoped locals |
| 6 | `tosca_playlist_edit` SetSchedule | `cronExpression` (null/empty clears) | Schedule set/cleared |
| 7 | `tosca_playlist` Get | `playlistId` | Full definition + merged `tcp[]` + `url` |

## Notes

- `runMode`: Parallel \| Sequential \| SequentialOnSameAgent.
- Prefer `tcp[]` over raw `parameters`; Password values redacted on Get; never pass secrets.
- To run → [run-playlist.md](run-playlist.md).
