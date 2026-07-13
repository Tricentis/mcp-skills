# DI workflow 7 — Data Quality checks with DB Expert (non-emptiness, not-null, uniqueness, length, reconciliation completeness)

### DIWorkflow 7 — Data Quality checks with DB Expert (non-emptiness, not-null, uniqueness, length, reconciliation completeness)

**Goal:** Generate standard data quality checks on a target table using `create_di_db_expert_module`.

> **"Completeness" means two different things — do not confuse them.**
>
> - **Non-emptiness / has-data** (single table, one connection): the table simply has rows,
>   i.e. `COUNT(*) > 0`. This is a data-quality smoke check, NOT a migration/reconciliation check.
> - **Reconciliation completeness** (source vs target): **no rows were lost** moving data from a
>   source to a target, i.e. `source COUNT(*) == target COUNT(*)`. This is the meaning whenever the
>   user references a source AND a target — migration, ETL load, lineage/mapping, replica, or any
>   "compare source vs target" / "verify completeness" request.
>
> **Default rule:** if a source and a target are in play, "completeness check" means the row counts
> **match** — never `COUNT(*) > 0`. A `>0` check passes even if the target lost 90% of its rows, so
> it is wrong for completeness. See **Step 1c** (reconciliation completeness) below.

> **Two rules that save the most time here — read before building DQ checks.**
>
> **1. Two assertion styles — pick the right one per situation.**
>
> **Style A — `dataType:"Numeric"` with an operator prefix.**
> Pass the operator as a prefix of the value string: `">0"`, `">=1"`, `"<10"`, `"<=255"`, `"!=5"`.
> The tool parses the prefix and sets Tosca's internal operator condition automatically — the value
> stored on the cell is the number only, and the comparison operator is set as the steer property.
> Use this style for **single-check queries** where the SQL returns a meaningful count or total
> (e.g. `SELECT COUNT(*) AS ROW_COUNT FROM T` asserted as `">0"`).
>
> **Style B — violation count asserted as `"0"`.**
> Make the SQL return a violation count with `CASE WHEN <bad condition> THEN 1 ELSE 0 END`
> (or `COUNT(*) - COUNT(DISTINCT col)` for uniqueness) and assert the exact string `"0"`.
> Use this style when you **consolidate many checks into one query** (rule 2): every column becomes
> a plain `"0"` equality, so all cells share one uniform assertion and no `dataType` is needed.
>
> **2. Consolidate per table; `execute_test_suite` is strictly sequential.**
> Every `execute_test_suite` runs one-at-a-time on the Commander UI thread (a few seconds each), so the
> number of test cases — not their size — dominates runtime. Put all four checks for one table into
> **one** DB Expert query with one column per check, instead of one test case per check. Four tables
> then cost 4 validations instead of ~24.

**Step 1 — Inspect the target schema (and sample data only if a check needs a predicate)**
```
► get_di_connection_schema(connectionName="TargetDB")
◄ { "count": 4, "columns": [ { "tableName": "CUSTOMERS", "columnName": "CUSTOMER_ID", ... }, ... ] }
```

**Step 1b — Single-check example using Style A (Numeric operator prefix): non-emptiness / has-data**
Use this form for a standalone **non-emptiness** smoke check (the table has rows). This is NOT a
completeness check — for source-vs-target completeness use Step 1c instead.
```
► create_di_db_expert_module(
    name="DQ | CUSTOMERS | Non-emptiness",
    connection="TargetDB",
    sqlStatement="SELECT COUNT(*) AS ROW_COUNT FROM CUSTOMERS",
    resultTable=[
      { "row": "$1", "column": "#1", "value": ">0", "dataType": "Numeric" }
    ]
  )
◄ { "success": true, "testCaseId": "...", "testStepId": "..." }
```
The `">0"` prefix is parsed automatically: Tosca's operator condition is set to `Greater` and the
cell value is stored as `0`. Other supported prefixes: `>=`, `<`, `<=`, `!=` (no prefix = `Equals`).

**Step 1c — Reconciliation completeness: source vs target row-count match**
This is what "completeness check" means whenever a source and a target are in play (migration, ETL,
lineage, replica). Assert that the two row counts are **equal** — not that the target is non-empty.

**Same database** (source and target reachable from one connection) — one DB Expert step (Style B,
assert `"0"`); the CASE returns `0` only when the counts match:
```
► create_di_db_expert_module(
    name="Completeness | ORDERS_RAW -> ORDERS_PREPARED",
    connection="DuckDB Persistent Connection",
    sqlStatement="
      SELECT CASE WHEN
        (SELECT COUNT(*) FROM ORDERS_RAW) = (SELECT COUNT(*) FROM ORDERS_PREPARED)
      THEN 0 ELSE 1 END AS RowCountMismatch",
    resultTable=[
      { "row": "$1", "column": "#1", "value": "0" }
    ]
  )
◄ { "success": true, "testCaseId": "...", "testStepId": "..." }
```
Optionally also return both counts as extra columns (e.g. `(SELECT COUNT(*) FROM ORDERS_RAW) AS SourceCount, ...`)
for visibility — assert only the mismatch column as `"0"`.

**Different databases** (source and target on separate connections) — a single DB Expert SQL cannot
span two connections, so completeness needs a count from each side. Pick the path by intent:

- **Preferred for completeness (counts only): compare a source count against a target count.**
  This is lightweight and scale-independent — it moves two numbers, not the rows. Two ways to persist it:
  - **Two-step buffer test case** (single self-contained check): step 1 runs `SELECT COUNT(*)` on the
    source and **buffers** the result; step 2 runs `SELECT COUNT(*)` on the target and asserts it
    **equals the buffered value**. The DI-specific MCP tools create only single-step test cases, so
    assemble this in Commander (or via the generic `create_test_case` + drop-task/step tools) — it is
    not produced by a single `create_di_*` call.
  - **Two DB Expert checks + external compare**: create one `create_di_db_expert_module` per side
    (`SELECT COUNT(*)`), or read each count with `run_di_sql_statement`, and compare the two numbers.
- **Full value verification (also proves completeness): `create_di_row_by_row_comparison`.** Its
  built-in row-count pre-check plus unmatched-row reporting catches missing rows, and it also compares
  every value. Use it when a `rowKey` exists AND you want value-level reconciliation, not just counts.
  > **Scale caution:** Row by Row reads and matches *every* row, so on large tables it is slow and can
  > time out / be cancelled. For a counts-only completeness check, use the count-compare paths above,
  > or scope Row by Row with a `WHERE` filter (e.g. one partition/measure) to keep it small.

**Step 2 — Build ONE consolidated DQ query per table (Style B)**
```
► create_di_db_expert_module(
    name="DQ | CUSTOMERS",
    connection="TargetDB",
    sqlStatement="
      SELECT
        CASE WHEN COUNT(*) > 0 THEN 0 ELSE 1 END                AS NonEmpty,
        SUM(CASE WHEN CUSTOMER_ID IS NULL THEN 1 ELSE 0 END)    AS NullCustomerId,
        COUNT(*) - COUNT(DISTINCT CUSTOMER_ID)                  AS DuplicateCustomerId,
        SUM(CASE WHEN LENGTH(ZIP) > 10 THEN 1 ELSE 0 END)       AS ZipTooLong
      FROM CUSTOMERS",
    resultTable=[
      { "row": "$1", "column": "#1", "value": "0" },
      { "row": "$1", "column": "#2", "value": "0" },
      { "row": "$1", "column": "#3", "value": "0" },
      { "row": "$1", "column": "#4", "value": "0" }
    ]
  )
◄ { "success": true, "testCaseId": "...", "testStepId": "..." }
```
Each asserted column is a violation count (Style B), so the test passes only when every check returns `0`:
- **Non-emptiness** — `CASE WHEN COUNT(*) > 0 THEN 0 ELSE 1 END` → `0` when the table has rows.
  (This only proves the table is non-empty. For source-vs-target completeness use the row-count
  match in Step 1c — `>0` is not a completeness check.)
- **Not-null** — `SUM(CASE WHEN col IS NULL THEN 1 ELSE 0 END)` → `0` when no NULLs.
- **Uniqueness** — `COUNT(*) - COUNT(DISTINCT col)` → `0` when no duplicates (use a concatenation of
  columns for composite keys, e.g. `COUNT(DISTINCT col_a || '|' || col_b)`).
- **Length** — `SUM(CASE WHEN LENGTH(col) > N THEN 1 ELSE 0 END)` → `0` when none exceed `N`.

> **Dialect note:** use `LENGTH()` on SQLite/MySQL, `LEN()` on SQL Server; string concat is `||`
> on SQLite/Oracle/Postgres and `+` (or `CONCAT`) on SQL Server.

**Step 3 — Validate (one call per test case, sequential)**
```
► execute_test_suite(test_case_id="<testCaseId>", is_validation_run=true)
◄ { ... result severity + scratchbook logs ... }
```

Only split a table's checks into separate test cases when the user explicitly needs per-check
pass/fail reporting — and expect one sequential `execute_test_suite` per test case.

---
