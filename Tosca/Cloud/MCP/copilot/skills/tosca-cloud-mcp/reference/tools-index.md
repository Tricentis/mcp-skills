# MCP tools index

Quick lookup. Noun tools use `operation` enums. Wire form: `tosca_<entity>` (read) / `tosca_<entity>_edit` (mutate), plus domain verbs for DI.

## Noun tools (authoring + execution)

### module
- `tosca_module` — Get, Search (`scope`: All \| StandardObjects \| UserAssets)
- `tosca_module_edit` — Upsert, Delete, Scan, Rescan (User assets only)

### testcase
- `tosca_testcase` — Get
- `tosca_testcase_edit` — Upsert, Delete, UploadRecording
### testcasetemplate
- `tosca_testcasetemplate` — Get (read-only; TestCaseDesign entitlement; find via `tosca_asset` Search `artifactType=testCaseTemplate`)

### teststep
- `tosca_teststep` — Get, List (`testCase` / `rtsb` / `testCaseTemplate`)
- `tosca_teststep_edit` — Upsert, Delete, Move (steps, folders, if/while/do/else control flow, recovery/cleanup scenarios, `testStepFolderReference`; same container types. `rtsbId` only when inserting a reference)

### rtsb (reusable test step block)
- `tosca_rtsb` — Get (read-only)
- `tosca_rtsb_edit` — Upsert, Delete

### testoutline
- `tosca_testoutline` — Get, GetByExternalId (read-only; manual steps synced from qTest and other sources)

### requirement
- `tosca_requirement` — Get, ListSets, GetSet, ListFolders, GetFolder
- `tosca_requirement_edit` — Upsert, Delete, Link, Unlink, LinkPlaylist, UnlinkPlaylist, sets, folders, playlist configurations, test-sheet mapping

### testrun (personal / Builder trial)
- `tosca_testrun` — Get, List
- `tosca_testrun_edit` — Create, Delete

### testsheet (TDM test sheets and classes)
- `tosca_testsheet` — List, Get, ListInstances (read-only; TestCaseDesign entitlement)
- `tosca_testsheet_edit` — Upsert, Delete, AttributeUpsert, AttributeDelete, InstanceUpsert, InstanceDelete, ClassReferenceAdd, ClassReferenceDetach, ConvertToClass, AssignChildInstance, UnassignChildInstance, GenerateRows, RowUpsert, RowDelete

### playlist
- `tosca_playlist` — Get, Search
- `tosca_playlist_edit` — Upsert, Delete, SetTestCases, SetSchedule, FolderUpsert, FolderDelete, FolderMove

### playlistrun
- `tosca_playlistrun` — Get, Search
- `tosca_playlistrun_edit` — Create, Cancel, Delete

## asset
- `tosca_asset` — Search, AdvancedSearch (paginated; no Get)

## asset folder
- `tosca_asset_folder` — Get (omit `folderId` = workspace root)
- `tosca_asset_folder_edit` — Upsert, Delete, Move

## apimessage
- `tosca_apimessage` — Get
- `tosca_apimessage_edit` — Upsert, Delete

## dataintegrity
- `tosca_diconnection` — List, Get
- `tosca_diconnection_edit` — Create, Update, Delete
- `tosca_dataintegrity_checkSqlResult`
- `tosca_dataintegrity_checkTestConnectionResult`
- `tosca_dataintegrity_createLoadCachingDbFromCustomization`
- `tosca_dataintegrity_createRowByRowComparison`
- `tosca_dataintegrity_parseLineageMapping`
- `tosca_dataintegrity_runSql`
- `tosca_dataintegrity_testConnection`

## mobile
- `tosca_mobileconnection` — Get, List
- `tosca_mobileconnection_edit` — Upsert, Delete (Delete also removes linked capability sets)
- `tosca_mobilecapabilityset` — Get, List (always by `connectionId`)
- `tosca_mobilecapabilityset_edit` — Upsert, Delete, SetCapability, DeleteCapability

## simulator
- `tosca_simulator` — List
- `tosca_simulator_edit` — Upsert, Deploy

## apiconnection
- `tosca_apiconnection` — Get, List (optional `name` filter)
- `tosca_apiconnection_edit` — Create, Update (full replace), Delete

Full parameters: [tools-catalog.md](tools-catalog.md)
