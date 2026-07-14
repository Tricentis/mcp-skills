# Changelog

All notable changes to the **commander-mcp** skill are documented here.

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
