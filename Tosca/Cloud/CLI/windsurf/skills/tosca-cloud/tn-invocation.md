# TN invocation patterns

IDE agents delegate Tosca Cloud work to **`tn`** in the workspace terminal. TN handles MCP OAuth, tool dispatch, and model reasoning.

## REPL mode

```bash
tn
```

In session:

```text
/tosca
Analyze playlist "Smoke Tests" — why did the latest run fail?
```

Use when the user is present for tool approvals (write/edit, MCP calls).

## Piped single-shot

```bash
echo "/tosca then list workspaces and summarize artifact counts" | tn
```

Or prefix the prompt:

```bash
echo "Switch to /tosca mode. Search for playlist Smoke Tests and report latest run status." | tn
```

Use for one-shot tasks from IDE agents without opening a REPL.

## Loop mode (autonomous)

```bash
tn --loop "Activate /tosca. Find playlist Smoke Tests. Get recent runs. If latest failed, fetch failed steps, diagnose root cause, write findings to tosca-analysis.md, then call loop_complete."
```

- Default 25 iterations, 30-minute timeout
- Auto-approved MCP only (configure `alwaysAllow` in mcp.json for loop)
- Model calls `loop_complete` when done

Best for: multi-step diagnose + file write-back without IDE round-trips.

## Robot mode (long-running)

```bash
tn --robot tosca-playlist-watcher "Monitor playlist Smoke Tests every hour; yield when idle; resume on schedule."
```

```bash
tn --robots list
tn --robot --resume <runId>
```

Best for: scheduled monitoring, yield/resume across sessions.

## Skill loading inside tn

When `/tosca` is active, tn exposes `skill_tosca_*` tools (if shipped in tn Content). IDE journey skills in **this repo** are for the **outer IDE agent** routing to tn; inner tn may load its own skills via tool calls.

## Provider and auth

- AI provider: `~/.tn/appsettings.json` — run `tn --setup` once
- Tosca MCP OAuth: triggered on first `/tosca` tool use; browser opens automatically
- Never echo JWT tokens or API keys in IDE chat

## Verify success

After any invocation, confirm:

1. `/tosca` mode active (or prompt included `/tosca`)
2. `tosca_organization_listWorkspaces` equivalent succeeded
3. Task output matches expected artifact/run state
