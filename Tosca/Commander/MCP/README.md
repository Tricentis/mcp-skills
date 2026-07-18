# Commander MCP — install guide

Install **commander-mcp** skills from [Tricentis/mcp-skills](https://github.com/Tricentis/mcp-skills).

**Prerequisite:** Tosca Commander **26.1+** open with a workspace.

For **TCShell / TCAPI / Remote Control** when Commander is closed, use [Tosca.Commander.IDE.integration](https://github.com/Tricentis-Tosca/Tosca.Commander.IDE.integration).

## Quick start

1. Read `START-HERE.md` for install tiers.
2. Run `Install-CommanderMcpPack.ps1 -Ide Cursor` (skills and rules only).
3. Add **tosca-commander** in **Cursor → Settings → MCP** (`http://127.0.0.1:46248/mcp`).

## What you get

| Item | Purpose |
|------|---------|
| `commander-mcp` skill | Orchestration for Commander MCP tools (Code Mode or direct tool mode) |
| IDE rules / instructions | When to use checkout, save, DI workflows |

This export does **not** ship `mcp.json`. Configure MCP in your IDE.

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

## Tier 1: Manual folder copy

Copy from this directory (`Tosca/Commander/MCP/`) with File Explorer or an approved sync tool.

### Cursor (user scope)

| Copy from | To |
|-----------|-----|
| `cursor/skills/commander-mcp/` | `%USERPROFILE%\.cursor\skills\commander-mcp\` |
| `cursor/rules/commander-mcp.mdc` | `%USERPROFILE%\.cursor\rules\commander-mcp.mdc` |

Add MCP in **Cursor → Settings → MCP**:

```json
{
  "mcpServers": {
    "tosca-commander": {
      "url": "http://127.0.0.1:46248/mcp"
    }
  }
}
```

DEBUG Commander builds use port **8080**.

### Claude Code (user scope)

| Copy from | To |
|-----------|-----|
| `claude/skills/commander-mcp/` | `%USERPROFILE%\.claude\skills\commander-mcp\` |

Configure Commander MCP in Claude Code settings separately.

### Windsurf (user scope)

| Copy from | To |
|-----------|-----|
| `windsurf/skills/commander-mcp/` | `%USERPROFILE%\.codeium\windsurf\skills\commander-mcp\` |
| `windsurf/rules/commander-mcp.md` | `%USERPROFILE%\.codeium\windsurf\rules\commander-mcp.md` |

### VS Code + Copilot (project scope)

| Copy from | To (project root) |
|-----------|-------------------|
| `vscode/copilot-instructions.md.fragment` | `.github/copilot-instructions.md` (if missing) |
| `vscode/instructions/commander-mcp.instructions.md` | `.github/instructions/commander-mcp.instructions.md` |

### Project scope (team checkout)

| Copy from | To (project root) |
|-----------|-------------------|
| `cursor/skills/commander-mcp/` | `.cursor/skills/commander-mcp/` |
| `cursor/rules/commander-mcp.mdc` | `.cursor/rules/commander-mcp.mdc` |
| `windsurf/skills/commander-mcp/` | `.codeium/windsurf/skills/commander-mcp/` |
| `windsurf/rules/commander-mcp.md` | `.codeium/windsurf/rules/commander-mcp.md` |

Configure `.cursor/mcp.json` or IDE MCP settings for project scope as needed.

---

## Security and trust

| Control | What it means |
|---------|----------------|
| **SHA256** | Verify release zip against `SHA256SUMS` before extract (Tier 2–3). |
| **sourceSha** | `manifest.json` records the integration-repo commit used to build this tree. |
| **Localhost MCP only** | User-configured endpoint `http://127.0.0.1:46248/mcp` — no remote endpoints in this pack. |
| **No network in installer** | Install scripts copy local files only; they do not download or execute remote code. |
| **Optional verify** | `.\Install-CommanderMcpPack.ps1 -Ide Cursor -VerifyManifest` checks `manifest.json` before copy. |

See [SECURITY.md](SECURITY.md) for IT review checklist.

Pick **one** install method per profile (marketplace **or** zip/git) to avoid duplicate skills.

---

## Tier 2: IT-approved zip mirror

1. IT mirrors `commander-mcp-{version}-user.zip` from [GitHub Releases](https://github.com/Tricentis/mcp-skills/releases) to an internal portal.
2. Verify SHA256 when required.
3. Extract and follow **Tier 1** or **Tier 3**.

---

## Tier 3: Zip + installer script

1. Download `commander-mcp-{version}-user.zip` from [mcp-skills Releases](https://github.com/Tricentis/mcp-skills/releases).
2. Extract to a writable folder.
3. Run:

```bat
Install-CommanderMcpPack.bat -Ide Cursor
```

```powershell
.\Install-CommanderMcpPack.ps1 -Ide Cursor
```

Supported `-Ide` values: `Cursor`, `Claude`, `VSCode`, `Windsurf`.

**Project scope:**

```powershell
.\Install-CommanderMcpPack.ps1 -Ide Cursor -Scope Project -ProjectPath "C:\src\my-tosca-project"
```

VS Code requires project scope: `.\Install-CommanderMcpPack.ps1 -Ide VSCode -Scope Project`

---

## Tier 4: Git clone + install script

```powershell
git clone https://github.com/Tricentis/mcp-skills.git
cd mcp-skills/Tosca/Commander/MCP
.\Install-CommanderMcpPack.ps1 -Ide Cursor
```

---

## Tier 5: Team / private marketplace

When your organization publishes **commander-mcp** to a Cursor or Claude team marketplace:

1. Install the plugin from **Customize** (Cursor 3.8+) or your org Claude marketplace.
2. Enable **tosca-commander** MCP in IDE settings (`http://127.0.0.1:46248/mcp`).
3. Confirm `/commander-mcp` skill and rules are active.

---

## Tier 6: Public marketplace

When published to public Cursor or Claude marketplaces, install from **Customize** and enable MCP as in Tier 5. Do not also run the zip/git installer to the same profile paths.

---

## Invoke the skill

| IDE | Command |
|-----|---------|
| Cursor | `/commander-mcp` |
| Claude Code | `/commander-mcp` |
| Windsurf | `@commander-mcp` |
| VS Code Copilot | Reference skill content via project instructions |

## MCP vs skill

| Layer | Purpose |
|-------|---------|
| **MCP connection** | HTTP to Commander (`:46248`) — tool execution |
| **Skill + rules** | Code Mode vs direct tool mode; orchestration guidance |

Both are required for automation.

## Validate installation

1. Skill `/commander-mcp` appears in your IDE.
2. **tosca-commander** MCP is enabled (Cursor: Settings → MCP).
3. Commander is open with a workspace.
4. Run read-only test: `get_workspace_info`.

## Support

These skills are provided on an **open-source cadence** — outside Tricentis product support agreements, with no SLA or indemnification. Report issues via [GitHub Issues](https://github.com/Tricentis/mcp-skills/issues).

## License

Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0). See [repository LICENSE](../../../LICENSE).

## Source

Exported from `Tricentis-Tosca/Tosca.Commander.MCP.Integration`. See `manifest.json` for `sourceRepo`, `sourceSha`, and version.
