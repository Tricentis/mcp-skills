# DI workflow — row-by-row comparison

Create a Complete Row by Row Comparison test case between two database connections.

Load **di-orchestration.md**, then this file. Schema steps are the canonical recipe in [conventions.md](../conventions.md) — copy them; do not invent a schema tool.

```text
Row-by-row comparison:
- [ ] tosca_diconnection List → user picks source and target
- [ ] Five-step schema per connection (Get, allowAiQueries, DBMS, runSql catalog)
- [ ] Propose SQL + RowKey + remaps; confirm
- [ ] tosca_dataintegrity_createRowByRowComparison (include columnRenames when names differ; expectedResult only when differences are expected)
- [ ] tosca_testcase Get
```

## Step 1 — List connections

```
Call tosca_diconnection List
→ Present connectionName, dataSourceType, allowAiQueries, id.id
→ Ask: "Which connection is the **source** and which is the **target**?"
```

If none exist, or the user asked to create/test a connection, follow `reference/workflows/di-connection.md`, then resume at List.

## Step 2 — Schema for each connection

For **each** picked connection, run the five-step recipe from [conventions.md](../conventions.md):

1. `tosca_diconnection` Get (`connectionId` = inner Ulid)
2. If `allowAiQueries` is false → **stop**; enable Allow AI queries in Connection Manager
3. Infer DBMS from `dataSourceType`, name, description, `metadata.databaseCategory`
4. If unclear → ask
5. Catalog `SELECT` via `tosca_dataintegrity_runSql` → open `launcherLink` → poll `checkSqlResult`

Both connections can start in parallel; each `runSql` → `checkSqlResult` pair is sequential. Do not narrate pending polls.

If catalog retrieval fails (Custom ODBC with no usable catalog SQL), ask the user to describe tables and columns.

## Step 3 — Propose SQL + RowKey + remaps

Using catalog columns:

- Match tables/columns between source and target.
- Propose a `SELECT` per side (explicit columns, not `SELECT *`).
- Suggest `rowKey` (PK/business key, composite with `;`, or `"All Source Columns"`). Catalog rows do not include PK metadata — ask if unclear.
- If names differ (e.g. `ORDER_ID` vs `OrderId`), plan `sourceOptions.columnRenames` / `targetOptions.columnRenames`. After remaps, RowKey names must match.

## Step 4 — Confirm

```
Source connection: <name>
Source SQL: SELECT ...
Target connection: <name>
Target SQL: SELECT ...
RowKey: <column(s)>
Remaps: <from → to, or none>
```

Ask: "Does this look correct, or would you like to adjust anything?"

## Step 5 — Create, then verify

Default write: `tosca_dataintegrity_createRowByRowComparison`. Fill remaps and optional tolerances on that request — do not rebuild the module with `tosca_teststep_edit`.

`expectedResult` is what the step verifies after the comparison has run. Omit it when source and target are meant to match: it falls back to the module default `OK*`, whose trailing wildcard absorbs the row counts and report path the executor appends to the message. Set it only when differences are the expected outcome — a known defect, or a migration still in flight. In that case run the comparison once, take the message off the failing step, and pass that text with a trailing `*`; do not hand-write an expected error from memory, because the wording and counts come from the executor. Setting `OK*` on a comparison that is supposed to find differences turns a meaningful check into a permanently red test.

Then `tosca_testcase` Get on the returned `testCaseId`.

Do **not** start `tosca_testrun_edit` Create unless the user asked to run.

---

## Example — names differ; remap on create

```
► tosca_diconnection List
◄ [{ connectionName: "SourceDB", dataSourceType: "ODBC", allowAiQueries: true,
     id: { spaceId: "...", id: "01J..." } },
   { connectionName: "TargetDB", ... id: { spaceId: "...", id: "01K..." } }]

► tosca_diconnection Get  connectionId="01J..."
◄ { connectionId: "01J...", connectionName: "SourceDB", dataSourceType: "ODBC",
    allowAiQueries: true, metadata: { databaseCategory: "MSSQL" } }

► tosca_dataintegrity_runSql  connectionId="01J..."
    sql="SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Orders'"
◄ { launcherLink: "tricentistosca://di?...", notificationId: "abc-123" }
► open launcherLink
► tosca_dataintegrity_checkSqlResult  notificationId="abc-123"  (poll until completed)
◄ columns include dbo.Orders.ORDER_ID, CUSTOMER_ID, ORDER_DATE, TOTAL

(same Get + runSql catalog on 01K... → dbo.Orders.OrderId, CustomerId, OrderDate, Total)

► tosca_dataintegrity_createRowByRowComparison({
    name: "Orders: SourceDB vs TargetDB",
    source: {
      type: "Database",
      connectionName: "SourceDB",
      sqlStatement: "SELECT ORDER_ID, CUSTOMER_ID, ORDER_DATE, TOTAL FROM dbo.Orders"
    },
    target: {
      type: "Database",
      connectionName: "TargetDB",
      sqlStatement: "SELECT OrderId, CustomerId, OrderDate, Total FROM dbo.Orders"
    },
    rowKey: "OrderId",
    sourceOptions: {
      columnRenames: [
        { from: "ORDER_ID", to: "OrderId" },
        { from: "CUSTOMER_ID", to: "CustomerId" },
        { from: "ORDER_DATE", to: "OrderDate" },
        { from: "TOTAL", to: "Total" }
      ]
    }
  })
◄ { success: true, testCaseId: "...", testCasePath: "/TestCases/Orders: SourceDB vs TargetDB" }

► tosca_testcase Get  testCaseId="..."
```

Optional tolerances on the same create call, e.g. `tolerances.numericByColumn: [{ column: "Total", tolerance: "0.01" }]`.
