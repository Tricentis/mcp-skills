# DI workflow 4 — JDBC source vs ODBC target comparison

### DIWorkflow 4 — JDBC source vs ODBC target comparison

**Goal:** Compare a MySQL database (accessed via JDBC — no DI connection needed) against a SQL
Server database (accessed via an existing ODBC DI connection), matching rows by primary key.

The JDBC endpoint does **not** use a DI connection. You supply the JDBC connection string, driver
class name, and driver directory directly in the comparison parameters.

**Step 1 — Verify the ODBC connection exists**
```
► di_connection(operation="list", name="SqlServer_Sales")
◄ {
    "count": 1,
    "connections": [
      { "connectionId": "aaa-111", "name": "SqlServer_Sales", "connectionType": "BI", "category": "MSSQL" }
    ]
  }
  → Connection exists — use name "SqlServer_Sales" in the comparison.
```

**Step 2 — Get schema from the ODBC side**
```
► get_di_connection_schema(connectionName="SqlServer_Sales")
◄ {
    "count": 4,
    "columns": [
      { "schemaName": "dbo", "tableName": "Orders", "columnName": "OrderId",    "dataType": "int",      "isNullable": "N" },
      { "schemaName": "dbo", "tableName": "Orders", "columnName": "CustomerId", "dataType": "int",      "isNullable": "Y" },
      { "schemaName": "dbo", "tableName": "Orders", "columnName": "OrderDate",  "dataType": "datetime", "isNullable": "Y" },
      { "schemaName": "dbo", "tableName": "Orders", "columnName": "Total",      "dataType": "decimal",  "isNullable": "Y" }
    ]
  }
  → Use this as the target-side metadata.
```

**Step 3 — Discover the primary key on the ODBC side**
```
► run_di_sql_statement(
    connectionName="SqlServer_Sales",
    sql="SELECT kcu.COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY' AND kcu.TABLE_SCHEMA = 'dbo' AND kcu.TABLE_NAME = 'Orders' ORDER BY kcu.ORDINAL_POSITION"
  )
◄ { "columns": ["COLUMN_NAME"], "count": 1, "rows": [["OrderId"]] }
  → ODBC primary key = OrderId → use as rowKey if the JDBC side matches.
```

**Step 4 — Ask the user for JDBC source details**
```
The MCP tools cannot inspect a JDBC source (no JDBC executor exists). Ask the user for:
- Driver class name (e.g., `com.mysql.cj.jdbc.Driver`)
- Driver directory (folder containing the driver `.jar`)
- Source table name + columns (confirm they align with the ODBC target columns from step 2)
- Source primary key (confirm it matches the ODBC PK from step 3, or supply the actual one)
- If column names differ between sides, plan to use `sourceColumnRenames`

Do NOT ask for the JDBC connection string — it may embed credentials and is never passed through MCP.
After the test step is created, the user enters the JDBC URL in the Tosca UI on the JDBC endpoint.

If the user is unsure of the JDBC schema or PK, they can create a temporary ODBC DI connection
(`di_connection(operation="create", connectionType="ODBC Connection String", category="Custom", ...)`)
to the same database and use steps 2–3 against it, then proceed with JDBC for the comparison.
```

**Step 5 — Create the Row by Row Comparison with JDBC source**
```
► create_di_row_by_row_comparison(
    name="Orders: MySQL (JDBC) vs SQL Server",
    source={
      "type": "jdbc",
      "className":        "com.mysql.cj.jdbc.Driver",
      "driverDirectory":  "C:\jdbc-drivers\mysql",
      "sql":              "SELECT OrderId, CustomerId, OrderDate, Total FROM orders"
    },
    target={
      "type": "odbc", "connection": "SqlServer_Sales",
      "sql": "SELECT OrderId, CustomerId, OrderDate, Total FROM dbo.Orders"
    },
    rowKey="OrderId"
  )
◄ {
    "success": true,
    "testCaseId":   "39efee3b-0001-aaaa-bbbb-ccccddddeeee",
    "testCasePath": "/TestCases/Orders: MySQL (JDBC) vs SQL Server",
    "testStepId":   "39efee3b-0002-ffff-1111-222233334444"
  }
```
The JDBC connection string (e.g. `jdbc:mysql://host:port/db`) is NOT passed through MCP — enter it
in the Tosca UI on the created JDBC endpoint before executing.
JDBC parameters:
- `className` — fully qualified driver class (e.g., `com.mysql.cj.jdbc.Driver`, `org.postgresql.Driver`)
- `driverDirectory` — local folder containing the driver `.jar` file
- `sql` — SQL statement executed by the JDBC driver (use database-native syntax)

---
