# Security — cli-api-commander IDE pack

IT and security review checklist for the Tosca Commander IDE integration (`cli-api-commander`). This pack adds **agent skills and optional local helper scripts** — not a background service, MCP server, or network endpoint.

## Summary

| Property | Value |
|----------|--------|
| **Publisher** | Tricentis — [Tricentis-Tosca/Tosca.Commander.IDE.integration](https://github.com/Tricentis-Tosca/Tosca.Commander.IDE.integration) |
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
| **Commander MSI bundle** (optional, separate) | Read-only reference under `%COMMANDER_HOME%\TCShell\AI\` | No |

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
| `pack_release.ps1` | Repo sources | `dist/*.zip`, `SHA256SUMS` | No |

Doc URL strings in scripts point to Tricentis DevCorner for human-readable API reference — **no automatic HTTP calls** at runtime.

## Integrity verification

1. Download `cli-api-commander-IDE-{version}-user.zip` and `SHA256SUMS` from [Releases](https://github.com/Tricentis-Tosca/Tosca.Commander.IDE.integration/releases).
2. Verify hash (PowerShell):

```powershell
Get-FileHash -Path .\cli-api-commander-IDE-1.0.0-user.zip -Algorithm SHA256
# Compare to SHA256SUMS
```

3. Mirror verified artifacts internally (Tier 2) before wide distribution.

**Code signing:** Releases are SHA256-checksummed only. Organizations requiring Authenticode or minisign may re-sign mirrored zips under their own certificate policy.

## Agent permissions

Skills are Markdown instructions. They do not sandbox the IDE agent — when active, the agent may invoke terminal tools per IDE policy. Rules use `alwaysApply: false` (opt-in routing).

## Reporting issues

Report security concerns via your Tricentis support channel or a private GitHub Security Advisory on the repository (organization members).

## Related docs

- [docs/START-HERE.md](docs/START-HERE.md) — install tier decision tree
- [docs/installation.md](docs/installation.md) — full install guide
- [docs/marketplace-submission.md](docs/marketplace-submission.md) — plugin submission checklist
