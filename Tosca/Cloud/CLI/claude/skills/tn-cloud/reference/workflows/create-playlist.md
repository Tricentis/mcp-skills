# Create playlist

Create a new playlist in inventory.

```text
Create playlist:
- [ ] tosca_inventory_search (optional folder)
- [ ] tosca_playlist_add
- [ ] tosca_playlist_searchByName (verify)
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_inventory_search` | `artifactType: folder` (optional) | Parent folder `entityId` |
| 2 | `tosca_playlist_add` | name, test case items per schema | Playlist created |
| 3 | `tosca_playlist_searchByName` | name fragment | Playlist id |

To run after creation → [run-playlist.md](run-playlist.md).
