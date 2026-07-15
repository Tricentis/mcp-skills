# Data Integrity getting started

**Mandatory first step:** read **di-orchestration.md** at the skill root, then **one** scenario file from **reference/di/index.md**.

```text
DI getting started:
- [ ] di-orchestration.md + one reference/di/workflows/*.md
- [ ] tosca_dataintegrity_workflow (mandatory first tool call)
- [ ] tosca_dataintegrity_listConnections
- [ ] test/schema or comparison tools per scenario
- [ ] inventory search to verify created test case
```

## High-level plan

| Phase | Tools | Notes |
|-------|-------|-------|
| 1. Plan | Skill docs | di-orchestration.md + one `reference/di/workflows/*.md` |
| 2. Connections | `listConnections`, `testConnection` → `checkTestConnectionResult` | Create/update connections in Cloud UI only |
| 3. Schema | `getConnectionSchema` → `checkSchemaResult` | Open `launcherLink`; poll until complete |
| 4. Build | `createRowByRowComparison` or `createDiDbExpertTestcase` | Confirm SQL + RowKey with user |
| 5. Verify | `tosca_inventory_search` | Confirm test case exists |

## Async polling loop

```text
tosca_dataintegrity_getConnectionSchema(connectionId)
  → launcherLink, notificationId

open launcherLink on user machine (if required)

loop:
  tosca_dataintegrity_checkSchemaResult(notificationId)
  if incomplete: wait and retry
  else: use columns metadata
```

Same pattern for `tosca_dataintegrity_testConnection` → `tosca_dataintegrity_checkTestConnectionResult`.

## Scenario quick-pick

| User asks | Workflow file |
|-----------|---------------|
| Compare two databases row-by-row | [01-row-by-row-comparison.md](../di/workflows/01-row-by-row-comparison.md) |
| Compare CSV/file to database | [02-file-comparison.md](../di/workflows/02-file-comparison.md) |
| DB Expert test case | [di-db-expert-testcase.md](di-db-expert-testcase.md) |
