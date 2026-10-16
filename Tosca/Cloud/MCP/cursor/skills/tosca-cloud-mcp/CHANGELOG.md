# Changelog — tosca-cloud-mcp

## Unreleased

### Added

- `tosca_testsheet` List / Get / ListInstances (TOSCA-57257): read TDM test sheets and classes — attribute tree with dotted paths, instances, straight-through values, portal url, and paged rows (test case instances).
- `tosca_testsheet_edit` (TOSCA-57258): Upsert, Delete, AttributeUpsert, AttributeDelete, InstanceUpsert, InstanceDelete, ClassReferenceAdd, ClassReferenceDetach, ConvertToClass, AssignChildInstance, UnassignChildInstance, GenerateRows, RowUpsert, RowDelete. Both tools are gated by EnableV2Tools and the TestCaseDesign entitlement; some operations follow the TDM editor's tenant flags.
- `reference/testsheet-structure.md` (sheets vs classes, paths and ids, rows, downstream impact on templates and requirements, limits) and the `inspect-testsheet` / `manage-testsheet` workflows with the confirmation texts.
- Routing in `SKILL.md`, `builder-orchestration.md` (Test sheets (TDM)), `tool-orchestration.md`; `tosca-cloud-basics` object model, building blocks, destructive-operations list and Extended MCP domains. `toolCount` 42.

## 1.15.1 — 2026-10-12

### Changed

- One secrets policy in `tosca-cloud-basics/references/safety-and-space.md` (TOSCA-59577). Default stays "never ask, never echo"; Password TCPs and DI connections still never take secret values. Scoped exception for `tosca_apiconnection_edit`, `tosca_apimessage_edit` and the mobile tools: offer the portal first, forward only user-volunteered values, never echo them, use a secret slot only. API message `headers` are not a secret slot — bearer tokens and API keys stay on a named API connection, or the user fills the header in the portal. API message Update with inline Basic auth clears the stored password (the server has no way to carry it over): warn, update without it, point the user to the portal — never ask for it. Hard rule 4 and the API / mobile workflows link to it.
- Cursor rule names tools `tosca_<entity>` / `tosca_<entity>_edit` instead of `tosca_{domain}_{action}`.

### Fixed

- Packs no longer ship the "Activation testing" section that linked to the excluded `evaluations/` folder.
- Consumer export stamps versions and copies `LICENSE` into the Copilot pack too, and fails if any pack skill folder lacks either.
- Installer errors throw, and `Install-ToscaCloudMcpPack.ps1` reports them through one `Install failed:` path.
- Tool-catalog parser accepts camelCase tool names again (`tosca_dataintegrity_runSql`).
- `toolCount` matches the 40 listed tools; "Rename playlist items" and "Create / edit test case" workflow labels.

## 1.15.0 — 2026-10-09

### Added

- `tosca_teststep` / `tosca_teststep_edit` `testStepContainerType=testCaseTemplate` (TOSCA-57250): read and mutate a template's steps, folders, control-flow, and scenarios the same way as a test case. Per-item `instantiationCondition` / `xlBasePath` on Get/List/Upsert (rejected on `testCase` / `rtsb`). Requires TestCaseDesign at runtime. Convert / delete / metadata Upsert stay on a later `tosca_testcasetemplate_edit` PR.
- `tosca-cloud-basics` object-model: template step edit via `tosca_teststep[_edit]` (`testCaseTemplate`)

### Changed

- `tosca_teststep` / `tosca_teststep_edit` identify the container with `testStepContainerType` (`testCase` default, `rtsb`, `testCaseTemplate`) and `testStepContainerId`. `testCaseId` is not a parameter on these tools. `rtsbId` on `tosca_teststep_edit` is only the referenced block for `kind: testStepFolderReference`.

## 1.14.0 — 2026-10-09

### Added

- `tosca_testcasetemplate` Get (TOSCA-57249): read a TestCaseDesign template (`testCaseTemplateId` (the hit `id`) from `tosca_asset` Search `artifactType=testCaseTemplate`) → `portalUrl`, `workState`, merged `tcp[]`, `parameterSetIds`, `testSheetId`, `instantiationCondition`, `items[]` (per-item `instantiationCondition` / `xlBasePath` when set). Gated by EnableV2Tools + TestCaseDesign. Do not call `tosca_testcase` Get for a template id.

### Changed

- Journey skills share the pack version in `SKILL.md` metadata (`1.14.0`, same as `metadata.json` / plugin) so a copied skill still identifies the install.

## 1.13.0 — 2026-10-05

### Added

- `tosca_rtsb_edit` — create, update and delete reuseable test step blocks (RTSBs); Delete reports the consuming artifacts and refuses unless `force` is passed
- `rtsbId` on `tosca_teststep` and `tosca_teststep_edit`, so steps and folders inside an RTSB are read and edited with the same operations as test case items
- RTSB write guidance in `builder-orchestration.md` — the read/write tool split, business parameter id carry-over, and the delete guard
- Control flow on `tosca_teststep_edit` / `tosca_teststep` (TOSCA-59366): insert `if` (optional `includeElse`), `while`, and `do` (`maximumRepetitions`: positive integer or `{CP[…]}` expression, default `"30"`); add an ELSE later with `kind: else` + the if's id. Branches (`Condition` / `THEN` / `ELSE` / `Loop`) appear as `kind: controlFlowCondition` in `items[]` and are addressed by id as `parentId`; Get on a block returns `branches[]`. Delete rules, move cycle guard, retry and optional-path recipes in `reference/testcase-structure.md`; conditional example in the `create-testcase` workflow
- Recovery and cleanup scenarios on `tosca_teststep_edit` / `tosca_teststep` (TOSCA-59367): `kind: recoveryScenario` (optional `retryLevel` TestStep | TestStepValue | TestCase) and `kind: cleanupScenario`, at root or in a folder; scenario ids work as `parentId` for their steps; positions count scenarios only
- `tosca_testcase` / `_edit` `workState` (Planned | InWork | Completed; create defaults to InWork) (TOSCA-57262)
- `tosca_testcase_edit` UploadRecording: `recordingResult` (recorder JSON, unmodified), optional `testCaseId` (replace in place — confirm), `parentFolderId`, `autoMerge` (TRI1-94)
- `tosca_rtsb` Get for reusable test step blocks (TOSCA-57251), `tosca_testoutline` Get / GetByExternalId (TRI1-55), `tosca_requirement` / `tosca_requirement_edit` (TOSCA-57259) in tools catalog, index, manifest, and SKILL.md routing
- `tosca_playlist_edit` `agentCharacteristics[]` next to `runOnlyOnCloudAgents` (TRI1-55)
- Mandatory (`ExactlyOne` / `OneToN`) attributes with a module `defaultValue` get that default when a step is created without a value (TOSCA-59406)
- Installer `-Ide Copilot` copies skills to `~/.copilot/skills` (user; honors `COPILOT_HOME`) or `.github/skills` (project). Same tree is used by Copilot CLI and VS Code Copilot Chat. MCP is still user-configured (`copilot mcp add` / VS Code MCP settings).
- Step values: double every `"` (`"` → `""`) so TBox does not treat it as the start of a quoted string. Wrap the whole value in `"` only when it contains `{`. Documented in `reference/testcase-structure.md`, `builder-orchestration.md`, and the TBox Read/Create File row in `reference/standard-modules.md`

### Changed

- `tosca_module_edit` Scan / Rescan listed in tools catalog and index (engine values, ME3.0 connection args)
- `controlFlowItem` is no longer listed as read-only / out of scope; instantiation conditions (template-only) and runtime conditions (RTSB-only) are documented as not supported. Builder orchestration, tools catalog/index, and SKILL.md routing mention control flow (TOSCA-59366)
- Row-by-row comparison workflow documents `expectedResult` on the create call: omit it to take the module default `OK*`, set it only when differences are the expected outcome, and take the text from a real run rather than writing it from memory (TOSCA-59406)

## 1.12.0 — 2026-09-11

### Changed

- Cross-asset inventory search now documents the consolidated noun surface: `tosca_asset` Search / AdvancedSearch (TOSCA-58409)
- Hits are camelCase `{ id, type, name, … }` with paginated `{ items, nextPageToken, total }` (default pageSize 50). No Get and no portal `url` — Get the typed artifact on the owning noun
- Document new surface only (no V1 `tosca_inventory_search` / `advancedSearch` — they are hidden once the noun tools are active)
- Search args: `name` (not `artifactName`), `folderId` (not `folderEntityId`). Search hit `id` is the same value as folder-child `id`/`entityId` and Move `entityId`
- Entries in `reference/tools-index.md`, `reference/tools-catalog.md`, `reference/manifest.json`, journey skills, and the `tosca-cloud-basics` building-blocks / object-model references

## 1.11.0 — 2026-09-10

### Changed

- Session heartbeat uses `tosca_module` Search (bounded). Space comes from the MCP URL `/{spaceId}/_mcp/api/mcp`. Find artifacts with `tosca_inventory_search` / `advancedSearch`.

## 1.10.0 — 2026-09-09

### Changed

- Inventory folder orchestration and the `manage-folder` workflow now document the consolidated noun surface: `tosca_asset_folder` (Get) and `tosca_asset_folder_edit` (Upsert / Delete / Move) (TOSCA-57235, TOSCA-57236)
- Omit `folderId` on Get to list workspace root (`id` is null, `name` is `"root"`). Cross-asset search stays on `tosca_inventory_search` / `advancedSearch`
- Document new surface only (no V1 `tosca_inventory_createFolder` / `modifyFolder` / `deleteFolder` / `move` — they are hidden once the noun tools are active)
- Folder entries in `reference/tools-index.md`, `reference/tools-catalog.md`, `reference/manifest.json`, and the `tosca-cloud-basics` building-blocks / safety references

## 1.9.0 — 2026-09-04

### Changed

- Simulation orchestration and the `deploy-simulation` workflow now document the consolidated noun surface: `tosca_simulator` (List) and `tosca_simulator_edit` (Upsert / Deploy) (TOSCA-57247, TOSCA-57248)
- Document new surface only (no V1 `tosca_simulation_*` verb tools — they are hidden once the noun tools are active)
- Simulator entries in `reference/tools-index.md`, `reference/tools-catalog.md`, `reference/manifest.json`, and the `tosca-cloud-basics` building-blocks reference

## 1.8.0 — 2026-09-04

### Changed

- API message orchestration and the `manage-api-message` workflow now document the consolidated noun surface: `tosca_apimessage` (Get) and `tosca_apimessage_edit` (Upsert / Delete) (TOSCA-57239, TOSCA-57240)
- Upsert without `messageId` creates; with `messageId` is a full replacement (Get first; omit = cleared). Document new surface only (no V1 `tosca_builder_*ApiMessage` verb tools — they are hidden once the noun tools are active)
- API message entries in `reference/tools-index.md`, `reference/tools-catalog.md`, `reference/manifest.json`, and the `tosca-cloud-basics` building-blocks / safety references

## 1.7.0 — 2026-09-03

### Changed

- API connection orchestration and the `api-execution-connection` workflow now document the consolidated noun surface: `tosca_apiconnection` (Get / List) and `tosca_apiconnection_edit` (Create / Update / Delete) (TOSCA-57241, TOSCA-57242)
- Update is a full replacement (Get first; omit = cleared). Document new surface only (no V1 `tosca_apiexecution_*` verb tools — they are hidden once the noun tools are active)
- API connection entries in `reference/tools-index.md`, `reference/tools-catalog.md`, `reference/manifest.json`, and the `tosca-cloud-basics` building-blocks / safety references

## 1.6.0 — 2026-09-02

### Changed

- Split personal trial runs onto the noun pair: `tosca_testrun` is Get / List (ReadOnly); `tosca_testrun_edit` is Create / Delete (TOSCA-57237, TOSCA-57238)
- List is the portal Test Runs catalog (`runInfo` search): name contains, state filter, pagination. In-progress `Running` / `Pending` / `Canceling` all match rows displayed as `running`
- Trial-run, execution orchestration, Code Mode, catalog/index/manifest, and journey skills that previously called `tosca_testrun` Create/Delete

## 1.5.0 — 2026-09-02

### Changed

- Mobile orchestration and the `mobile-connection` workflow now document the consolidated noun surface: `tosca_mobileconnection` (Get / List), `tosca_mobileconnection_edit` (Upsert / Delete), `tosca_mobilecapabilityset` (Get / List), `tosca_mobilecapabilityset_edit` (Upsert / Delete / SetCapability / DeleteCapability) (TOSCA-57243, TOSCA-57244)
- Mobile entries in `reference/tools-index.md`, `reference/tools-catalog.md`, `reference/manifest.json`, and the `tosca-cloud-basics` building-blocks / safety references
- Document new surface only (no V1 mobile verb tools — they are hidden once the noun tools are active)

### Added

- Configurator-blob guidance: JSON namespace capabilities (`bstack:options`, `sauce:options`, …) as `valueType=Json` capabilities, capability-set grouping by device / app / session, required `appium:automationName`, secret classification, and `capabilitySetErrors` partial-failure retry
- Capability rule: reads omit encoded values, so existing sets change one capability at a time via SetCapability

## 1.4.0 — 2026-09-01

### Added

- DI workflow `04-analyze-execution-results.md` — Commander-parity failed-run diagnosis using Cloud run result tools
- DI workflow `05-remediate-from-results.md` — approved config fix followed by focused re-validation
- `reference/di/comparison-options-and-reports.md` — Cloud tolerances, DateTime formats, transforms, and execution-agent report limitations

### Changed

- Route DI failure analysis and remediation through DI orchestration while preserving generic playlist journey routing
- Map Commander `execute_test_suite` / `set_attribute` to Cloud `tosca_testrun` / `tosca_playlistrun` / `tosca_teststep_edit`
- Align skill frontmatter and metadata version with the changelog

## 1.3.0 — 2026-08-31

### Added

- `reference/playlist-structure.md` — playlist TCP hierarchy (tenant → workspace → test case → playlist → folder → item), `tcpScope`, FolderUpsert/Delete/Move, `{CP[…]}` values, Password caveats vs Builder

### Changed

- Playlist orchestration / tools-catalog / create-playlist for FE-parity TCP + folder surface (TOSCA-57264)
- Document new surface only (no V1 “preserve parameters” gap)

## 1.2.0 — 2026-08-27

### Added

- DI workflow `03-business-rules-to-sql.md` — NL/pseudo-code → LLM SQL → `createRowByRowComparison`
- `reference/workflows/di-connection.md` — List/Get/Create/Update/Test (`tosca_diconnection` / `_edit`)
- Canonical five-step schema recipe in `reference/di/conventions.md` (`runSql` catalog SELECT; no schema tool)

### Changed

- DI orchestration on V2: `tosca_diconnection` List/Get; drop `listConnections`, `dataintegrity_connection`, `getConnectionSchema`, `workflow`
- Default write is `createRowByRowComparison` including `columnRenames`; `teststep_edit` is SQL-only patch on an existing comparison step
- Optional connection create/test and optional `tosca_testrun` (only if the user asks) — not Story 2 AC
- DB Expert: test case **generated from** Standard Object **`DI DB Expert module`** (`tosca_module` Search/Get → `tosca_testcase_edit`; no `createDiDbExpertTestcase` tool)
- Hand-edit tools-index / manifest for V2 DI surface (do not regenerate from `DiWorkflowTool.cs`)

## 1.1.0 — 2026-08-26

### Added

- Document noun-tool surface as the primary MCP model: `tosca_module`, `tosca_testcase`, `tosca_teststep`, `tosca_testrun`, `tosca_playlist`, `tosca_playlistrun` (+ `_edit` pairs)
- Rewrite builder / playlist / execution orchestration for Upsert/Get/Search/Create/poll flows
- Replace obsolete playlist verb guidance with playlistrun Get facets and `tosca_teststep_edit` renames
- Replace obsolete Builder scaffold/find/detail verbs with module + testcase + teststep noun tools; remove scaffold-test-case workflow
- Add trial-run and create-testcase workflows; module attribute value reference (`defaultActionMode`, data types, cardinality, business types, parameter types)
- Add `testcase-structure.md` — TCP hierarchy (tenant → workspace → case-local), `inheritedFrom` / `overwritten`, parameterSetIds, folders/steps
- Add curated `standard-modules.md` (Standard Objects when-to-use; resolve via Search/Get, no hardcoded ids)
- Add **Claude Code** IDE pack (`packages/claude-pack`) and installer `-Ide Claude` (skills → `~/.claude/skills`)
- Refresh tools index/catalog, planning, activation, and Code Mode examples
- metadata author: Henry Fieglein | Fractal

## 0.2.0 — 2026-07-20

### Added

- Outcome-tool guidance across orchestration docs: `summarizeLatestRun`, `diagnoseFailures`, `getTestCaseDetail`, `findTestCase` / `findArtifact`, `findModule`, `appendTestSteps`, `impactSearch`
- Updated workflow templates: analyze-run-failures, scaffold-test-case, search-artifacts, inspect-space

### Changed

- Journey skills aligned with MCPServer PR2 outcome tools (0.2.0); removed interim read-path / append-step gaps
- `builder-orchestration.md`, `playlist-orchestration.md`, `tool-planning.md`, `mcp-building-blocks.md`
- Regenerated tools catalog from MCPServer `feature/mcp-pr2-journeys`

## 1.0.0 — 2026-07-14

### Added

- mcp-skills consumer export under `Tosca/Cloud/MCP` (tag `tosca/cloud/mcp/1.0.0`)
- Python pack sync/validate (`sync_mcp_packs.py`, `validate_pack.py`); removed legacy PowerShell pack scripts

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
- Prerequisites — IDE MCP settings for hosted tenant (skills-only pack)
- `validate_skill.py` — required files for new orchestration and workflows
- `validate_journey_skills.py` — verifies `references/` files exist

## 0.1.1 — 2026-07-07

### Added

- `tosca-cloud-connect` journey skill — hosted tenant MCP setup and tool navigation
- `packages/cursor-pack/` — Cursor plugin, `/tosca-cloud-connect` command
- Tenant connection via IDE Settings → MCP (no connection automation in consumer export)
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
