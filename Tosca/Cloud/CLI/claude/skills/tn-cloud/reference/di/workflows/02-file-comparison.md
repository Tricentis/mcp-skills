# DI workflow — file comparison

## File-to-Database or File-to-File Comparison

Use `Type: "File"` for file endpoints:
```
Source: { "Type": "File", "File": { "Format": "Csv", "LocalPath": "C:/data/export.csv" } }
Target: { "Type": "Database", "ConnectionName": "<name>", "SqlStatement": "<sql>" }
```
Supported file formats: `Csv`, `Parquet`, `Avro`. Only local file paths are supported.

For CSV files, detect the separator and line ending from the first few lines before creating the comparison.
Pass `Options` only when defaults differ: `ColumnSeparator` (default `|`), `RowSeparator` (`Windows (\r\n)` or `Unix (\n)`), `Encoding` (default UTF8).

---

