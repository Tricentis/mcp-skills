# tosca-cloud-mcp — consumer install

Install Tosca Cloud MCP skills from [Tricentis/mcp-skills](https://github.com/Tricentis/mcp-skills).

## Quick start

1. Open the `cursor/` folder for Cursor plugin or zip install.
2. Read `START-HERE.md` for install tiers.
3. Run `Install-ToscaCloudMcpPack.ps1 -Ide Cursor` (skills only).
4. Add your tenant MCP server in **Cursor → Settings → MCP**.

## Version and releases

Pack version is in [`manifest.json`](manifest.json) (currently **1.0.0**). Install from [GitHub Releases](https://github.com/Tricentis/mcp-skills/releases) tag `tosca/cloud/mcp/{version}`; verify with `SHA256SUMS` in this folder.

For security review, see [`SECURITY.md`](SECURITY.md).
