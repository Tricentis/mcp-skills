# Security — Commander CLI pack

IT review checklist for the Commander CLI & API pack (`cli-api-commander`). Adds **agent skills and optional local helper scripts** — not a background service, MCP server, or network endpoint.

## Summary

| Property | Value |
|----------|--------|
| **Publisher** | Tricentis — [mcp-skills](https://github.com/Tricentis/mcp-skills) (Commander CLI pack) |
| **Install scope** | User profile (default) or project checkout — **no admin** for the IDE pack |
| **Runtime network** | **None** from the pack itself; automation runs local shell against installed Commander |
| **Secrets** | Skill instructs agents to use env vars for `-auth`; pack does not ship credentials |
| **Integrity** | Release zip published with `SHA256SUMS` on GitHub Releases |

## What ships where

| Artifact | Contents | Scripts? |
|----------|----------|----------|
| **Release zip** (`cli-api-commander-IDE-{version}-user.zip`) | Skills, rules, install scripts, path detectors, TCAPI helpers | Yes (optional, user-run) |
| **Cursor / Claude plugin** | Skills + rules only | **No** |
| **VS Code pack** | Copilot instructions (project scope) | No |

**Plugin vs zip:** Marketplace plugins install skills only. For `Get-CommanderAutomationPaths.ps1` / `.py`, use the release zip (Tier 2–3) or Commander `TCShell/AI/` bundle. Headless TCShell via `cmd` works without zip scripts.

## Files the installer may write (user scope)

| Path | Purpose |
|------|---------|
| `%USERPROFILE%\.cursor\skills\cli-api-commander\` | Cursor skill |
| `%USERPROFILE%\.cursor\rules\cli-api-commander.mdc` | Cursor rule (`alwaysApply: false`) |
| `%USERPROFILE%\.claude\skills\cli-api-commander\` | Claude skill |
| `%USERPROFILE%\.codeium\windsurf\skills\cli-api-commander\` | Windsurf skill |
| `%USERPROFILE%\.codeium\windsurf\rules\cli-api-commander.md` | Windsurf rule |
| `%USERPROFILE%\.tricentis\tcshell-ide.env` | Optional Commander path hints (no secrets) |

The installer **does not** modify `%ProgramFiles%`, registry, Windows services, or MCP configuration.

## Legacy skill cleanup

Installers remove the retired skill id `tcshell-commander` from the same profile paths when present (rename from 0.3.0). This prevents duplicate or conflicting skills after upgrade.

## Script behavior (zip / git only)

| Script | Reads | Writes | Network |
|--------|-------|--------|---------|
| `Install-CliApiCommanderPack.ps1` | Pack source | Profile skill/rule paths | No |
| `Get-CommanderAutomationPaths.ps1` / `.py` | Commander install dirs, workspace path | Stdout only | No |
| `Invoke-TcApi.ps1`, `Get-TcApiRuntime.ps1` | Commander DLLs, workspace | Stdout / local IPC | No |
| `TcShellRemoteControl.ps1` | Commander Remote Control IPC | GUI automation (user-attended) | No |

Doc URL strings in scripts point to Tricentis DevCorner for human-readable API reference — **no automatic HTTP calls** at runtime.

## Integrity verification

1. Download `cli-api-commander-IDE-{version}-user.zip` and `SHA256SUMS` from [GitHub Releases](https://github.com/Tricentis/mcp-skills/releases) tag `tosca/commander/cli/{version}`.
2. Verify hash (PowerShell):

```powershell
Get-FileHash -Path .\cli-api-commander-IDE-1.0.0-user.zip -Algorithm SHA256
# Compare to SHA256SUMS
```

3. Extract the zip only after hash verification succeeds.

**Code signing:** Release `.ps1` / `.bat` installers and `lib/*.ps1` helpers are **Authenticode-signed** by Tricentis. Verify with `Get-AuthenticodeSignature` and compare file hashes to `SHA256SUMS`.

## PowerShell execution policy

Default install does **not** use `-ExecutionPolicy Bypass`; scripts honor the machine policy (`AllSigned`, `RemoteSigned`, etc.) when the Tricentis publisher is trusted.

```powershell
.\Install-CliApiCommanderPack.ps1
# or double-click Install-CliApiCommanderPack.bat
```

Runtime helpers (`Get-TcApiRuntime.ps1`, `TcShellRemoteControl.ps1`, etc.) spawn child PowerShell with `-File` only — no Bypass.

**Fallback** (unsigned dev checkout, or publisher not in your trust store — only with security team approval):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-CliApiCommanderPack.ps1
```

## Agent permissions

Skills are Markdown instructions. They do not sandbox the IDE agent — when active, the agent may invoke terminal tools per IDE policy. Rules use `alwaysApply: false` (opt-in routing).

## Reporting issues

Report security concerns via a private [GitHub Security Advisory](https://github.com/Tricentis/mcp-skills/security/advisories) on this repository.

## Related docs

- [START-HERE.md](START-HERE.md) — install tier decision tree
- [README.md](README.md) — full install guide
