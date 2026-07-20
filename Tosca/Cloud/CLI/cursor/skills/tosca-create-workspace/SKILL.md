---
name: tosca-create-workspace
description: Create a new workspace in Tosca Cloud
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "<name> [--description TEXT] [--access-type public|private]"
---

# Create a Workspace

Create a new workspace in Tosca Cloud.

Always use `--json --silent` on every `toscactl` command.

## Steps

1. **Parse arguments.** Extract from `$ARGUMENTS`:
   - Workspace name (required)
   - `--description TEXT` (optional)
   - `--access-type public|private` (optional, defaults to server default)
   - `--import-examples` flag (optional)
   - `--asset-library` flag (optional)

2. **Create the workspace.**
   ```
   toscactl workspaces create "<name>" --json --silent [--description "<text>"] [--access-type public|private] [--import-examples] [--asset-library]
   ```
   Parse the JSON response to extract the workspace ID and name.

3. **Report result.** Show the created workspace name, ID, access type, and description.

4. **Offer to activate.** Ask the user if they want to set the new workspace as active. If yes, run:
   ```
   toscactl workspaces set "<name>" --json --silent
   ```

## Error Handling

- If creation fails with a "name already exists" error, suggest choosing a different name or listing existing workspaces with `/tosca-find`.
- If creation fails with an authorization error, check auth with `toscactl config --json --silent` and suggest re-authenticating with `/tosca-setup`.
- Workspace names must be 1-64 characters and cannot contain: `/ \ : . ~ & % ; @ ' " ? < > | # $ * } { , + = [ ]`
