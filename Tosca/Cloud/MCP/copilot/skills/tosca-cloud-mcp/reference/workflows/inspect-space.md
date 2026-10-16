# Inspect space

Browse inventory in the current space.

```text
Inspect space:
- [ ] tosca_asset Search
- [ ] Optional: tosca_asset_folder Get (omit folderId = root)
- [ ] Optional: tosca_playlist Search / tosca_module Search
```

## Steps

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_asset` Search | `artifactType`, optional filters | Matching artifacts (`id`, `type`) |
| 2 | `tosca_asset_folder` Get | omit `folderId` (root) or folder UUID | Folder metadata + direct children |
| 3 | `tosca_playlist` Search | optional name | Playlist summaries |
