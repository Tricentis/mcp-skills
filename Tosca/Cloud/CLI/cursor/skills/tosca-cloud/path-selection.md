# Path selection — hybrid runtime

Run detection before first automation.

## Step 1 — Run detection

```bash
python3 verify_toscactl.py
python3 Get-TnCloudPaths.py
```

## Step 2 — Default path (toscactl)

| Field | Use |
|-------|-----|
| `ToscactlAvailable` | `toscactl` on PATH |
| `LoggedIn` | tenant URL in config |
| `WorkspaceName` | active workspace |
| `Ready` | both available |

If `Ready`: use **toscactl** for connect, search, run, diagnose, history, agents, datasets.

Load [toscactl-invocation.md](toscactl-invocation.md).

## Step 3 — Gap path (tn)

Required when [runtime-routing.md](runtime-routing.md) sends you to tn (Builder, DI, author, remediate mutations, loop, robot).

| Field | Use |
|-------|-----|
| `TnAvailable` | `tn` on PATH |
| `ToscaMcpConfigured` | `~/.tn/mcp.json` |
| `ProviderConfigured` | `tn --setup` done |
| `Paths[]` | Repl, Piped, Loop, Robot |

Configure if missing:

```bash
python3 configure_tn_connection.py --tenant <tenant> --output ~/.tn/mcp.json
tn --setup
```

Load [tn-invocation.md](tn-invocation.md).

## Step 4 — Pick execution path

| Intent | Runtime | Pattern |
|--------|---------|---------|
| Connect, search, run, diagnose | **toscactl** | shell commands + JSON piping |
| Builder / DI / multi-step gap batch | **tn** | piped, REPL, `--loop`, `--robot` |

See journey skill **`tosca-cloud-connect`** for full setup.
