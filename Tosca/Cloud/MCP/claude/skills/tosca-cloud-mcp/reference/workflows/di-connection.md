# DI connection

List, get, create, update, test, or delete a Tosca Cloud Data Integrity connection.

Not Story 2 AC. On the Story 2 graph this branch is only: **List empty, or the user asked to create / update / test**. Then return to List. Do not run this branch unprompted when a usable connection already exists.

```text
DI connection:
- [ ] tosca_diconnection List
- [ ] Get before mutate
- [ ] Only the operation the user asked for (Create / Update / Delete / Test)
- [ ] After Create: user sets password in Connection Manager; enable Allow AI queries if they will runSql
- [ ] Back to List
```

## Fork after List

| User / situation | Tools | Then |
|------------------|-------|------|
| Test an existing connection | Get (Ulid) → `tosca_dataintegrity_testConnection` → `checkTestConnectionResult` | Back to List. No Create. |
| Create | `tosca_diconnection_edit` Create → user sets secrets in Connection Manager | Optional test (next row) or back to List |
| Test after Create (user asked, or Create just succeeded and they want a connectivity check) | `testConnection` → `checkTestConnectionResult` | Back to List |
| Update | Get → `tosca_diconnection_edit` Update | Back to List |
| Delete | Confirm → `tosca_diconnection_edit` Delete | Stop or List |

`testConnection` is **optional** on the graph. It does **not** require `allowAiQueries`. Do not treat it as a mandatory step after every Create.

## Create types

| `connectionType` | Required args |
|------------------|---------------|
| `ODBC` / `ODBCDataSource` | `dsnName` + `category` (`MSSQL` \| `Oracle` \| `DB2` \| `Custom`) |
| `ConnectionString` / `ODBC Connection String` | `connectionStringExpression` + `category` |
| `SQLite` | `connectionStringExpression`, or `useCachingDatabase=true` |

Never pass `password` or a plaintext `connectionString`. Expressions (`connectionStringExpression`, `passwordExpression`) are allowed.

**Create** leaves `allowAiQueries` false. If they will `runSql` next, they must enable **Allow AI queries** in Connection Manager (same stop as Story 2 schema step 2).

## Update / Delete

- **Update:** `connectionId` required. Omit fields to leave them. **Cannot rename** (do not pass `name`). Cannot set `allowAiQueries` or secrets. Changing `connectionType` needs the new type’s fields (same as Create).
- **Delete:** confirm first unless the user asked to delete.

## IDs

- Get / `runSql` / `testConnection`: Ulid `connectionId` (`id.id`).
- `createRowByRowComparison`: **`connectionName`**.

After this branch, return to List and continue 01 / 02 / 03. Schema recipe: [../di/conventions.md](../di/conventions.md).
