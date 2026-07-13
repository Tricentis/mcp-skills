# DI workflow 6 — Field-mapping CSV (e.g. Collibra) → DI comparisons

### DIWorkflow 6 — Field-mapping CSV (e.g. Collibra) → DI comparisons

**Goal:** Turn a data-governance field-mapping export into DI test cases, one per mapping group, using
`parse_di_lineage_mapping` to classify the rows first. Row by Row Comparison is the default (full value
verification); when the user only wants **completeness** (no rows lost), build a source-vs-target
row-count match instead — see Step 3.

> **Pick the check type up front.** "Verify the mapping / migration" or "compare source vs target" →
> Row by Row Comparison (default; it also proves completeness because missing rows are reported as
> unmatched). "Completeness check" / "did we lose any rows" / "counts match" → row-count match
> (Step 3, completeness option). Do NOT satisfy a completeness request with a `COUNT(*) > 0` check.

**Step 1 — Parse the mapping file**
```
► parse_di_lineage_mapping(csvPath="C:\exports\Field Mapping.csv")
◄ {
    "groupCount": 3,
    "groups": [
      { "mappingType": "1:1",
        "targetCatalog": "PREPARED", "targetSchema": "NAMES", "targetTable": "BABY_NAMES_PREPARED",
        "sources": [ { "sourceCatalog": "RAW", "sourceSchema": "NAMES", "sourceTable": "BABY_NAMES_RAW",
                       "columnMappings": [ { "sourceColumn": "NAME1", "targetColumn": "FIRST_NAME" }, ... ] } ] },
      { "mappingType": "Merge", "targetTable": "CUSTOMERS",
        "sources": [ { "sourceTable": "BUSINESS_CUSTOMERS", ... }, { "sourceTable": "PRIVATE_CUSTOMERS", ... } ] },
      { "mappingType": "Split", "targetTable": "RETAIL_PRODUCTS", "sources": [ { "sourceTable": "PRODUCTS", ... } ] }
    ],
    "warning": null, "error": null
  }
```
- Check `error` first — if set, stop and report it (e.g. wrong columns, row-limit exceeded, all rows blank).
- Surface any `warning` to the user (rows skipped for blank Source/Target Table, unrecognised types treated as 1:1).
- The tool only reports what is in the file — it never infers mappings.

> **Fallback parsing — only when the tool genuinely cannot read the file.** `parse_di_lineage_mapping`
> is the primary, deterministic path; always call it first. Fall back to reading the CSV yourself ONLY
> when the tool returns an `error` you cannot resolve by fixing the input — e.g. a non-comma delimiter,
> quoted fields with embedded newlines (the tool parses each physical line as one row), or an otherwise
> malformed export. When you do fall back, you must still **only transcribe what is literally in the
> file** — the same columns and the same 1:1/Merge/Split classification rules — and **never infer or
> guess a mapping** (AC1). If the file is well-formed, do not second-guess the tool's output.

**Step 2 — Identify the DI connections (ask the user)**
```
The CSV gives table/column names but NOT the Tosca DI connection that backs each database. Use
di_connection(operation="list") to find candidates, then confirm with the user which connection is
the SOURCE (raw) and which is the TARGET (prepared) side. Do not guess connection names.
```

**Step 3 — Create one test case per group (follow the mappingType)**

*Default — Row by Row Comparison (full value verification; also covers completeness):*
```
1:1   → one source → one target. Create ONE comparison.
        Use sourceColumnRenames for the columnMappings whose names differ; rowKey = the business/primary key.

Merge → multiple sources → one target. Create ONE comparison PER source, each restricted (WHERE) to the
        rows that originated from that source. You need a discriminator (e.g. CUSTOMER_ID LIKE 'B%' vs 'P%').
        Infer it from sampled DISTINCT values first; ask the user only if ambiguous.

Split → one source → multiple targets. Create ONE comparison PER target, each restricted (WHERE) by the
        routing predicate (e.g. PROD_CAT = 'RETAIL'). Infer from DISTINCT values; ask only if ambiguous.
```

*Completeness-only option (when the user wants "no rows lost", not a full value comparison):* build a
source-vs-target **row-count match** per group instead of a Row by Row Comparison (see DIWorkflow 7,
Step 1c). Keep the same per-mappingType grouping and WHERE restrictions so each count pair covers the
same row set:
```
1:1   → one row-count match: source COUNT(*) == target COUNT(*).
Merge → per source: SUM of source COUNT(*)s == target COUNT(*) (or one count match per source using the discriminator WHERE).
Split → per target: source COUNT(*) filtered by the routing predicate == target COUNT(*).
```
Same database → one DB Expert step per pair (CASE-WHEN counts equal → assert `"0"`). Different databases
→ for completeness (counts only) prefer a source-count-vs-target-count compare (two-step buffer, or two
count checks — lightweight and scale-independent); use Row by Row Comparison when you also want full
value verification, sizing/filtering it since it reads every row. See DIWorkflow 7, Step 1c. Do NOT use
`COUNT(*) > 0` for completeness.
Example for the 1:1 group above (target column names differ from source → use `sourceColumnRenames`):
```
► create_di_row_by_row_comparison(
    name="1:1 | BABY_NAMES_RAW -> BABY_NAMES_PREPARED",
    source={ "type": "odbc", "connection": "RawDB",      "sql": "SELECT NAME1, NAME2, YEAR FROM BABY_NAMES_RAW" },
    target={ "type": "odbc", "connection": "PreparedDB", "sql": "SELECT FIRST_NAME, LAST_NAME, YEAR_OF_BIRTH FROM BABY_NAMES_PREPARED" },
    rowKey="FIRST_NAME;LAST_NAME;YEAR_OF_BIRTH",
    sourceColumnRenames=[
      { "from": "NAME1", "to": "FIRST_NAME" },
      { "from": "NAME2", "to": "LAST_NAME" },
      { "from": "YEAR",  "to": "YEAR_OF_BIRTH" }
    ]
  )
◄ { "success": true, "testCaseId": "...", "testStepId": "..." }
```
See DIWorkflow 5 for the rename rules and DIWorkflow 1 for rowKey/PK discovery. As always, read the
schema of both sides (and sample the discriminator/predicate columns) BEFORE writing the SQL.

**Step 4 — Validate sequentially**
```
► execute_test_suite(test_case_id="<testCaseId>", is_validation_run=true)   // one call per test case — execute_test_suite is not parallel
```

---
