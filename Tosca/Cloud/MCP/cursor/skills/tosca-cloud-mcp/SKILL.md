---
name: tosca-cloud-mcp
description: >-
  Automates Tosca Cloud via noun MCP tools — modules, test cases, test steps, personal
  trial runs, playlists, playlist runs, inventory, test sheets (TDM), API messages, API simulation, and Data Integrity. Use for
  Tosca Cloud automation, /tosca-cloud-mcp, or when Tosca Cloud MCP tools connect. Does NOT
  cover tester journey workflows (see AGENTS.md journey skills).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Henry Fieglein | Fractal
  version: "1.16.0"
---

# Tosca Cloud MCP — space automation

Automate Tosca Cloud through the **HTTP MCP server**. Requires a connected tenant with valid Okta bearer token and configured `spaceId`.

**Naming:** `tosca_<entity>` is read-only (Get / Search / List). `tosca_<entity>_edit` mutates (Upsert, Delete, and entity-specific ops). Long-running work: Create on `_edit`, then poll Get on the read tool (`tosca_testrun_edit` Create → `tosca_testrun` Get; `tosca_playlistrun_edit` Create → `tosca_playlistrun` Get).

**MCP tool names:** bare names when Tosca Cloud is the only MCP server; `tosca-cloud:tosca_asset` when multiple servers are connected.

## Session checklist

```text
Tosca Cloud MCP session:
- [ ] Readiness — when-to-use-mcp.md; tosca_module Search succeeds
- [ ] Mode — code-mode.md OR direct-tool-mode.md
- [ ] Intent — authoring / trial run / playlist / inventory / DI / other (one only)
- [ ] Plan — script or numbered tool table before first mutation
- [ ] Execute — resolve ids before mutate; never invent module attribute paths
- [ ] Verify — Get / Search after mutations; poll runs until terminal
```

## Product flows ↔ tools

Map user goals to the same sequence Tosca Cloud docs describe (create tests → trial run → playlists → agents → results):

| Cloud flow | MCP sequence |
|------------|--------------|
| Find / create / scan modules | `tosca_module` Search/Get → `tosca_module_edit` Upsert / **Scan** / **Rescan** (User assets; Scan returns launcher/portal link — after user finishes, Search `scope=UserAssets` `sort=Latest`) |
| Create / design test case | `tosca_testcase_edit` Upsert → `tosca_teststep_edit` for steps/folders/control flow (if, while, do, else)/recovery + cleanup scenarios |
| Read / edit a test case template | `tosca_asset` Search `artifactType=testCaseTemplate` → `tosca_testcasetemplate` Get → `tosca_teststep_edit` with `testStepContainerType=testCaseTemplate` |
| Test case from a recording | `tosca_testcase_edit` UploadRecording (`recordingResult` passed through unmodified) |
| Read / write reusable step block / test outline | `tosca_rtsb` Get · `tosca_rtsb_edit` Upsert/Delete · `tosca_teststep_edit` with `testStepContainerType=rtsb` and `testStepContainerId` for items · `tosca_testoutline` Get / GetByExternalId (qTest ids) |
| Read / inspect a test sheet (TDM) | `tosca_testsheet` List → Get → ListInstances (rows) |
| Create / edit a test sheet or its rows | `tosca_testsheet` Get → `tosca_testsheet_edit` Upsert / Attribute* / Instance* / ClassReference* / GenerateRows / Row* |
| Requirements coverage | `tosca_requirement` ListSets/GetSet/Get → `tosca_requirement_edit` Link / LinkPlaylist / Upsert |
| Trial run (Builder Run) | `tosca_testrun_edit` Create → `tosca_testrun` Get until terminal (personal agent) |
| Create playlist + schedule | `tosca_playlist_edit` Upsert / SetTestCases / SetSchedule |
| Run playlist (team/cloud or personal) | `tosca_playlistrun_edit` Create → `tosca_playlistrun` Get |
| Inspect results | `tosca_playlistrun` Get/Search or `tosca_testrun` Get/List |
| Find workspace assets | `tosca_asset` Search / AdvancedSearch → Get on the owning noun |
| Manage folders / move artifacts | `tosca_asset` Search → `tosca_asset_folder` Get → `tosca_asset_folder_edit` Upsert / Delete / Move |
| Author API messages | `tosca_apimessage` Get → `tosca_apimessage_edit` Upsert / Delete |
| Deploy API simulation | `tosca_simulator` List → `tosca_simulator_edit` Upsert / Deploy |
| Data Integrity comparison | `tosca_diconnection` List/Get → `runSql` catalog → `createRowByRowComparison` |
| Diagnose / remediate DI failure | `tosca_testrun`/`tosca_playlistrun` Get → DI workflow 04 → confirm → workflow 05 |

## Conditional routing

| User goal | Read first | Then |
|-----------|------------|------|
| Is MCP appropriate? | [when-to-use-mcp.md](when-to-use-mcp.md) | Classify intent below |
| Read-only / audit | [tool-orchestration.md](tool-orchestration.md) | `tosca_asset` Search / playlist Search |
| Edit folders / move assets | [inventory-orchestration.md](inventory-orchestration.md) | `tosca_asset` Search → `tosca_asset_folder` Get → `_edit` |
| Modules / test cases / steps / RTSB / test outlines / templates / test sheets | [builder-orchestration.md](builder-orchestration.md) | module → testcase → teststep / `tosca_testcasetemplate` Get → `tosca_teststep*` `testCaseTemplate` / `tosca_testsheet` → `tosca_testsheet_edit` |
| Requirements | [reference/tools-catalog.md](reference/tools-catalog.md#requirement) | `tosca_requirement` → `tosca_requirement_edit` |
| Trial run (single TC) | [execution-orchestration.md](execution-orchestration.md) | `tosca_testrun_edit` Create → `tosca_testrun` Get/List |
| Playlist / schedule / batch run | [playlist-orchestration.md](playlist-orchestration.md) | playlist → playlistrun |
| Mobile connections / capability sets | [mobile-orchestration.md](mobile-orchestration.md) | `tosca_mobileconnection` List → Get → `_edit` Upsert |
| API connections | [apiexecution-orchestration.md](apiexecution-orchestration.md) | `tosca_apiconnection` List → Get → `_edit` |
| API messages | [builder-orchestration.md](builder-orchestration.md) | `tosca_apimessage` Get → `_edit` Upsert / Delete |
| API simulation | [simulation-orchestration.md](simulation-orchestration.md) | `tosca_simulator` List → `_edit` Upsert / Deploy |
| Data Integrity | [di-orchestration.md](di-orchestration.md) | One DI reference file below |
| Tester journey (analyze, author, explain) | Journey skills — see repo `AGENTS.md` | Pick one journey skill |

## Execution modes

| Mode | When | Document |
|------|------|----------|
| **Code Mode** (preferred) | IDE has code execution / programmatic MCP | [code-mode.md](code-mode.md) |
| **Direct tool mode** (fallback) | MCP tools only, one call per turn | [direct-tool-mode.md](direct-tool-mode.md) |

## Workflow templates (pick one)

| Workflow | File |
|----------|------|
| Connect tenant | [reference/workflows/connect-tenant.md](reference/workflows/connect-tenant.md) |
| Inspect space | [reference/workflows/inspect-space.md](reference/workflows/inspect-space.md) |
| Search artifacts | [reference/workflows/search-artifacts.md](reference/workflows/search-artifacts.md) |
| Manage folder | [reference/workflows/manage-folder.md](reference/workflows/manage-folder.md) |
| Create / edit test case | [reference/workflows/create-testcase.md](reference/workflows/create-testcase.md) |
| Trial run test case | [reference/workflows/trial-run-testcase.md](reference/workflows/trial-run-testcase.md) |
| Create playlist | [reference/workflows/create-playlist.md](reference/workflows/create-playlist.md) |
| Run playlist | [reference/workflows/run-playlist.md](reference/workflows/run-playlist.md) |
| Analyze run failures | [reference/workflows/analyze-run-failures.md](reference/workflows/analyze-run-failures.md) |
| Rename playlist items | [reference/workflows/rename-playlist-items.md](reference/workflows/rename-playlist-items.md) |
| Manage API message | [reference/workflows/manage-api-message.md](reference/workflows/manage-api-message.md) |
| Inspect test sheet | [reference/workflows/inspect-testsheet.md](reference/workflows/inspect-testsheet.md) |
| Manage test sheet | [reference/workflows/manage-testsheet.md](reference/workflows/manage-testsheet.md) |
| Data Integrity intro | [reference/workflows/di-getting-started.md](reference/workflows/di-getting-started.md) |
| DI connection | [reference/workflows/di-connection.md](reference/workflows/di-connection.md) |
| DI DB Expert testcase | [reference/workflows/di-db-expert-testcase.md](reference/workflows/di-db-expert-testcase.md) |
| Mobile connection | [reference/workflows/mobile-connection.md](reference/workflows/mobile-connection.md) |
| API connection | [reference/workflows/api-execution-connection.md](reference/workflows/api-execution-connection.md) |
| Deploy simulation | [reference/workflows/deploy-simulation.md](reference/workflows/deploy-simulation.md) |

## Data Integrity reference (pick one)

Load [di-orchestration.md](di-orchestration.md) first, then **one** file:

| Scenario | File |
|----------|------|
| Index / router | [reference/di/index.md](reference/di/index.md) |
| Overview | [reference/di/overview.md](reference/di/overview.md) |
| Conventions | [reference/di/conventions.md](reference/di/conventions.md) |
| Row-by-row comparison | [reference/di/workflows/01-row-by-row-comparison.md](reference/di/workflows/01-row-by-row-comparison.md) |
| File comparison | [reference/di/workflows/02-file-comparison.md](reference/di/workflows/02-file-comparison.md) |
| Business rules → SQL | [reference/di/workflows/03-business-rules-to-sql.md](reference/di/workflows/03-business-rules-to-sql.md) |
| Analyze DI execution results | [reference/di/workflows/04-analyze-execution-results.md](reference/di/workflows/04-analyze-execution-results.md) |
| Remediate from DI results | [reference/di/workflows/05-remediate-from-results.md](reference/di/workflows/05-remediate-from-results.md) |
| Comparison options / reports | [reference/di/comparison-options-and-reports.md](reference/di/comparison-options-and-reports.md) |
| DB Expert testcase | [reference/workflows/di-db-expert-testcase.md](reference/workflows/di-db-expert-testcase.md) |

## Tool reference (on demand)

| Resource | Purpose |
|----------|---------|
| [reference/tools-catalog.md](reference/tools-catalog.md) | Tool names, ops, and parameters |
| [reference/tools-index.md](reference/tools-index.md) | Quick tool lookup by entity |
| [reference/workflows-index.md](reference/workflows-index.md) | Workflow template index |
| [reference/testcase-structure.md](reference/testcase-structure.md) | TCPs (tenant → workspace → case), folders, steps, recipes |
| [reference/testsheet-structure.md](reference/testsheet-structure.md) | Test sheets, classes, paths, rows, downstream impact (TDM) |
| [reference/playlist-structure.md](reference/playlist-structure.md) | Playlist TCPs (full hierarchy), tcpScope, playlist folders |
| [reference/module-attribute-values.md](reference/module-attribute-values.md) | ActionMode, DataType, cardinality, business types |
| [reference/standard-modules.md](reference/standard-modules.md) | Standard Objects catalog — when to use which; Search/Get for ids |
| [tool-planning.md](tool-planning.md) | Planning primitives |

## Hard rules (all flows)

1. **Search / Get before mutate** — resolve ids; do not invent module attribute paths (Get the module first).
2. **Two run worlds** — `tosca_testrun` ids ≠ `playlistTestCaseRuns[].id` from `tosca_playlistrun`. Never cross-wire.
3. **Personal agent gate** — if `_edit` Create returns `agentLink` / `needsAgent` only, open the link, wait for registration, Create again. Do not invent a run id.
4. **Secrets** — never ask for or echo secrets. Password TCPs: empty shell only; set secrets in the portal via returned `url`. API connections, API messages, and mobile capabilities have a scoped exception for user-volunteered values — see [safety-and-space.md](../tosca-cloud-basics/references/safety-and-space.md#secrets).
5. **Portal `url`** — present on Get responses only (not Search summaries).
6. **Confirm** before Delete / hardCancel / destructive connection deletes / API message Upsert-update and Delete / test sheet Delete (incl. `force`), AttributeDelete, RowDelete, attribute or row renames, ClassReferenceDetach and ConvertToClass.

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| Tosca Cloud tenant | `https://{tenant}.my.tricentis.com` (production) |
| MCP connected | Okta via IDE MCP settings or Cursor pack |
| Space configured | `spaceId` in MCP URL path |
| Agents | Trial runs need a personal agent; playlist runs default to team/cloud agents |

## When MCP is unavailable

Use the Tosca Cloud portal UI.

## Journey skills (tester workflows)

For analyze / remediate / author / explain journeys, use the journey skills installed beside this skill, starting with [tosca-cloud-basics](../tosca-cloud-basics/SKILL.md). This skill handles tool orchestration; journey skills handle user-story workflows.
