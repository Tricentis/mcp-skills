# Tosca Cloud object model

## Artifact types

| Type | `artifactType` value | Purpose |
|------|----------------------|---------|
| Folder | `folder` | Organizational container |
| Test case | `testCase` | Executable test definition |
| Module | `module` | Reusable automation building block |
| Reuseable test step block (RTSB) | `sharedAction` | Reusable step sequence |
| API message | `apiMessage` | API test message definition |
| Playlist | `playlist` | Collection of tests to run |
| Test case template | `testCaseTemplate` | Reusable TestCaseDesign template; Get via `tosca_testcasetemplate`; steps via `tosca_teststep` / `_edit` with `testCaseTemplate` |

## Authoring model

- **Module** — Standard Objects (packages, Get-only) or User assets (editable). Scan/Rescan via `tosca_module_edit` kicks off the Cloud scanner (agent opens link; user finishes scan).
- **Test case** — `name` + `description` + `workState` (Planned | InWork | Completed) + `tcp[]` + `parameterSetIds` + ordered `items[]` (test steps, folders, if/while/do blocks, recovery/cleanup scenarios).
- **Reusable test step block (RTSB)** — `sharedAction` in inventory; Get via `tosca_rtsb`, create/update/delete via `tosca_rtsb_edit`, items via `tosca_teststep_edit` with `testStepContainerType=rtsb` and `testStepContainerId`; appears in test cases as `testStepFolderReference`.
- **Test case template** — TestCaseDesign artifact (`testCaseTemplate` in inventory); Get via `tosca_testcasetemplate` (`testCaseTemplateId` from `tosca_asset` Search). Edit items with `tosca_teststep_edit` and `testStepContainerType=testCaseTemplate`. Do not use `tosca_testcase` Get.
- **Test sheet** — TestCaseDesign test data (TDM): attributes, their instances (possible values) and rows; a template's `testSheetId` points to one. Read via `tosca_testsheet` (List — not `tosca_asset`), edit via `tosca_testsheet_edit`.
- **Class** — reusable attribute block embedded in sheets as a class reference; same tools (`includeClasses` on List).
- **Test case instance (row)** — one combination of instances in a sheet; `tosca_testsheet` ListInstances, `tosca_testsheet_edit` GenerateRows / RowUpsert / RowDelete. Row ids feed `tosca_requirement_edit` LinkTestSheet.
- **Test outline** — manual steps synced from qTest and other sources onto a test case; read via `tosca_testoutline`.
- **Requirements** — folders → requirement sets → requirements with test-case and playlist links; `tosca_requirement` / `_edit` (Requirements entitlement).
- **Test step** — references a `moduleId` and sets `values[]` on attribute paths.
- **TCP** — String/Boolean/Password; Password values never flow through MCP.

## Execution model

| Kind | Tool | Agent |
|------|------|-------|
| Trial / Builder debug run | `tosca_testrun` Get/List; `tosca_testrun_edit` Create/Delete | Personal |
| Playlist run | `tosca_playlistrun` | Team/cloud (default) or personal |

- **Playlist** — named collection of test case items; optional `cronSchedule`, `runMode`, `runOnlyOnCloudAgents`, `agentCharacteristics[]`.
- **Playlist run** — one execution; states Pending → Running → Succeeded/Failed/Canceled/…
- Failed step detail arrives on `tosca_playlistrun` Get (inline failed steps + URI attachments).

## Search fields

`tosca_asset` Search supports: `artifactType`, `name`, `createdFrom`/`createdTo`, `updatedFrom`/`updatedTo`, `createdBy`, `updatedBy`, `folderId`, `tags`. AdvancedSearch adds `searchTerm`, `sort[]`, nested `filters`, `includeAncestors`, and pagination (`pageSize` / `pageToken`). Hits return camelCase `id` (no portal `url`).

Playlist Search uses curated name/description/date/sort/page filters on `tosca_playlist`.
