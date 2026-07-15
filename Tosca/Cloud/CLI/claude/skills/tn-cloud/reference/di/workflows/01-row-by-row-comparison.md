# DI workflow — row-by-row comparison

## Creating a Row-by-Row Comparison (Interactive Workflow)

When the user asks to create a row-by-row comparison test case, follow these steps:

### Step 1 — List available connections
```
Call tosca_dataintegrity_listConnections
→ Present the list to the user.
→ Ask: "Which connection should be the **source** and which should be the **target**?"
```

### Step 2 — Fetch schema for both connections
Run the two-step schema retrieval for each connection. Both can be started in parallel, but each pair (getConnectionSchema → checkSchemaResult) must be sequential.

**EXECUTION (no plan mode, no user confirmation needed for the launcher steps):**
For EACH connection:
```
a. Call tosca_dataintegrity_getConnectionSchema(connectionId="<id>")
   → Returns { launcherLink, notificationId, executorCommandId }
b. Open the launcherLink on the user's machine: Start-Process "<launcherLink>"
c. Call tosca_dataintegrity_checkSchemaResult(notificationId="<notificationId>")
   → Returns { connectionId, count, columns: [{ schemaName, tableName, columnName, dataType, isNullable }] }
```

> **If schema retrieval fails:** The connection may be a "Custom" ODBC type with no stored schema SQL.
> In that case, ask the user to describe the relevant tables and columns manually so you can write the SQL.

### Step 3 — Analyze both schemas and propose SQL + RowKey
Using the column metadata returned:
- Identify matching tables and columns between source and target.
- Propose a `SELECT` statement for each side listing only the relevant columns (avoid `SELECT *`).
- Suggest a `RowKey`: the primary key or a unique business key column.
  - Schema results do NOT include primary key info. If the primary key is not obvious from the column names, ask the user: "Which column(s) uniquely identify a row — for example, an Id or OrderNumber column?"
  - Composite key: join with semicolons, e.g. `"OrderId;LineItemId"`.
  - If no unique key exists: use `"All Source Columns"` — every source column becomes the key.

### Step 4 — Confirm with the user
Present the proposed parameters before creating:
```
Source connection: <name>
Source SQL: SELECT ...
Target connection: <name>
Target SQL: SELECT ...
RowKey: <column(s)>
```
Ask: "Does this look correct, or would you like to adjust anything?"

### Step 5 — Create the test case
```
Call tosca_dataintegrity_createRowByRowComparison with the confirmed parameters.
→ Returns { success, testCaseId, testCasePath }
```

---

## Example — Two database connections

```
► tosca_dataintegrity_listConnections
◄ { connections: [{ id: "01J...", name: "SourceDB", ... }, { id: "01K...", name: "TargetDB", ... }] }
  → User picks SourceDB as source and TargetDB as target.

► tosca_dataintegrity_getConnectionSchema(connectionId="01J...")
◄ { launcherLink: "tricentistosca://di?...", notificationId: "abc-123", executorCommandId: "..." }
► Start-Process "tricentistosca://di?..."
► tosca_dataintegrity_checkSchemaResult(notificationId="abc-123")
◄ { count: 4, columns: [
      { schemaName: "dbo", tableName: "Orders", columnName: "OrderId",    dataType: "int",      isNullable: false },
      { schemaName: "dbo", tableName: "Orders", columnName: "CustomerId", dataType: "int",      isNullable: true  },
      { schemaName: "dbo", tableName: "Orders", columnName: "OrderDate",  dataType: "datetime", isNullable: true  },
      { schemaName: "dbo", tableName: "Orders", columnName: "Total",      dataType: "decimal",  isNullable: true  }
    ]}

► tosca_dataintegrity_getConnectionSchema(connectionId="01K...")
◄ { launcherLink: "tricentistosca://di?...", notificationId: "def-456", executorCommandId: "..." }
► Start-Process "tricentistosca://di?..."
► tosca_dataintegrity_checkSchemaResult(notificationId="def-456")
◄ { count: 4, columns: [
      { schemaName: "dbo", tableName: "Orders", columnName: "OrderId",    dataType: "int",  isNullable: false },
      { schemaName: "dbo", tableName: "Orders", columnName: "CustomerId", dataType: "int",  isNullable: true  },
      { schemaName: "dbo", tableName: "Orders", columnName: "OrderDate",  dataType: "date", isNullable: true  },
      { schemaName: "dbo", tableName: "Orders", columnName: "Total",      dataType: "money",isNullable: true  }
    ]}
  → Both sides have an Orders table with matching column names.
  → OrderId is NOT NULL on both sides — good candidate for RowKey. Confirm with user.

► tosca_dataintegrity_createRowByRowComparison({
    Name: "Orders: SourceDB vs TargetDB",
    Source: { Type: "Database", ConnectionName: "SourceDB", SqlStatement: "SELECT OrderId, CustomerId, OrderDate, Total FROM dbo.Orders" },
    Target: { Type: "Database", ConnectionName: "TargetDB", SqlStatement: "SELECT OrderId, CustomerId, OrderDate, Total FROM dbo.Orders" },
    RowKey: "OrderId"
  })
◄ { success: true, testCaseId: "...", testCasePath: "/TestCases/Orders: SourceDB vs TargetDB" }
```

---

## Example — Two database connections

```
► tosca_dataintegrity_listConnections
◄ { connections: [{ id: "01J...", name: "SourceDB", ... }, { id: "01K...", name: "TargetDB", ... }] }
  → User picks SourceDB as source and TargetDB as target.

► tosca_dataintegrity_getConnectionSchema(connectionId="01J...")
◄ { launcherLink: "tricentistosca://di?...", notificationId: "abc-123", executorCommandId: "..." }
► Start-Process "tricentistosca://di?..."
► tosca_dataintegrity_checkSchemaResult(notificationId="abc-123")
◄ { count: 4, columns: [
      { schemaName: "dbo", tableName: "Orders", columnName: "OrderId",    dataType: "int",      isNullable: false },
      { schemaName: "dbo", tableName: "Orders", columnName: "CustomerId", dataType: "int",      isNullable: true  },
      { schemaName: "dbo", tableName: "Orders", columnName: "OrderDate",  dataType: "datetime", isNullable: true  },
      { schemaName: "dbo", tableName: "Orders", columnName: "Total",      dataType: "decimal",  isNullable: true  }
    ]}

► tosca_dataintegrity_getConnectionSchema(connectionId="01K...")
◄ { launcherLink: "tricentistosca://di?...", notificationId: "def-456", executorCommandId: "..." }
► Start-Process "tricentistosca://di?..."
► tosca_dataintegrity_checkSchemaResult(notificationId="def-456")
◄ { count: 4, columns: [
      { schemaName: "dbo", tableName: "Orders", columnName: "OrderId",    dataType: "int",  isNullable: false },
      { schemaName: "dbo", tableName: "Orders", columnName: "CustomerId", dataType: "int",  isNullable: true  },
      { schemaName: "dbo", tableName: "Orders", columnName: "OrderDate",  dataType: "date", isNullable: true  },
      { schemaName: "dbo", tableName: "Orders", columnName: "Total",      dataType: "money",isNullable: true  }
    ]}
  → Both sides have an Orders table with matching column names.
  → OrderId is NOT NULL on both sides — good candidate for RowKey. Confirm with user.

► tosca_dataintegrity_createRowByRowComparison({
    Name: "Orders: SourceDB vs TargetDB",
    Source: { Type: "Database", ConnectionName: "SourceDB", SqlStatement: "SELECT OrderId, CustomerId, OrderDate, Total FROM dbo.Orders" },
    Target: { Type: "Database", ConnectionName: "TargetDB", SqlStatement: "SELECT OrderId, CustomerId, OrderDate, Total FROM dbo.Orders" },
    RowKey: "OrderId"
  })
◄ { success: true, testCaseId: "...", testCasePath: "/TestCases/Orders: SourceDB vs TargetDB" }
```

---

