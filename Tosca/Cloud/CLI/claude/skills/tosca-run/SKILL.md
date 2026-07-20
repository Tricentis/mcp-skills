---
name: tosca-run
description: Run a Tosca playlist and wait for results
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "<playlist> [--param KEY=VALUE...] [--wait] [--assert-success] [--report junit --report-path PATH]"
---

# Run a Playlist

Start a Tosca playlist execution and optionally poll until completion.

Always use `--json --silent` on every `toscactl` command.

## Steps

1. **Parse arguments.** Extract from `$ARGUMENTS`:
   - Playlist name or ID (required)
   - `--param KEY=VALUE` pairs (optional, repeatable)
   - `--private` flag (optional)
   - `--wait` flag (optional — block until the run completes)
   - `--assert-success` flag (optional — exit non-zero if the run does not succeed; requires `--wait`)
   - `--report FORMAT --report-path PATH` (optional — write a results report to disk after the run; `junit` is the only supported format; implies `--wait`; report is written before `--assert-success` so failing runs still produce the file)

2. **Start the run.**
   ```
   toscactl playlists run start <name_or_id> --json --silent [--private] [--param KEY=VALUE...] [--wait] [--assert-success]
   ```
   Extract the run ID from the JSON response.

3. **Poll for completion** (if `--wait` was specified):
   - The `--wait` flag makes `toscactl` poll automatically every **5 seconds** and print live progress until a terminal state is reached. No manual polling loop needed.
   - If `--wait` was **not** specified, poll manually:
     - Run `toscactl playlists run view <run_id> --json --silent`
     - Check the `state` field in the response.
     - **Terminal states:** Succeeded, Failed, Cancelled, Error — stop polling.
     - **Non-terminal states:** Running, Pending, Queued — continue polling.
     - Poll every **5 seconds**.
     - Report progress between polls (e.g., "Run is still Running, checking again in 5s...").

4. **Report results.**
   - Show: run ID, final state, duration.
   - Show pass/fail counts for test cases.
   - If the run failed, list the failing test case names and their states.

## Error Handling

- If the playlist is not found, suggest using `/tosca-find` to search for it first.
- If the run fails to start, check auth with `toscactl config --json --silent`.
- If using `--wait`, the CLI polls indefinitely until a terminal state. If manual polling seems stuck, report the last known state and provide the run ID so the user can check later with `/tosca-status`.
- Use `--assert-success` in CI pipelines to fail the build on a failed run. The flag only takes effect with `--wait` (the CLI errors if `--assert-success` is passed alone). Exits 0 on `succeeded`, non-zero otherwise.
