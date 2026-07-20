---
name: tosca-datasets
description: List, view, create, and manage test data sets in Tosca Cloud
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "[list|view|create|next-row|list-subsets|view-subset|add-column|add-row|delete|lock|unlock|...] [options]"
---

# Manage Test Data Sets

Manage test data sets in Tosca Cloud — list, view, create, modify structure and data, control row consumption, and lock/unlock.

Always use `--json --silent` on every `toscactl` command.

## Routing

Parse `$ARGUMENTS` to determine the intent:

- **List data sets** (default if no subcommand or user says "list", "show"):
  ```
  toscactl datasets list --json --silent [--page-size 50] [--all]
  ```

- **View data set** — if the user provides a name/ID or says "view", "show details":
  ```
  toscactl datasets view "<name_or_id>" --json --silent [--page-size 50] [--all]
  ```

- **Create data set** — if the user says "create", "new":
  ```
  toscactl datasets create "<name>" --json --silent [--strategy circular|used-row]
  ```

- **Add column** — if the user says "add column":
  ```
  toscactl datasets add-column "<name_or_id>" --name "<column_name>" --type <string|double|boolean|datetime> --json --silent
  ```

- **Add row** — if the user says "add row":
  ```
  toscactl datasets add-row "<name_or_id>" --value "COL1=VAL1" --value "COL2=VAL2" --json --silent
  ```
  Values are typed automatically based on column data type. Column names are resolved to IDs.

- **Delete row** — if the user says "delete row", "remove row":
  ```
  toscactl datasets delete-row "<name_or_id>" --row "<row_id>" --dangerously-skip-confirmation --json --silent
  ```
  Warn the user this is irreversible and ask for explicit confirmation before proceeding.

- **Use row (consume)** — if the user says "use", "consume", "mark as used":
  ```
  toscactl datasets use-row "<name_or_id>" --row "<row_id>" --json --silent [--execution-run <id> --unit-execution <id>]
  ```

- **Next row** — if the user says "next row", "fetch row", "get next", "unused row":
  ```
  toscactl datasets next-row "<name_or_id>" --json --silent [--mark-as-used] [--subset "<name_or_id>"] [--json-flat] [--execution-run <id> --unit-execution <id>]
  ```
  Use `--mark-as-used` if the user wants to consume the row. Use `--subset` to scope to a specific subset. Use `--json-flat` for column-name-keyed output.

- **List subsets** — if the user says "list subsets", "show subsets":
  ```
  toscactl datasets list-subsets "<name_or_id>" --json --silent
  ```

- **View subset** — if the user says "view subset", "show subset", "subset details":
  ```
  toscactl datasets view-subset "<name_or_id>" "<subset_name_or_id>" --json --silent [--page-size 50] [--all]
  ```

- **Reuse row (unconsume)** — if the user says "reuse", "unconsume", "mark for reuse":
  ```
  toscactl datasets reuse-row "<name_or_id>" --row "<row_id>" [--row "<row_id>"] --json --silent
  ```

- **Lock** — if the user says "lock":
  ```
  toscactl datasets lock "<name_or_id>" --json --silent
  ```

- **Unlock** — if the user says "unlock":
  ```
  toscactl datasets unlock "<name_or_id>" --json --silent
  ```

- **Delete data set** — if the user says "delete dataset", "remove dataset":
  ```
  toscactl datasets delete "<name_or_id>" --dangerously-skip-confirmation --json --silent
  ```
  Warn the user this is irreversible and ask for explicit confirmation before proceeding.

## Presentation

- **List:** Show dataset count. For each dataset: name, subset count, locked status, and ID.
- **View:** Show metadata (name, ID, description, row count, lock state, strategy), then row data in a table with status (Used/empty), column values, and row IDs.
- **Next row:** Show the row data with column names and values. If no unused rows, say so. If `--mark-as-used`, confirm the row was consumed.
- **List subsets:** Show subset count. For each subset: name, description, and ID.
- **View subset:** Show subset metadata (name, ID, description, filter, created/modified info), then matching row data in a table.
- **Create:** Confirm dataset created with job ID.
- **Add column/row:** Confirm what was added.
- **Lock/Unlock:** Confirm the new state.
- **Delete:** Confirm the dataset or row was deleted.

## Error Handling

- If a dataset is not found by name, suggest listing datasets with `toscactl datasets list`.
- If commands fail with auth errors, check auth with `toscactl config --json --silent` and suggest re-authenticating with `/tosca-setup`.
- If `add-row` fails with an unknown column, suggest viewing the dataset first to see available columns.
