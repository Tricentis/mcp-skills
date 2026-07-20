---
name: toscactl-reference
description: >
  Use when the user mentions Tosca, toscactl, test automation, playlists,
  test cases, modules, workspaces, or any Tricentis Tosca Cloud concepts.
  Provides the full toscactl CLI reference for answering questions and
  using the tool correctly.
user-invocable: false
allowed-tools: Bash(toscactl *)
---

# toscactl CLI Reference

`toscactl` is a CLI for Tricentis Tosca Cloud.

## Critical Rules

- **Always** append `--json --silent` to every `toscactl` command. Never parse human-readable table output.
- When a command fails, first run `toscactl config --json --silent` to check if authentication and workspace are configured. If not, invoke `/tosca-login` to guide the user through login.

## Global Flags

These flags apply to every command:

| Flag                        | Description                                                                |
|-----------------------------|----------------------------------------------------------------------------|
| `--json`                    | Output results as JSON                                                     |
| `-s, --silent`              | Suppress all output except results                                         |
| `--workspace <NAME_OR_ID>`  | Override the active workspace for this command (name or id); not persisted |

Use `--workspace` in CI pipelines to target a specific workspace without calling `workspaces set`. The persisted configuration is never modified. Example:

```bash
toscactl --workspace "My Project" --json --silent playlists run start <PLAYLIST_ID>
```

## Available Slash Commands

- `/tosca-login` — Log in to Tosca Cloud (detects configured URL or prompts for one)
- `/tosca-setup` — Login and configure workspace
- `/tosca-find` — Search for assets or playlists
- `/tosca-run` — Execute a playlist and wait for results
- `/tosca-status` — View playlist details, run results, or history
- `/tosca-execution` — View test steps, logs, or JUnit results for a test case execution
- `/tosca-create-workspace` — Create a new workspace
- `/tosca-create-playlist` — Create a new playlist
- `/tosca-delete-workspace` — Delete a workspace
- `/tosca-delete-playlist` — Delete a playlist
- `/tosca-agents` — List, view, shut down, or delete execution agents
- `/tosca-datasets` — List, view, create, and manage test data sets
- `/tosca-import-dataset` — Import a CSV, Excel, or JSON file as a new data set
- `/tosca-export-dataset` — Export a data set to CSV, Excel, or JSON

## Command Reference

### Authentication

```
toscactl login --url <tenant>.my.tricentis.com [--headless]
```

- Opens browser for PKCE authentication by default.
- Use `--headless` for device code flow (CI/headless environments).
- Set `TOSCA_CLIENT_ID` and `TOSCA_CLIENT_SECRET` environment variables for non-interactive client credentials authentication.

### Configuration

```
toscactl config
```

Shows current tenant URL and active workspace.

### Workspaces

```
toscactl workspaces list
toscactl workspaces create <name> [--description TEXT] [--access-type public|private] [--import-examples] [--asset-library]
toscactl workspaces set <name_or_id>
toscactl workspaces view <name_or_id>
toscactl workspaces delete <name_or_id> [--dangerously-skip-confirmation]
```

- `<name_or_id>` accepts either a workspace name or UUID.
- `create` makes a new workspace. Name must be 1-64 characters, no special characters (`/ \ : . ~ & % ; @ ' " ? < > | # $ * } { , + = [ ]`).
- `delete` is irreversible. Without `--dangerously-skip-confirmation`, it prompts the user to type the workspace name to confirm. In `--silent`/`--json` mode, the flag is required.

### Assets

```
toscactl assets find [--type TYPE] [--name NAME] [--tag TAG...] [--sort FIELD:DIR] [--page-size N] [--all]
```

- **Types:** TestCase, Module, SharedAction, Playlist, ApiAction, ApiMessage, Folder, TestCaseTemplate
- **Tags:** `--tag` is repeatable with AND logic. E.g. `--tag smoke --tag regression` returns assets matching both tags.
- **Sort format:** `fieldName:asc` or `fieldName:desc` (common fields: `updatedAt`, `name`)
- `--all` fetches all pages (use sparingly on large result sets).

### Playlists

```
toscactl playlists create <name> [--description TEXT] [--test-case NAME_OR_ID...] [--run-mode parallel|sequential|sequentialOnSameAgent] [--characteristic KEY=VALUE...] [--cron-schedule EXPR] [--keep-recordings-on-success]
toscactl playlists delete <name_or_id> [--dangerously-skip-confirmation]
toscactl playlists find [--name NAME] [--sort FIELD:DIR] [--page-size N] [--all] [--results]
toscactl playlists view <name_or_id>
toscactl playlists history <name_or_id> [--page-size N] [--all]
```

- `create` makes a new playlist. `--test-case` is repeatable and accepts names or UUIDs. Names are resolved via inventory search; ambiguous names produce an error. Test case identifiers can also be piped via stdin (one per line). Default run mode is `sequential`.
- `delete` is irreversible. Without `--dangerously-skip-confirmation`, it prompts the user to type the playlist name to confirm. In `--silent`/`--json` mode, the flag is required.
- `--results` includes last run result status in the find output.
- `view` shows playlist details with test cases and last run results.
- `history` shows run history for a playlist.

### Playlist Runs

```
toscactl playlists run start <name_or_id> [--private] [--param KEY=VALUE...] [--wait] [--assert-success] [--report FORMAT --report-path PATH]
toscactl playlists run view <run_id> [--assert-success]
```

- `--param` is repeatable for multiple parameter overrides.
- `--private` runs the playlist as a private execution.
- `--wait` blocks until the run completes, polling every 5 seconds and showing live progress.
- `--assert-success` on `run start` makes the command exit non-zero when the final state is not `succeeded`. Requires `--wait` (passing it alone is rejected). On `run view`, exits non-zero only when the state is `failed` or `canceled` (non-terminal states like `running`/`pending` still exit 0). Intended for CI pipelines.
- `--report FORMAT` writes a results report to disk after the run reaches a terminal state. Currently supports `junit` (JUnit XML). Requires `--report-path`. Implies `--wait`. The report is written **before** `--assert-success` is evaluated, so failing runs still produce a file.
- `--report-path PATH` sets the output file path for the report (required when `--report` is used).
- `run view` shows detailed results including per-test-case status.

### Agents

```
toscactl agents list [--state connected|disconnected] [--agent-state idle|executing] [--hosted] [--self-hosted] [--characteristic KEY=VALUE...] [--sort FIELD:DIR] [--page-size N] [--all]
toscactl agents view <id>
toscactl agents shutdown <id> [--on-idle]
toscactl agents delete <id> [--dangerously-skip-confirmation]
toscactl agents screenshot <id> [--open]
```

- `list` shows all agents (self-hosted and Tricentis-hosted). Use `--hosted` or `--self-hosted` to filter by type. `--characteristic` is repeatable for filtering by agent characteristics (e.g. `--characteristic os=Windows --characteristic browser=Chrome`).
- `view` shows detailed agent information including characteristics. For hosted agents, also shows initialization status.
- `shutdown` shuts down an agent. `--on-idle` waits until the agent finishes its current execution (self-hosted only).
- `delete` removes a self-hosted agent registration. Irreversible. Without `--dangerously-skip-confirmation`, it prompts the user to type the agent ID to confirm. Not available for hosted agents.
- `screenshot` retrieves the live view screenshot URL. `--open` opens the URL in the default browser. Works for both self-hosted and Tricentis-hosted agents.

### Executions

```
toscactl executions attachments --type test-steps|logs|junit --run <run_id> --test-case <name_or_builder_id>
```

- Fetches an attachment for a specific test case within a playlist run.
- `--type test-steps` shows the test step hierarchy in a table (name, action mode, state, value, duration).
- `--type logs` prints plain-text execution logs.
- `--type junit` prints the JUnit XML report.
- `--test-case` matches by builder ID first, then by name. If a name matches multiple test cases, use the builder ID.

### Datasets

```
toscactl datasets create <name> [--strategy circular|used-row]
toscactl datasets list [--page-size N] [--all]
toscactl datasets view <name_or_id> [--page-size N] [--all]
toscactl datasets import <file> [--timeout 300] [--no-wait]
toscactl datasets export <name_or_id> --format csv|excel|json [--output PATH] [--sort-column COL] [--direction asc|desc]
toscactl datasets add-column <name_or_id> --name <column> --type string|double|boolean|datetime
toscactl datasets add-row <name_or_id> --value COL=VAL [--value COL=VAL ...]
toscactl datasets delete-row <name_or_id> --row <row_id> [--dangerously-skip-confirmation]
toscactl datasets next-row <name_or_id> [--mark-as-used] [--subset <name_or_id>] [--json-flat] [--execution-run ID --unit-execution ID]
toscactl datasets list-subsets <name_or_id>
toscactl datasets view-subset <name_or_id> <subset_name_or_id> [--page-size N] [--all]
toscactl datasets use-row <name_or_id> --row <row_id> [--execution-run ID --unit-execution ID]
toscactl datasets reuse-row <name_or_id> --row <row_id> [--row <row_id> ...]
toscactl datasets lock <name_or_id>
toscactl datasets unlock <name_or_id>
toscactl datasets delete <name_or_id> [--dangerously-skip-confirmation]
```

- `<name_or_id>` accepts either a dataset name (case-insensitive) or ID.
- `create` makes an empty dataset. `--strategy` sets the data row consumption strategy.
- `import` uploads a CSV, Excel, or JSON file to Azure Blob Storage and creates a dataset. `--no-wait` returns the job ID immediately.
- `export` downloads the dataset in the specified format. Defaults output path to `dataset_<id>.<ext>`.
- `add-column` adds a column. Column types: `string`, `double`, `boolean`, `datetime`.
- `add-row` adds a row. `--value` is repeatable. Column names are resolved to IDs automatically and values are converted based on column data type.
- `next-row` fetches the next unused row. `--mark-as-used` consumes the row. `--subset` scopes to a subset by name or ID. `--json-flat` outputs column-name-keyed JSON (requires `--json`).
- `list-subsets` lists all subsets of a dataset.
- `view-subset` shows subset details (metadata, filter, creation/modification info) and the subset's data rows. `<subset_name_or_id>` accepts a subset name (case-insensitive) or ID.
- `use-row` marks a single row as consumed. `--execution-run` and `--unit-execution` must be provided together.
- `reuse-row` marks one or more rows as available for reuse. `--row` is repeatable.
- `delete` and `delete-row` are irreversible. Without `--dangerously-skip-confirmation`, they prompt for confirmation.
- `view` shows metadata and row contents with a status column (Used/empty) and row IDs.

### Interactive UI

```
toscactl ui
```

- Launches an interactive terminal UI with keyboard-driven navigation for browsing assets and playlists.

## JSON Piping

Any JSON object piped to stdin is parsed and its keys injected as CLI flags. Named keys become `--key value` flags; numeric keys (`"0"`, `"1"`, ...) become positional arguments. CLI-provided flags take precedence over piped JSON.

This allows chaining commands without `xargs` or shell variable assignment:

```bash
# View the latest run of a playlist
toscactl playlists history --page-size 1 --json --silent "My Playlist" \
  | jq '{"0": .[0].id}' \
  | toscactl playlists run view --json --silent

# Show test steps for a test case from the latest run
toscactl playlists history --page-size 1 --json --silent "My Playlist" \
  | jq '{"0": .[0].id}' \
  | toscactl playlists run view --json --silent \
  | jq '{ run: .id, "test-case": (.items[] | select(.name == "My Test Case") | .builderId) }' \
  | toscactl executions attachments --type test-steps
```

## Global Flags

| Flag | Effect |
|------|--------|
| `--json` | Output as JSON instead of table |
| `--silent` / `-s` | Suppress all output except results |
