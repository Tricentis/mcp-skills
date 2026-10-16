# Changelog

All notable changes to the **commander-mcp** skill are documented here.

## [1.2.0] - 2026-10-12

### Added

- `reference/execution-object-model.md` — execution log object model, attribute-cost rules, and hard gaps
- Workflows: `locate-execution-results.md`, `diagnose-incomplete-run.md`, `run-and-monitor-execution.md`, `compare-two-runs.md`
- Routing and activation coverage for locating a run, diagnosing an incomplete run, comparing two runs, and starting a run
- `validate_skill.py` checks that `render_workflows_index()` matches `reference/workflows-index.md`

### Changed

- `execute_test_suite` runs an `ExecutionList`, `ExecutionEntry`, `ExecutionEntryFolder`, or `TestEvent` when `is_validation_run` is false. A `TestEvent` is only enqueued; per-entry rows are the last known logs
- Latest log is `references.ActualExecutionLog` on the list, not a child named `ActualLog`. Archived logs are `ExecutionLog` children
- Dialog-opening attribute tasks (`Name`, `Description`, `SynchronizationPolicy`, `OwningGroupName`, `ViewingGroupName`, `Pausable`, `TestCaseWorkState`) stay on `set_attribute`

## [1.1.1] - 2026-10-12

### Added

- `reference/workflows/configure-dex-agent.md` — refresh Distribution Agents on `TestConfigurationsRoot` in a multi-user workspace via `list_available_tasks` and `execute_task`, then read transient `Agent` / `AgentLink` objects

### Notes

- Follows published 1.1.0. Do not reuse 1.0.1.
- Agent install, server connection, and unattended RDP stay outside MCP.

## [1.1.0] - 2026-07-31

### Deprecated

- Published draft containing unsupported DEX attributes and out-of-MCP agent installation and
  unattended RDP instructions. Superseded by 1.1.1; do not use.

## [1.0.1] - 2026-07-14

### Changed

- Slimmer `SKILL.md` routing (81 lines) — workflow and DI tables defer to index files
- Progressive disclosure: Contents sections on long companions and DI reference files
- Activation: `tosca-commander` trigger in description; rules aligned with SKILL.md negatives
- Corrected tool names throughout (`get_object_info` replaces stale `get_objects` / `list_children`)
- `evaluations/` remains internal — excluded from consumer export

## [1.0.0] - 2026-07-13

### Added

- Public distribution via Tricentis/mcp-skills (`Tosca/Commander/MCP`)
- Apache 2.0 license; consumer export parity (`ConsumerExport.ps1`)
- Installer `-VerifyManifest`; six-tier install documentation

## [0.1.2] - 2026-07-06

### Added

- `metadata.json` with skill version and MCP server metadata
- `evaluations/activation.md` — trigger phrase and negative activation tests
- Flat link tables in `SKILL.md` for workflow templates and DI scenarios
- Stricter `validate_skill.py` checks (description length, name format, reference link depth)

### Changed

- Shortened `description` with negative cases, `/commander-mcp`, and IDE.integration boundary
- Reference files made self-contained (no outbound links to skill-root companions)
- Workflow templates include inline checkout and DI gate rules
- Code fence language tags on checklists (`text`, `bash`, `json`)

## [0.1.1] - 2026-06-26

### Added

- Session checklists across orchestration and workflow files
- `tosca-commander:tool_name` guidance for multi-server MCP setups
- Table of contents on long orchestration companions

### Changed

- Improved progressive disclosure routing in `SKILL.md`
- Synced IDE packs (Cursor, Claude, Windsurf, VS Code)

## [0.1.0] - 2026-06-01

### Added

- Initial commander-mcp skill with Code Mode and direct tool mode
- Generated tool catalog from Commander `McpServerAddIn`
- DI reference extracted from `DIWorkflowTool.cs`
- IDE pack installer and validation scripts
