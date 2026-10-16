# MCP building blocks — Tosca Cloud

## Discovery

```text
tosca_asset Search(...) / AdvancedSearch(...)
tosca_module Search / Get
tosca_playlist Search / Get
tosca_testcase Get
tosca_teststep Get / List
```

## Inventory

```text
tosca_asset Search / AdvancedSearch
tosca_asset_folder Get                      # omit folderId = workspace root
tosca_asset_folder_edit Upsert / Delete / Move
```

## Authoring

```text
tosca_module_edit Upsert / Delete / Scan / Rescan  # User assets; Scan/Rescan kick off scanner
tosca_testcase_edit Upsert / Delete
tosca_teststep_edit Upsert / Delete / Move
tosca_apimessage Get                      # API messages
tosca_apimessage_edit Upsert / Delete
tosca_testsheet List / Get / ListInstances   # TDM test sheets, classes, rows
tosca_testsheet_edit Upsert / Delete / AttributeUpsert / AttributeDelete / InstanceUpsert / InstanceDelete
tosca_testsheet_edit ClassReferenceAdd / ClassReferenceDetach / ConvertToClass / AssignChildInstance / UnassignChildInstance
tosca_testsheet_edit GenerateRows / RowUpsert / RowDelete
```

## Execution

```text
tosca_testrun Get / List               # personal trial catalog + poll
tosca_testrun_edit Create / Delete     # start / remove personal trial run
tosca_playlist_edit Upsert / SetTestCases / SetSchedule / Delete
tosca_playlistrun_edit Create / Cancel / Delete
tosca_playlistrun Get / Search             # results + failed steps + URIs
```

## Data Integrity

Async tools need polling via `check*Result` companions. See `tosca-cloud-mcp` → `di-orchestration.md`.

```text
tosca_diconnection List / Get
tosca_diconnection_edit Create / Update / Delete
tosca_dataintegrity_runSql / checkSqlResult          # schema = catalog SELECT
tosca_dataintegrity_testConnection / checkTestConnectionResult
tosca_dataintegrity_createRowByRowComparison
```

## Mobile / API execution / Simulation

```text
tosca_mobileconnection Get / List
tosca_mobileconnection_edit Upsert / Delete
tosca_mobilecapabilityset Get / List                # always by connectionId
tosca_mobilecapabilityset_edit Upsert / Delete / SetCapability / DeleteCapability
tosca_apiconnection Get / List
tosca_apiconnection_edit Create / Update / Delete
tosca_simulator List
tosca_simulator_edit Upsert / Deploy
```

## Response handling

Most tools return JSON strings. Parse in Code Mode; summarize for the user in direct tool mode. Portal `url` appears on Get, not on Search summaries. Secrets: [safety-and-space.md](safety-and-space.md#secrets).
