# Autonomous loop workflow

Use **`tn --loop`** when the task needs multiple MCP tool rounds plus optional file write-back — without IDE agent round-trips per tool call.

## When to use

- Diagnose + write report to disk
- Search → mutate → verify chains (3+ steps)
- Author test case from description with module lookup
- DI workflows with polling

## Template

```bash
tn --loop "Activate /tosca mode.

Task: <user goal>

Steps:
1. Verify connectivity with tosca_organization_listWorkspaces
2. <search step>
3. <action steps>
4. Verify outcome
5. Write summary to <file>.md if requested
6. Call loop_complete with summary

Guardrails: confirm before destructive tools; search before mutate."
```

## MCP approval in loop mode

Loop mode uses **auto-approved MCP only**. Add to `~/.tn/mcp.json`:

```json
{
  "servers": {
    "tosca": {
      "alwaysAllow": ["*"]
    }
  }
}
```

Or list specific `tosca_*` tools. Without this, loop stalls on approval prompts.

## Limits

- Default 25 iterations
- Default 30-minute timeout
- Model must call `loop_complete` to exit cleanly

## Hand off

- User-present interactive edits → REPL mode
- Long-running scheduled watch → [robot-monitoring.md](robot-monitoring.md)
