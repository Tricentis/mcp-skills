# Space orchestration — tenant, workspace, and artifact context

Tosca Cloud MCP operates in a **tenant + space** context. Mutations persist via API immediately — there is no local workspace file or checkout model.

## Tenant context

| Concept | How MCP exposes it |
|---------|-------------------|
| Tenant | Production: `https://<tenant>.my.tricentis.com` (staging: `.my-test.`; dev: `.my-dev.`) |
| Space | Configured `spaceId` in the MCP URL (`/{spaceId}/_mcp/api/mcp`) |
| Artifact | Inventory entity with camelCase `id`, `type`, `name`, `section` |

## Discovery flow

```
tosca_asset Search (artifactType, name, folderId, tags, dates)
  → optional: tosca_asset AdvancedSearch
```

## Artifact types

Valid `artifactType` values for `tosca_asset`:

- `*` (all), `folder`, `testCase`, `module`, `sharedAction`, `apiMessage`, `playlist`, `testCaseTemplate`

## Entity IDs

- Artifacts return `id` — use this as the typed Get id and as Move `entityId`.
- Folder scoping uses `folderId` in search filters (UUID → that folder; empty string → root; omit → all folders).
- Search hits have no portal `url`. Get the typed artifact on the owning noun (`testCaseTemplate` → `tosca_testcasetemplate` Get).

## Mutations

Cloud API mutations persist immediately. There is no `save_workspace` or `check_in_all` equivalent.

Before destructive operations (`tosca_asset_folder_edit` Delete, `tosca_playlist_edit` Delete, run Deletes, connection deletes):

1. Confirm target with user
2. Re-search to verify entity ID still matches intended object

## Related

- [inventory-orchestration.md](inventory-orchestration.md) — search, folder Get, Upsert / Delete / Move
- [tool-orchestration.md](tool-orchestration.md) — per-tool reference
