# Changelog — cli-api-commander

## 1.0.0

- **First stable release** — export to `Tricentis/mcp-skills` at `Tosca/Commander/CLI`
- Release branch and tag align with version: `cli-1.0.0`, `tosca/commander/cli/1.0.0`
- Six-tier install, mcp-skills export pipeline, skill-authoring hardening (0.3.x pre-release work)

## 0.3.7

- **Distribution plan:** `docs/ide-skills-distribution-plan.md` — ask-before-export; Phases 0–8 to mcp-skills
- **Consumer parity:** `sync/ide-skills-manifest.json`, `ConsumerExport.ps1`, `export_mcp_skills.ps1`
- **Export:** `-McpSkillsPath`, `-ReleaseBranch`, `-TagMcpSkills` (`tosca/commander/cli/{version}`)
- **Sync:** Exclude `evaluations/` from packs; strip activation from consumer `SKILL.md`
- **Target:** `Tosca/Commander/CLI` in Tricentis/mcp-skills

## 0.3.6

- **Token architecture:** Slim `SKILL.md` (~115 lines); token budget table; hub notice on `architecture.md`
- **Activation:** Description + rule add `.tws` synonyms; 6 new positive activation fixtures
- **Progressive disclosure:** `journeys-index.md` per-turn token budget; validation for hub notices
- **Docs:** `docs/skill-authoring-audit.md` — skill-authoring review scorecard

## 0.3.5

- **Distribution:** `SECURITY.md` IT audit checklist; `docs/START-HERE.md` one-page install decision tree (bundled in release zip)
- **Distribution:** Plugin descriptions state "skills and rules only"; Cursor/Claude plugin READMEs
- **Distribution:** Installer removes legacy `tcshell-commander` profile installs; sync prunes stale pack skill dirs
- **Distribution:** `Validate-MarketplacePack.ps1` asserts no scripts/stale skills in plugin bundles
- **Docs:** Fix stale version examples in `installation.md` and `PHASES.md`; clarify VS Code/Windsurf marketplace limits

## 0.3.4

- **P5:** `cli-flags.md` agent navigation notices (all version bundles)
- **P5:** `tcshell-task-catalog.json` + `validate_tasks.py` (tasks.md vs Commander TC.resx)
- **P5:** `validate_activation.py` — automated activation fixture checks in CI
- **P5:** `batch mode` added to skill description triggers

## 0.3.3

- **P4:** Agent navigation notices on `commands.md` and `examples-index.md` (all version bundles)
- **P4:** `remote-control.md` Contents section
- **P4:** Plugin descriptions include negative scope (DI, in-process automation)
- **P4:** `JumpToNode` added to skill description and rule

## 0.3.2

- **P2:** `output-patterns.md` agent navigation notice (all version bundles); scenarios-index routing
- **P2:** Contents sections on `path-selection.md`, `workspace-checkout.md`, `tcapi.md`
- **P2:** Extended `validate_skill.py` — companion TOC, output-patterns notice, tasks.md structure
- **P3:** `tasks.md` hand-authored notice; `workspace-checkout.md` in-process wording fix
- **P3:** `journeys-index` one-doc-per-turn rule for complex commands

## 0.3.1

- **P0:** Self-contained skill links — bundle `commander-versions.json`, `tcapi-compatibility.json`, `architecture.md`, `commander-compatibility.md` in `reference/`
- **P1:** Richer triggers in description, rule, and plugin manifests (`.tcs`, `workspace locked`, `checkinall`, batch mode)
- **P1:** Expanded `evaluations/activation.md` phrases

## 0.3.0

- **Rename** skill from `tcshell-commander` to `cli-api-commander` (CLI + TCAPI + Remote Control)
- Slash command: `/cli-api-commander`
- Installer: `Install-CliApiCommanderPack.ps1` / `.bat`
- Release zip: `cli-api-commander-IDE-{version}-user.zip`

## 0.2.0

- Refactor `SKILL.md` to router pattern with session checklist
- Add `journeys-index.md` intent router and workflow templates
- Add `metadata.json`, `evaluations/activation.md`, `docs/skill-authoring.md`
- Standalone scope boundaries — DI and in-process automation marked out of scope
- No cross-references to other skill packs

## 0.1.0

- Initial multi-IDE pack: path detection, versioned reference bundles, TCAPI examples
- Headless TCShell, TCAPI, Remote Control companions
- Cursor, Claude, VS Code, Windsurf adapter packs
