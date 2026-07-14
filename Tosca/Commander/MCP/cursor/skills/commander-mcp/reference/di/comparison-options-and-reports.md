# Row-by-row comparison — optional parameters and reports

## Contents

- [Optional parameters](#optional-createdi_row_by_row_comparison-parameters)
- [`folderId`](#folderid--place-the-test-case-in-a-specific-folder)
- [`generalOptions`](#generaloptions--tune-comparison-behaviour-and-reporting)
- [`results`](#results--write-a-comparison-report-to-disk)
- [`tolerances`](#tolerances--per-column-tolerance-and-datetimenumeric-formatting)
- [Reading the report](#reading-the-report-resultsdb)
- [HTML export](#exporting-the-report-to-html--always-offer-this)

## Optional `create_di_row_by_row_comparison` parameters

The five DIWorkflows above use only the required parameters. Three optional parameters are worth
knowing about — pass them only when the user asks for the behaviour, otherwise omit them.

### `folderId` — place the test case in a specific folder

Without `folderId`, the test case lands in the first `TestCases` folder under the project root.
To target a specific folder, look it up first and pass its ID.

```
► get_object_info(identifiers=["/TestCases/Migration Checks"])
◄ { "surrogateId": "5fee1234-aaaa-bbbb-cccc-111122223333", "name": "Migration Checks", "type": "TCFolder", ... }

► create_di_row_by_row_comparison(
    name="Customers: Prod vs Staging",
    folderId="5fee1234-aaaa-bbbb-cccc-111122223333",
    source={ "type": "odbc", "connection": "Prod_DB",    "sql": "..." },
    target={ "type": "odbc", "connection": "Staging_DB", "sql": "..." },
    rowKey="CustomerId"
  )
```

### `generalOptions` — tune comparison behaviour and reporting

Maps to the **General Options** section of the Complete Row by Row Comparison test step. All fields
are strings (the underlying DI step uses string values). Omit any field you don't want to set —
only listed fields are written; the rest keep their module defaults.

| Field | Purpose | Typical values |
|-------|---------|----------------|
| `maxErrors` | Stop after this many row mismatches | `"100"`, `"1000"`, `"-1"` (no limit) |
| `columnsToExclude` | Skip these columns during value comparison (semicolon-separated) | `"ModifiedDate;LastLogin"` |
| `caseSensitiveColumnNames` | Match column names case-sensitively | `"True"` / `"False"` |
| `skipRowcount` | Skip the row-count pre-check | `"True"` / `"False"` |
| `allowEmptyDataSources` | Pass when both sides are empty | `"True"` / `"False"` |

```
► create_di_row_by_row_comparison(
    name="Orders: SQL Server vs SQLite (tuned)",
    source={ "type": "odbc", "connection": "SqlExpress",  "sql": "SELECT * FROM dbo.Orders" },
    target={ "type": "odbc", "connection": "LocalSQLite", "sql": "SELECT * FROM Orders" },
    rowKey="OrderId",
    generalOptions={
      "maxErrors":                 "500",
      "columnsToExclude":          "ModifiedDate;RowVersion",
      "caseSensitiveColumnNames":  "False",
      "allowEmptyDataSources":     "False"
    }
  )
◄ { "success": true, "testCaseId": "...", "testCasePath": "/TestCases/Migration Checks/Orders: ...", "testStepId": "..." }
```

### `results` — write a comparison report to disk

Maps to the **General Options → Reporting** section of the Complete Row by Row Comparison test
step. Set it when you want the comparison to persist its differences to a Data Integrity Report
Viewer database (a `results.db` SQLite file) that can be opened in the Report Viewer or read back
later. All fields are strings. Omit any field to keep the module default.

| Field | Purpose | Typical values |
|-------|---------|----------------|
| `reportPath` | Full file path **or** folder for the report. If only a folder is given, DI generates `TestResultReport_yyyyMMdd-HHmmss`. | `"C:\reports\orders.db"`, `"C:\reports\orders-sync"` |
| `exportUnmatchedTargetRows` | Write target rows with no source match to the report (costly when many unmatched rows). | `"True"` / `"False"` |
| `exportMatchedData` | Write matched rows to the report. Hurts performance — leave `"False"` unless needed. | `"True"` / `"False"` |

```
► create_di_row_by_row_comparison(
    name="Orders: SQL Server vs SQLite (with report)",
    source={ "type": "odbc", "connection": "SqlExpress",  "sql": "SELECT * FROM dbo.Orders" },
    target={ "type": "odbc", "connection": "LocalSQLite", "sql": "SELECT * FROM Orders" },
    rowKey="OrderId",
    results={
      "reportPath":                "C:\reports\orders-sync.db",
      "exportUnmatchedTargetRows": "True",
      "exportMatchedData":         "False"
    }
  )
◄ { "success": true, "testCaseId": "...", "testCasePath": "/TestCases/Orders: ...", "testStepId": "..." }
```
After running the test case, the report at `reportPath` holds the differing rows (source vs target
values) for review in the Data Integrity Report Viewer.

### `tolerances` — per-column tolerance and datetime/numeric formatting

The `Tolerance` field is dual-purpose for **both** datetime and numeric columns:
1. **Actual tolerance** — allow a difference up to a given amount.
2. **Format specification** — tell DI how to parse the value on each side (datetime format string or number format string).

#### Datetime tolerances

`datetimeTolerance` combines two kinds of specifier, semicolon-separated and freely mixed:
- **Actual tolerance** — bare unit (e.g. `"5s"` = allow up to 5-second difference)
- **Ignore** — `i`-prefixed unit (e.g. `"ims"` = discard the milliseconds component entirely)

Units: `ms` (milliseconds), `s` (seconds), `m` (minutes), `h` (hours), `d` (days), `M` (months), `y` (years).
Ignore variants: `ims`, `is`, `im`, `ih`, `id`, `iM`, `iy`.

`sourceFormat`/`targetFormat` are parse formats (how to read the datetime string); they are
**separate** from the tolerance specifiers and are NOT tolerance units.

**Datetime example — different format on each side, compare date part only (ignore time):**
```
tolerances=[
  {
    "column":            "hire_date",
    "datetimeTolerance": "ims;is;im;ih",
    "sourceFormat":      "dd.MM.yyyy",
    "targetFormat":      "MM/dd/yyyy"
  }
]
```
Underlying JSON written to the test step:
```json
{
  "Columns": [
    {
      "Name": "hire_date",
      "Type": "DateTime",
      "SourceDateTimeFormat": "dd.MM.yyyy",
      "TargetDateTimeFormat": "MM/dd/yyyy",
      "Tolerance": "ims;is;im;ih"
    }
  ]
}
```

#### Numeric tolerances and number format

For numeric columns, `Tolerance` is the allowed difference range (`"-0.01;+0.01"` or `"-1%;+1%"`).
`sourceNumberFormat`/`targetNumberFormat` specify decimal and thousands separators so DI can parse
numbers that are formatted differently on each side. Use them whenever source and target store numbers
in different locale formats (e.g. European `,` decimal vs US `.` decimal).

Format string convention: write an example number in the format used by that side.
- `"1.234,56"` → period = thousands separator, comma = decimal separator (European)
- `"1,234.56"` → comma = thousands separator, period = decimal separator (US/UK)

`targetNumberFormat` defaults to `sourceNumberFormat` when omitted.

**Numeric example — tolerance only:**
```
tolerances=[
  { "column": "price",        "numericTolerance": "-0.01;+0.01" },
  { "column": "discount_pct", "numericTolerance": "-1%;+1%" }
]
```

**Numeric example — format only (source uses European format, target uses US format):**
```
tolerances=[
  {
    "column":             "amount",
    "sourceNumberFormat": "1.234,56",
    "targetNumberFormat": "1,234.56"
  }
]
```

**Numeric example — format + tolerance combined:**
```
tolerances=[
  {
    "column":             "amount",
    "sourceNumberFormat": "1.234,56",
    "targetNumberFormat": "1,234.56",
    "numericTolerance":   "-0.01;+0.01"
  }
]
```

---

### Reading the report (`results.db`)

The report file is a **standard SQLite database** — there is no Tosca-specific format. Read it with
any SQLite client: attach it as a DI SQLite connection and use `run_di_sql_statement`, or open it
directly with the `sqlite3` CLI / any SQLite library (e.g. from bash or Python).

**Via a Tosca DI connection**
```
► di_connection(operation="create", name="ReportDb", connectionType="SQLite",
                sqliteFilePath="C:\reports\orders-sync.db")
► run_di_sql_statement(connectionName="ReportDb",
                sql="SELECT name FROM sqlite_master WHERE type='table'")
```

**Via the sqlite3 CLI (bash / PowerShell)**
```
sqlite3 "C:\reports\orders-sync.db" "SELECT Key, Value FROM Metadata"
sqlite3 "C:\reports\orders-sync.db" "SELECT * FROM DifferencesSummary"
```

**Tables**

| Table | Columns | Contents |
|-------|---------|----------|
| `Metadata` | `Key`, `Value` | Report info as `$.reportInfo.*` key/value pairs: `ReportType`, `createdAt`, `DIVersion`, `NodePath`, source/target `type`/`description`/`sql`, and `comparisonOverview.*` (`status`, `errorsFound`, `errorLimit`, `rowsWithDifferences`, `sourceRowsProcessed`, `targetRowsProcessed`, `matchedRowsCount`, `sourceRowsNotFound`, `targetRowsNotFound`, `invalidSourceRows`, `invalidTargetRows`). |
| `DifferencesSummary` | `ColumnName`, `NumberOfDifferences` | One row per column that had value differences, with the count. Empty when there are no differences. |
| `ColumnNames` | `TableName`, `ColumnId`, `ColumnName` | Column layout (ordinal + name) for the data tables below — i.e. the compared columns. |
| `Differences` | the compared columns | Rows that matched on `rowKey` but differ in at least one column. |
| `Matched` | the compared columns | Matched rows. Only populated when `exportMatchedData="True"` (otherwise empty even though `matchedRowsCount` is set in `Metadata`). |
| `UnmatchedSource` | the compared columns | Source rows with no matching target row (by `rowKey`). |
| `UnmatchedTarget` | the compared columns | Target rows with no matching source row. Only populated when `exportUnmatchedTargetRows="True"`; otherwise `targetRowsNotFound` in `Metadata` is `-1` (not computed). |
| `InvalidSource` | the compared columns | Source rows that could not be read/parsed. |
| `InvalidTarget` | the compared columns | Target rows that could not be read/parsed. |

**Quick interpretation**
- Overall pass/fail + counts: read `Metadata` rows where `Key` starts with
  `$.reportInfo.comparisonOverview.` (`status` = `"Comparison Successful"`, `errorsFound`,
  `rowsWithDifferences`, `matchedRowsCount`).
- Which columns differ and how often: `SELECT * FROM DifferencesSummary`.
- The actual differing rows: `SELECT * FROM Differences` (plus `UnmatchedSource` / `UnmatchedTarget`
  for missing rows).
- `Matched` and `UnmatchedTarget` are only filled when the matching `results` export flag was set.

### Exporting the report to HTML — ALWAYS OFFER THIS

After a test run that has a `reportPath` set (i.e. a `.db` file was written), **always suggest
exporting and opening the HTML report** for the user — this is one of the most valuable things you
can do after a comparison. The Data Integrity Report Exporter produces a self-contained HTML file
with a tabbed view of differences, unmatched rows, and a summary.

**Exporter executable:**
```
C:\Program Files (x86)\TRICENTIS\Tosca Testsuite\Data Integrity\tools\windows\Tricentis.DataIntegrity.Report.Exporter.exe
```

**Export to HTML and open (PowerShell):**
```powershell
$exporter = "C:\Program Files (x86)\TRICENTIS\Tosca Testsuite\Data Integrity\tools\windows\Tricentis.DataIntegrity.Report.Exporter.exe"
$outDir   = "C:\tmp\report_html"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
& $exporter --input "C:\reports\orders-sync.db" --output $outDir --format HTML --progress
Start-Process "$outDir\<report-name>.html"
```

**Key flags:**

| Flag | Meaning |
|------|---------|
| `--input` / `--i` | Path to the `.db` report file |
| `--output` / `--o` | Output directory (or full file path) |
| `--format` / `--f` | `HTML` (default) or `CSV` |
| `--table` / `--t` | Which tab to export: `Differences`, `UnmatchedSource`, `UnmatchedTarget`, `InvalidSource`, `InvalidTarget`, `Summary` — omit to export all |
| `--delimiter` / `--d` | CSV only — column delimiter (default `,`) |
| `--progress` | Print progress to stdout |

**Notes:**
- Export of the `Matched` tab is NOT supported for HTML.
- The exporter writes one `<report-name>.html` file (all tabs) plus a `<report-name>_summary.json`.
- If only a directory is given as `--output`, the exporter names the file after the `.db` file.
- Run this with `Bash` or `PowerShell` tool.

**When to suggest this:** any time `execute_test_suite` or a test run returns differences AND a `reportPath`
was set in `results`. Offer to export and open the HTML immediately after showing the error summary —
the user gets a rich, shareable visual diff without any additional setup.
