# Tricentis MCP Skills

Open-source agent skills that help customers automate Tricentis products through IDE agents, MCP servers, and command-line interfaces.

**License:** [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) — see [LICENSE](LICENSE).

> "Tricentis MCP Skills" © Tricentis. Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## Which skill set do I need?

| Your situation | Skill set | Install guide |
|----------------|-----------|---------------|
| Commander **open** with a workspace; IDE connected to **in-process MCP** (`McpServerAddIn`, port 46248) | **Commander MCP** | [Tosca/Commander/MCP/README.md](Tosca/Commander/MCP/README.md) |
| Commander **closed**, batch/CI, workspace locked, or **TCShell / TCAPI / Remote Control** | **Commander CLI & API** | [Tosca/Commander/CLI/README.md](Tosca/Commander/CLI/README.md) |
| **Tosca Cloud** tenant; hosted **Tosca Cloud MCP** (inventory, playlists, runs, Builder) | **Tosca Cloud MCP** | [Tosca/Cloud/MCP/README.md](Tosca/Cloud/MCP/README.md) |
| **Tosca Cloud** + **TN CLI** (`tn`, `/tosca`, `--loop`, `--robot`) | **Tosca Cloud CLI** | [Tosca/Cloud/CLI/README.md](Tosca/Cloud/CLI/README.md) |

Commander MCP and Commander CLI are complementary — use MCP when the GUI is running; use CLI when automation must be headless.

**Tosca Cloud MCP** and **Tosca Cloud CLI** are complementary — use MCP for IDE-native Code Mode; use CLI when **tn** is the runtime (loop, robot, multi-provider AI).

---

## Installation (all skill sets)

Every product path uses the same **six-tier enterprise install model**. Pick **one tier** and **one scope** (user or project) per IDE profile — do not install via marketplace **and** zip/git to the same paths.

| Tier | When | Mechanism |
|------|------|-----------|
| **1** | Scripts blocked | Manual folder copy from the product directory |
| **2** | No direct GitHub; IT mirror OK | Approved zip + SHA256 verify → Tier 1 or 3 |
| **3** | PowerShell or batch allowed | Release zip + product installer script |
| **4** | Git clone allowed | Clone this repo → run installer from product path |
| **5** | Enterprise IDE marketplace | Team/private plugin (skills + rules) |
| **6** | Public marketplace | Public plugin when published |

### Supported across all skill sets

| Capability | Detail |
|------------|--------|
| **Admin rights** | Not required — user or project scope only |
| **License** | [Apache 2.0](LICENSE) |
| **Integrity** | `SHA256SUMS` on release zips; `manifest.json` records `sourceSha` and version |
| **Offline install** | Scripts copy local files only — no download at install time |
| **IDE agents** | Skills, rules/instructions, and orchestration companions per product |
| **Install scripts** | `Install-*Pack.ps1` / `.bat` in each product directory (Tier 3–4) |

Tier details, path tables, and security notes live in **each product README** — the guides differ by runtime (MCP vs CLI vs Cloud tenant).

### Installation by skill set

| Skill set | Installer | IDEs in this repo | Scope notes | Product-specific |
|-----------|-----------|-------------------|-------------|------------------|
| [Commander MCP](Tosca/Commander/MCP/) | `Install-CommanderMcpPack.ps1` | Cursor, Claude, VS Code, Windsurf | VS Code: project scope | `cursor/mcp.json` for localhost MCP; optional `-VerifyManifest` |
| [Commander CLI](Tosca/Commander/CLI/) | `Install-CliApiCommanderPack.ps1` | Cursor, Claude, VS Code, Windsurf | VS Code: project scope | Helper scripts in zip/git only (not marketplace plugins); [START-HERE.md](Tosca/Commander/CLI/START-HERE.md) |
| [Tosca Cloud MCP](Tosca/Cloud/MCP/) | `Install-ToscaCloudMcpPack.ps1` | **Cursor** (primary export) | User scope | `-Tenant`, `-Space`, `-Env`; MCP config helper; [START-HERE.md](Tosca/Cloud/MCP/START-HERE.md) |
| [Tosca Cloud CLI](Tosca/Cloud/CLI/) | `Install-TnCloudPack.ps1` | Cursor, Claude, Windsurf | User scope; VS Code fragment | `-Tenant`, `-Space`; tn + `configure_tn_connection.py`; [START-HERE.md](Tosca/Cloud/CLI/START-HERE.md) |

**Releases:** [GitHub Releases](https://github.com/Tricentis/mcp-skills/releases) — tags like `tosca/commander/mcp/{version}`, `tosca/commander/cli/{version}`, `tosca/cloud/mcp/{version}`, `tosca/cloud/cli/{version}`.

---

## Skill sets

### [Tosca Commander MCP](Tosca/Commander/MCP/) — `commander-mcp`

Automate **Tosca Commander** through the in-process HTTP MCP server while Commander is **running** with a workspace open.

| | |
|--|--|
| **Skill** | `commander-mcp` — workspace navigation, checkout, tasks, test case creation, Data Integrity |
| **Prerequisite** | Commander 26.1+, workspace loaded, MCP on port **46248** |
| **IDEs** | Cursor, Claude, VS Code, Windsurf |
| **Install** | Six tiers — [README.md](Tosca/Commander/MCP/README.md) (`Install-CommanderMcpPack.ps1`) |
| **Version** | See [manifest.json](Tosca/Commander/MCP/manifest.json) |

Does **not** cover headless TCShell, TCAPI, or Remote Control — use [Commander CLI](#tosca-commander-cli--cli-api-commander) instead.

---

### [Tosca Commander CLI & API](Tosca/Commander/CLI/) — `cli-api-commander`

Automate **Tosca Commander** through **TCShell**, **TCAPI**, or **Remote Control** — no MCP server required.

| | |
|--|--|
| **Skill** | `cli-api-commander` — JumpToNode, checkout/check-in, batch `.tcs` scripts, execution lists, GUI RC |
| **Prerequisite** | Commander installed; headless TCShell via `cmd` is the minimum path |
| **IDEs** | Cursor, Claude, VS Code, Windsurf |
| **Install** | Six tiers — [README.md](Tosca/Commander/CLI/README.md) · [START-HERE.md](Tosca/Commander/CLI/START-HERE.md) (`Install-CliApiCommanderPack.ps1`) |
| **Version** | See [manifest.json](Tosca/Commander/CLI/manifest.json) |

Does **not** cover in-process Commander MCP or Data Integrity — use [Commander MCP](#tosca-commander-mcp--commander-mcp) when Commander is open.

---

### [Tosca Cloud MCP](Tosca/Cloud/MCP/) — `tosca-cloud-mcp` + journey skills

Automate **Tosca Cloud** through the hosted MCP server — inventory, playlists, execution runs, Builder, and Data Integrity.

| | |
|--|--|
| **Core skill** | `tosca-cloud-mcp` — search, playlists, runs, Builder, DI orchestration |
| **Journey skills** | `tosca-cloud-connect`, `tosca-cloud-basics`, authoring, execution analysis, remediation, explain |
| **Prerequisite** | Tosca Cloud tenant, Okta auth, configured `spaceId` |
| **IDEs** | Cursor (primary in this export) |
| **Install** | Six tiers — [README.md](Tosca/Cloud/MCP/README.md) · [START-HERE.md](Tosca/Cloud/MCP/START-HERE.md) (`Install-ToscaCloudMcpPack.ps1`) |
| **Version** | See [manifest.json](Tosca/Cloud/MCP/manifest.json) |

Start with **connect** and **basics**, then route to **tosca-cloud-mcp** or a journey skill for your task.

For **tn-native** loop/robot autonomy and multi-provider AI, use [Tosca Cloud CLI](#tosca-cloud-cli--tn-cloud--journey-skills) instead of installing both to the same IDE profile.

---

### [Tosca Cloud CLI](Tosca/Cloud/CLI/) — `tn-cloud` + journey skills

Automate **Tosca Cloud** via the **TN CLI** (`tn`) — `/tosca` mode, **`--loop`**, and **`--robot`**.

| | |
|--|--|
| **Core skill** | `tn-cloud` — orchestration, loop, robot, DI |
| **Journey skills** | connect, basics, analyzing ×2, remediate, authoring ×2, explain |
| **Prerequisite** | tn CLI on PATH, tenant, `/tosca` |
| **IDEs** | Cursor, Claude, Windsurf (+ VS Code fragment) |
| **Install** | Six tiers — [README.md](Tosca/Cloud/CLI/README.md) · [START-HERE.md](Tosca/Cloud/CLI/START-HERE.md) (`Install-TnCloudPack.ps1`) |
| **Version** | See [manifest.json](Tosca/Cloud/CLI/manifest.json) |

Does **not** cover direct IDE MCP (Code Mode) — use [Tosca Cloud MCP](#tosca-cloud-mcp--tosca-cloud-mcp--journey-skills); on-prem Commander — [Commander CLI](#tosca-commander-cli--api--cli-api-commander).

---

## Repository layout

```text
mcp-skills/
├── Tosca/
│   ├── Commander/
│   │   ├── MCP/          # commander-mcp — in-process Commander MCP
│   │   └── CLI/          # cli-api-commander — TCShell / TCAPI / RC
│   └── Cloud/
│       ├── MCP/          # tosca-cloud-mcp + Tosca Cloud journey skills (IDE MCP)
│       └── CLI/          # tn-cloud + journey skills (TN CLI)
├── sync/manifests/       # Export allowlists (maintainers)
└── docs/                 # CI/CD and governance
```

Each product path contains IDE packs (`cursor/`, `claude/`, `windsurf/`, `vscode/`), tiered install scripts, `manifest.json`, and a product **README.md** with full install steps for that skill set.

---

## Support disclaimer

These skills are provided **as-is** on an open-source cadence. They are **outside** Tricentis product support agreements — no SLA, no indemnification, and no guarantee of function.

## Contributing

See **[CONTRIBUTING.md](CONTRIBUTING.md)** for the contribution model, source-repo workflow, and what to change here vs in a maintainer repo. Governance, approvers, and audit rules are in **[GOVERNANCE.md](GOVERNANCE.md)**.

## Governance and CI/CD

| Document | Purpose |
|----------|---------|
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution model and source-repo workflow |
| [GOVERNANCE.md](GOVERNANCE.md) | Approvers, auditors, contribution rules |
| [MAINTAINERS.md](MAINTAINERS.md) | Team roster (TBD until public launch) |
| [docs/github-cicd-pipeline.md](docs/github-cicd-pipeline.md) | GitHub-only sync pipeline |
| [docs/branch-protection.md](docs/branch-protection.md) | Branch protection checklist |

## Trademark

Tricentis trademarks belong to Tricentis. Third-party skills must not imply Tricentis endorsement, certification, or product support.
