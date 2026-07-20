---
name: tosca-execution
description: View test steps, logs, or JUnit results for a test case execution
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "<playlist> <test-case> [test-steps|logs|junit]"
---

# View Execution Attachments

Fetch and display test steps, logs, or JUnit results for a specific test case from a playlist run.

Always use `--json --silent` on every `toscactl` command, except for getting logs or junit results since they are plain text where apply only `--silent` flag.

## Steps

1. **Parse arguments.** Extract from `$ARGUMENTS`:
   - Playlist name or ID (required)
   - Test case name or builder ID (required)
   - Attachment type: `test-steps`, `logs`, or `junit` (default: `test-steps`)

2. **Get the latest run ID.**
   ```
   toscactl playlists history --page-size 1 --json --silent "<playlist>"
   ```
   Extract `.id` from the first element of the returned array. If the array is empty, report that no runs exist for the playlist.

3. **Get the run details and find the test case builder ID.**
   ```
   toscactl playlists run view <run_id> --json --silent
   ```
   Search `items` (recursively through any folder items) for the entry where `.name` matches the test case argument. Extract its `.builderId`. If not found, report which test cases are available in the run.

4. **Fetch the attachment.**
   ```
   toscactl executions attachments --type <type> --run <run_id> --test-case <builder_id> --json --silent
   ```

5. **Present results.**

   - **test-steps:** Render the step list as a table showing name (with indentation for nested steps), action mode, state, value, and duration. Highlight failed steps.
   - **logs:** Display the raw log text. Highlight errors or warnings if present.
   - **junit:** Summarise the JUnit report: total tests, passed, failed, skipped. List failing test cases with their error messages.

## Error Handling

- If the playlist is not found, suggest using `/tosca-find` to search for it.
- If the test case is not found in the run, list the available test case names from the run.
- If the attachment does not exist (e.g. the test case did not execute), report that the attachment is unavailable and suggest checking the run state with `/tosca-status`.
- If any command fails with an auth error, check with `toscactl config --json --silent` and suggest re-authenticating with `/tosca-setup`.
