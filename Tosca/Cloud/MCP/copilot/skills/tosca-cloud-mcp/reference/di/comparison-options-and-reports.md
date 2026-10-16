# Row-by-row comparison — options, tolerances, and reports

Cloud reference for `tosca_dataintegrity_createRowByRowComparison`. Use this when creating or recreating a comparison after failure analysis.

## General options

All values are strings because they map to Complete Row by Row Comparison module attributes.

| `generalOptions` field | Purpose |
|------------------------|---------|
| `maxErrors` | Maximum reported errors before comparison stops |
| `columnsToExclude` | Semicolon-separated columns excluded from comparison |
| `caseSensitiveColumnNames` | `"True"` / `"False"` |
| `skipRowcount` | `"True"` / `"False"` |
| `allowEmptyDataSources` | `"True"` / `"False"` |

Use exclusions only when the field is intentionally outside the test contract. Do not exclude a failing column merely to make the run green.

## Reporting

`generalOptions.reporting` maps to **General Options → Reporting**:

| Field | Purpose |
|-------|---------|
| `reportPath` | Full path or folder **on the execution agent** for a Data Integrity Report Viewer database |
| `exportUnmatchedTargetRows` | `"True"` to include unmatched target rows |
| `exportMatchedData` | `"True"` to include equal rows; potentially expensive |

Example:

```json
{
  "generalOptions": {
    "reporting": {
      "reportPath": "C:\\reports\\orders.db",
      "exportUnmatchedTargetRows": "True",
      "exportMatchedData": "False"
    }
  }
}
```

The path belongs to the execution agent, not the MCP server or user's IDE. Cloud MCP currently cannot open that `results.db` or export it to HTML/CSV. Use terminal `testSteps`, `attachments`, `logsUrl`, and `portalUrl` for available run evidence. Retrieval of the DI report itself is tracked separately by TOSCA-49584.

## Numeric tolerances

Use `tolerances.numericByColumn`:

```json
{
  "tolerances": {
    "numericByColumn": [
      { "column": "Amount", "tolerance": "-0.01;+0.01" },
      { "column": "Discount", "tolerance": "-1%;+1%" }
    ]
  }
}
```

Accepted forms include symmetric (`"5"`), absolute range (`"-5;+5"`), percentage range (`"-5%;+5%"`), and one-sided values (`"-5"` or `"+5%"`).

## DateTime tolerances and formats

Use `tolerances.dateTimeByColumn`. `unit` is `Seconds`, `Minutes`, `Hours`, or `Milliseconds`; do not append the unit to `tolerance`.

```json
{
  "tolerances": {
    "dateTimeByColumn": [
      {
        "column": "OrderDate",
        "tolerance": "5",
        "unit": "Seconds",
        "sourceDateTimeFormat": "dd.MM.yyyy HH:mm:ss",
        "targetDateTimeFormat": "MM/dd/yyyy HH:mm:ss"
      }
    ]
  }
}
```

Formats describe how each side is parsed. Tolerance describes the allowed time difference. A format mismatch does not by itself justify a non-zero tolerance.

## Tolerance file forms

Choose exactly one:

1. `numericByColumn` / `dateTimeByColumn` — preferred; the tool builds validated JSON.
2. `json` — complete tolerances JSON already supplied by the user.
3. `filename` — path to a file that already exists on the execution agent.

With the first two forms, the tool prepends a TBox Read/Create File step and points the comparison step at that file. Optional `tolerances.file` controls directory, filename, encoding, overwrite, and BOM.

## Side options and transforms

`sourceOptions` and `targetOptions` support:

- `columnRenames`: `{ "from": "...", "to": "..." }`
- `locale`
- `firstRowContainsColumnNames`
- `skipFirstNRows`
- `cellSettings.allColumns`
- `cellSettings.singleColumns`: `{ "column": "...", "transform": "..." }`

Common transforms include `Trim`, `TrimStart`, `TrimEnd`, `Replace`, `ReplaceRegex`, `Substring`, `Right`, `Lowercase`, and `Uppercase`.

Prefer targeted `singleColumns` transforms. Apply `allColumns` only when the same normalization is an explicit requirement across the dataset.

## Remediation rule

`tosca_teststep_edit` is appropriate only for a narrow SQL text or connection-name patch on an existing comparison step. Tolerances, formats, remaps, transforms, endpoints, RowKey, and general options require recreating the comparison with `tosca_dataintegrity_createRowByRowComparison`, then validating the new test case.
