---
name: tosca-export-dataset
description: Export a data set to CSV, Excel, or JSON from Tosca Cloud
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "<dataset-name-or-id> --format csv|excel|json [--output <path>]"
---

# Export a Data Set

Export a test data set from Tosca Cloud to a local CSV, Excel, or JSON file.

Always use `--json --silent` on every `toscactl` command.

## Steps

1. **Parse arguments.** Extract from `$ARGUMENTS`:
   - Dataset name or ID (required)
   - Format: `csv`, `excel`, or `json` (required — ask the user if not specified)
   - Output path (optional — defaults to `dataset_<id>.<ext>`)

2. **Run the export.**
   ```
   toscactl datasets export "<name_or_id>" --format <csv|excel|json> --json --silent [--output "<path>"] [--sort-column "<column>"] [--direction asc|desc]
   ```

3. **Parse the result.** The JSON response contains:
   - `path` — the output file path
   - `size` — file size in bytes

4. **Report to the user.** Show the file path and size. If relevant, offer to view the file contents.

## Export Options

- `--sort-column <name>` — sort rows by a specific column before exporting
- `--direction asc|desc` — sort direction (default: ascending)
- `--separator <char>` — CSV field separator (default: comma)
- `--encoding <name>` — character encoding (e.g., `utf-8`)

## Error Handling

- If the dataset is not found, suggest listing datasets with `/tosca-datasets list`.
- If the export fails with authorization errors, suggest re-authenticating with `/tosca-setup`.
