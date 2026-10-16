# Tosca Cloud MCP tools catalog

Noun-tool surface for modules, test cases, steps, trial runs, playlists, playlist runs, test sheets (TDM), API messages, and simulators, plus inventory / DI / mobile / API companions.

> **Progressive disclosure:** open parameter details only for tools in your plan. For Data Integrity, load **di-orchestration.md** then one file from **reference/di/index.md**.

## Noun tools

| Tool | Ops | Read-only | Destructive | Key parameters |
|------|-----|-----------|-------------|----------------|
| `tosca_module` | Get, Search | yes | no | `moduleId` (Get); `name?`, `scope` All\|StandardObjects\|UserAssets (Search) |
| `tosca_module_edit` | Upsert, Delete, Scan, Rescan | no | yes | Create: `name`, optional `attributes[]`, `interfaceType` (default NonGui), `parentFolderId`. Update: omit=no change; `attributes[]` replaces whole tree. Scan: `engine` (Html, Desktop, Salesforce, Pdf, ME3.0, Host, IBTA, File, WebDriver; ME3.0 + `connectionId` + `capabilitySetIds`) → `launcherLink` / `portalUrl`. Rescan: `moduleId` |
| `tosca_testcase` | Get | yes | no | `testCaseId` → url, workState, tcp[] (merged inherited), parameterSetIds, items[] |
| `tosca_testcase_edit` | Upsert, Delete, UploadRecording | no | no* | Create: `name`, optional `workState` (Planned\|InWork\|Completed, default InWork), `steps[{moduleId,values}]`, tcp[], parameterSetIds. Update: omit=no change; `tcp=[]` clears. UploadRecording: `recordingResult` (unmodified recorder JSON), `testCaseId?` (set = replace in place), `parentFolderId?`, `autoMerge?` |
| `tosca_testcasetemplate` | Get | yes | no | `testCaseTemplateId` (the hit `id` from `tosca_asset` Search `artifactType=testCaseTemplate`) → portalUrl, workState, tcp[], parameterSetIds, testSheetId, instantiationCondition, items[] (with per-item instantiationCondition / xlBasePath). TestCaseDesign entitlement. Do not call `tosca_testcase` Get for a template id. |
| `tosca_teststep` | Get, List | yes | no | Get/List: `testStepContainerType` testCase\|rtsb\|testCaseTemplate + `testStepContainerId`. Get: +`itemId` (control-flow → `branches[]`). List: +`parentId` (container root, folder, control-flow branch, or scenario). Template Get/List include per-item instantiationCondition / xlBasePath when set |
| `tosca_teststep_edit` | Upsert, Delete, Move | no | no* | Same container as Get. Insert: `kind` testStep\|testStepFolder\|testStepFolderReference\|if\|while\|do\|else\|recoveryScenario\|cleanupScenario, `moduleId`/`name`, `values[]`, `includeElse` (if), `maximumRepetitions` (while/do), `retryLevel` (recovery: TestStep\|TestStepValue\|TestCase). `rtsbId` only for `kind: testStepFolderReference` (the block to reuse, not the container). Template only: `instantiationCondition` / `xlBasePath` (empty string clears). Move: `itemId`+`parentId`+`toIndex`. Delete: `itemIds[]` (incl. ELSE branch id), `recursive?` |
| `tosca_rtsb` | Get | yes | no | `rtsbId` (from `tosca_asset` Search `artifactType=sharedAction`) → name, version, parameterLayerId, businessParameters[], items[] |
| `tosca_rtsb_edit` | Upsert, Delete | no | yes | Create: omit `rtsbId`, `name` required. Update: `rtsbId` + name / description / `businessParameters[]`. Delete: `rtsbId`; reports `usages[]` and refuses unless `force`. Items belong on `tosca_teststep_edit` with `testStepContainerType=rtsb` and `testStepContainerId` |
| `tosca_testoutline` | Get, GetByExternalId | yes | no | Get: `testCaseId`. GetByExternalId: `externalTenantId`+`externalProjectId`+`externalTestCaseId` (+ returns `workspaceId`/`workspacePath`) → groups[].steps[] {order, description, expectedResult}. No search |
| `tosca_testrun` | Get, List | yes | no | Get: `testRunId`. List: optional `name` (contains), `state`, `pageSize`/`pageToken`. Hits include `personal`. Personal Builder catalog |
| `tosca_testrun_edit` | Create, Delete | no | yes | Create: `testCaseId`, `testStepIds[]?`. Delete: `testRunId`. May return `needsAgent` + `agentLink` only |
| `tosca_playlist` | Get, Search | yes | no | Get: `playlistId` → url, merged `tcp[]` (root + items), item `path`. Search: name/description/dates/sort/page — summaries without url |
| `tosca_playlist_edit` | Upsert, Delete, SetTestCases, SetSchedule, FolderUpsert, FolderDelete, FolderMove | no | yes | `tcp[]`+`tcpScope`, `parameterSetIds`, folder path ops, `runMode`, `runOnlyOnCloudAgents`, `agentCharacteristics[{name,value}]` (omit = keep, `[]` = clear), `cronExpression` (null clears) |
| `tosca_playlistrun` | Get, Search | yes | no | Get: exactly one of playlistRunId \| playlistId \| playlistName. Search: playlistName?, state?, page |
| `tosca_playlistrun_edit` | Create, Cancel, Delete | no | yes | Create: `playlistId`, `runOnAPersonalAgent` (default false), partial `testCaseIds[]` (playlist item ids). Cancel: `hardCancel?` |

\*Edit tools for testcase/teststep are mutating (`ReadOnly=false`); confirm Deletes with the user.

Module attribute enums and business types: [module-attribute-values.md](module-attribute-values.md).

### values[] (steps)

`{ path, value?, actionMode?, explicitName? }` — `path` is dot-separated from the module root. Get the module before setting paths.

### TCP / secrets

Password TCP values are never readable or settable via MCP. Create empty Password TCP shells only; set secrets in the portal using the returned `url`. Other secrets: see hard rule 4 in the skill's `SKILL.md`.

### Run id rule

`tosca_testrun` ids ≠ `playlistTestCaseRuns[].id` from `tosca_playlistrun`.

## requirement

Requires the Requirements entitlement.

| Tool | Ops | Read-only | Destructive | Key parameters |
|------|-----|-----------|-------------|----------------|
| `tosca_requirement` | Get, ListSets, GetSet, ListFolders, GetFolder | yes | no | Get: `requirementId` → url, weight, coveragePercent, frequencyClass, damageClass, items[] (requirement \| testCaseLink \| substituteLink). GetSet: `requirementSetId` → items[] (requirement \| playlistConfiguration \| playlistLink). GetFolder: `folderId`. List* take no ids |
| `tosca_requirement_edit` | Upsert, Delete, Link, Unlink, UnassignTestCase, LinkTestSheet, UnlinkTestSheet, DeleteSubstitutes, ReplaceSubstitutes, CreateFolder, RenameFolder, DeleteFolder, CreateSet, RenameSet, DeleteSet, CreatePlaylistConfiguration, RenamePlaylistConfiguration, DeletePlaylistConfiguration, LinkPlaylist, UnlinkPlaylist | no | yes | Upsert create: `name` + `parentId` (set or parent requirement); optional `description`, `frequencyClass`/`damageClass` (0–10), `weight`. Link: `requirementId` + `testCaseId`/`testCaseIds`. LinkPlaylist: `parentId` (set or playlist configuration) + `playlistId`/`playlistIds`. Bulk variants take id lists |

## testsheet

Requires the TestCaseDesign entitlement. Concepts, paths and downstream impact: [testsheet-structure.md](testsheet-structure.md).

| Tool | Ops | Read-only | Destructive | Key parameters |
|------|-----|-----------|-------------|----------------|
| `tosca_testsheet` | List, Get, ListInstances | yes | no | List: `testSheetName?` (contains), `includeClasses` (default false) → `{ total, items[{ id, name, kind, folderPath?, updatedAt, updatedBy }] }`. Get: exactly one of `testSheetId` \| `testSheetName` → url, summary, `attributes[]` tree `{ id, name, path, nodeType group\|attribute\|classReference, businessRelevance, referencedClass?, instances[], attributes[] }`. ListInstances: sheet + `pageSize` (≤200, default 50), `pageToken` → `testCaseInstances[{ id, name, values[] }]` |
| `tosca_testsheet_edit` | Upsert, Delete, AttributeUpsert, AttributeDelete, InstanceUpsert, InstanceDelete, ClassReferenceAdd, ClassReferenceDetach, ConvertToClass, AssignChildInstance, UnassignChildInstance, GenerateRows, RowUpsert, RowDelete | no | yes | Every target: exactly one of id or path/name — `testSheetId\|testSheetName`, `attributeId\|attributePath`, `parentAttributeId\|parentPath` (empty = root), `instanceId\|instanceName`, `classId\|className`, `childAttributeId\|childAttributePath`, `childInstanceId\|childInstanceName`. Upsert create: `name`, `kind` testSheet\|class, `description`, `attributes[]` tree. GenerateRows: `algorithm` linearExpansion\|orthogonal, `preview` (default true). RowUpsert: `rows[{ rowId?, name?, values{ attributePath: instanceName\|null } }]` (≤1000). RowDelete: `rowIds[]`. Delete of a referenced class: `force`. Structural writes return the re-read sheet; row ops return `rows[]`, `skipped[]`, `failed[]`, `url` |

## inventory

| Tool | Ops | Read-only | Destructive | Key parameters |
|------|-----|-----------|-------------|----------------|
| `tosca_asset` | Search, AdvancedSearch | yes | no | Search: `artifactType`, `name`, `folderId` (UUID / empty=root / omit=all), dates, tags, `pageSize`/`pageToken` (default 50). AdvancedSearch adds `searchTerm`, `sort[]`, nested `filters`, `includeAncestors`. Hits `{ id, type, name, tags, section, folderId, createdAt, createdBy, updatedAt, updatedBy }` (+ `ancestors[]` UUID ids). No Get, no portal url — Get the typed artifact on the owning noun |
| `tosca_asset_folder` | Get | yes | no | Omit `folderId` = workspace root `{ id: null, name: "root", children[] }`. With UUID: metadata, `parentFolderId`, `ancestors[]` (bare UUIDs), color, `children[]` (`id` and `entityId` alias). Cross-asset search stays on `tosca_asset` |
| `tosca_asset_folder_edit` | Upsert, Delete, Move | no | yes | Create: omit `folderId`, `name` required; optional `parentFolderId` (omit = root), `description`, `tags[]`. Update: `folderId` + `name` and/or `color` / `removeColor` (not both). Delete: omit `childBehavior` to probe, then Abort \| DeleteRecursively \| MoveToParent. Move: `artifacts[{ entityId, type }]`; `parentFolderId` omit/empty = root |

## apimessage

| Tool | Ops | Read-only | Destructive | Key parameters |
|------|-----|-----------|-------------|----------------|
| `tosca_apimessage` | Get | yes | no | `messageId` → full JSON |
| `tosca_apimessage_edit` | Upsert, Delete | no | yes | Create: omit `messageId`, `request` (`name`, `method`, `endpoint` **or** `connectionId`). Update: `messageId` + full `request`. Delete: `messageId` |

## simulator

| Tool | Ops | Read-only | Destructive | Key parameters |
|------|-----|-----------|-------------|----------------|
| `tosca_simulator` | List | yes | no | No args. Returns agent JSON (id, state, version, hostname, …) |
| `tosca_simulator_edit` | Upsert, Deploy | no | yes | Upsert: `simulation` (YAML) + `name` (`.yaml` / `.yml`); name conflict returns existing file. Deploy: `simulatorId` + `simulationFileId` (guid) |

## dataintegrity / mobile / apiconnection

See [tools-index.md](tools-index.md) for the live list. Load domain orchestration docs before calling.

| Tool | Ops | Notes |
|------|-----|-------|
| `tosca_diconnection` | List, Get | List is unfiltered. Get uses Ulid `connectionId`. Never returns secrets. |
| `tosca_diconnection_edit` | Create, Update, Delete | No password / plaintext connectionString. Cannot set `allowAiQueries`. |
| `tosca_dataintegrity_runSql` | — | Dialect `SELECT` including catalog/schema. Requires `allowAiQueries`. Poll `checkSqlResult`. |
| `tosca_dataintegrity_testConnection` | — | Optional connectivity test. Does not need `allowAiQueries`. |
| `tosca_dataintegrity_createRowByRowComparison` | — | Default write: SQL, `columnRenames`, tolerances, File/Olap/Sap |
| `tosca_mobileconnection` | Get, List | Get returns `{ connection, capabilitySets }` by GUID `connectionId`. List is unfiltered (`$type`: AppiumConnection \| TmaConnection). Secret values omitted. |
| `tosca_mobileconnection_edit` | Upsert, Delete | Create: `name`, `connectionType` Appium \| Tma, `server`, `serverIsSecret` (Appium), optional create-only `capabilitySets[]`. `connectionType` immutable. Delete also removes linked sets. |
| `tosca_mobilecapabilityset` | Get, List | Always by `connectionId` — no get-by-id, no space-wide list. |
| `tosca_mobilecapabilityset_edit` | Upsert, Delete, SetCapability, DeleteCapability | `capabilities[]` create-only; change one capability at a time with SetCapability (reads omit secrets). |
| `tosca_apiconnection` | Get, List | Get by `connectionId` (full properties). List optional `name` filter. |
| `tosca_apiconnection_edit` | Create, Update, Delete | Update is **full replacement** — Get first and carry unchanged fields. Confirm Delete. |
