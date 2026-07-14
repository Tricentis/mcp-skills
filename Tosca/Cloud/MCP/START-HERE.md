# START HERE — Tosca Cloud MCP

Pick **one** install method. Do not combine plugin + zip on the same profile.

## 1. Pick your IDE

| IDE | Marketplace plugin? | Without plugin |
|-----|---------------------|----------------|
| **Cursor** | Tier 5–6 — Customize → install plugin | Tier 1–3 zip or Tier 4 git / mcp-skills |

Other IDEs: use a future adapter pack from mcp-skills when published. **This export is Cursor-first.**

## 2. Pick your tier

```text
Can use Cursor marketplace?
├─ YES → Tier 5 (team) or Tier 6 (public)
│         Skills + rules only. Need installer + MCP config helper? Also get release zip.
└─ NO
   ├─ Scripts blocked?     → Tier 1: copy cursor/skills and cursor/rules manually
   ├─ No GitHub access?    → Tier 2: IT mirror + verify SHA256 → Tier 1 or 3
   ├─ PowerShell OK?       → Tier 3: extract zip → Install-ToscaCloudMcpPack.ps1 -Ide Cursor -Tenant <tenant>
   └─ Git clone OK?        → Tier 4: clone mcp-skills path Tosca/Cloud/MCP → run installer
```

## 3. Quick command (Tier 3)

```powershell
.\Install-ToscaCloudMcpPack.ps1 -Ide Cursor -Tenant acme -Space default -Env prod
```

Or configure MCP only:

```bash
python3 configure_mcp_connection.py --tenant acme --space default --env prod
```

## 4. Verify connection

Reload Cursor → Settings → MCP → enable **tosca-cloud** → run `tosca_organization_listWorkspaces`.

Slash command: `/tosca-cloud-connect`

## 5. Bundled skills

| Skill | Purpose |
|-------|---------|
| `tosca-cloud-connect` | Connect hosted MCP tenant |
| `tosca-cloud-basics` | Cloud object model |
| `tosca-cloud-mcp` | Engineering / tool orchestration |
| `tosca-analyzing-execution-results` | Latest run diagnosis |
| `tosca-analyzing-execution-history` | Trends over time |
| `tosca-authoring-*` | Create test cases |
| `tosca-explaining-testcase` | Explain test cases |
| `tosca-remediating-from-results` | Apply fixes from results |

## 6. Security

Verify zip integrity with `SHA256SUMS`. See [SECURITY.md](../SECURITY.md) for IT review checklist.

## Full guide

[installation.md](installation.md) — tiers, tenant URL pattern, troubleshooting.
