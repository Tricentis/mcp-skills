# START HERE — Tosca Cloud CLI pack (consumer)

Install **24 skills** for automating Tosca Cloud via **toscactl** (default) and **tn** (CLI gaps).

Install **toscactl** per your Tricentis distribution (must be on PATH).

## 1. Pick install tier

| Tier | When | Action |
|------|------|--------|
| **1** | Manual | Copy skill folders from `cursor/skills/` to IDE user skills path |
| **2** | Zip | Verify SHA256 → extract → Tier 1 or 3 |
| **3** | Script | `Install-ToscaCloudPack.ps1 -Ide Cursor -Tenant <tenant>` |
| **4** | Git | Clone mcp-skills `Tosca/Cloud/CLI` → Tier 3 |

## 2. Prerequisites

- `toscactl` on PATH
- Python 3 (for `verify_toscactl.py`, `Get-TnCloudPaths.py`, `configure_tn_connection.py`)
- Tosca Cloud tenant

## 3. Configure toscactl (default)

```bash
toscactl login --url <tenant>.my.tricentis.com
toscactl workspaces set "My Workspace"
python3 verify_toscactl.py
```

Or script install:

```powershell
.\Install-ToscaCloudPack.ps1 -Ide Cursor -Tenant <tenant>
```

## 4. Configure tn (gap workflows only)

Required for Builder author/remediate, DI, loop, robot:

```bash
python3 configure_tn_connection.py --tenant <tenant> --output ~/.tn/mcp.json
tn --setup
```

## 5. Verify

```bash
toscactl config --json --silent
python3 Get-TnCloudPaths.py
```

## 6. Read first

Load **`tosca-cloud-basics`** then the journey skill for your task. See `AGENTS.md.fragment` in the install root.

Gap routing: [`runtime-routing.md`](cursor/skills/tosca-cloud/runtime-routing.md) in the `tosca-cloud` skill (also under `claude/` and `windsurf/` for your IDE).
