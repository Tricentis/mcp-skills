# Data Integrity — overview

Read on demand when planning DI work. **Before any DI tool:** read **di-orchestration.md** at the skill root, then one scenario file from **reference/di/index.md**.

> Executing DI tests requires a Data Integrity (DI) license. Creating connections and test cases is
> gated on the DI license; `execute_test_suite` is not itself gated, but a DI test run through it
> fails at runtime without a DI license.

## Contents

- [Available Tools](#available-tools)
- [Connection Types](#connection-types)
- [Connection Tags and the Query Gate](#connection-tags-and-the-query-gate)
- [Example Workflows](#example-workflows)
- [DI Modules](#di-modules-for-creating-test-steps)
- [Prerequisites](#prerequisites--importing-the-di-template)
- [Tips](#tips)

## Tools, connections, and quick patterns

## Available Tools

| Tool | Purpose |
|------|---------|
| di_connection | Create, update, delete, get, or list DI connections (returns surrogate ID for drop task). `tag` is read-only — see **Connection Tags and the Query Gate** below |
| get_di_connection_schema | Get table/column schema for a connection. Gated by connection tag — may require user confirmation via elicitation |
| run_di_sql_statement | Execute SQL against a connection and return results. Gated by connection tag — may require user confirmation via elicitation |
| create_di_db_expert_module | Create a DB Expert test case with connection + SQL statement |
| create_di_row_by_row_comparison | Create a Row by Row Comparison test case with source/target/rowKey |
| execute_test_suite | Execute a test case/step (is_validation_run=true) and return scratchbook logs and result severity. The tool itself is not license-gated, but executing a DI test requires a Data Integrity (DI) license. |
| parse_di_lineage_mapping | Parse a field-mapping CSV (e.g. from Collibra) and return classified mapping groups (1:1 / Merge / Split) |

## Connection Types

| connectionType | Required Fields | Notes |
|----------------|-----------------|-------|
| ODBC | dsnName, category | Uses a pre-configured System/User DSN |
| ODBC Connection String | category | Set the connection string (and any credentials) in the Tosca UI after creation — it is never passed through MCP |
| SQLite | sqliteFilePath | e.g. "C:\path\to\db.db3" |

> **Secrets are never passed through MCP.** No DI tool accepts a password, secret/access key, SAS URL,
> service-account key path, or a credential-bearing connection string as a parameter. Create the
> connection / test step with the non-secret fields, then open it in the Tosca UI and enter any
> secret there (stored encrypted as a Commander Password type). Never ask the user to paste a secret
> into the chat.

## Categories (for ODBC / ODBC Connection String)
MSSQL, Oracle, DB2, Custom

## Connection Tags and the Query Gate

Every DI connection carries a `tag` (`Production`, `Dev`, `Development`, `Staging`, or `Stg`, case-insensitive).
It is **read-only through MCP** — `di_connection` never accepts a `tag` parameter on `create` or `update`.
Every connection created through `di_connection` is tagged `Production` by default; to change it, open
the connection in the Tosca UI and set the tag there. `get`/`list` always report the current tag.

**This gates `run_di_sql_statement` and `get_di_connection_schema` (not `di_connection` itself — CRUD
operations work on every connection regardless of tag):**
- Connections tagged `Dev`, `Development`, `Staging`, or `Stg` are queried immediately, no prompt.
- Untagged, `Production`, or any unrecognized tag triggers an **MCP elicitation prompt** asking the human
  to confirm before the query runs. There is no session-level consent cache — expect a prompt on every
  such call, even repeated calls against the same connection in the same conversation.
  - If the user declines (or the client doesn't respond within ~30s), the tool returns an error like
    `"User did not confirm execution against connection '<name>' (tagged '<tag>')."` — this is not a bug,
    retry the call to prompt again, or ask the user to re-tag the connection in Tosca UI.
  - If the connecting MCP client does not support elicitation at all, the call is refused outright with
    a message to that effect — there is no way to bypass this from the agent side.

Keep this in mind across the DIWorkflows: any `run_di_sql_statement`/`get_di_connection_schema` call may
pause for human confirmation if the target connection isn't tagged Dev/Development/Staging/Stg.

## Example Workflows

### 1. Connect to an existing database and query it
```
1. di_connection(operation="list") → find existing connections
2. run_di_sql_statement(connectionName="MyConn", sql="SELECT * FROM Users")
```

### 2. Create a new ODBC connection and explore schema
```
1. di_connection(operation="create", name="SalesDB", connectionType="ODBC", dsnName="SalesDSN", category="MSSQL")
2. get_di_connection_schema(connectionId="<returned_id>")
3. run_di_sql_statement(connectionId="<id>", sql="SELECT TOP 10 * FROM Orders")
```

### 3. Create a new SQLite connection
```
1. di_connection(operation="create", name="LocalDB", connectionType="SQLite", sqliteFilePath="C:\data\app.db3")
2. run_di_sql_statement(connectionName="LocalDB", sql="SELECT * FROM sqlite_master")
```

### 4. Compare two databases (RECOMMENDED WORKFLOW)
```
1. get_di_connection_schema(connectionName="SourceDB") → understand source tables/columns
2. get_di_connection_schema(connectionName="TargetDB") → understand target tables/columns
   (If schema tool returns no results for Custom ODBC or SQLite, use run_di_sql_statement instead:
    - SQLite: run_di_sql_statement(connectionName="X", sql="SELECT * FROM sqlite_master")
    - Generic ODBC: run_di_sql_statement(connectionName="X", sql="SELECT * FROM INFORMATION_SCHEMA.COLUMNS"))
3. Based on the metadata, identify matching tables and key columns
4. create_di_row_by_row_comparison(
     name="Compare Orders",
     source={type:"odbc", connection:"SourceDB", sql:"SELECT * FROM Orders"},
     target={type:"odbc", connection:"TargetDB", sql:"SELECT * FROM Orders"},
     rowKey="OrderId")
```
IMPORTANT: Always read metadata from both connections BEFORE creating a comparison.
This ensures correct column names, matching schemas, and a valid rowKey.

### 5. Compare a database table against a CSV file
```
1. get_di_connection_schema(connectionName="MyDB") or run_di_sql_statement to inspect columns
2. create_di_row_by_row_comparison(
     name="DB vs CSV",
     source={type:"odbc", connection:"MyDB", sql:"SELECT id, name FROM Products"},
     target={type:"csv_local", filename:"C:\data\products.csv"},
     rowKey="id")
```

### 6. Compare a JSON file against a CSV file
```
create_di_row_by_row_comparison(
  name="JSON vs CSV",
  source={type:"json_local", filename:"C:\data\people.json",
          jsonPaths:[{name:"id",   jsonPath:"people[*].id"},
                     {name:"city", jsonPath:"people[*].person.address.city"}]},
  target={type:"csv_local", filename:"C:\data\people.csv", columnSeparator:","},
  rowKey="id")
```
`json_local` reads a JSON file directly — no caching DB needed. `jsonPaths` (inline `{name, jsonPath}`
pairs) flattens the JSON into named columns; pass `jsonPathsFilename` instead to reuse an existing
JSONPaths file, or omit both to unpack one level deep. Works on either side (JSON vs JSON too).
The JSON file root must be an object (not a bare array), and array paths use `[*]` (e.g. `people[*].id`).

### 7. Create and execute a DI test case
```
1. create_di_db_expert_module(name="Check Orders", connection="MyDB", sqlStatement="SELECT COUNT(*) FROM Orders")
2. execute_test_suite(test_case_id="<returned_testcase_id>", is_validation_run=true)
   → Returns result severity and scratchbook logs (Passed/Failed), used values, and descriptions
```

## DI Modules (for creating test steps)

| Module | ID | Path |
|--------|----|------|
| DI DB Expert module | 39efee3b-3edb-a21f-9820-4bed61cf94d1 | /Data Integrity Testing_import.../Modules/Standard modules/TBox XEngines/Database/DI DB Expert module |
| TBox DB Expert module | 39efee3b-3d73-a4da-6fde-4e4fac67632a | /Data Integrity Testing_import.../Modules/Standard modules/TBox XEngines/Database/TBox DB Expert module |
| TBox DB Open Connection | 39efee3b-3edb-b1b8-f88d-0b817b55655b | /Data Integrity Testing_import.../Modules/Standard modules/TBox XEngines/Database/TBox DB Open Connection |
| Complete Row by Row Comparison | 39efee3b-3e9d-d047-1b77-646ccd906c78 | /Data Integrity Testing_import.../Modules/Data Integrity Testing/Complete Row by Row Comparison |
| Metadata Comparison | 39efee3b-3d73-20ee-102c-351e17af6f35 | /Data Integrity Testing_import.../Modules/Data Integrity Testing/Metadata Comparison |
| File Load into Caching Database | 39efee3b-3d63-1dc7-1141-34767d65ab14 | /Data Integrity Testing_import.../Modules/Data Integrity Testing/File Load into Caching Database |
| Defined File Tests against Caching Database | 39efee3b-3d63-fe2f-22da-53ae1eac0263 | /Data Integrity Testing_import.../Modules/Data Integrity Testing/Defined File Tests against Caching Database |
| JSON/XML File Load into Caching Database | 39efee3b-3efb-62e6-eb3c-9aaba150d6b0 | /Data Integrity Testing_import.../Modules/Data Integrity Testing/JSON/XML File Load into Caching Database |
| Load Data into Database | 39f2bb8f-6d84-d03c-4b55-07aed1e996f0 | /Data Integrity Testing_import.../Modules/Data Integrity Testing/Load Data into Database |
| JSON to JSON Comparison | 3a03c412-2543-ba4a-cabc-67de5796431f | /Data Integrity Testing_import.../Modules/Data Integrity Testing/JSON to JSON Comparison |
| Complete Tree Comparison | 01JVC5N572764N02M7344Y9ABA | /Data Integrity Testing_import.../Modules/Data Integrity Testing/Complete Tree Comparison |

## Creating Test Steps from Modules

To create a test step from a DI module, use one of these approaches:
1. Use `create_di_db_expert_module` (for DI DB Expert module — provides connection + SQL statement).
2. For other modules, use the generic `execute_drop_task` tool:
   - First create or select a test case
   - Call `execute_drop_task(targetId="<testcase_id>", sourceIds=["<module_id>"], taskName="Create TestStep from Module")`

## Prerequisites — Importing the DI Template

The DI modules (DB Expert, Row by Row Comparison, etc.) are only available after importing the
Data Integrity Testing subset into the workspace. The subset file is located at:

  C:\Tosca_Projects\ToscaCommander\Tosca Data Integrity Modules And Samples.tsu

To import it programmatically:
1. Select the project root: `set_object_selection(identifier="<project_root_id>")` — use `get_workspace_info` to get the Project Root ID.
2. Execute the Import Subset task: `execute_task(taskName="Import Subset", parameters={"FilesToImport": "C:\\Tosca_Projects\\ToscaCommander\\Tosca Data Integrity Modules And Samples.tsu"})`
3. If prompted with ConfirmUseLargeSubsetImport, accept with "OK".

After import, the DI modules will be available under "/Data Integrity Testing_import.../Modules/".

## Tips
- Use `di_connection` with `operation="list"` to find connections by name substring.
- After creating a connection, call `di_connection` with `operation="get"` to verify the stored fields.
- The `connectionId` returned by `di_connection` is the surrogate ID usable with `execute_drop_task` to assign connections to DI test steps.
- Pagination: when `nextOffset` is returned, call again with `offset=nextOffset`.
- Secrets (passwords, keys, SAS URLs, credential-bearing connection strings) are never passed through MCP — set them in the Tosca UI after creating the connection, or supply them via DSN configuration.
- `tag` cannot be set or changed via `di_connection` — new connections default to `Production`; re-tag in Tosca UI to `Dev`/`Development`/`Staging`/`Stg` to avoid the elicitation prompt on `run_di_sql_statement`/`get_di_connection_schema` (see **Connection Tags and the Query Gate**).
- For any CSV endpoint (`csv_local`, `csv_ssh`, `csv_*`), always detect the file's separator/line-ending/header first and set `columnSeparator` explicitly — the DI default is `|`, so an undetected comma/semicolon file fails as a single column. See [workflows/03-database-vs-csv.md](workflows/03-database-vs-csv.md), Step 3.
- For ODBC connections, the DSN must be pre-configured on the machine (System or User DSN).
- `run_di_sql_statement` uses a CLI executor — results are capped at maxRows (default 1000).
- For SQLite connections, set `useCachingDatabase=true` to use Tosca's pre-existing caching database (no sqliteFilePath needed).
- `create_*` tool calls can run in parallel, but `execute_test_suite` is strictly sequential (Commander UI thread). Minimise the number of test cases — see DIWorkflow 7 for consolidating checks.
- `execute_test_suite` is not itself DI-license-gated, but running a DI test through it requires a Data Integrity (DI) license — without one, execution fails at runtime.
- For DB Expert checks: use `dataType:"Numeric"` with an operator prefix (`">0"`, `"<=N"`, `">=1"`, `"<10"`, `"!=5"`) for single-check queries — the prefix is parsed into Tosca's operator condition automatically. For consolidated multi-check queries prefer violation counts via `CASE WHEN` asserting `"0"` — see DIWorkflow 7.
