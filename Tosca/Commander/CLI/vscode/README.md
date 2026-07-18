# VS Code + GitHub Copilot pack

Project-scope install for Copilot Chat and agent instructions. User-global Copilot paths vary by setup; use **project scope** for reproducible teams.

## Install

From the release zip root:

```powershell
.\Install-CliApiCommanderPack.ps1 -Ide VSCode -Scope Project -ProjectPath "C:\path\to\repo"
```

Or from the consumer export root (`Tosca/Commander/CLI`):

```powershell
.\Install-CliApiCommanderPack.ps1 -Ide VSCode -Scope Project
```

## Artifacts

| File | Purpose |
|------|---------|
| `.github/copilot-instructions.md` | Copilot-specific TCShell / Remote Control guidance |
| `.github/instructions/cli-api-commander.instructions.md` | Glob-scoped rules for `*.tcs` scripts |
| `AGENTS.md` (project root) | Cross-agent pointer (created if missing) |

Copy `settings.json.example` into your workspace or user settings to enable `AGENTS.md` and Copilot instruction files.

## Skills

When VS Code Agent Skills are enabled, copy the Claude/Cursor skill folder to `.github/skills/cli-api-commander/` manually or extend the install script for your org.
