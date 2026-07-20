# MCP building blocks — Tosca Cloud

## Discovery

```text
tosca_organization_listWorkspaces
tosca_inventory_search(artifactType, artifactName, ...)
tosca_inventory_advancedSearch(...)   # complex filters
tosca_playlist_searchByName(name)
```

## Execution

```text
tosca_playlist_run(playlistId)
tosca_playlist_getRecentRuns(playlistId, limit)
tosca_playlist_getFailedTestSteps(runIds)   # failed runs only
tosca_execution_getRecentRunLogs(...)
```

## Builder

```text
tosca_builder_scaffoldTestCase(...)
tosca_builder_getModulesSummary(...)
tosca_builder_createApiMessage / get / update / delete
```

## Data Integrity

Always start with `tosca_dataintegrity_workflow`. Async tools need polling via `check*Result` companions.

| Tool group | Purpose |
|------------|---------|
| `workflow`, `listConnections` | Gate + connection discovery |
| `testConnection` / `checkTestConnectionResult` | Validate connectivity (async) |
| `getConnectionSchema` / `checkSchemaResult` | Column metadata for SQL (async) |
| `createRowByRowComparison` | Row-by-row or file comparison TC |
| `createDiDbExpertTestcase` | DB Expert TC |

Engineering detail: `tosca-cloud` → `di-orchestration.md`.

## Mobile

Connection and Appium capability management — no run-from-connection outcome tool.

```text
tosca_mobile_listConnections / getConnection / createConnection / updateConnection
tosca_mobile_addCapabilitySet / setCapability / renameCapabilitySet
```

Engineering detail: `mobile-orchestration.md`, `mobile-connection` workflow.

## API execution

HTTP/JMS/Kafka connection CRUD — configure endpoints for API tests.

```text
tosca_apiexecution_listConnections / getConnection / createConnection / updateConnection
```

Engineering detail: `apiexecution-orchestration.md`, `api-execution-connection` workflow.

## Simulation

Deploy API simulations to agents.

```text
tosca_simulation_listAgents / create / deploy
```

Engineering detail: `simulation-orchestration.md`, `deploy-simulation` workflow.

## Response handling

Most tools return JSON strings. Parse in Code Mode; summarize for the user in direct tool mode.
