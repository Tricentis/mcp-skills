---
name: tosca-delete-workspace
description: Delete a workspace in Tosca Cloud
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "<name_or_id>"
---

# Delete a Workspace

Delete a workspace in Tosca Cloud. This is a destructive, irreversible action.

Always use `--json --silent` on every `toscactl` command.

## Steps

1. **Parse arguments.** Extract from `$ARGUMENTS`:
   - Workspace name or ID (required)

2. **Look up the workspace** to confirm it exists and show the user what will be deleted.
   ```
   toscactl workspaces view "<name_or_id>" --json --silent
   ```
   Parse the JSON response to extract the workspace name and ID. Show these details to the user.

3. **Confirm with the user.** Warn that this action is irreversible and ask for explicit confirmation before proceeding. Do NOT proceed without the user saying yes.

4. **Delete the workspace.**
   ```
   toscactl workspaces delete "<name_or_id>" --dangerously-skip-confirmation --json --silent
   ```

5. **Report result.** Confirm the workspace was deleted. If it was the active workspace, suggest selecting a new one with `toscactl workspaces set`.

## Error Handling

- If the workspace is not found, suggest listing workspaces with `/tosca-find`.
- If deletion fails with an authorization error, check auth with `toscactl config --json --silent` and suggest re-authenticating with `/tosca-setup`.
