# Data Integrity reference index

Load **di-orchestration.md** from the skill root first, then **one** file below.

| Topic | File |
|-------|------|
| Overview | [overview.md](overview.md) |
| Conventions (schema recipe, remaps, RowKey) | [conventions.md](conventions.md) |
| Comparison options, tolerances, and reports | [comparison-options-and-reports.md](comparison-options-and-reports.md) |

## End-to-end walkthroughs

Read **one** workflow file that matches the user's scenario:

| Scenario | File |
|----------|------|
| DI connection List / Get / Create / Update / Test | [../workflows/di-connection.md](../workflows/di-connection.md) |
| Row By Row Comparison | [workflows/01-row-by-row-comparison.md](workflows/01-row-by-row-comparison.md) |
| File Comparison | [workflows/02-file-comparison.md](workflows/02-file-comparison.md) |
| Business rules → SQL comparison | [workflows/03-business-rules-to-sql.md](workflows/03-business-rules-to-sql.md) |
| Analyze DI execution results | [workflows/04-analyze-execution-results.md](workflows/04-analyze-execution-results.md) |
| Apply and validate a DI fix | [workflows/05-remediate-from-results.md](workflows/05-remediate-from-results.md) |
| Field-mapping CSV (e.g. Collibra) to comparisons | [workflows/06-lineage-csv.md](workflows/06-lineage-csv.md) |
| DB Expert testcase | [../workflows/di-db-expert-testcase.md](../workflows/di-db-expert-testcase.md) |

Cloud DI uses V2 `tosca_diconnection` plus async `runSql` / `testConnection` polling.
