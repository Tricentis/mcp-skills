# Security — Tosca Cloud MCP pack

IT and security review checklist for the Tosca Cloud MCP integration (`tosca-cloud-mcp`). This pack adds **agent skills and rules** for use with the **hosted** Tosca Cloud MCP endpoint. Users configure the MCP server in their IDE — this pack does not ship connection automation.

## Summary

| Property | Value |
|----------|--------|
| **Publisher** | Tricentis — [Tricentis-Tosca/Tosca.Cloud.MCP.integration](https://github.com/Tricentis-Tosca/Tosca.Cloud.MCP.integration) |
| **Install scope** | User profile (default) or project checkout — **no admin** for the IDE pack |
| **Runtime network** | **Yes** — MCP client connects to `https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp` via OAuth (Okta) |
| **Secrets** | OAuth tokens managed by the IDE MCP client; pack does not ship credentials or write `mcp.json` |
| **Integrity** | Release zip published with `SHA256SUMS` on GitHub Releases |

## What ships where

| Artifact | Contents | Scripts? |
|----------|----------|----------|
| **Release zip** (`tosca-cloud-mcp-{version}-user.zip`) | Cursor skills, rules, skills installer | Yes (user-run) |
| **Cursor plugin** | Skills + rules + commands | **No** standalone scripts in plugin tree |
| **mcp-skills export** | Same consumer tree under `Tosca/Cloud/MCP/cursor/` | Install script at export root |

**Plugin vs zip:** Both install skills and rules. Zip/git adds `Install-ToscaCloudMcpPack.ps1`. MCP connection is always configured by the user in IDE settings.

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

The installer **does not** modify `%ProgramFiles%`, registry, Windows services, or `mcp.json`.

## Script behavior

| Script | Reads | Writes | Network |
|--------|-------|--------|---------|
| `Install-ToscaCloudMcpPack.ps1` | Pack source | Profile skill/rule paths | No (local files only) |
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

## PowerShell execution policy

Install scripts are **Authenticode-signed** by Tricentis. Default install does **not** use `-ExecutionPolicy Bypass`; scripts honor the machine policy (`AllSigned`, `RemoteSigned`, etc.) when the Tricentis publisher is trusted.

```powershell
.\Install-ToscaCloudMcpPack.ps1
```

**Fallback** (unsigned dev checkout, or publisher not in your trust store — only with security team approval):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-ToscaCloudMcpPack.ps1
```

## Agent permissions

Skills are Markdown instructions. They do not sandbox the IDE agent — when active, the agent may invoke MCP tools and terminal commands per IDE policy. Rules use `alwaysApply: false` (opt-in routing).

## Reporting issues

Report security concerns via your Tricentis support channel or a private GitHub Security Advisory on the repository.

## Related docs

- [docs/START-HERE.md](docs/START-HERE.md) — install decision tree
- [docs/installation.md](docs/installation.md) — full install guide
