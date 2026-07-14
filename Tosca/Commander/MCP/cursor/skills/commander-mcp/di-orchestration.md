# Data Integrity orchestration

DI tools have **strict ordering**, **license gating**, and **sequential validation**. There is **no TCShell/TCAPI equivalent** for most DI tools — orchestration is MCP-specific.

**Progressive disclosure:** read only the files you need for the current DI goal. Do **not** load the full DI reference tree upfront.

Copy and track progress:

```text
DI workflow:
- [ ] Phase 1 — This file + one reference/di/*.md
- [ ] Phase 2 — Connections / schema (di_connection, SQL)
- [ ] Phase 3 — Build artifacts (create_di_*)
- [ ] Phase 4 — Validate (execute_test_suite → poll status; one at a time)
- [ ] Phase 5 — save_workspace
```

## Contents

- [Step 0 — Route before any DI tool call](#step-0--route-before-any-di-tool-call)
- [DI orchestration phases](#di-orchestration-phases)
- [Phase 2–5 details](#phase-2--connections-and-schema)
- [Scenario → reference file](#scenario--which-reference-file)
- [Anti-patterns](#anti-patterns)

## Step 0 — Route before any DI tool call

1. Confirm DI is licensed and MCP is ready ([when-to-use-mcp.md](when-to-use-mcp.md)).
2. Read this file (phases + gates).
3. Open [reference/di/index.md](reference/di/index.md) and pick **one** supplemental doc:
   - [overview.md](reference/di/overview.md) — tools, connection types, tips
   - [conventions.md](reference/di/conventions.md) — rowKey rules
   - [workflows/](reference/di/workflows/) — one end-to-end walkthrough matching the scenario
   - [sap-endpoints.md](reference/di/sap-endpoints.md) — SAP source/target
   - [comparison-options-and-reports.md](reference/di/comparison-options-and-reports.md) — tolerances, reports, HTML export

**Do not call** `di_connection`, `get_di_connection_schema`, `run_di_sql_statement`, `create_di_*`, or `execute_test_suite` until you have read the routing doc(s) for your scenario.

## DI orchestration phases

```
Phase 1  Read skill docs           → this file + one reference/di/*.md
Phase 2  Connections / schema     → di_connection, get_di_connection_schema OR run_di_sql_statement
Phase 3  Build test artifacts     → create_di_* (may parallelize)
Phase 4  Validate                 → execute_test_suite (synchronous; strictly sequential)
Phase 5  Persist                  → save_workspace
```

## Phase 2 — Connections and schema

| Tool | When | Orchestration note |
|------|------|-------------------|
| `di_connection` | List/create/update/delete connections | List before create to avoid duplicates |
| `get_di_connection_schema` | Small/medium schema overview | **Avoid** on huge Oracle/DB2 |
| `run_di_sql_statement` | Targeted tables/columns/sample rows | Prefer SQL `LIMIT` / filtered catalog queries |

## Phase 3 — Create comparison artifacts

| Tool | When |
|------|------|
| `create_di_row_by_row_comparison` | Row-by-row table comparison TC |
| `create_di_db_expert_module` | DB Expert module TC |
| `create_di_load_caching_db_from_customization` | Load caching DB from customization |
| `parse_di_lineage_mapping` | CSV from Collibra/governance tool |

- `create_*` calls **can run in parallel** when building independent test cases.
- After `parse_di_lineage_mapping`, one `create_di_row_by_row_comparison` **per returned group** — see [workflows/06-lineage-csv.md](reference/di/workflows/06-lineage-csv.md).

## Phase 4 — Validate (sequential only)

Only **one** `execute_test_suite` at a time on the Commander UI thread.

```
execute_test_suite(test_case_id=testCaseId, is_validation_run=true)
  → returns result severity + scratchbook logs synchronously (no JobId/polling)
```

Plan **one validate step per test case** in sequence. Consolidate checks per table when using DB Expert — see [workflows/07-db-expert-data-quality.md](reference/di/workflows/07-db-expert-data-quality.md).

## Phase 5 — Persist

```
save_workspace
```

## Scenario → which reference file

| User goal | Read |
|-----------|------|
| Two DBs / SQL Server vs SQLite | [workflows/01-sql-server-vs-sqlite.md](reference/di/workflows/01-sql-server-vs-sqlite.md) |
| SAP vs database | [workflows/02-sap-vs-sql-server.md](reference/di/workflows/02-sap-vs-sql-server.md) + [sap-endpoints.md](reference/di/sap-endpoints.md) |
| Database vs CSV | [workflows/03-database-vs-csv.md](reference/di/workflows/03-database-vs-csv.md) |
| JDBC vs ODBC | [workflows/04-jdbc-vs-odbc.md](reference/di/workflows/04-jdbc-vs-odbc.md) |
| Column name mismatch | [workflows/05-column-renames.md](reference/di/workflows/05-column-renames.md) |
| Lineage / Collibra CSV | [workflows/06-lineage-csv.md](reference/di/workflows/06-lineage-csv.md) |
| Data quality / DB Expert | [workflows/07-db-expert-data-quality.md](reference/di/workflows/07-db-expert-data-quality.md) |
| Tolerances, reports, HTML export | [comparison-options-and-reports.md](reference/di/comparison-options-and-reports.md) |

## When to prompt the user

| Situation | Ask |
|-----------|-----|
| DI license error | Cannot proceed — contact admin |
| Large schema | Use filtered SQL vs full schema tool? |
| Many test cases | Confirm sequential validate plan (N × few seconds each) |
| SAP credentials / table | Required — MCP cannot inspect SAP |
| Active validate job | Wait for current job before new validate? |

## Anti-patterns

| Avoid | Why |
|-------|-----|
| Load all `reference/di/` files | Progressive disclosure — one scenario file at a time |
| Parallel `execute_test_suite` | Second call rejected |
| Full `get_di_connection_schema` on huge DB | Timeout / token overflow |
| DI tools before reading scenario doc | Wrong SQL, wrong column names, failed comparisons |

## Related

- [reference/di/index.md](reference/di/index.md) — DI reference index
- [reference/workflows/di-getting-started.md](reference/workflows/di-getting-started.md) — short Code Mode plan template
- [tool-orchestration.md](tool-orchestration.md) — per-tool when/how (DI summary only)
