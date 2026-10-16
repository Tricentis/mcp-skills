# Tosca Cloud MCP — GitHub Copilot skills

Install **skills** for hosted Tosca Cloud MCP. Does not configure MCP servers.

The same `~/.copilot/skills` tree is discovered by **GitHub Copilot CLI** and **VS Code Copilot Chat** (agent skills). Project install uses `.github/skills`.

## Quick install

```powershell
# From consumer export root (Windows)
.\Install-ToscaCloudMcpPack.ps1 -Ide Copilot
```

User scope writes to `%USERPROFILE%\.copilot\skills\` (or `$env:COPILOT_HOME\skills` when set).

Project scope:

```powershell
.\Install-ToscaCloudMcpPack.ps1 -Ide Copilot -Scope Project -ProjectPath "C:\path\to\project"
```

That copies skills to `<project>\.github\skills\`.

## Connect MCP (user action)

This pack does **not** write `mcp-config.json` or `.vscode/mcp.json`. Copilot CLI and VS Code use different MCP file schemas.

### Copilot CLI

```powershell
copilot mcp add --transport http tosca-cloud "https://{tenant}.my.tricentis.com/{space}/_mcp/api/mcp"
copilot
```

If the server shows `needs-auth`, run `/mcp auth tosca-cloud`. Confirm skills with `copilot skill list` or `/skills info tosca-cloud-connect`.

### VS Code Copilot Chat

Command Palette → **MCP: Add Server** (HTTP) with the same tenant URL. Reload the window and complete Okta sign-in. Skills under `~/.copilot/skills` are personal; workspace skills live in `.github/skills`.

Then `/tosca-cloud-connect`.

## What installs

| Artifact | Purpose |
|----------|---------|
| `skills/tosca-*` | Connect, basics, engineering, journey skills |

See [docs/installation.md](../../docs/installation.md).
