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

Commander MCP and Commander CLI are complementary — use MCP when the GUI is running; use CLI when automation must be headless. See each install guide for prerequisites and tier options.

---

## Skill sets

### [Tosca Commander MCP](Tosca/Commander/MCP/) — `commander-mcp`

Automate **Tosca Commander** through the in-process HTTP MCP server while Commander is **running** with a workspace open.

| | |
|--|--|
| **Skill** | `commander-mcp` — workspace navigation, checkout, tasks, test case creation, Data Integrity |
| **Prerequisite** | Commander 26.1+, workspace loaded, MCP on port **46248** |
| **IDEs** | Cursor, Claude, VS Code, Windsurf |
| **Version** | See [manifest.json](Tosca/Commander/MCP/manifest.json) |
| **Install** | [Tosca/Commander/MCP/README.md](Tosca/Commander/MCP/README.md) |

Does **not** cover headless TCShell, TCAPI, or Remote Control — use [Commander CLI](#tosca-commander-cli--cli-api-commander) instead.

---

### [Tosca Commander CLI & API](Tosca/Commander/CLI/) — `cli-api-commander`

Automate **Tosca Commander** through **TCShell**, **TCAPI**, or **Remote Control** — no MCP server required.

| | |
|--|--|
| **Skill** | `cli-api-commander` — JumpToNode, checkout/check-in, batch `.tcs` scripts, execution lists, GUI RC |
| **Prerequisite** | Commander installed; headless TCShell via `cmd` is the minimum path |
| **IDEs** | Cursor, Claude, VS Code, Windsurf |
| **Version** | See [manifest.json](Tosca/Commander/CLI/manifest.json) |
| **Install** | [Tosca/Commander/CLI/README.md](Tosca/Commander/CLI/README.md) · [START-HERE.md](Tosca/Commander/CLI/START-HERE.md) |

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
| **Version** | See [manifest.json](Tosca/Cloud/MCP/manifest.json) |
| **Install** | [Tosca/Cloud/MCP/README.md](Tosca/Cloud/MCP/README.md) · [START-HERE.md](Tosca/Cloud/MCP/START-HERE.md) |

Start with **connect** and **basics**, then route to **tosca-cloud-mcp** or a journey skill for your task.

---

## Repository layout

```text
mcp-skills/
├── Tosca/
│   ├── Commander/
│   │   ├── MCP/          # commander-mcp — in-process Commander MCP
│   │   └── CLI/          # cli-api-commander — TCShell / TCAPI / RC
│   └── Cloud/
│       └── MCP/          # tosca-cloud-mcp + Tosca Cloud journey skills
├── sync/manifests/       # Export allowlists (maintainers)
└── docs/                 # CI/CD and governance
```

Each product path contains IDE packs (`cursor/`, `claude/`, `windsurf/`, `vscode/`), install scripts, `manifest.json`, and a product **README.md** with tiered install steps.

---

## Support disclaimer

These skills are provided **as-is** on an open-source cadence. They are **outside** Tricentis product support agreements — no SLA, no indemnification, and no guarantee of function.

## Contributing

Skill content is authored in internal source repositories and synced here via GitHub Actions. Direct pull requests are welcome for documentation fixes and issues. Changes to skill content may be redirected to the source repo — see [GOVERNANCE.md](GOVERNANCE.md).

## Governance and CI/CD

| Document | Purpose |
|----------|---------|
| [GOVERNANCE.md](GOVERNANCE.md) | Approvers, auditors, contribution rules |
| [MAINTAINERS.md](MAINTAINERS.md) | Team roster (TBD until public launch) |
| [docs/github-cicd-pipeline.md](docs/github-cicd-pipeline.md) | GitHub-only sync pipeline |
| [docs/branch-protection.md](docs/branch-protection.md) | Branch protection checklist |

## Trademark

Tricentis trademarks belong to Tricentis. Third-party skills must not imply Tricentis endorsement, certification, or product support.
