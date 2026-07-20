# Inspect space

Read-only Code Mode sequence to understand artifacts in the current Tosca Cloud space.

```text
Inspect space:
- [ ] tosca_organization_listWorkspaces
- [ ] tosca_inventory_search (artifactType=* or specific type)
- [ ] optional: tosca_inventory_advancedSearch
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_organization_listWorkspaces` | — | Workspace list |
| 2 | `tosca_inventory_search` | `artifactType`, optional filters | Matching artifacts with EntityId, Name, Type |
| 3 | `tosca_inventory_search` | `folderEntityId` from step 2 | Children in folder |

## Notes

- Summarize for the user in human terms (names, types) — not raw JSON unless debugging.
- Use `tosca_inventory_advancedSearch` when simple search filters are insufficient.
