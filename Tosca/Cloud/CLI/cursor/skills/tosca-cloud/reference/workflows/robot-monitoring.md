# Robot monitoring workflow

Use **`tn --robot`** for long-running, resumable Tosca Cloud monitoring — playlist watches, scheduled re-checks, yield on idle.

## When to use

- "Watch playlist X and notify when it fails"
- Scheduled regression monitoring across days
- Tasks that need `agent_yield` / resume across sessions

## Prerequisites

- Robot agent definition in `.tn/agents/<agent-id>/agent.md` with `mode: tosca`
- tn configured with `/tosca` MCP and AI provider

## Template

```bash
tn --robot tosca-playlist-watcher "Monitor playlist <name>. On failure, summarize failed steps and yield 1 hour. On pass, yield 24 hours. Complete when user says stop."
```

## Lifecycle commands

```bash
tn --robots list
tn --robots inspect <runId>
tn --robot --resume <runId>
tn --robots kill <runId>
```

## vs loop mode

| Concern | `--loop` | `--robot` |
|---------|----------|-----------|
| Duration | Minutes (≤30 default) | Days (yield TTL 7d default) |
| Persistence | Ephemeral | `.tn/agent-runs/` state |
| Resume | No | Yes via `--resume` |
| Best for | One-shot autonomous task | Ongoing monitoring |

## Hand off

- One-shot diagnose → `tosca-analyzing-execution-results` journey skill with piped/loop
- Interactive fix → `tosca-remediating-from-results` in REPL
