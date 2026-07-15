# TN Cloud IDE pack — consumer install

Automate **Tosca Cloud** via the **TN CLI** (`tn`): `/tosca` mode, native MCP OAuth, **`--loop`** (multi-step autonomy), and **`--robot`** (long-running tasks). This pack ships **9 agent skills**, IDE rules, and helper scripts — not the tn binary itself.

## What you get

| Component | Purpose |
|-----------|---------|
| **9 skills** | `tn-cloud` (engineering) + 8 journey skills (connect, basics, analyze, author, remediate, explain) |
| **IDE rules** | Cursor / Windsurf always-on routing to tn |
| **`configure_tn_connection.py`** | Write `~/.tn/mcp.json` for your tenant |
| **`Get-TnCloudPaths.py`** | Detect tn, config, and recommended execution path |
| **`Install-TnCloudPack.ps1`** | Copy skills + optional tn config (local files only) |

### Skills

| Skill | Purpose |
|-------|---------|
| `tn-cloud` | Orchestration, loop, robot, DI, all MCP workflows |
| `tn-cloud-connect` | Tenant setup, OAuth, fix 401 |
| `tn-cloud-basics` | Cloud object model |
| `tn-analyzing-execution-results` | Diagnose **latest** run (read-only) |
| `tn-analyzing-execution-history` | Trends / flakiness over time |
| `tn-remediating-from-results` | Apply fixes from failures |
| `tn-authoring-manual-testcase` | Written manual test → Cloud testcase |
| `tn-authoring-automated-testcase` | Description → automated testcase |
| `tn-explaining-testcase` | Explain what a testcase does |

See `AGENTS.md.fragment` for journey routing.

## Prerequisites

1. **tn** CLI on PATH — build from [Tricentis-UX/tn](https://github.com/Tricentis-UX/tn) or your internal distribution
2. Tosca Cloud tenant with MCP entitlement
3. Python 3 (for helper scripts)
4. PowerShell 5+ (Tier 3 installer on Windows; macOS/Linux via `pwsh`)

## Quick start (Tier 3)

```powershell
.\Install-TnCloudPack.ps1 -Ide Cursor -Tenant <tenant> -Space default -VerifyManifest
tn --setup
```

```bash
echo "/tosca then list workspaces" | tn
```

---

## Install tiers

### Tier 1 — Manual copy

No scripts. Copy skill folders from the IDE pack subfolder to your user profile.

**Cursor**

| Copy from | To |
|-----------|-----|
| `cursor/skills/tn-*` | `%USERPROFILE%\.cursor\skills\` (macOS/Linux: `~/.cursor/skills/`) |
| `cursor/rules/tn-cloud.mdc` | `%USERPROFILE%\.cursor\rules\` |

**Claude Code**

| Copy from | To |
|-----------|-----|
| `claude/skills/tn-*` | `~/.claude/skills/` |

**Windsurf**

| Copy from | To |
|-----------|-----|
| `windsurf/skills/tn-*` | `~/.codeium/windsurf/skills/` |
| `windsurf/rules/tn-cloud.md` | `~/.codeium/windsurf/rules/` |

Then configure tn:

```bash
python3 configure_tn_connection.py --tenant <tenant> --output ~/.tn/mcp.json
tn --setup
```

### Tier 2 — Zip + integrity verify

1. Download `tn-cloud-IDE-{version}-user.zip` and `SHA256SUMS` from GitHub Releases
2. Verify hash matches
3. Extract and proceed with **Tier 1** or **Tier 3**

Release artifacts include `manifest.json` with `sourceSha` for supply-chain audit.

### Tier 3 — Installer script (recommended)

From extracted zip or git checkout of this folder:

```powershell
.\Install-TnCloudPack.ps1 -Ide Cursor -Tenant <tenant> -Space default
# or
.\Install-TnCloudPack.bat -Ide Cursor -Tenant <tenant>
```

| Parameter | Description |
|-----------|-------------|
| `-Ide` | `Cursor`, `Claude`, `VSCode`, `Windsurf` |
| `-Scope` | `User` (default) or `Project` |
| `-Tenant` | Tosca Cloud tenant name |
| `-SkipTnConfig` | Skills only; skip `configure_tn_connection.py` |
| `-VerifyManifest` | Assert `manifest.json` package name/version |

Then:

```bash
tn --setup
echo "/tosca then list workspaces" | tn
```

### Tier 4 — Git clone (mcp-skills)

```bash
git clone https://github.com/Tricentis/mcp-skills.git
cd mcp-skills/Tosca/Cloud/CLI
# checkout tag tosca/cloud/cli/1.0.0 when released
.\Install-TnCloudPack.ps1 -Ide Cursor -Tenant <tenant>
tn --setup
```

Or sparse checkout of `Tosca/Cloud/CLI` only (see [mcp-skills README](https://github.com/Tricentis/mcp-skills)).

### Tier 5 — Cursor marketplace plugin

When published: install **tn-cloud** plugin from Cursor marketplace. Plugin ships skills + rules only. For `configure_tn_connection.py` and path detection, also use Tier 2/3 zip **or** copy scripts from this tree.

**Do not** install marketplace plugin and run Tier 3 to the same profile — pick one delivery path per IDE.

### Tier 6 — Claude Code plugin

When published: install from Claude plugin directory (`claude/.claude-plugin/plugin.json`). Same mutual-exclusion note as Tier 5.

---

## VS Code + Copilot

This pack does not install a VS Code extension. For Copilot:

1. Run `Install-TnCloudPack.ps1 -Ide VSCode -Scope Project` in your repo, **or**
2. Merge `vscode/copilot-instructions.md.fragment` into `.github/copilot-instructions.md`
3. Copy `AGENTS.md.fragment` to project `AGENTS.md` if desired
4. Use terminal + `tn` for Cloud automation

---

## Path detection

```bash
python3 Get-TnCloudPaths.py
```

Use before first automation session. See skill `tn-cloud` → `path-selection.md` after install.

---

## TN CLI vs direct IDE MCP

| Concern | TN CLI (this pack) | Tosca.Cloud.MCP.integration |
|---------|-------------------|----------------------------|
| OAuth | Native in tn | mcp-remote + npx |
| Tool surface | `/tosca` in tn REPL | IDE MCP panel |
| Multi-step | `tn --loop` | One tool per IDE turn |
| Long-running | `tn --robot` | Not supported |
| File write-back | tn tools | IDE-native tools |

Install **one** Cloud automation stack per IDE profile.

---

## Security

- Installer performs **local file copies only** — no network at install time
- Release zip signed by SHA256 on GitHub Releases; `manifest.json` records `sourceRepo` and `sourceSha`
- OAuth and Cloud API calls occur when **you** run `tn` — tokens live in `~/.tn/`
- See `SECURITY.md` for full IT review checklist

---

## Troubleshooting

| Symptom | Action |
|---------|--------|
| 401 / auth errors | Skill `tn-cloud-connect`; re-run `tn --setup` |
| tn not found | Install tn; re-run `Get-TnCloudPaths.py` |
| Skills not loading | Reload IDE; confirm skills path from Tier 1 table |

---

## Source

Maintained in [Tricentis-Tosca/Tosca.Cloud.IDE.integration](https://github.com/Tricentis-Tosca/Tosca.Cloud.IDE.integration).

Distributed via [Tricentis/mcp-skills](https://github.com/Tricentis/mcp-skills) at **`Tosca/Cloud/CLI`**.

Package: **`tn-cloud-IDE`** · Release tag: **`tosca/cloud/cli/1.0.0`**

See `manifest.json` in this folder for version, `sourceSha`, and sync timestamp.
