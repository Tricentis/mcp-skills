# Tosca Cloud MCP — Cursor plugin (demo layout)

Install skills, rules, and MCP connection helper for **direct** hosted Cloud MCP.

## Quick install

```powershell
# From repo root (Windows)
.\scripts\Install-ToscaCloudMcpPack.ps1 -Ide Cursor

# Configure tenant (all platforms)
python3 scripts/configure_mcp_connection.py --output ~/.cursor/mcp.json
```

Reload Cursor → **Settings → MCP** → enable **tosca-cloud** → `/tosca-cloud-connect` or chat "connect Tosca Cloud MCP".

## What installs

| Artifact | Purpose |
|----------|---------|
| `skills/tosca-*` | Connect, basics, engineering, journey skills |
| `rules/tosca-cloud-mcp.mdc` | Route agents to correct skill |
| `mcp.json` | Merged via `configure_mcp_connection.py` (not the template alone) |

Production MCP URL: `https://{tenant}.my.tricentis.com/{space}/_mcp/api/mcp`

See [docs/installation.md](../../docs/installation.md).
