# Space orchestration — tenant, workspace, and artifact context

Tosca Cloud MCP operates in a **tenant + space** context. Mutations persist via API immediately — there is no local workspace file or checkout model.

## Tenant context

| Concept | How MCP exposes it |
|---------|-------------------|
| Tenant | Production: `https://<tenant>.my.tricentis.com` (staging: `.my-test.`; dev: `.my-dev.`) |
| Space | Configured `spaceId` in MCP server settings |
| Workspace | `tosca_organization_listWorkspaces` — logical workspaces within tenant |
| Artifact | Inventory entity with `EntityId`, `Type`, `Name`, `Section` |

## Discovery flow

```
tosca_organization_listWorkspaces
  → tosca_inventory_search (artifactType, artifactName, folderEntityId, tags, dates)
  → optional: tosca_inventory_advancedSearch
```

## Artifact types

Valid `artifactType` values for `tosca_inventory_search`:

- `*` (all), `folder`, `testCase`, `module`, `sharedAction`, `apiMessage`, `playlist`

## Entity IDs

- Artifacts return `EntityId` — use this in subsequent inventory, builder, and playlist tools.
- Folder scoping uses `folderEntityId` in search filters.
- Portal links may appear in tool responses — treat as navigation hints, not MCP identifiers.

## Mutations

Cloud API mutations persist immediately. There is no `save_workspace` or `check_in_all` equivalent.

Before destructive operations (`tosca_inventory_deleteFolder`, `tosca_playlist_deleteById`, connection deletes):

1. Confirm target with user
2. Re-search to verify entity ID still matches intended object

## Related

- [inventory-orchestration.md](inventory-orchestration.md) — folder and move operations
- [tool-orchestration.md](tool-orchestration.md) — per-tool reference
