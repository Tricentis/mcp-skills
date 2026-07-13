# DI workflow 1 — SQL Server vs SQLite: order sync check

### DIWorkflow 1 — SQL Server vs SQLite: order sync check

**Goal:** Detect missing, extra, or changed rows between a SQL Server Orders table and a SQLite
replica, matching by primary key.

**Step 1 — Check whether connections already exist (run in parallel)**
```
► di_connection(operation="list", name="SqlExpress")
◄ { "count": 0, "connections": [] }     → not found; create in step 2

► di_connection(operation="list", name="LocalSQLite")
◄ { "count": 0, "connections": [] }     → not found; create in step 3
```
If a connection is returned, skip its create step and use its `name` in later calls.

**Step 2 — Create the SQL Server connection**
```
► di_connection(
    operation="create",
    name="SqlExpress",
    connectionType="ODBC Connection String",
    category="MSSQL"
  )
◄ { "operation": "created", "connectionId": "a1b2c3d4-1111-2222-3333-444455556666", "name": "SqlExpress" }
  → connectionId = surrogate ID, used with execute_drop_task
  → name "SqlExpress" is used in run_di_sql_statement and create_di_row_by_row_comparison
```
The connection string (e.g. `Server=localhost\SQLEXPRESS;Database=master;Trusted_Connection=Yes;TrustServerCertificate=Yes;`)
is NOT passed through MCP — enter it in the Tosca UI on the created connection before querying it.

**Step 3 — Create the SQLite connection**
```
► di_connection(
    operation="create",
    name="LocalSQLite",
    connectionType="SQLite",
    sqliteFilePath="C:\tmp\demo.db3"
  )
◄ { "operation": "created", "connectionId": "b2c3d4e5-aaaa-bbbb-cccc-ddddeeee1111", "name": "LocalSQLite" }
```

**Step 4 — Inspect schemas of both connections (run in parallel)**
```
► get_di_connection_schema(connectionName="SqlExpress")
◄ {
    "count": 4,
    "columns": [
      { "schemaName": "dbo", "tableName": "Orders", "columnName": "OrderId",    "dataType": "int",      "isNullable": "N" },
      { "schemaName": "dbo", "tableName": "Orders", "columnName": "CustomerId", "dataType": "int",      "isNullable": "Y" },
      { "schemaName": "dbo", "tableName": "Orders", "columnName": "OrderDate",  "dataType": "datetime", "isNullable": "Y" },
      { "schemaName": "dbo", "tableName": "Orders", "columnName": "Total",      "dataType": "decimal",  "isNullable": "Y" }
    ]
  }

► get_di_connection_schema(connectionName="LocalSQLite")
◄ {
    "count": 4,
    "columns": [
      { "schemaName": "", "tableName": "Orders", "columnName": "OrderId",    "dataType": "INTEGER", "isNullable": "Y" },
      { "schemaName": "", "tableName": "Orders", "columnName": "CustomerId", "dataType": "INTEGER", "isNullable": "Y" },
      { "schemaName": "", "tableName": "Orders", "columnName": "OrderDate",  "dataType": "TEXT",    "isNullable": "Y" },
      { "schemaName": "", "tableName": "Orders", "columnName": "Total",      "dataType": "REAL",    "isNullable": "Y" }
    ]
  }
  → Both databases expose an Orders table with matching columns.
  → Schema results do NOT include primary key metadata — discover PKs in step 5.
```

**Step 5 — Discover primary keys (run in parallel)**
```
► run_di_sql_statement(
    connectionName="SqlExpress",
    sql="SELECT kcu.COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY' AND kcu.TABLE_SCHEMA = 'dbo' AND kcu.TABLE_NAME = 'Orders' ORDER BY kcu.ORDINAL_POSITION"
  )
◄ { "columns": ["COLUMN_NAME"], "count": 1, "rows": [["OrderId"]] }
  → SQL Server primary key = OrderId

► run_di_sql_statement(
    connectionName="LocalSQLite",
    sql="PRAGMA table_info(Orders)"
  )
◄ {
    "columns": ["cid","name","type","notnull","dflt_value","pk"],
    "count": 4,
    "rows": [
      ["0","OrderId",   "INTEGER","0","","1"],
      ["1","CustomerId","INTEGER","0","","0"],
      ["2","OrderDate", "TEXT",   "0","","0"],
      ["3","Total",     "REAL",   "0","","0"]
    ]
  }
  → Rows where pk > 0 are primary key columns → SQLite primary key = OrderId
  → Both sides agree: rowKey = "OrderId"
```
For a composite PK (e.g., pk=1 and pk=2 in PRAGMA output), sort by pk value and join with
semicolons: `rowKey="OrderId;LineItemId"`.

**Step 6 — Create the Row by Row Comparison test case**
```
► create_di_row_by_row_comparison(
    name="Orders: SQL Server vs SQLite",
    source={ "type": "odbc", "connection": "SqlExpress",  "sql": "SELECT OrderId, CustomerId, OrderDate, Total FROM dbo.Orders" },
    target={ "type": "odbc", "connection": "LocalSQLite", "sql": "SELECT OrderId, CustomerId, OrderDate, Total FROM Orders" },
    rowKey="OrderId"
  )
◄ {
    "success": true,
    "testCaseId":   "19efee3b-0001-aaaa-bbbb-ccccddddeeee",
    "testCasePath": "/TestCases/Orders: SQL Server vs SQLite",
    "testStepId":   "19efee3b-0002-ffff-1111-222233334444"
  }
```
Note: SQLite DI connections are referenced via `type: "odbc"` in `create_di_row_by_row_comparison`
— there is no separate `sqlite` endpoint type. The DI engine resolves the actual connection type
from the stored connection definition.

---
