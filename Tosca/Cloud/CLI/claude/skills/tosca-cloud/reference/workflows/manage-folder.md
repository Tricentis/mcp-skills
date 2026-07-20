# Manage folder

Create, modify, move into, or delete inventory folders.

```text
Manage folder:
- [ ] tosca_inventory_search (parent / target folder)
- [ ] folder mutate tool
- [ ] tosca_inventory_search (verify)
```

## Create folder

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_inventory_search` | `artifactType: folder`, parent name | Parent `entityId` |
| 2 | `tosca_inventory_createFolder` | name, `parentFolderEntityId` | New folder |
| 3 | `tosca_inventory_search` | `artifactType: folder`, name | Verify |

## Modify folder

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_inventory_search` | `artifactType: folder` | Folder `entityId` |
| 2 | `tosca_inventory_modifyFolder` | `folderEntityId`, new name/color | Success message |

## Delete folder

**Destructive** — confirm with user first.

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_inventory_deleteFolder` | `folderEntityId` only | Allowed `ChildBehavior` values |
| 2 | `tosca_inventory_deleteFolder` | `folderEntityId`, `childBehavior` | Folder removed |

## Move artifacts into folder

Use `tosca_inventory_moveIntoFolder` after resolving source artifact and target folder via `tosca_inventory_search`. Load **inventory-orchestration.md** from the skill root for full move/rename sequences.
