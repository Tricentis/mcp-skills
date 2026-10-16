# Data Integrity getting started

**Mandatory first step:** read **di-orchestration.md** at the skill root, then **one** scenario file from **reference/di/index.md**.

```text
DI getting started:
- [ ] di-orchestration.md + one reference/di/workflows/*.md
- [ ] tosca_diconnection List / Get
- [ ] Five-step schema via runSql (not a schema tool)
- [ ] createRowByRowComparison
- [ ] tosca_testcase Get
- [ ] Optional run → analyze → approved remediation loop
```

## High-level plan

| Phase | Tools | Notes |
|-------|-------|-------|
| 1. Plan | Skill docs | di-orchestration.md + one `reference/di/workflows/*.md` |
| 2. Connections | `tosca_diconnection` List / Get | Optional Create/Test: [di-connection.md](di-connection.md) |
| 3. Schema | Five-step recipe in [conventions.md](../di/conventions.md) | `runSql` → launcher → `checkSqlResult`. Requires `allowAiQueries`. |
| 4. Build | `createRowByRowComparison` | Confirm SQL + RowKey + remaps. Use `columnRenames` when names differ. |
| 5. Verify | `tosca_testcase` Get | Confirm structure |
| 6. Optional run | `tosca_testrun_edit` Create → `tosca_testrun` Get | Only if the user asked to execute |
| 7. Failed result | DI workflow 04 → optional workflow 05 | Diagnose read-only; confirm before applying a fix |

## Async polling loop

```text
tosca_dataintegrity_runSql(connectionId, sql)
  → launcherLink, notificationId

open launcherLink on user machine

loop:
  tosca_dataintegrity_checkSqlResult(notificationId)
  if pending: wait and retry
  else: use result rows
```

Same pattern for `tosca_dataintegrity_testConnection` → `tosca_dataintegrity_checkTestConnectionResult` (optional; does not need `allowAiQueries`).

## Scenario quick-pick

| User asks | Workflow file |
|-----------|---------------|
| List / create / test a DI connection | [di-connection.md](di-connection.md) |
| Compare two databases row-by-row | [01-row-by-row-comparison.md](../di/workflows/01-row-by-row-comparison.md) |
| Compare CSV/file to database | [02-file-comparison.md](../di/workflows/02-file-comparison.md) |
| Turn business rules into a DI comparison | [03-business-rules-to-sql.md](../di/workflows/03-business-rules-to-sql.md) |
| Analyze a failed DI run | [04-analyze-execution-results.md](../di/workflows/04-analyze-execution-results.md) |
| Apply and validate an approved fix | [05-remediate-from-results.md](../di/workflows/05-remediate-from-results.md) |
| Configure tolerances, transforms, or reports | [comparison-options-and-reports.md](../di/comparison-options-and-reports.md) |
| DB Expert test case | [di-db-expert-testcase.md](di-db-expert-testcase.md) |
