# START HERE — TN Cloud CLI pack (consumer)

Install **9 skills** for automating Tosca Cloud via the **TN CLI** (`tn`, `/tosca`, `--loop`, `--robot`).

## 1. Pick install tier

| Tier | When | Action |
|------|------|--------|
| **1** | Manual / air-gapped | Copy skill folders from `cursor/skills/` (or claude/windsurf) to your IDE user skills path |
| **2** | Zip download | Verify SHA256 → extract → Tier 1 or Tier 3 |
| **3** | Script install | `Install-TnCloudPack.ps1 -Ide Cursor -Tenant <tenant>` |
| **4** | Git | Clone mcp-skills `Tosca/Cloud/CLI` → Tier 3 |
| **5–6** | Marketplace | Cursor / Claude plugin when published (see `cursor/.cursor-plugin/`) |

## 2. Prerequisites

- `tn` on PATH
- Python 3 (for `configure_tn_connection.py` and `Get-TnCloudPaths.py`)
- Tosca Cloud tenant

## 3. Configure tn

```powershell
.\Install-TnCloudPack.ps1 -Ide Cursor -Tenant <tenant> -Space default
```

Or config only:

```bash
python3 configure_tn_connection.py --tenant <tenant> --output ~/.tn/mcp.json
tn --setup
```

## 4. Verify

```bash
echo "/tosca then list workspaces" | tn
python3 Get-TnCloudPaths.py
```

## 5. Pick IDE

| IDE | User skills path |
|-----|------------------|
| Cursor | `~/.cursor/skills/` |
| Claude | `~/.claude/skills/` |
| Windsurf | `~/.codeium/windsurf/skills/` |
| VS Code | Project `.github/copilot-instructions.md` (fragment in `vscode/`) |

## 6. First task

| I want to… | Skill |
|------------|-------|
| Fix setup / 401 | `tn-cloud-connect` |
| Why did my run fail? | `tn-analyzing-execution-results` |
| Run playlist autonomously | `tn-cloud` → loop-autonomous |
| Explain a test case | `tn-explaining-testcase` |

See `AGENTS.md.fragment` for full journey routing.

## 7. TN vs direct IDE MCP

| Use this pack (TN CLI) | Use Tosca.Cloud.MCP.integration |
|------------------------|----------------------------------|
| Native OAuth via tn | IDE direct MCP OAuth |
| `--loop` / `--robot` | One MCP tool per IDE turn |

Install **one** Cloud automation path per IDE profile — not both.

## 8. Security

See `SECURITY.md`. Installer copies local files only; OAuth runs when **you** invoke `tn`.

## Source

Exported from [Tricentis-Tosca/Tosca.Cloud.IDE.integration](https://github.com/Tricentis-Tosca/Tosca.Cloud.IDE.integration). Version and `sourceSha` in `manifest.json`.
