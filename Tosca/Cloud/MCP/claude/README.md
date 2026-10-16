# Tosca Cloud MCP — Claude Code plugin

Install **skills** for hosted Tosca Cloud MCP. Does not configure MCP servers.

## Quick install

```powershell
# From consumer export root (Windows)
.\Install-ToscaCloudMcpPack.ps1 -Ide Claude
```

Then configure your tenant MCP server in Claude Code settings:

`https://{tenant}.my.tricentis.com/{space}/_mcp/api/mcp`

Reload → sign in when prompted → `/tosca-cloud-connect`.

## What installs

| Artifact | Purpose |
|----------|---------|
| `skills/tosca-*` | Connect, basics, engineering, journey skills |

MCP connection is configured by the user in IDE settings (same as marketplace plugin).

See [docs/installation.md](../../docs/installation.md).
