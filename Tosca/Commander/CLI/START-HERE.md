# START HERE — cli-api-commander

Pick **one** install method. Do not combine plugin + zip on the same profile.

## 1. Pick your IDE

| IDE | Marketplace plugin? | Without plugin |
|-----|---------------------|----------------|
| **Cursor** | Tier 5–6 — Customize → install plugin | Tier 1–3 zip or Tier 4 git |
| **Claude Code** | Tier 5–6 — `/plugin marketplace` | Tier 1–3 zip or Tier 4 git |
| **VS Code + Copilot** | **Not published** — use zip/git | Tier 1–3 or 4, **project scope only** |
| **Windsurf** | **No marketplace** — zip/git only | Tier 1–3 or 4 |

## 2. Pick your tier

```text
Can use IDE marketplace (Cursor/Claude)?
├─ YES → Tier 5 (team) or Tier 6 (public)
│         Skills + rules only. Need path scripts? Also get release zip (Tier 2–3).
└─ NO
   ├─ Scripts blocked?        → Tier 1: copy folders (see README-INSTALL.md § Tier 1)
   ├─ No GitHub access?       → Tier 2: IT mirror + verify SHA256 → Tier 1 or 3
   ├─ PowerShell/batch OK?    → Tier 3: extract zip → Install-CliApiCommanderPack.bat -Ide <IDE>
   └─ Git clone OK?           → Tier 4: clone repo → scripts\Install-CliApiCommanderPack.ps1 -Ide <IDE>
```

## 3. Quick commands (Tier 3)

```bat
Install-CliApiCommanderPack.bat -Ide Cursor
```

```powershell
.\Install-CliApiCommanderPack.ps1 -Ide Claude
.\Install-CliApiCommanderPack.ps1 -Ide VSCode -Scope Project
.\Install-CliApiCommanderPack.ps1 -Ide Windsurf
```

## 4. Invoke the skill

| IDE | Invoke |
|-----|--------|
| Cursor | `/cli-api-commander` |
| Claude | Skill **cli-api-commander** |
| Windsurf | `@cli-api-commander` |
| VS Code | Copilot Chat + terminal (see `.github/copilot-instructions.md`) |

## 5. Plugin-only users

Plugins ship **skills and rules only** — no `Get-CommanderAutomationPaths` scripts. You can still automate via:

- **cmd + TCShell.exe** (headless, no extra scripts)
- **Release zip** for optional detectors (separate install to a tools folder)

## 6. Security

Verify zip integrity with `SHA256SUMS`. See [SECURITY.md](../SECURITY.md) for IT review checklist.

## Full guide

[installation.md](installation.md) — all six tiers, paths, troubleshooting.
