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
│         Skills + rules only. Zip/git adds Install-ToscaCloudMcpPack.ps1.
└─ NO
   ├─ Scripts blocked?     → Tier 1: copy cursor/skills and cursor/rules manually
   ├─ No GitHub access?    → Tier 2: IT mirror + verify SHA256 → Tier 1 or 3
   ├─ PowerShell OK?       → Tier 3: extract zip → Install-ToscaCloudMcpPack.ps1 -Ide Cursor
   └─ Git clone OK?        → Tier 4: clone mcp-skills path Tosca/Cloud/MCP → run installer
```

## 3. Connect MCP (user action)

This pack **does not** write `mcp.json`. In Cursor:

1. **Settings → MCP → Add server**
2. URL: `https://{tenant}.my.tricentis.com/{space}/_mcp/api/mcp`
3. Reload; sign in when prompted

## 4. Verify connection

Run `tosca_organization_listWorkspaces`. Slash command: `/tosca-cloud-connect`

## 5. Bundled skills

| Skill | Purpose |
|-------|---------|
| `tosca-cloud-connect` | Verify hosted MCP tenant connection |
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
