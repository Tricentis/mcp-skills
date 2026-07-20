---
name: tosca-agents
description: List, view, shut down, or delete execution agents in Tosca Cloud
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "[list|view|shutdown|delete|screenshot] [options]"
---

# Manage Execution Agents

Manage Elastic Execution Grid (E2G) agents, both self-hosted and Tricentis-hosted.

Always use `--json --silent` on every `toscactl` command.

## Routing

Parse `$ARGUMENTS` to determine the intent:

- **List agents** (default if no subcommand or user says "list", "show", "agents"):
  ```
  toscactl agents list --json --silent [--state connected|disconnected] [--agent-state idle|executing] [--hosted] [--self-hosted] [--characteristic KEY=VALUE] [--page-size 50]
  ```

- **View agent details** — if the user provides an agent ID:
  ```
  toscactl agents view <id> --json --silent
  ```

- **Shut down an agent** — if the user says "shutdown", "stop", or "shut down":
  ```
  toscactl agents shutdown <id> --json --silent [--on-idle]
  ```
  `--on-idle` is only valid for self-hosted agents. Confirm with the user before proceeding.

- **Delete an agent** — if the user says "delete" or "remove":
  ```
  toscactl agents delete <id> --dangerously-skip-confirmation --json --silent
  ```
  Only works for self-hosted agents. Warn the user this is irreversible and ask for explicit confirmation before proceeding.

- **Screenshot** — if the user says "screenshot", "live view", or "liveview":
  ```
  toscactl agents screenshot <id> --json --silent
  ```
  Returns the last screenshot URL and capture timestamp.

## Presentation

- **List:** Show agent count. For each agent, display: ID, connection state, agent state, type (hosted/self-hosted), last update, and authorized by.
- **View:** Show all agent details including characteristics.
- **Shutdown/Delete:** Confirm the action was initiated.
- **Screenshot:** Show the screenshot URL and capture timestamp. Offer to open it.

## Filtering Tips

- `--state connected` — show only connected agents
- `--agent-state idle` — show only idle agents ready for execution
- `--hosted` / `--self-hosted` — filter by agent type
- `--characteristic os=Windows` — filter by characteristic (repeatable)

## Error Handling

- If the agent is not found, suggest listing agents first.
- If delete is attempted on a hosted agent, explain it's only available for self-hosted agents.
- If commands fail with auth errors, check auth with `toscactl config --json --silent` and suggest re-authenticating with `/tosca-setup`.
