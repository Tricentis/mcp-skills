# DI workflow 3 — Database table vs CSV export

### DIWorkflow 3 — Database table vs CSV export

**Goal:** Confirm that a CSV file exported from a database still matches the current database state.

**Step 1 — Get the database schema**
```
► get_di_connection_schema(connectionName="Prod_DB")
◄ {
    "count": 3,
    "columns": [
      { "schemaName": "dbo", "tableName": "Products", "columnName": "ProductId",   "dataType": "int",     "isNullable": "N" },
      { "schemaName": "dbo", "tableName": "Products", "columnName": "ProductName", "dataType": "varchar", "isNullable": "N" },
      { "schemaName": "dbo", "tableName": "Products", "columnName": "Price",       "dataType": "decimal", "isNullable": "Y" }
    ]
  }
```

**Step 2 — Discover the primary key**
```
► run_di_sql_statement(
    connectionName="Prod_DB",
    sql="SELECT kcu.COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY' AND kcu.TABLE_SCHEMA = 'dbo' AND kcu.TABLE_NAME = 'Products' ORDER BY kcu.ORDINAL_POSITION"
  )
◄ { "columns": ["COLUMN_NAME"], "count": 1, "rows": [["ProductId"]] }
  → rowKey = "ProductId"
```

**Step 3 — Detect CSV format (MANDATORY for every `csv_local`/CSV endpoint)**

> **Always detect the separator, line ending, and header before creating a CSV endpoint — never rely
> on defaults.** The DI reader's default `columnSeparator` is `|`, which almost never matches a real
> file; guessing wrong yields a confusing single-column / "No matching column name found for RowKey"
> failure instead of a clear error. Run the detection below, then set `columnSeparator` (and
> `rowSeparator` if not CRLF) explicitly. Only ask the user if detection is ambiguous.

Run this PowerShell snippet — it reads the first 512 bytes and reports the column separator,
line ending, and whether a header row is likely present:

```powershell
$path = "C:\exports\products_export.csv"
$fs   = [System.IO.File]::OpenRead($path)
$buf  = New-Object byte[] 512
$n    = $fs.Read($buf, 0, 512)
$fs.Close()
$text = [System.Text.Encoding]::UTF8.GetString($buf, 0, $n)
$nl   = [Array]::IndexOf($buf, [byte]10, 0, $n)
$rowSep = if ($nl -gt 0 -and $buf[$nl-1] -eq 13) { "CRLF (\r\n)" } else { "LF (\n)" }
$firstLine = ($text -split "`r?`n")[0]
$counts = @{ "," = ($firstLine.ToCharArray() | Where-Object { $_ -eq "," }).Count
             "|" = ($firstLine.ToCharArray() | Where-Object { $_ -eq "|" }).Count
             ";" = ($firstLine.ToCharArray() | Where-Object { $_ -eq ";" }).Count
             "`t" = ($firstLine.ToCharArray() | Where-Object { $_ -eq "`t" }).Count }
$sep = ($counts.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1).Key
$sepName = @{ "," = "comma (,)"; "|" = "pipe (|)"; ";" = "semicolon (;)"; "`t" = "tab (\t)" }[$sep]
Write-Host "Row separator : $rowSep"
Write-Host "Col separator : $sepName"
Write-Host "First line    : $firstLine"
```

Interpret the output:
- `rowSeparator`: use `"\r\n"` for CRLF, `"\n"` for LF
- `columnSeparator`: use `","` / `"|"` / `";"` / `"\t"` from the detected separator
- **Header row**: if the first-line values look like column names (text, not numbers), set `firstRowColumnNames: "True"` (default); if all values are data, set `"False"` and use `targetColumnRenames` to supply names

Show the detected values to the user with a one-line confirmation ("Detected: comma separator, CRLF line endings, header row present — proceeding.") before creating the test case.
The DI file reader's default `columnSeparator` is **`|`** (pipe), not comma — so a comma- or
semicolon-delimited CSV **must** set `columnSeparator` explicitly (e.g. `","` or `";"`), otherwise the
whole line is read as a single column and the comparison fails with *"No matching column name found for
RowKey"*. The default `rowSeparator` is the OS newline (`\r\n` on Windows); set `"\n"` for LF-only
files. Always pass `columnSeparator` for CSV; only pass `rowSeparator` when the file isn't CRLF.

**Step 4 — Create the comparison**
```
► create_di_row_by_row_comparison(
    name="Products: DB vs CSV export",
    source={ "type": "odbc",      "connection": "Prod_DB", "sql": "SELECT ProductId, ProductName, Price FROM dbo.Products" },
    target={
      "type":                "csv_local",
      "filename":            "C:\exports\products_export.csv",
      "columnSeparator":     ";",
      "rowSeparator":        "\n",
      "firstRowColumnNames": "True"
    },
    rowKey="ProductId"
  )
◄ { "success": true, "testCaseId": "...", "testCasePath": "/TestCases/Products: DB vs CSV export", "testStepId": "..." }
```

If CSV header names differ from the SQL column names, use `targetColumnRenames` to align them.

---
