# Inventory orchestration — search, folders, move

Inventory tools find artifacts and manage folder structure in Tosca Cloud.

## Search first (always)

| Tool | Use when |
|------|----------|
| `tosca_asset` Search | Convenience filters: type, name, folder, dates, creator, tags. Paginated (default pageSize 50) |
| `tosca_asset` AdvancedSearch | Search plus `searchTerm`, `sort[]`, nested AND/OR `filters`, `includeAncestors` |

Leave `artifactType` empty or `*` to match all types. Hits are `{ items, nextPageToken, total }`; each item is `{ id, type, name, tags, section, folderId, createdAt, createdBy, updatedAt, updatedBy }` (+ `ancestors[]` with UUID ids when `includeAncestors`). No portal `url`. No Get on this tool — Get the typed artifact on the owning noun (`tosca_module`, `tosca_testcase`, `tosca_testcasetemplate`, `tosca_apimessage`, `tosca_asset_folder`, `tosca_playlist`).

Cross-asset search stays on `tosca_asset`. Folder tree reads use `tosca_asset_folder`. Document the noun surface only (V1 `tosca_inventory_search` / `advancedSearch` are hidden when V2 is active).

## Folder operations

| Tool | When | Destructive |
|------|------|-------------|
| `tosca_asset_folder` Get | Folder metadata + direct children. Omit `folderId` = workspace root | No |
| `tosca_asset_folder_edit` Upsert | Create (omit `folderId`) or rename/recolor (with `folderId`) | No |
| `tosca_asset_folder_edit` Delete | Remove folder (`childBehavior` probe then confirm) | **Yes** |
| `tosca_asset_folder_edit` Move | Move artifacts (any type) into a folder or root | No |

`folderId` / `parentFolderId` are UUID v4. `ancestors[].id` and `parentFolderId` on Get are bare UUIDs (pass them back as `folderId`). Children expose `id` and `entityId` (same value). Search hit `id` is the same value as Move `entityId`.

## Browse folders

```
tosca_asset_folder Get                  # omit folderId → { id: null, name: "root", children[] }
tosca_asset_folder Get folderId         # metadata + children[] (id, entityId alias, name, type, tags)
```

## Create / update

```
1. tosca_asset_folder Get (parent) or omit folderId for root
2. tosca_asset_folder_edit Upsert — no folderId, name required; optional parentFolderId, description, tags[]
3. tosca_asset_folder Get (returned id) → verify

Update: Upsert with folderId + name and/or color (or removeColor). Parent changes belong on Move.
```

Colors: Fusion, Accelerate, Thruster, Warp, Blaze, Navy, Rocket. Specify either `color` or `removeColor`, not both.

## Move workflow

```
1. tosca_asset Search → source ids + types
2. tosca_asset_folder Get → target folder (omit folderId = root)
3. tosca_asset_folder_edit Move artifacts[{ entityId, type }] parentFolderId (omit/empty = root)
4. tosca_asset_folder Get → verify children
```

Move types: TestCase, Module, SharedAction, Playlist, ApiAction, ApiMessage, Folder. Same workspace only.

## Delete workflow

**Destructive** — confirm with the user first.

```
1. tosca_asset_folder_edit Delete folderId only → deletionPolicy (allowed childBehavior values)
2. tosca_asset_folder_edit Delete folderId + childBehavior Abort | DeleteRecursively | MoveToParent
```

## Related

- [space-orchestration.md](space-orchestration.md)
- [reference/workflows/search-artifacts.md](reference/workflows/search-artifacts.md)
- [reference/workflows/manage-folder.md](reference/workflows/manage-folder.md)
