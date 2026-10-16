# START HERE — Commander MCP

Pick **one** install method. Do not combine plugin + zip on the same profile.

## 1. Pick your IDE

| IDE | Marketplace plugin? | Without plugin |
|-----|---------------------|----------------|
| **Cursor** | Tier 5–6 — Customize → install plugin | Tier 1–3 zip or Tier 4 git / mcp-skills |
| **Claude Code** | Tier 5–6 — org marketplace | Tier 1–3 zip or Tier 4 git |
| **VS Code + Copilot** | **Not published** — use zip/git | Tier 1–3 or 4, **project scope only** |
| **Windsurf** | **No marketplace** — zip/git only | Tier 1–3 or 4 |

**Prerequisite:** Tosca Commander **26.1+** open with a workspace.

For **TCShell / TCAPI / Remote Control** when Commander is closed, use [Tosca.Commander.IDE.integration](https://github.com/Tricentis-Tosca/Tosca.Commander.IDE.integration).

## 2. Pick your tier

```text
Can use IDE marketplace (Cursor/Claude)?
├─ YES → Tier 5 (team) or Tier 6 (public)
│         Skills + rules. Configure MCP in IDE settings (see §3).
└─ NO
   ├─ Scripts blocked?     → Tier 1: copy skills/rules manually (see README)
   ├─ No GitHub access?    → Tier 2: IT mirror + verify SHA256 → Tier 1 or 3
   ├─ PowerShell OK?       → Tier 3: extract zip → Install-CommanderMcpPack.ps1 -Ide Cursor
   └─ Git clone OK?        → Tier 4: clone mcp-skills path Tosca/Commander/MCP → run installer
```

## 3. Connect MCP (user action)

This pack **does not** write `mcp.json`. In Cursor:

1. **Settings → MCP → Add server**
2. Name: `tosca-commander`
3. URL: `http://127.0.0.1:46248/mcp` (DEBUG builds: port **8080**)
4. Reload; confirm Commander has a workspace open

## 4. Verify connection

Run MCP tool `get_workspace_info`. Slash command: `/commander-mcp`

## 5. What you get

| Item | Purpose |
|------|---------|
| `commander-mcp` skill | Orchestration for Commander MCP tools (Code Mode or direct tool mode) |
| IDE rules / instructions | When to use checkout, save, DI workflows |

## 6. Security

Verify zip integrity with `SHA256SUMS`. See [SECURITY.md](../SECURITY.md) for IT review checklist.

## Full guide

[installation.md](installation.md) — tiers, MCP setup, troubleshooting.
