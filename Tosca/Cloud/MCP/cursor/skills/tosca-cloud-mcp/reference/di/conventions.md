# Data Integrity conventions — Tosca Cloud

## Naming

Connection lifecycle uses noun tools: `tosca_diconnection` (List / Get) and `tosca_diconnection_edit` (Create / Update / Delete). Query, test, and comparison stay on `tosca_dataintegrity_*` verbs.

Do **not** call `tosca_dataintegrity_listConnections`, `tosca_dataintegrity_connection`, `tosca_dataintegrity_getConnectionSchema`, `tosca_dataintegrity_checkSchemaResult`, or `tosca_dataintegrity_workflow`. Those are hidden or removed when V2 is on.

## Schema recipe (canonical — copy verbatim)

Use these five steps whenever you need tables/columns before writing SQL. Do **not** fold connection Create or Test into this recipe.

1. `tosca_diconnection` List / Get
2. If `allowAiQueries` is false → **stop**; the user enables **Allow AI queries** in Connection Manager (MCP cannot set it)
3. Infer DBMS from `dataSourceType`, name, description, `metadata.databaseCategory`
4. If unclear → **ask**
5. Catalog `SELECT` via `tosca_dataintegrity_runSql` → open `launcherLink` → poll `tosca_dataintegrity_checkSqlResult`

Notes under those steps only:

- List rows return `id: { spaceId, id }`. Use the inner Ulid (`id.id`, also `connectionId` on Get) for Get, `runSql`, and `testConnection`.
- `tosca_dataintegrity_createRowByRowComparison` uses **`connectionName`**, not the Ulid.
- `dataSourceType` is `ODBC` / `ConnectionString` / `SQLite` — not a dialect by itself. `metadata.databaseCategory` is `MSSQL` | `Oracle` | `DB2` | `Custom`.

## Infer DBMS

| Signal | Typical dialect |
|--------|-----------------|
| `dataSourceType` is SQLite | SQLite |
| `databaseCategory` MSSQL | T-SQL / SQL Server |
| `databaseCategory` Oracle | Oracle SQL |
| `databaseCategory` DB2 | DB2 SQL |
| Name / description mentions Postgres, Snowflake, MySQL, DuckDB, … | That product’s dialect |
| `databaseCategory` Custom, or nothing matches | **Ask the user** which DBMS |

## Catalog SELECT (examples)

Single read-only `SELECT` (or `WITH … SELECT`) only. Writes and DDL are rejected.

| Dialect | Catalog query |
|---------|----------------|
| SQL Server | `SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS` |
| PostgreSQL / MySQL / Snowflake | `INFORMATION_SCHEMA.COLUMNS` (qualify catalog/schema as needed) |
| Oracle | `SELECT OWNER, TABLE_NAME, COLUMN_NAME, DATA_TYPE FROM ALL_TAB_COLUMNS WHERE OWNER = USER` |
| DB2 | `SELECT TABSCHEMA, TABNAME, COLNAME, TYPENAME FROM SYSCAT.COLUMNS` |
| SQLite | `SELECT name FROM sqlite_master WHERE type = 'table'` then `PRAGMA table_info('<table>')` |

Narrow with `WHERE` if the catalog is large. The executor returns a preview cap.

## Agent rules

1. Read **di-orchestration.md** then **one** scenario file before any DI tool.
2. Poll `checkSqlResult` / `checkTestConnectionResult` — do not assume immediate results.
3. Never echo passwords, plaintext connection strings, or other secrets.
4. Confirm before `tosca_diconnection_edit` Delete.
5. MCP **can** Create / Update / Delete connections via `tosca_diconnection_edit`. Secrets and `allowAiQueries` stay in Connection Manager.
6. Column remaps go on `createRowByRowComparison` as `sourceOptions.columnRenames` / `targetOptions.columnRenames` (`from` / `to`). Do **not** use `explicitName` on `tosca_teststep_edit` for remaps.

## Entitlements

DI tools may require product entitlements. Report entitlement errors and stop.

## Row Key

- Single key column: `"CustomerId"`
- Composite key: `"OrderId;LineNo"` (semicolon-separated)
- No natural key: `"All Source Columns"`
- Names must match **after remaps**. Catalog results do not include primary-key metadata — ask if the key is not obvious.

## SQL statements (Database endpoints)

- SQL chooses which rows and columns each side fetches.
- Both sides must return the same RowKey column name(s) after remaps.
- Prefer explicit column lists over `SELECT *`.
