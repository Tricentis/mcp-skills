# Windsurf (Cascade) pack

Skills and rules for Windsurf Cascade agent automation of Tosca Commander.

## Install

User scope (default, no admin):

```powershell
.\Install-CliApiCommanderPack.ps1 -Ide Windsurf
```

Project scope:

```powershell
.\Install-CliApiCommanderPack.ps1 -Ide Windsurf -Scope Project
```

## Paths

| Scope | Skills | Rules |
|-------|--------|-------|
| User | `%USERPROFILE%\.codeium\windsurf\skills\cli-api-commander\` | `%USERPROFILE%\.codeium\windsurf\rules\` |
| Project | `.windsurf/skills/cli-api-commander/` | `.windsurf/rules/` |

Invoke with `@cli-api-commander` in Cascade.
