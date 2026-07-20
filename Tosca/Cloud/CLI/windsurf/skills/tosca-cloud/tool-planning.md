# MCP tool planning guide

Use with [tn-invocation.md](tn-invocation.md), [tool-orchestration.md](tool-orchestration.md), and [reference/tools-catalog.md](reference/tools-catalog.md) — open the catalog only for tools in your plan.

## Planning checklist

```text
Plan checklist:
- [ ] Goal stated in Cloud terms (tenant, space, artifact, playlist)
- [ ] Readiness: tosca_organization_listWorkspaces
- [ ] Discover before every mutation
- [ ] Async poll steps identified (DI schema, playlist runs)
- [ ] Destructive steps flagged for user confirmation
- [ ] Verify step at end
```

## Planning primitives

### Resolve identity

Cloud artifacts use **EntityId** from inventory search.

```
tosca_inventory_search(artifactType, artifactName, folderEntityId?)
  → EntityId for downstream tools
```

Prefer `tosca_inventory_advancedSearch` when filters are complex or results paginate.

### Playlist resolution

```
tosca_playlist_searchByName(name)
  → playlistId

tosca_execution_getPlaylistIdsByName(name)   # id-only, read-only
```

### Run polling

```
tosca_playlist_run(playlistId) → runId
tosca_playlist_getRecentRuns(playlistId, limit)
  → repeat until state ∉ {Running, ...}
```

Only then `tosca_playlist_getFailedTestSteps` for failed runs.

### DI async chain

```
tosca_dataintegrity_getConnectionSchema(connectionId) → notificationId
tosca_dataintegrity_checkSchemaResult(notificationId) → poll until complete
```

Same pattern for `testConnection` / `checkTestConnectionResult`.

### Builder scaffold chain

```
tosca_builder_getModulesSummary
tosca_inventory_search(artifactType: module)   # if moduleName ambiguous
tosca_builder_scaffoldTestCase(name, testSteps?)
tosca_inventory_move(artifactIds, folderEntityId)
```

## Category-specific plans

### Space audit (read-only)

See [reference/workflows/inspect-space.md](reference/workflows/inspect-space.md).

### Connect tenant

See [reference/workflows/connect-tenant.md](reference/workflows/connect-tenant.md) and journey skill `tosca-cloud-connect`.

### Search artifacts

See [reference/workflows/search-artifacts.md](reference/workflows/search-artifacts.md).

### Run and analyze playlist

```
run-playlist.md → analyze-run-failures.md
```

Or journey skill `tosca-analyzing-execution-results`.

### Manage folders

See [reference/workflows/manage-folder.md](reference/workflows/manage-folder.md).

### Data Integrity

```
di-orchestration.md + one reference/di/workflows/*.md
tosca_dataintegrity_workflow
listConnections → schema (async) → createRowByRowComparison
```

**Never** call DI mutate tools before reading `tosca_dataintegrity_workflow` output.

### Mobile / API / simulation

| Scenario | Workflow |
|----------|----------|
| Mobile connection | [mobile-connection.md](reference/workflows/mobile-connection.md) |
| API execution connection | [api-execution-connection.md](reference/workflows/api-execution-connection.md) |
| Simulation deploy | [deploy-simulation.md](reference/workflows/deploy-simulation.md) |

## Error recovery

| Signal | Plan adjustment |
|--------|-------------------|
| 401 | Re-auth via `tn`; see `tosca-cloud-connect` |
| Entitlement error | Stop; inform user |
| Empty search | Broaden filters or ask user |
| DI async incomplete | Continue polling check*Result |
| Wrong entityId | Re-search inventory |

## Journey vs engineering

| Need | Use |
|------|-----|
| Tool order, polling, parameters | `tosca-cloud` (this skill) |
| User-story diagnose/author/explain | Journey skills — `AGENTS.md` |
