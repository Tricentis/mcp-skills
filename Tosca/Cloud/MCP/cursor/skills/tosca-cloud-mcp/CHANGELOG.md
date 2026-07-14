# Changelog — tosca-cloud-mcp

## 0.1.3 — 2026-07-14

### Added

- Expanded `di-orchestration.md` — phased workflow, scenario router, anti-patterns (Commander-style)
- `tosca-explaining-testcase/references/read-path.md` — interim read path + `getTestCaseDetail` gap
- Extended MCP domains in `tosca-cloud-basics` (DI, mobile, apiexecution, simulation)
- DI activation tests mirroring Commander phrasing

### Changed

- Regenerated `reference/di/*` from MCPServer `DiWorkflowTool.cs`
- `di-getting-started.md` — async polling loop and scenario quick-pick
- Removed Commander cross-routing from agent-facing skills, `AGENTS.md`, activation tests
- Skill descriptions use within-repo mutual exclusion only
- `journey-activation.md` — DI phrases route to `tosca-cloud-mcp`
- `docs/mcp-product-audit.md` — updated gap status

## 0.1.2 — 2026-07-13

### Added

- Domain orchestration companions: execution, mobile, apiexecution, simulation
- Workflow templates: manage-folder, create-playlist, rename-playlist-items, manage-api-message, di-db-expert-testcase, mobile-connection, api-execution-connection, deploy-simulation
- `scripts/validate_pack.ps1` — sync + validate engineering and journey skills + Cursor pack
- Expanded `docs/skill-authoring.md` — Commander parity authoring guide
- Journey skill session checklists and guardrails aligned with Tosca-AI-Skills depth

### Changed

- `SKILL.md` routing tables — all orchestration domains and workflow templates
- `when-to-use-mcp.md` — simulation intent; execution log routing
- `reference/di/index.md` — DB Expert testcase workflow link
- Prerequisites — `configure_mcp_connection.py` instead of `run-cloud.ps1`
- `validate_skill.py` — required files for new orchestration and workflows
- `validate_journey_skills.py` — verifies `references/` files exist

## 0.1.1 — 2026-07-07

### Added

- `tosca-cloud-connect` journey skill — hosted tenant MCP setup and tool navigation
- `packages/cursor-pack/` — Cursor plugin, `/tosca-cloud-connect` command
- `scripts/configure_mcp_connection.py` — generate `mcp.json` for `{tenant}.my.tricentis.com`
- `scripts/Install-ToscaCloudMcpPack.ps1`, `scripts/sync_mcp_packs.ps1`
- `scripts/extract_di_reference_docs.py` — extract DI walkthroughs from MCPServer `DiWorkflowTool.cs`
- `reference/workflows/connect-tenant.md`
- `reference/di/workflows/01-row-by-row-comparison.md` and `02-file-comparison.md`
- Builder guidance: steps-at-creation, module name collision handling, append-step MCP gap

### Changed

- Production URL pattern documented (`my.tricentis.com`); my-dev relegated to internal dev
- `when-to-use-mcp.md`, `installation.md`, `AGENTS.md` updated for connect-first flow
- `scaffold-test-case.md` — aligned with `tosca_builder_scaffoldTestCase` API (testSteps, move for folder placement)
- `di-orchestration.md` — connections are UI-managed; MCP supports get/delete only
- Regenerated `reference/di/overview.md` and `conventions.md` from MCPServer source

## 0.1.0 — 2026-07-06

- Initial engineering skill scaffolded from Tosca.Commander.MCP.Integration patterns
- Tool catalog generated from MCPServer `main` (51 tools)
- Journey skills adapted from Tosca-AI-Skills for Cloud MCP wire names
- MCP product audit and improvement proposal for MCPServer
