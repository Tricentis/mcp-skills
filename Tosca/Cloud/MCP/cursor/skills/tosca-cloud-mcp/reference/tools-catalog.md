# Tosca Cloud MCP tools catalog

Generated from the Tosca Cloud MCP tool registry. Load **tool-planning.md** from the skill root to build **Code Mode** sequences.

> **Progressive disclosure:** open parameter details only for tools in your plan. For Data Integrity, load **di-orchestration.md** then one file from **reference/di/index.md**.

| Tool | Domain | Read-only | Destructive | Description |
|------|--------|-----------|-------------|-------------|
| `tosca_apiexecution_createConnection` | apiexecution | no | no |  |
| `tosca_apiexecution_deleteConnection` | apiexecution | no | yes |  |
| `tosca_apiexecution_getConnection` | apiexecution | yes | no |  |
| `tosca_apiexecution_listConnections` | apiexecution | yes | no |  |
| `tosca_apiexecution_updateConnection` | apiexecution | no | yes |  |
| `tosca_builder_createApiMessage` | builder | no | no |  |
| `tosca_builder_deleteApiMessage` | builder | no | yes |  |
| `tosca_builder_getApiMessage` | builder | yes | no |  |
| `tosca_builder_getModulesSummary` | builder | yes | no | Returns a summary list of all available modules with their properties (name, description, tags) |
| `tosca_builder_scaffoldTestCase` | builder | — | no | Creates a scaffold of a test case with the specific name, optional description. |
| `tosca_builder_updateApiMessage` | builder | no | yes |  |
| `tosca_dataintegrity_checkSchemaResult` | dataintegrity | yes | no | The notificationId returned by tosca_dataintegrity_getConnectionSchema. |
| `tosca_dataintegrity_checkTestConnectionResult` | dataintegrity | yes | no | The notificationId returned by tosca_dataintegrity_testConnection. |
| `tosca_dataintegrity_connection` | dataintegrity | no | yes |  |
| `tosca_dataintegrity_createDiDbExpertTestcase` | dataintegrity | no | no | Creates a Data Integrity test case using the DI DB Expert module with a prefilled database connection |
| `tosca_dataintegrity_createRowByRowComparison` | dataintegrity | no | no | Creates a Data Integrity test case that performs a row-by-row comparison between a source and target endpoint. |
| `tosca_dataintegrity_getConnectionSchema` | dataintegrity | no | no | The unique identifier (Ulid string) of the DI connection to query. |
| `tosca_dataintegrity_listConnections` | dataintegrity | yes | no |  |
| `tosca_dataintegrity_testConnection` | dataintegrity | no | no | The unique identifier (Ulid string) of the DI connection to test. |
| `tosca_dataintegrity_workflow` | dataintegrity | yes | no | REQUIRED — call this FIRST before any other Data Integrity tool. Returns the full workflow guide, available tools, and step-by-step examples. MANDATORY NEXT STEP: The output may be large. Your MCP client may save it to a file and return a file path instead of the full content. Whether you receive the content inline or as a file path, you MUST read the complete contents before calling any other DI tool — a truncated preview is NOT sufficient. Section index (use to jump directly to the relevant section after reading): - Available tools overview → "## Available Tools" - Row-by-row comparison w... |
| `tosca_execution_getPlaylistIdsByName` | execution | yes | — | Get playlist ID by its name. Only the first 50 matches are returned. |
| `tosca_execution_getRecentRunLogs` | execution | yes | — | Get recent runs logs, one failed, one passed, for specified playlist. |
| `tosca_inventory_advancedSearch` | inventory | yes | no | Enhanced inventory search with pagination, full-text search, sort, and rich filter operators. |
| `tosca_inventory_createFolder` | inventory | no | no | This tool allows you to create a new folder. You need to provide the folder name, and optionally, a description, tags and the entity ID of the parent folder. |
| `tosca_inventory_deleteFolder` | inventory | no | yes | Deletes a folder by its entity ID. Omit ChildBehavior on the first call to inspect which deletion behaviors are allowed. Then call again with one of: Abort, DeleteRecursively, MoveToParent. |
| `tosca_inventory_modifyFolder` | inventory | no | no | Modifies a folder's name and/or color in a single operation. Provide the folder entity ID together with any combination of a new name, a new color, or removeColor. |
| `tosca_inventory_move` | inventory | no | no | This tool allows you to move artifacts (test cases, modules, shared actions, playlists, folders, etc...) to a different folder. Currently this tool only supports moving artifacts within the same workspace. You need to provide a list of artifact keys (EntityId and Type) to move, and optionally, the entity ID of the destination folder. If the destination folder is not provided, the artifacts will be moved to the root level. |
| `tosca_inventory_search` | inventory | yes | no | This tool allows you to search for artifacts. |
| `tosca_mobile_addCapabilitySet` | mobile | no | no |  |
| `tosca_mobile_createConnection` | mobile | no | no |  |
| `tosca_mobile_deleteCapability` | mobile | no | yes |  |
| `tosca_mobile_deleteConnection` | mobile | no | yes |  |
| `tosca_mobile_getConnection` | mobile | yes | no |  |
| `tosca_mobile_listConnections` | mobile | yes | no |  |
| `tosca_mobile_removeCapabilitySet` | mobile | no | yes |  |
| `tosca_mobile_renameCapabilitySet` | mobile | no | no |  |
| `tosca_mobile_setCapability` | mobile | no | no |  |
| `tosca_mobile_updateConnection` | mobile | no | no |  |
| `tosca_organization_listWorkspaces` | organization | yes | no |  |
| `tosca_playlist_add` | playlist | — | no | Creates a playlist with the given input. |
| `tosca_playlist_analyzeTestCaseItems` | playlist | yes | — | Analyzes test case items and provides contextual information for semantic naming. |
| `tosca_playlist_applyTestCaseItemRenames` | playlist | — | — | Applies confirmed test case item renames. |
| `tosca_playlist_deleteById` | playlist | — | yes | Delete playlist by id. |
| `tosca_playlist_getFailedTestSteps` | playlist | yes | — | Gets the failed test steps of all the failed test cases of runs with the given ids. |
| `tosca_playlist_getRecentRuns` | playlist | yes | — | Searches the most recent runs that match given filters and returns their ids. |
| `tosca_playlist_run` | playlist | — | no | Run a playlist and return the run ID. |
| `tosca_playlist_searchByName` | playlist | yes | — | Gets playlists that contain the given text in the name. |
| `tosca_playlist_updateRunSchedule` | playlist | — | — | Updates, adds or removes the playlist run schedule. |
| `tosca_simulation_create` | simulation | — | no | The simulation file in YAML format |
| `tosca_simulation_deploy` | simulation | — | — | Deploys a simulation to a simulator |
| `tosca_simulation_listAgents` | simulation | yes | — | List simulatior agents where simulation files can be deployed to. it contains a list of simulator agents with their ids and states and version |

## By domain

### apiexecution

- **`tosca_apiexecution_createConnection`** — 
  - Source: `src/McpService/Tools/ApiExecution/CreateConnection/CreateConnectionTool.cs`
- **`tosca_apiexecution_deleteConnection`** (destructive) — 
  - Source: `src/McpService/Tools/ApiExecution/DeleteConnection/DeleteConnectionTool.cs`
- **`tosca_apiexecution_getConnection`** (read-only) — 
  - Source: `src/McpService/Tools/ApiExecution/GetConnection/GetConnectionTool.cs`
- **`tosca_apiexecution_listConnections`** (read-only) — 
  - Source: `src/McpService/Tools/ApiExecution/ListConnections/ListConnectionsTool.cs`
- **`tosca_apiexecution_updateConnection`** (destructive) — 
  - Source: `src/McpService/Tools/ApiExecution/UpdateConnection/UpdateConnectionTool.cs`

### builder

- **`tosca_builder_createApiMessage`** — 
  - Source: `src/McpService/Tools/Builder/ApiMessages/CreateApiMessage/CreateApiMessageTool.cs`
- **`tosca_builder_deleteApiMessage`** (destructive) — 
  - Source: `src/McpService/Tools/Builder/ApiMessages/DeleteApiMessage/DeleteApiMessageTool.cs`
- **`tosca_builder_getApiMessage`** (read-only) — 
  - Source: `src/McpService/Tools/Builder/ApiMessages/GetApiMessage/GetApiMessageTool.cs`
- **`tosca_builder_getModulesSummary`** (read-only) — Returns a summary list of all available modules with their properties (name, description, tags)
  - Source: `src/McpService/Tools/Builder/GetModulesSummary/GetModulesSummaryTool.cs`
- **`tosca_builder_scaffoldTestCase`** — Creates a scaffold of a test case with the specific name, optional description.
  - Source: `src/McpService/Tools/Builder/ScaffoldTestCase/ScaffoldTestCaseTool.cs`
- **`tosca_builder_updateApiMessage`** (destructive) — 
  - Source: `src/McpService/Tools/Builder/ApiMessages/UpdateApiMessage/UpdateApiMessageTool.cs`

### dataintegrity

- **`tosca_dataintegrity_checkSchemaResult`** (read-only) — The notificationId returned by tosca_dataintegrity_getConnectionSchema.
  - Source: `src/McpService/Tools/DataIntegrity/GetConnectionSchema/GetConnectionSchemaTool.cs`
- **`tosca_dataintegrity_checkTestConnectionResult`** (read-only) — The notificationId returned by tosca_dataintegrity_testConnection.
  - Source: `src/McpService/Tools/DataIntegrity/TestConnection/TestConnectionTool.cs`
- **`tosca_dataintegrity_connection`** (destructive) — 
  - Source: `src/McpService/Tools/DataIntegrity/Connection/ConnectionTool.cs`
- **`tosca_dataintegrity_createDiDbExpertTestcase`** — Creates a Data Integrity test case using the DI DB Expert module with a prefilled database connection
  - Source: `src/McpService/Tools/DataIntegrity/CreateDiDbExpertTestcase/CreateDiDbExpertTestcaseTool.cs`
- **`tosca_dataintegrity_createRowByRowComparison`** — Creates a Data Integrity test case that performs a row-by-row comparison between a source and target endpoint.
  - Source: `src/McpService/Tools/DataIntegrity/CreateRowByRowComparison/CreateRowByRowComparisonTool.cs`
- **`tosca_dataintegrity_getConnectionSchema`** — The unique identifier (Ulid string) of the DI connection to query.
  - Source: `src/McpService/Tools/DataIntegrity/GetConnectionSchema/GetConnectionSchemaTool.cs`
- **`tosca_dataintegrity_listConnections`** (read-only) — 
  - Source: `src/McpService/Tools/DataIntegrity/ListConnections/ListConnectionsTool.cs`
- **`tosca_dataintegrity_testConnection`** — The unique identifier (Ulid string) of the DI connection to test.
  - Source: `src/McpService/Tools/DataIntegrity/TestConnection/TestConnectionTool.cs`
- **`tosca_dataintegrity_workflow`** (read-only) — REQUIRED — call this FIRST before any other Data Integrity tool. Returns the full workflow guide, available tools, and step-by-step examples. MANDATORY NEXT STEP: The output may be large. Your MCP client may save it to a file and return a file path instead of the full content. Whether you receive the content inline or as a file path, you MUST read the complete contents before calling any other DI tool — a truncated preview is NOT sufficient. Section index (use to jump directly to the relevant section after reading): - Available tools overview → "## Available Tools" - Row-by-row comparison w...
  - Source: `src/McpService/Tools/DataIntegrity/Workflow/DiWorkflowTool.cs`

### execution

- **`tosca_execution_getPlaylistIdsByName`** (read-only) — Get playlist ID by its name. Only the first 50 matches are returned.
  - Source: `src/McpService/Tools/Execution/ExecutionComparisonTool.cs`
- **`tosca_execution_getRecentRunLogs`** (read-only) — Get recent runs logs, one failed, one passed, for specified playlist.
  - Source: `src/McpService/Tools/Execution/ExecutionComparisonTool.cs`

### inventory

- **`tosca_inventory_advancedSearch`** (read-only) — Enhanced inventory search with pagination, full-text search, sort, and rich filter operators.
  - Source: `src/McpService/Tools/Inventory/AdvancedSearchArtifactsTool.cs`
- **`tosca_inventory_createFolder`** — This tool allows you to create a new folder. You need to provide the folder name, and optionally, a description, tags and the entity ID of the parent folder.
  - Source: `src/McpService/Tools/Inventory/CreateFolderTool.cs`
- **`tosca_inventory_deleteFolder`** (destructive) — Deletes a folder by its entity ID. Omit ChildBehavior on the first call to inspect which deletion behaviors are allowed. Then call again with one of: Abort, DeleteRecursively, MoveToParent.
  - Source: `src/McpService/Tools/Inventory/DeleteFolderTool.cs`
- **`tosca_inventory_modifyFolder`** — Modifies a folder's name and/or color in a single operation. Provide the folder entity ID together with any combination of a new name, a new color, or removeColor.
  - Source: `src/McpService/Tools/Inventory/ModifyFolderTool.cs`
- **`tosca_inventory_move`** — This tool allows you to move artifacts (test cases, modules, shared actions, playlists, folders, etc...) to a different folder. Currently this tool only supports moving artifacts within the same workspace. You need to provide a list of artifact keys (EntityId and Type) to move, and optionally, the entity ID of the destination folder. If the destination folder is not provided, the artifacts will be moved to the root level.
  - Source: `src/McpService/Tools/Inventory/MoveArtifactsTool.cs`
- **`tosca_inventory_search`** (read-only) — This tool allows you to search for artifacts.
  - Source: `src/McpService/Tools/Inventory/SearchArtifactsTool.cs`

### mobile

- **`tosca_mobile_addCapabilitySet`** — 
  - Source: `src/McpService/Tools/Mobile/AddCapabilitySet/AddCapabilitySetTool.cs`
- **`tosca_mobile_createConnection`** — 
  - Source: `src/McpService/Tools/Mobile/CreateConnection/CreateConnectionTool.cs`
- **`tosca_mobile_deleteCapability`** (destructive) — 
  - Source: `src/McpService/Tools/Mobile/DeleteCapability/DeleteCapabilityTool.cs`
- **`tosca_mobile_deleteConnection`** (destructive) — 
  - Source: `src/McpService/Tools/Mobile/DeleteConnection/DeleteConnectionTool.cs`
- **`tosca_mobile_getConnection`** (read-only) — 
  - Source: `src/McpService/Tools/Mobile/GetConnection/GetConnectionTool.cs`
- **`tosca_mobile_listConnections`** (read-only) — 
  - Source: `src/McpService/Tools/Mobile/ListConnections/ListConnectionsTool.cs`
- **`tosca_mobile_removeCapabilitySet`** (destructive) — 
  - Source: `src/McpService/Tools/Mobile/RemoveCapabilitySet/RemoveCapabilitySetTool.cs`
- **`tosca_mobile_renameCapabilitySet`** — 
  - Source: `src/McpService/Tools/Mobile/RenameCapabilitySet/RenameCapabilitySetTool.cs`
- **`tosca_mobile_setCapability`** — 
  - Source: `src/McpService/Tools/Mobile/SetCapability/SetCapabilityTool.cs`
- **`tosca_mobile_updateConnection`** — 
  - Source: `src/McpService/Tools/Mobile/UpdateConnection/UpdateConnectionTool.cs`

### organization

- **`tosca_organization_listWorkspaces`** (read-only) — 
  - Source: `src/McpService/Tools/Organization/ListWorkspacesTool.cs`

### playlist

- **`tosca_playlist_add`** — Creates a playlist with the given input.
  - Source: `src/McpService/Tools/Playlist/GeneralTools/PlaylistTools.cs`
- **`tosca_playlist_analyzeTestCaseItems`** (read-only) — Analyzes test case items and provides contextual information for semantic naming.
  - Source: `src/McpService/Tools/Playlist/RenameTestCaseItems/RenameTestCaseItemsTool.cs`
- **`tosca_playlist_applyTestCaseItemRenames`** — Applies confirmed test case item renames.
  - Source: `src/McpService/Tools/Playlist/RenameTestCaseItems/RenameTestCaseItemsTool.cs`
- **`tosca_playlist_deleteById`** (destructive) — Delete playlist by id.
  - Source: `src/McpService/Tools/Playlist/GeneralTools/PlaylistTools.cs`
- **`tosca_playlist_getFailedTestSteps`** (read-only) — Gets the failed test steps of all the failed test cases of runs with the given ids.
  - Source: `src/McpService/Tools/Playlist/GetFailedTestSteps/GetFailedTestStepsTool.cs`
- **`tosca_playlist_getRecentRuns`** (read-only) — Searches the most recent runs that match given filters and returns their ids.
  - Source: `src/McpService/Tools/Playlist/SearchRuns/SearchRunsTool.cs`
- **`tosca_playlist_run`** — Run a playlist and return the run ID.
  - Source: `src/McpService/Tools/Playlist/GeneralTools/PlaylistRunTools.cs`
- **`tosca_playlist_searchByName`** (read-only) — Gets playlists that contain the given text in the name.
  - Source: `src/McpService/Tools/Playlist/GeneralTools/PlaylistTools.cs`
- **`tosca_playlist_updateRunSchedule`** — Updates, adds or removes the playlist run schedule.
  - Source: `src/McpService/Tools/Playlist/GeneralTools/PlaylistTools.cs`

### simulation

- **`tosca_simulation_create`** — The simulation file in YAML format
  - Source: `src/McpService/Tools/Simulation/ApiSimulationTools.cs`
- **`tosca_simulation_deploy`** — Deploys a simulation to a simulator
  - Source: `src/McpService/Tools/Simulation/ApiSimulationTools.cs`
- **`tosca_simulation_listAgents`** (read-only) — List simulatior agents where simulation files can be deployed to. it contains a list of simulator agents with their ids and states and version
  - Source: `src/McpService/Tools/Simulation/ApiSimulationTools.cs`

