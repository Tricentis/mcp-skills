# Security — Tosca Cloud CLI pack (maintainer)

IT review checklist for **Tosca.Cloud.IDE.integration** (`tosca-cloud-IDE`). Adds agent skills and optional helper scripts — not a background service.

## Summary

| Property | Value |
|----------|--------|
| **Publisher** | Tricentis — [Tosca.Cloud.IDE.integration](https://github.com/Tricentis-Tosca/Tosca.Cloud.IDE.integration) |
| **Install scope** | User profile or project — **no admin** |
| **Runtime network** | tn CLI contacts Tosca Cloud MCP + configured AI provider |
| **Secrets** | OAuth tokens and API keys in `~/.tn/` — pack does not ship credentials |
| **Integrity** | Release zip with `SHA256SUMS` on GitHub Releases |

## What ships

| Artifact | Scripts? |
|----------|----------|
| Release zip | Yes — install, configure, path detection |
| Cursor / Claude plugin | Skills + rules only |

## Files installer may write

| Path | Purpose |
|------|---------|
| `~/.cursor/skills/tosca-*/` | Cursor skills |
| `~/.tn/mcp.json` | Tosca MCP server config for tn |
| `~/.claude/skills/tosca-*/` | Claude skills |

Installer does **not** modify system directories or IDE MCP config (unlike Tosca.Cloud.MCP.integration).

## Script behavior

| Script | Network |
|--------|---------|
| `Install-ToscaCloudPack.ps1` | No (local copy) |
| `configure_tn_connection.py` | No (writes local JSON) |
| `Get-TnCloudPaths.py` | No |
| `tn` (user-run) | Yes — Tosca Cloud + AI provider |

## PowerShell execution policy

Install scripts are **Authenticode-signed** by Tricentis. Default install does **not** use `-ExecutionPolicy Bypass`; scripts honor the machine policy (`AllSigned`, `RemoteSigned`, etc.) when the Tricentis publisher is trusted.

```powershell
.\Install-ToscaCloudPack.ps1
# or double-click Install-ToscaCloudPack.bat
```

**Fallback** (unsigned dev checkout, or publisher not in your trust store — only with security team approval):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-ToscaCloudPack.ps1
```

## TN runtime security

- Tool approvals in REPL for write/edit and non-auto-approved MCP
- Loop mode uses auto-approved MCP only — document in skill
- Never commit `~/.tn/appsettings.json` with secrets
