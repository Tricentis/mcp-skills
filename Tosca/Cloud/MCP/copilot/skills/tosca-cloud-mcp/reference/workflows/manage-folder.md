# Manage folder

Create, modify, move into, or delete inventory folders.

```text
Manage folder:
- [ ] tosca_asset_folder Get (parent / target; omit folderId = root)
- [ ] tosca_asset_folder_edit Upsert | Move | Delete
- [ ] tosca_asset_folder Get (verify)
```

Load **inventory-orchestration.md** from the skill root for browse / move / delete sequences.

## Create folder

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_asset_folder` Get | omit `folderId` (root) or parent `folderId` | Parent children |
| 2 | `tosca_asset_folder_edit` Upsert | `name`; optional `parentFolderId`, `description`, `tags[]` (no `folderId`) | Created folder Get |
| 3 | `tosca_asset_folder` Get | returned `id` | Verify metadata + children |

## Modify folder

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_asset_folder` Get or `tosca_asset` Search | `folderId` / `artifactType: folder` | Folder id |
| 2 | `tosca_asset_folder_edit` Upsert | `folderId` + `name` and/or `color` (or `removeColor`) | Updated folder Get |

Parent changes belong on Move, not Upsert. Colors: Fusion, Accelerate, Thruster, Warp, Blaze, Navy, Rocket.

## Delete folder

**Destructive** — confirm with user first.

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_asset_folder_edit` Delete | `folderId` only | `deletionPolicy` (allowed `childBehavior` values) |
| 2 | `tosca_asset_folder_edit` Delete | `folderId`, `childBehavior` Abort \| DeleteRecursively \| MoveToParent | `{ folderId, deleted: true }` |

## Move artifacts into folder

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_asset` Search | type / name | Source `id` + type |
| 2 | `tosca_asset_folder` Get | target `folderId` (omit = root) | Destination |
| 3 | `tosca_asset_folder_edit` Move | `artifacts[{ entityId, type }]`, `parentFolderId` (omit/empty = root) | `{ moved: true, parentFolderId, artifactCount }` |

Types: TestCase, Module, SharedAction, Playlist, ApiAction, ApiMessage, Folder.
