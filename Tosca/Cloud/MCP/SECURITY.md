# Security — Tosca Cloud MCP pack

IT and security review checklist for the Tosca Cloud MCP integration (`tosca-cloud-mcp`). This pack adds **agent skills, rules, and MCP client configuration** for connecting to the **hosted** Tosca Cloud MCP endpoint — not a local MCP server binary.

## Summary

| Property | Value |
|----------|--------|
| **Publisher** | Tricentis — [Tricentis-Tosca/Tosca.Cloud.MCP.integration](https://github.com/Tricentis-Tosca/Tosca.Cloud.MCP.integration) |
| **Install scope** | User profile (default) or project checkout — **no admin** for the IDE pack |
| **Runtime network** | **Yes** — MCP client connects to `https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp` via OAuth (Okta) |
| **Secrets** | OAuth tokens managed by the IDE MCP client (`mcp-remote`); pack does not ship credentials |
| **Integrity** | Release zip published with `SHA256SUMS` on GitHub Releases |

## What ships where

| Artifact | Contents | Scripts? |
|----------|----------|----------|
| **Release zip** (`tosca-cloud-mcp-{version}-user.zip`) | Cursor skills, rules, install scripts, MCP config helper | Yes (user-run) |
| **Cursor plugin** | Skills + rules + commands | **No** standalone scripts in plugin tree |
| **mcp-skills export** | Same consumer tree under `Tosca/Cloud/MCP/cursor/` | Install scripts at export root |

**Plugin vs zip:** Marketplace plugins install skills and rules. For `configure_mcp_connection.py` and full installer, use the release zip or mcp-skills export.

## Hosted MCP endpoint

```text
https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp
```

- Authentication: Okta bearer token via browser OAuth on first connect
- No customer-hosted MCPServer required
- Tenant and space are user-supplied install parameters

## Files the installer may write (user scope)

| Path | Purpose |
|------|---------|
| `%USERPROFILE%\.cursor\skills\tosca-*\` | Cursor skills (9 bundled) |
| `%USERPROFILE%\.cursor\rules\tosca-cloud-mcp.mdc` | Cursor rule (`alwaysApply: false`) |
| `%USERPROFILE%\.cursor\mcp.json` | Merged MCP server entry for `tosca-cloud` |

The installer **does not** modify `%ProgramFiles%`, registry, or Windows services.

## Script behavior

| Script | Reads | Writes | Network |
|--------|-------|--------|---------|
| `Install-ToscaCloudMcpPack.ps1` | Pack source | Profile skill/rule paths, optional `mcp.json` | No (local files only) |
| `configure_mcp_connection.py` | CLI args | `~/.cursor/mcp.json` or project MCP config | No at install time |
| `pack_release.py` | Repo sources | `dist/*.zip`, `SHA256SUMS` | No |

MCP **runtime** network calls occur when the IDE connects to the hosted endpoint — governed by IDE MCP policy and customer firewall rules.

## Integrity verification

1. Download `tosca-cloud-mcp-{version}-user.zip` and `SHA256SUMS` from GitHub Releases.
2. Verify hash (PowerShell):

```powershell
Get-FileHash -Path .\tosca-cloud-mcp-1.0.0-user.zip -Algorithm SHA256
# Compare to SHA256SUMS
```

3. Mirror verified artifacts internally before wide distribution.

## Agent permissions

Skills are Markdown instructions. They do not sandbox the IDE agent — when active, the agent may invoke MCP tools and terminal commands per IDE policy. Rules use `alwaysApply: false` (opt-in routing).

## Reporting issues

Report security concerns via your Tricentis support channel or a private GitHub Security Advisory on the repository.

## Related docs

- [docs/START-HERE.md](docs/START-HERE.md) — install decision tree
- [docs/installation.md](docs/installation.md) — full install guide
