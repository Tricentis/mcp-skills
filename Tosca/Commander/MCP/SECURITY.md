# Security — Commander MCP pack

IT and security review checklist for the Tosca Commander MCP integration (`commander-mcp`). This pack adds **agent skills and rules** for use with the **local** Commander MCP HTTP endpoint. Users configure the MCP server in their IDE — this pack does not ship connection automation or write `mcp.json`.

## Summary

| Property | Value |
|----------|--------|
| **Publisher** | Tricentis — [mcp-skills](https://github.com/Tricentis/mcp-skills) (Commander MCP pack) |
| **Install scope** | User profile (default) or project checkout — **no admin** for the IDE pack |
| **Runtime network** | **Localhost only** — MCP client connects to `http://127.0.0.1:<port>/mcp` (default port **46248**; DEBUG often **8080**). Use the port from **Commander MCP configuration**. |
| **Secrets** | No credentials shipped; Commander workspace auth is handled by the local MCP server |
| **Integrity** | Release zip published with `SHA256SUMS` on GitHub Releases |

## What ships where

| Artifact | Contents | Scripts? |
|----------|----------|----------|
| **Release zip** (`commander-mcp-{version}-user.zip`) | Cursor/Claude/Windsurf skills, rules, VS Code instructions, skills installer | Yes (user-run) |
| **Cursor plugin** | Skills + rules (+ plugin `mcp.json` for marketplace auto-discovery) | **No** standalone scripts in plugin tree |
| **mcp-skills export** | Skills-only consumer tree under `Tosca/Commander/MCP/` | Install script at export root |

**Plugin vs zip/git:** Marketplace plugins may bundle MCP config for Cursor auto-discovery. Zip/git export installs **skills and rules only** — MCP connection is configured by the user in IDE settings.

## Local MCP endpoint

```text
http://127.0.0.1:<port>/mcp
```

Replace `<port>` with the MCP port from Commander settings (default **46248**; DEBUG often **8080**).

- Transport: HTTP to Commander's embedded MCP server
- Requires Tosca Commander **26.1+** open with a workspace
- No remote/cloud MCP endpoint in this pack

## Files the installer may write (user scope)

| Path | Purpose |
|------|---------|
| `%USERPROFILE%\.cursor\skills\commander-mcp\` | Cursor skill |
| `%USERPROFILE%\.cursor\rules\commander-mcp.mdc` | Cursor rule (`alwaysApply: false`) |
| `%USERPROFILE%\.claude\skills\commander-mcp\` | Claude skill |
| `%USERPROFILE%\.codeium\windsurf\skills\commander-mcp\` | Windsurf skill |
| `%USERPROFILE%\.codeium\windsurf\rules\commander-mcp.md` | Windsurf rule |

The installer **does not** modify `%ProgramFiles%`, registry, Windows services, or `mcp.json`.

## Script behavior

| Script | Reads | Writes | Network |
|--------|-------|--------|---------|
| `Install-CommanderMcpPack.ps1` | Pack source | Profile skill/rule paths | No (local files only) |

MCP **runtime** calls occur when the IDE connects to localhost Commander — governed by IDE MCP policy and local firewall rules.

## Integrity verification

1. Download `commander-mcp-{version}-user.zip` and `SHA256SUMS` from GitHub Releases.
2. Verify hash (PowerShell):

```powershell
Get-FileHash -Path .\commander-mcp-1.0.0-user.zip -Algorithm SHA256
# Compare to SHA256SUMS
```

3. Extract the zip only after hash verification succeeds.

## PowerShell execution policy

Install scripts are **Authenticode-signed** by Tricentis. Default install does **not** use `-ExecutionPolicy Bypass`; scripts honor the machine policy (`AllSigned`, `RemoteSigned`, etc.) when the Tricentis publisher is trusted.

```powershell
.\Install-CommanderMcpPack.ps1
# or double-click Install-CommanderMcpPack.bat
```

**Fallback** (unsigned dev checkout, or publisher not in your trust store — only with security team approval):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CommanderMcpPack.ps1
```

## Agent permissions

Skills are Markdown instructions. They do not sandbox the IDE agent — when active, the agent may invoke MCP tools and terminal commands per IDE policy. Rules use `alwaysApply: false` (opt-in routing).

## Reporting issues

Report security concerns via your Tricentis support channel or a private GitHub Security Advisory on the repository.

## Related docs

- [START-HERE.md](START-HERE.md) — install decision tree
- [README.md](README.md) — full install guide
