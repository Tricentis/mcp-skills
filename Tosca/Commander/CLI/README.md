# CLI & API Commander — install guide

Install **cli-api-commander** skills in your IDE **without admin rights**. All methods install the same content (skills, rules, and optional helper scripts) — pick what your organization allows.

**Prerequisite:** Tosca Commander installed for runtime automation. Headless TCShell via `cmd` is the minimum path — no Python or PowerShell required.

For **in-process MCP** when Commander is open, use [Tosca/Commander/MCP](https://github.com/Tricentis/mcp-skills/tree/main/Tosca/Commander/MCP) in [Tricentis/mcp-skills](https://github.com/Tricentis/mcp-skills).

## What you get

| Item | Purpose |
|------|---------|
| `cli-api-commander` skill | TCShell, TCAPI, and Remote Control orchestration |
| IDE rules / instructions | Path detection, checkout, batch mode |
| Helper scripts (zip/git) | `Get-CommanderAutomationPaths`, TCAPI, Remote Control clients |

**Plugins (Tier 5–6)** ship **skills and rules only** — no helper scripts. Use zip/git for path detectors, or headless TCShell via `cmd`.

## Quick start

See [START-HERE.md](START-HERE.md) for IDE + tier decision tree.

## Choose your install tier

| Tier | When | Mechanism |
|------|------|-----------|
| **1** | Scripts blocked | [Manual folder copy](#tier-1-manual-folder-copy) |
| **2** | Internal zip mirror only | [IT-approved zip](#tier-2-it-approved-zip-mirror) |
| **3** | PowerShell or batch allowed | [Zip + installer script](#tier-3-zip--installer-script) |
| **4** | Git clone allowed | [Git clone + install script](#tier-4-git-clone--install-script) |
| **5** | Enterprise IDE plugins | [Team marketplace](#tier-5-team--private-marketplace) |
| **6** | Public marketplace | [Public marketplace](#tier-6-public-marketplace) |

Pick **one** tier and **one** scope (user or project). Do not install via plugin and zip/git to the same profile paths.

---

## Security and trust

| Control | What it means |
|---------|----------------|
| **SHA256** | Verify release zip against `SHA256SUMS` before extract (Tier 2–3). |
| **sourceSha** | `manifest.json` records the integration-repo commit used to build this tree. |
| **No network in installer** | Install scripts copy local files only. |
| **Local automation only** | No MCP server; shell/stdio against installed Commander. |

Details: [SECURITY.md](SECURITY.md).

---

## Tier 1: Manual folder copy

Copy from this directory (`Tosca/Commander/CLI/`) with File Explorer or an approved sync tool.

### Cursor (user scope)

| Copy from | To |
|-----------|-----|
| `cursor/skills/cli-api-commander/` | `%USERPROFILE%\.cursor\skills\cli-api-commander\` |
| `cursor/rules/cli-api-commander.mdc` | `%USERPROFILE%\.cursor\rules\cli-api-commander.mdc` |

### Claude Code (user scope)

| Copy from | To |
|-----------|-----|
| `claude/skills/cli-api-commander/` | `%USERPROFILE%\.claude\skills\cli-api-commander\` |

### Windsurf (user scope)

| Copy from | To |
|-----------|-----|
| `windsurf/skills/cli-api-commander/` | `%USERPROFILE%\.codeium\windsurf\skills\cli-api-commander\` |
| `windsurf/rules/cli-api-commander.md` | `%USERPROFILE%\.codeium\windsurf\rules\cli-api-commander.md` |

### VS Code + Copilot (project scope)

| Copy from | To (project root) |
|-----------|-------------------|
| `vscode/copilot-instructions.md.fragment` | `.github/copilot-instructions.md` (if missing) |
| `vscode/instructions/cli-api-commander.instructions.md` | `.github/instructions/cli-api-commander.instructions.md` |

---

## Tier 2: IT-approved zip mirror

1. IT mirrors `cli-api-commander-IDE-{version}-user.zip` from [mcp-skills Releases](https://github.com/Tricentis/mcp-skills/releases).
2. Verify SHA256 when required.
3. Extract and follow **Tier 1** or **Tier 3**.

---

## Tier 3: Zip + installer script

1. Download `cli-api-commander-IDE-{version}-user.zip` from [mcp-skills Releases](https://github.com/Tricentis/mcp-skills/releases).
2. Extract to a writable folder.
3. Run:

```bat
Install-CliApiCommanderPack.bat -Ide Cursor
```

```powershell
.\Install-CliApiCommanderPack.ps1 -Ide Cursor
```

Supported `-Ide` values: `Cursor`, `Claude`, `VSCode`, `Windsurf`.

**Project scope:**

```powershell
.\Install-CliApiCommanderPack.ps1 -Ide Cursor -Scope Project -ProjectPath "C:\src\my-tosca-project"
```

---

## Tier 4: Git clone + install script

```powershell
git clone https://github.com/Tricentis/mcp-skills.git
cd mcp-skills/Tosca/Commander/CLI
.\Install-CliApiCommanderPack.ps1 -Ide Cursor
```

---

## Tier 5: Team / private marketplace

Install **cli-api-commander** from your org Cursor or Claude team marketplace (**Customize**). Skills and rules only — add zip scripts separately if IT allows.

Do not also run the zip/git installer to the same profile paths.

---

## Tier 6: Public marketplace

Install from public Cursor or Claude marketplace. Do not duplicate with zip/git on the same profile.

---

## Invoke the skill

| IDE | Command |
|-----|---------|
| Cursor | `/cli-api-commander` |
| Claude Code | `cli-api-commander` skill |
| Windsurf | `@cli-api-commander` |
| VS Code Copilot | Project instructions + terminal |

## Support

Open-source cadence — outside Tricentis product support agreements. Report issues via [GitHub Issues](https://github.com/Tricentis/mcp-skills/issues).

## License

Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0). See [repository LICENSE](../../../LICENSE).
