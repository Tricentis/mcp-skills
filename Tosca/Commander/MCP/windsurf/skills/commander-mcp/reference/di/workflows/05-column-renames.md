# DI workflow 5 — Column name mismatch: compare with renames

### DIWorkflow 5 — Column name mismatch: compare with renames

**Goal:** Compare two databases where the same logical column has different names
(e.g., a legacy naming convention vs a modern one).

**Step 1 — Get schemas of both connections (run in parallel)**
```
► get_di_connection_schema(connectionName="LegacyDB")
◄ {
    "count": 3,
    "columns": [
      { "schemaName": "dbo", "tableName": "ORDERS", "columnName": "ORD_ID",   "dataType": "int",      "isNullable": "N" },
      { "schemaName": "dbo", "tableName": "ORDERS", "columnName": "CUST_ID",  "dataType": "int",      "isNullable": "Y" },
      { "schemaName": "dbo", "tableName": "ORDERS", "columnName": "ORD_DATE", "dataType": "datetime", "isNullable": "Y" }
    ]
  }

► get_di_connection_schema(connectionName="ModernDB")
◄ {
    "count": 3,
    "columns": [
      { "schemaName": "dbo", "tableName": "Orders", "columnName": "OrderId",    "dataType": "int",      "isNullable": "N" },
      { "schemaName": "dbo", "tableName": "Orders", "columnName": "CustomerId", "dataType": "int",      "isNullable": "Y" },
      { "schemaName": "dbo", "tableName": "Orders", "columnName": "OrderDate",  "dataType": "datetime", "isNullable": "Y" }
    ]
  }
  → Column names differ: ORD_ID→OrderId, CUST_ID→CustomerId, ORD_DATE→OrderDate.
  → Use sourceColumnRenames to normalise legacy columns to modern names before comparison.
```

**Step 2 — Discover primary keys (run in parallel)**
```
► run_di_sql_statement(
    connectionName="LegacyDB",
    sql="SELECT kcu.COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY' AND kcu.TABLE_SCHEMA = 'dbo' AND kcu.TABLE_NAME = 'ORDERS' ORDER BY kcu.ORDINAL_POSITION"
  )
◄ { "rows": [["ORD_ID"]] }
  → Legacy PK = ORD_ID; after rename → "OrderId"

► run_di_sql_statement(
    connectionName="ModernDB",
    sql="SELECT kcu.COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY' AND kcu.TABLE_SCHEMA = 'dbo' AND kcu.TABLE_NAME = 'Orders' ORDER BY kcu.ORDINAL_POSITION"
  )
◄ { "rows": [["OrderId"]] }
  → Modern PK = OrderId
  → After rename, both map to "OrderId" → rowKey = "OrderId"
```

**Step 3 — Create the comparison with column renames**
```
► create_di_row_by_row_comparison(
    name="Orders: Legacy vs Modern",
    source={
      "type": "odbc", "connection": "LegacyDB",
      "sql": "SELECT ORD_ID, CUST_ID, ORD_DATE FROM dbo.ORDERS"
    },
    target={
      "type": "odbc", "connection": "ModernDB",
      "sql": "SELECT OrderId, CustomerId, OrderDate FROM dbo.Orders"
    },
    rowKey="OrderId",
    sourceColumnRenames=[
      { "from": "ORD_ID",   "to": "OrderId" },
      { "from": "CUST_ID",  "to": "CustomerId" },
      { "from": "ORD_DATE", "to": "OrderDate" }
    ]
  )
◄ { "success": true, "testCaseId": "...", "testCasePath": "/TestCases/Orders: Legacy vs Modern", "testStepId": "..." }
```
Rules for column renames:
- `sourceColumnRenames` renames source columns to match target column names.
- `targetColumnRenames` renames target columns to match source column names.
- `rowKey` must use the column name **after renaming**.

---
