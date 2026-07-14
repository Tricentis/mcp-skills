# Commander MCP — install guide

Install **commander-mcp** skills in your IDE **without admin rights**. All methods install the same content (skills, rules, and Cursor MCP config) — pick what your organization allows.

**Prerequisite:** Tosca Commander **26.1+** open with a workspace, and your IDE connected to the Commander MCP server (default port **46248**).

For **TCShell / TCAPI / Remote Control** when Commander is closed, use [Tosca.Commander.IDE.integration](https://github.com/Tricentis-Tosca/Tosca.Commander.IDE.integration).

## What you get

| Item | Purpose |
|------|---------|
| `commander-mcp` skill | Orchestration for Commander MCP tools (Code Mode or direct tool mode) |
| IDE rules / instructions | When to use checkout, save, DI workflows |
| `cursor/mcp.json` | Cursor MCP server entry for `tosca-commander` |

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

> **Maintainers:** Skill authoring, build, and export scripts live in the internal source repo ([Tosca.Commander.MCP.Integration `scripts/`](https://github.com/Tricentis-Tosca/Tosca.Commander.MCP.Integration/tree/main/scripts)). This directory ships **install scripts only**.

---

## Tier 1: Manual folder copy

Copy from this directory (`Tosca/Commander/MCP/`) with File Explorer or an approved sync tool.

### Cursor (user scope)

| Copy from | To |
|-----------|-----|
| `cursor/skills/commander-mcp/` | `%USERPROFILE%\.cursor\skills\commander-mcp\` |
| `cursor/rules/commander-mcp.mdc` | `%USERPROFILE%\.cursor\rules\commander-mcp.mdc` |
| `cursor/mcp.json` | Merge into `%USERPROFILE%\.cursor\mcp.json` |

Merge `mcp.json` — add the `tosca-commander` entry if the file already exists:

```json
{
  "mcpServers": {
    "tosca-commander": {
      "url": "http://127.0.0.1:46248/mcp"
    }
  }
}
```

Or add the server in **Cursor → Customize → MCP** (Cursor 3.8+).

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
| `cursor/mcp.json` | `.cursor/mcp.json` (merge if exists) |
| `windsurf/skills/commander-mcp/` | `.codeium/windsurf/skills/commander-mcp/` |
| `windsurf/rules/commander-mcp.md` | `.codeium/windsurf/rules/commander-mcp.md` |

---

## Security and trust

| Control | What it means |
|---------|----------------|
| **SHA256** | Verify release zip against `SHA256SUMS` before extract (Tier 2–3). |
| **sourceSha** | `manifest.json` records the integration-repo commit used to build this tree. |
| **Localhost MCP only** | Pack `mcp.json` points to `http://127.0.0.1:46248/mcp` — no remote endpoints. |
| **No network in installer** | Install scripts copy local files only; they do not download or execute remote code. |
| **Optional verify** | `.\Install-CommanderMcpPack.ps1 -Ide Cursor -VerifyManifest` checks `manifest.json` before copy. |

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

Optional manifest check before copy:

```powershell
.\Install-CommanderMcpPack.ps1 -Ide Cursor -VerifyManifest
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

Also available for Claude, Windsurf, and VS Code (project scope).

---

## Tier 5: Team / private marketplace

When your organization publishes **commander-mcp** to a Cursor or Claude team marketplace:

1. Install the plugin from **Customize** (Cursor 3.8+) or your org Claude marketplace.
2. Enable **tosca-commander** MCP (`http://127.0.0.1:46248/mcp`).
3. Confirm `/commander-mcp` skill and rules are active.

DEBUG Commander builds use port **8080** — add a second MCP entry if needed.

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

## MCP client setup

| Setting | Value |
|---------|-------|
| Transport | HTTP |
| Server name | `tosca-commander` |
| URL | `http://127.0.0.1:46248/mcp` |
| DEBUG builds | Port **8080** |

Verify with MCP tool `get_workspace_info` after Commander opens a workspace.

## Validate installation

1. Skill `/commander-mcp` appears in your IDE.
2. **tosca-commander** MCP is enabled (Cursor: Customize → MCP).
3. Commander is open with a workspace.
4. Run read-only test: `get_workspace_info`.

## Support

These skills are provided on an **open-source cadence** — outside Tricentis product support agreements, with no SLA or indemnification. Report issues via [GitHub Issues](https://github.com/Tricentis/mcp-skills/issues).

## License

Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0). See [repository LICENSE](../../../LICENSE).
