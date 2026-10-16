# DI workflow — file comparison

File endpoints go through **`tosca_dataintegrity_createRowByRowComparison`** (`source` / `target` `type: "File"`). Formats include `Csv`, `Parquet`, `Avro`, and `Json`. Storage includes Local (default), Ssh (CSV), S3, Gcp, Azure, and Rclone. Secrets for cloud/SSH stay in the Tosca UI after create.

If the other side is a Database, resolve schema with the five-step `runSql` recipe in [conventions.md](../conventions.md) (`tosca_diconnection` List/Get — not `listConnections`).

## File-to-Database or File-to-File Comparison

Use `type: "File"` for file endpoints:
```
source: { type: "File", file: { format: "Csv", localPath: "C:/data/export.csv" } }
target: { type: "Database", connectionName: "<name>", sqlStatement: "<sql>" }
```

For CSV files, detect the separator and line ending from the first few lines before creating the comparison.
Pass `file.options` only when defaults differ: `columnSeparator` (default `|`), `rowSeparator` (`Windows (\r\n)` or `Unix (\n)`), `encoding` (default UTF8).

---

