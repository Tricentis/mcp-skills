---
name: tosca-delete-playlist
description: Delete a playlist in Tosca Cloud
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "<name_or_id>"
---

# Delete a Playlist

Delete a playlist in Tosca Cloud. This is a destructive, irreversible action.

Always use `--json --silent` on every `toscactl` command.

## Steps

1. **Parse arguments.** Extract from `$ARGUMENTS`:
   - Playlist name or ID (required)

2. **Look up the playlist** to confirm it exists and show the user what will be deleted.
   ```
   toscactl playlists view "<name_or_id>" --json --silent
   ```
   Parse the JSON response to extract the playlist name and ID. Show these details to the user.

3. **Confirm with the user.** Warn that this action is irreversible and ask for explicit confirmation before proceeding. Do NOT proceed without the user saying yes.

4. **Delete the playlist.**
   ```
   toscactl playlists delete "<name_or_id>" --dangerously-skip-confirmation --json --silent
   ```

5. **Report result.** Confirm the playlist was deleted.

## Error Handling

- If the playlist is not found, suggest searching for playlists with `/tosca-find`.
- If deletion fails with an authorization error, check auth with `toscactl config --json --silent` and suggest re-authenticating with `/tosca-setup`.
