# tosca-cloud-mcp — consumer install

Install Tosca Cloud MCP skills from [Tricentis/mcp-skills](https://github.com/Tricentis/mcp-skills).

## Quick start

1. Read `START-HERE.md` for install tiers.
2. Run the installer for your IDE:
   - Cursor: `Install-ToscaCloudMcpPack.ps1 -Ide Cursor` (skills + rules from `cursor/`)
   - Claude Code: `Install-ToscaCloudMcpPack.ps1 -Ide Claude` (skills from `claude/`)
   - GitHub Copilot: `Install-ToscaCloudMcpPack.ps1 -Ide Copilot` (skills from `copilot/` → `~/.copilot/skills`)
3. Add your tenant MCP server in the host (IDE Settings → MCP, or Copilot CLI `copilot mcp add`).

URL: `https://{tenant}.my.tricentis.com/{space}/_mcp/api/mcp`

## Source

Exported from `Tricentis-Tosca/Tosca.Cloud.MCP.integration`. See `manifest.json` for `sourceRepo`, `sourceSha`, and version.
