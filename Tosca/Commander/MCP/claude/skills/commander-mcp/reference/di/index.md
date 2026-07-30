# Data Integrity reference index

Progressive disclosure for DI orchestration. **Do not load all files at once.**

## DI gate (before any DI tool)

1. Confirm DI license and MCP readiness (`get_workspace_info`).
2. Read **di-orchestration.md** at the skill root (phases and gates).
3. Open **one** supplemental file from this index.

## Reference files

| File | When |
|------|------|
| [overview.md](overview.md) | Tool list, connection types, short patterns, tips |
| [conventions.md](conventions.md) | rowKey rules, walkthrough notation (`►` / `◄`) |
| [sap-endpoints.md](sap-endpoints.md) | SAP source or target endpoint |
| [comparison-options-and-reports.md](comparison-options-and-reports.md) | `generalOptions`, `tolerances`, `results`, HTML export |

## End-to-end walkthroughs

Read **one** workflow file that matches the user's scenario:

| # | File |
|---|------|
| 1 | [workflows/01-sql-server-vs-sqlite.md](workflows/01-sql-server-vs-sqlite.md) |
| 2 | [workflows/02-sap-vs-sql-server.md](workflows/02-sap-vs-sql-server.md) |
| 3 | [workflows/03-database-vs-csv.md](workflows/03-database-vs-csv.md) |
| 4 | [workflows/04-jdbc-vs-odbc.md](workflows/04-jdbc-vs-odbc.md) |
| 5 | [workflows/05-column-renames.md](workflows/05-column-renames.md) |
| 6 | [workflows/06-lineage-csv.md](workflows/06-lineage-csv.md) |
| 7 | [workflows/07-db-expert-data-quality.md](workflows/07-db-expert-data-quality.md) |
