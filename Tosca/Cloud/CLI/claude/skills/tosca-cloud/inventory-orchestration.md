# Inventory orchestration — search, folders, move

Inventory tools manage artifacts and folder structure in Tosca Cloud.

## Search first (always)

| Tool | Use when |
|------|----------|
| `tosca_inventory_search` | Standard filters: type, name, dates, creator, folder, tags |
| `tosca_inventory_advancedSearch` | Complex boolean filters |

Leave parameters empty or `*` to match all for that dimension.

## Folder operations

| Tool | When | Destructive |
|------|------|-------------|
| `tosca_inventory_createFolder` | New folder under parent | No |
| `tosca_inventory_modifyFolder` | Rename or recolor | No |
| `tosca_inventory_deleteFolder` | Remove folder | **Yes** |
| `tosca_inventory_move` | Move artifacts between folders | No |

## Move workflow

```
1. tosca_inventory_search → source artifact entityIds
2. tosca_inventory_search → target folder entityId
3. tosca_inventory_move(sourceIds, targetFolderId)
4. tosca_inventory_search → verify new folderKey
```

## Related

- [space-orchestration.md](space-orchestration.md)
- [reference/workflows/search-artifacts.md](reference/workflows/search-artifacts.md)
