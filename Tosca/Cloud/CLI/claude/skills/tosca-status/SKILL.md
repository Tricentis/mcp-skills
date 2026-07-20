---
name: tosca-status
description: View playlist details, run results, or run history in Tosca Cloud
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "<playlist-or-run-id> [history]"
---

# View Playlist or Run Status

View details about a playlist, a specific run, or run history.

Always use `--json --silent` on every `toscactl` command.

## Routing

Parse `$ARGUMENTS` to determine the intent:

- **Run details** — if the user says "run" and provides what looks like a run ID:
  ```
  toscactl playlists run view <run_id> --json --silent
  ```

- **Run history** — if the user says "history":
  ```
  toscactl playlists history <name_or_id> --json --silent --page-size 10
  ```

- **Playlist details** (default):
  ```
  toscactl playlists view <name_or_id> --json --silent
  ```

## Presentation

- **Playlist view:** Show name, ID, number of test cases. List each test case with its last execution state.
- **Run view:** Show run ID, state, triggered by, duration. List per-test-case results with pass/fail status.
- **History:** Show recent runs with date, state, and duration. Highlight failed runs.

## Follow-up

If the user asks about a specific run from the history output, use `toscactl playlists run view <run_id> --json --silent` to drill down into that run's details.
