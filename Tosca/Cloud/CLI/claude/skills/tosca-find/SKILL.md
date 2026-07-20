---
name: tosca-find
description: Search for assets or playlists in Tosca Cloud
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "<query> [--type TYPE]"
---

# Find Assets or Playlists

Search for test assets or playlists in the current Tosca workspace.

Always use `--json --silent` on every `toscactl` command.

## Routing

Parse `$ARGUMENTS` to determine the search target:

- If the user mentions **"playlist"** or includes `--type Playlist`, use:
  ```
  toscactl playlists find --json --silent --name <query> --results --page-size 50
  ```
  Always include `--results` so the last run state is visible.

- Otherwise, search assets:
  ```
  toscactl assets find --json --silent --name <query> [--type TYPE] [--tag TAG...] --page-size 50
  ```
  If the user specifies a type, pass it with `--type`. Valid types: TestCase, Module, SharedAction, Playlist, ApiAction, ApiMessage, Folder, TestCaseTemplate.
  If the user mentions tags, pass each tag with `--tag` (repeatable, AND logic).

## Presentation

- Report the total count of results found.
- List each result showing: name, type, ID, and (for playlists) last run state.
- Use `--page-size 50` by default (matches CLI default). Only use `--all` if the user explicitly asks for all results.

## No Results

If zero results are returned:
- Suggest broadening the search (e.g., shorter or partial name).
- Suggest checking the active workspace with `toscactl config --json --silent`.
