# START HERE — Tosca Cloud MCP

Pick **one** install method. Do not combine plugin + zip on the same profile.

## 1. Pick your IDE

| IDE | Marketplace plugin? | Without plugin |
|-----|---------------------|----------------|
| **Cursor** | Tier 5–6 — Customize → install plugin | Tier 1–3 zip or Tier 4 git / mcp-skills |
| **Claude Code** | Team/public marketplace when published | Tier 1–3 zip or Tier 4 git / mcp-skills |
| **GitHub Copilot** (CLI and VS Code Chat) | No plugin in this pack | Tier 1–3 zip or Tier 4 git / mcp-skills |

Supported installer IDEs: `Cursor`, `Claude`, `Copilot`.

## 2. Pick your tier

```text
Can use marketplace plugin?
├─ YES (Cursor / Claude) → Tier 5 (team) or Tier 6 (public)
│         Skills (+ Cursor rules). Zip/git adds Install-ToscaCloudMcpPack.ps1.
└─ NO
   ├─ Scripts blocked?     → Tier 1: copy cursor/skills (+ rules), claude/skills, or copilot/skills manually
   ├─ No GitHub access?    → Tier 2: IT mirror + verify SHA256 → Tier 1 or 3
   ├─ PowerShell OK?       → Tier 3: extract zip → Install-ToscaCloudMcpPack.ps1 -Ide Cursor|Claude|Copilot
   └─ Git clone OK?        → Tier 4: clone mcp-skills path Tosca/Cloud/MCP → run installer
```

## 3. Connect MCP (user action)

This pack **does not** write MCP config files. In your host:

1. Add the tenant URL `https://{tenant}.my.tricentis.com/{space}/_mcp/api/mcp`
   - Cursor / Claude Code / VS Code: Settings or **MCP: Add Server**
   - Copilot CLI: `copilot mcp add --transport http tosca-cloud "<url>"` then `/mcp auth tosca-cloud` if needed
2. Complete sign-in when prompted

## 4. Verify connection

Run `tosca_module` Search. Slash command: `/tosca-cloud-connect`

Copilot CLI: `copilot skill list` then `/tosca-cloud-connect`.

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
