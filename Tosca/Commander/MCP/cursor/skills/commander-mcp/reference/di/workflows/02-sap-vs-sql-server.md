# DI workflow 2 — SAP table vs SQL Server replica

### DIWorkflow 2 — SAP table vs SQL Server replica

**Goal:** Verify that a SQL Server replica matches an SAP source table, matching rows by the SAP
key column. The SAP side uses `type: "sap"` (the SAP Custom Data Reader) — it does NOT use a DI
connection and has NO `sql`; you supply logon details, a `tablename`, and optional
`rowFilters`/`columnFilters`. SAP works as the source OR the target side.

> **Prerequisite (one-time machine setup).** SAP reads require the SAP Connector for Microsoft.Net
> 3.1 (64-bit, .NET) DLLs copied to
> `C:\Program Files (x86)\TRICENTIS\Tosca Testsuite\Data Integrity\Custom Data Readers\SAP`,
> plus the ABAP AddOn from the Tricentis support portal. The tool sets the Class Attribute Name to
> `SapReader` for you. If the DLLs are missing, creation still succeeds but execution
> (`execute_test_suite`) fails at runtime. See **SAP endpoint format → Prerequisites** below for the
> exact six-DLL checklist to give the user.

**Step 1 — Verify the SQL Server (target) connection exists**
```
► di_connection(operation="list", name="SqlServer_CRM")
◄ { "count": 1, "connections": [ { "connectionId": "aaa-111", "name": "SqlServer_CRM", "connectionType": "BI", "category": "MSSQL" } ] }
  → Connection exists — use name "SqlServer_CRM" for the ODBC target.
```

**Step 2 — Get the SQL Server schema and primary key (the SAP side cannot be inspected)**
```
► get_di_connection_schema(connectionName="SqlServer_CRM")
◄ {
    "count": 3,
    "columns": [
      { "schemaName": "dbo", "tableName": "Customers", "columnName": "KUNNR", "dataType": "varchar", "isNullable": "N" },
      { "schemaName": "dbo", "tableName": "Customers", "columnName": "NAME1", "dataType": "varchar", "isNullable": "Y" },
      { "schemaName": "dbo", "tableName": "Customers", "columnName": "LAND1", "dataType": "varchar", "isNullable": "Y" }
    ]
  }
  → The replica mirrors the SAP customer-master columns (KUNNR, NAME1, LAND1).

► run_di_sql_statement(
    connectionName="SqlServer_CRM",
    sql="SELECT kcu.COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY' AND kcu.TABLE_SCHEMA = 'dbo' AND kcu.TABLE_NAME = 'Customers' ORDER BY kcu.ORDINAL_POSITION"
  )
◄ { "columns": ["COLUMN_NAME"], "count": 1, "rows": [["KUNNR"]] }
  → rowKey = "KUNNR" (SAP table column name; use the SAP field name, not a SQL alias)
```

**Step 3 — Ask the user for the SAP source details**
```
The MCP tools cannot inspect an SAP system. Ask the user for:
- systemNumber (00-99), applicationServer (host/IP), client (e.g. 200), language (e.g. EN)
- username (the SAP password is NOT collected here — see below)
- tablename (case-sensitive SAP table, e.g. KNA1 for the customer master)
- which columns to compare → columnFilters (omit to read all columns)
- any row restriction → rowFilters (omit to read all rows)
```
Do NOT ask for the SAP password. It is never passed through MCP; after the test step is created,
the user enters it in the Tosca UI on the SAP Custom Data Reader (stored encrypted, masked in the UI).

**Step 4 — Create the comparison (SAP source, ODBC target)**
```
► create_di_row_by_row_comparison(
    name="Customers: SAP vs SQL Server",
    source={
      "type":              "sap",
      "systemNumber":      "00",
      "applicationServer": "sap-server.acme.com",
      "client":            "200",
      "language":          "EN",
      "username":          "RFC_USER",
      "tablename":         "KNA1",
      "columnFilters":     "F[KUNNR];F[NAME1];F[LAND1]",
      "rowFilters":        "F[LAND1],O[EQ],L[DE],S[I]"
    },
    target={ "type": "odbc", "connection": "SqlServer_CRM", "sql": "SELECT KUNNR, NAME1, LAND1 FROM dbo.Customers WHERE LAND1 = 'DE'" },
    rowKey="KUNNR"
  )
◄ {
    "success": true,
    "testCaseId":   "29efee3b-0001-aaaa-bbbb-ccccddddeeee",
    "testCasePath": "/TestCases/Customers: SAP vs SQL Server",
    "testStepId":   "29efee3b-0002-ffff-1111-222233334444"
  }
```
The SAP password is not part of the call — after creation, open the test step in the Tosca UI and
enter it on the SAP Custom Data Reader before executing.
The `columnFilters` projection should line up with the columns the ODBC side selects, and the
`rowFilters` restriction should mirror the target `WHERE` clause so both sides return the same row
set. See the **SAP endpoint format** section below for the full filter syntax.

---
