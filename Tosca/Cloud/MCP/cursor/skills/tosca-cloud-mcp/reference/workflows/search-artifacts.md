# Search artifacts

Find inventory artifacts by type and name.

```text
Search artifacts:
- [ ] tosca_asset Search for type/name/folder
- [ ] tosca_asset AdvancedSearch for searchTerm / sort / filters / pagination
- [ ] tosca_module Search for modules (Builder catalog)
- [ ] tosca_playlist Search for playlists
```

## Inventory

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_asset` Search | `artifactType`, `name` | `{ items, nextPageToken, total }` camelCase hits (`id`, `type`) |
| 2 | `tosca_asset` Search | add `folderId` or `tags` | Refined list |
| 3 | `tosca_asset` AdvancedSearch | `searchTerm` / `sort` / `filters` / `pageToken` | Paginated results |

Then Get the typed artifact on the owning noun (`tosca_testcase`, `tosca_testcasetemplate`, `tosca_module`, `tosca_apimessage`, `tosca_asset_folder`, `tosca_playlist`). There is no Get on `tosca_asset`.

Test sheets and classes (TDM) are not inventory artifacts — find them with `tosca_testsheet` List, not `tosca_asset` ([inspect-testsheet.md](inspect-testsheet.md)).

## Modules / playlists

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_module` Search | `name?`, `scope` | Module summaries |
| 2 | `tosca_playlist` Search | `name?`, dates, page | Playlist summaries (no url) |
