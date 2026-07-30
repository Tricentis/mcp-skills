# Tosca Cloud MCP — Cursor plugin

Install **skills and rules** for hosted Tosca Cloud MCP. Does not configure MCP servers.

## Quick install

```powershell
# From consumer export root (Windows)
.\Install-ToscaCloudMcpPack.ps1 -Ide Cursor
```

Then in Cursor: **Settings → MCP → Add server** with your tenant URL:

`https://{tenant}.my.tricentis.com/{space}/_mcp/api/mcp`

Reload Cursor → sign in when prompted → `/tosca-cloud-connect`.

## What installs

| Artifact | Purpose |
|----------|---------|
| `skills/tosca-*` | Connect, basics, engineering, journey skills |
| `rules/tosca-cloud-mcp.mdc` | Route agents to correct skill |

MCP connection is configured by the user in IDE settings (same as marketplace plugin).

See [README.md](../../README.md) and [START-HERE.md](../../START-HERE.md).
