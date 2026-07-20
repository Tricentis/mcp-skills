---
name: tosca-create-playlist
description: Create a new playlist in Tosca Cloud
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "<name> [--test-case NAME_OR_ID...] [--run-mode MODE] [--description TEXT]"
---

# Create a Playlist

Create a new playlist in Tosca Cloud, optionally pre-populated with test cases.

Always use `--json --silent` on every `toscactl` command.

## Steps

1. **Parse arguments.** Extract from `$ARGUMENTS`:
   - Playlist name (required)
   - `--test-case NAME_OR_ID` (optional, repeatable) — each value can be a test case name or UUID
   - `--run-mode parallel|sequential|sequentialOnSameAgent` (optional, defaults to `sequential`)
   - `--description TEXT` (optional)
   - `--characteristic KEY=VALUE` (optional, repeatable) — agent matching characteristics
   - `--cron-schedule EXPR` (optional)
   - `--keep-recordings-on-success` flag (optional)

2. **If the user wants to add test cases by name but doesn't know exact names**, search first:
   ```
   toscactl assets find --type testCase --name "<search term>" [--tag TAG...] --json --silent
   ```
   If the user wants to filter by tags, pass each tag with `--tag` (repeatable, AND logic).
   Present the results and let the user pick which test cases to include.

3. **Create the playlist.**
   ```
   toscactl playlists create "<name>" --json --silent [--description "<text>"] [--test-case "<name_or_id>"...] [--run-mode <mode>] [--characteristic KEY=VALUE...] [--cron-schedule "<expr>"] [--keep-recordings-on-success]
   ```
   Parse the JSON response to extract the playlist ID and name.

4. **Report result.** Show the created playlist name, ID, run mode, and number of test cases included.

5. **Offer next steps.** Suggest:
   - Run the playlist: `/tosca-run "<playlist name>"`
   - View the playlist: `toscactl playlists view "<playlist name>"`

## Error Handling

- If a test case name is ambiguous (multiple matches), the command fails with an error. Suggest the user use the test case UUID instead, or search with `/tosca-find` to find the correct ID.
- If a test case name is not found, suggest checking the name with `/tosca-find`.
- If creation fails with an authorization error, check auth with `toscactl config --json --silent` and suggest re-authenticating with `/tosca-setup`.
- Playlist names must be 1-140 characters. Descriptions must be at most 300 characters.
