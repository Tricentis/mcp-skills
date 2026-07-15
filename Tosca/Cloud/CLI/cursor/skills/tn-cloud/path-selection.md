# Path selection — TN Cloud

Always run detection before invoking `tn`. **Neither Python nor PowerShell is required** for headless piped mode.

## Step 1 — Run detection

```bash
python3 Get-TnCloudPaths.py
```

If **neither** script runs, use the manual checklist below.

## Step 2 — Read detection output

| Field | Use |
|-------|-----|
| `TnAvailable` | `tn` found on PATH |
| `TnVersion` | Installed version string |
| `ConfigPath` | `~/.tn/mcp.json` and `~/.tn/appsettings.json` |
| `ToscaMcpConfigured` | `tosca` server entry present in mcp.json |
| `ToscaMcpUrl` | Resolved tenant MCP endpoint |
| `ProviderConfigured` | AI provider in appsettings |
| `Paths[]` | `Repl`, `Piped`, `Loop`, `Robot` — each with `Available` |
| `Selection` | Recommended path; `UserPromptRequired` when ambiguous |

Exit codes: `0` = clear recommendation · `1` = tn not found · `2` = **ask the user**.

## Step 3 — Manual checklist (no scripts)

1. `tn --version` or `dotnet run --project <tn-repo>/src/Tricentis.AI.Tn -- --version`
2. `~/.tn/mcp.json` contains `tosca` server with tenant URL
3. `~/.tn/appsettings.json` has active AI provider (or run `tn --setup`)
4. Test: `echo "/tosca" | tn` — should switch mode without error

## Step 4 — Pick execution path

| Condition | Path |
|-----------|------|
| Interactive, user present | **Repl** — `tn` then `/tosca` |
| Single prompt, no approval needed | **Piped** — `echo "..." \| tn` |
| Multi-step, write report to disk | **Loop** — `tn --loop "..."` |
| Monitor / schedule / resume later | **Robot** — `tn --robot <id> "..."` |

## Step 5 — Configure if missing

```bash
python3 configure_tn_connection.py --tenant <tenant> --output ~/.tn/mcp.json
tn --setup
```

See journey skill **`tn-cloud-connect`** for full setup.
