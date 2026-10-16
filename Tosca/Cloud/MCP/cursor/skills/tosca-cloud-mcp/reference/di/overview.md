# Data Integrity — overview

Read on demand when planning DI work. Load **di-orchestration.md** from the skill root first.

## Available tools

| Tool | Purpose |
|------|---------|
| `tosca_diconnection` | List / Get DI connections. List has no search. Get never returns password or connectionString. |
| `tosca_diconnection_edit` | Create / Update / Delete. Never pass password or plaintext connectionString. Cannot set `allowAiQueries`. |
| `tosca_dataintegrity_runSql` | Step 1 of 2: dialect `SELECT` (including catalog/schema queries). Requires `allowAiQueries`. |
| `tosca_dataintegrity_checkSqlResult` | Step 2 of 2: poll query result |
| `tosca_dataintegrity_testConnection` | Step 1 of 2: connectivity test. Does **not** require `allowAiQueries`. |
| `tosca_dataintegrity_checkTestConnectionResult` | Step 2 of 2: poll test-connection result |
| `tosca_dataintegrity_createRowByRowComparison` | Default write — comparison test case (SQL, remaps, tolerances, File/Olap/Sap) |
| `tosca_dataintegrity_createLoadCachingDbFromCustomization` | Load caching DB from customization |
| `tosca_dataintegrity_parseLineageMapping` | Parse lineage mapping |

Schema is **not** a dedicated tool. Follow the five-step `runSql` recipe in [conventions.md](conventions.md).

Connection Create/Update/Test: [di-connection.md](../workflows/di-connection.md).
