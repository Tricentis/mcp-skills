# Commander MCP tools catalog

Generated from the Commander MCP server tool registry. Load **tool-planning.md** from the skill root to build **Code Mode** sequences.

> **Progressive disclosure:** open parameter details only for tools in your plan. For Data Integrity, load **di-orchestration.md** then one file from **reference/di/index.md**.

| Tool | Category | Description |
|------|----------|-------------|
| `get_workspace_info` | workspace | Returns information about the currently active workspace. |
| `get_current_selection` | workspace | Returns the objects currently selected in the Commander UI. Each entry contains surrogateId, objectType (e.g. TestCase, Module), name (display name), and nodePath. |
| `get_object_info` | workspace | Resolves one or more objects by surrogate ID or node path. Returns each object's surrogateId, type, name, nodePath, and an error field if resolution failed. Optional arg: include_parent_and_children (default false) adds the direct parent (or null for the workspace root) and direct children of the object; requires exactly one identifier. limit (default 200) and offset (default 0) paginate children; when nextOffset is present, call again with offset=nextOffset (same limit) to fetch the next page. |
| `set_object_selection` | workspace | Selects an object in the workspace by surrogate ID or node path. |
| `get_attributes` | workspace | Lists attributes of one or more Tosca objects. Optional arg: identifiers (array of surrogate IDs or node paths). If omitted or empty, uses the current Commander UI selection — at least one object must be selected. Returns a per-object result containing either the object's attributes (name, current value as string or null if unset, is_readonly flag, value_type as string/bool/int/float/enum/object, allowed_values as array of enum names or null) or an error message when an identifier cannot be resolved. |
| `set_attribute` | workspace | Sets a single writable attribute on a Tosca object. To discover writable attributes first, call get_attributes — only attributes returned with is_readonly=false are accepted here. Args: identifier (surrogate id or node path; required), attribute_name, value (string). Returns an error if the attribute is unknown, hidden (Never visibility), read-only, or if the value cannot be converted to the attribute's type. Writes are in-memory; durability depends on the user saving the workspace. Returns the surrogate id, attribute name, the value before the write (old_value), and the read-back value aft... |
| `list_available_tasks` | workspace | Returns tasks available for the currently selected object(s) in Commander, equivalent to the right-click context menu. Each entry includes the task name and its declared parameters (if any). Pass the name to `execute_task`.                  Optionally pass `objectIds` (surrogate ids or node paths) to scope tasks to specific objects without an active selection. When omitted, the currently selected object(s) are used.                  Tasks that edit, create or delete objects are not visible if the parent object is not checked out. In this case try to run the checkout task for the parent firs... |
| `execute_task` | workspace | Executes the named task against the currently selected object(s). The name must be one returned by `list_available_tasks`.                  Optionally pass `objectIds` (surrogate ids or node paths) to execute the task on specific objects without an active selection. When omitted, the currently selected object(s) are used. |
| `save_workspace` | workspace | Saves pending workspace changes. |
| `check_in_all` | workspace | Checks in all objects currently checked out in the active workspace (Check In All, same as Ctrl+Shift+I). |
| `update_all` | workspace | Pulls the latest object state from the common repository into the active workspace (Update All, same as Ctrl+Shift+U). Multi-user workspaces only; use save_workspace to persist local edits first. |
| `execute_drop_task` | workspace | Programmatically performs a drag-and-drop operation by executing a drop task. Supply a target object, one or more source objects, an optional copy flag, and an optional task name. |
| `create_test_case` | workspace | Creates a test case at the given folder path with optional test steps and requirement links in a single call. The first path segment must reference an existing top-level folder (e.g. 'TestCases'); intermediate segments below it are created automatically. |
| `execute_test_suite` | workspace | Starts execution of a test case or execution list in the background and immediately returns a job ID (async). Supply identifier (surrogate ID or node path). Strictly sequential — only one may run at a time on the Commander UI thread. |
| `execute_test_suite_status` | workspace | Polls the status of an execute_test_suite job. Supply jobId (returned by execute_test_suite). Returns IsRunning (bool) and, when complete, Result with pass/fail details. Poll in a loop until IsRunning=false. |
| `create_api_module` | workspace | Creates an API module at the given folder path. Supply name and path; returns the surrogate ID of the created module. |
| `create_di_db_expert_module` | data-integrity | Creates a Data Integrity 'DB Expert' test case with a test step from the DI DB Expert module. |
| `create_di_load_caching_db_from_customization` | data-integrity | Creates a Data Integrity 'Load Data into Caching Database from Customization' test case. |
| `create_di_row_by_row_comparison` | data-integrity | Creates a Data Integrity 'Complete Row by Row Comparison' test case. |
| `di_connection` | data-integrity | Create, update, delete, list, or get Data Integrity database connections. |
| `get_di_connection_schema` | data-integrity | Returns database schema metadata (tables and columns) for a configured Data Integrity BI connection. NOTE: all columns are returned in a single response with no pagination — on large enterprise schemas (Oracle, DB2) this may be a very large result. Use run_di_sql_statement with a filtered INFORMATION_SCHEMA or catalog query if you only need a subset. |
| `parse_di_lineage_mapping` | data-integrity | Reads a comma-delimited field-mapping CSV exported from a Data Governance tool (e.g. Collibra) and returns |
| `run_di_sql_statement` | data-integrity | Executes a SQL statement against a configured Data Integrity connection via the CLI executor and returns result rows. Provide either connectionId or connectionName. limit (default 200) and offset (default 0) paginate results; when nextOffset is present, call again with offset=nextOffset (same limit) to fetch the next page. NOTE: pagination is applied client-side — the full result set is fetched from the database before slicing. For large tables, add LIMIT/OFFSET (or equivalent) directly in the SQL to avoid transferring unnecessary rows. |

## By category

### data-integrity

- **`create_di_db_expert_module`** — Creates a Data Integrity 'DB Expert' test case with a test step from the DI DB Expert module.
- **`create_di_load_caching_db_from_customization`** — Creates a Data Integrity 'Load Data into Caching Database from Customization' test case.
- **`create_di_row_by_row_comparison`** — Creates a Data Integrity 'Complete Row by Row Comparison' test case.
- **`di_connection`** — Create, update, delete, list, or get Data Integrity database connections.
- **`get_di_connection_schema`** — Returns database schema metadata (tables and columns) for a configured Data Integrity BI connection. NOTE: all columns are returned in a single response with no pagination — on large enterprise schemas (Oracle, DB2) this may be a very large result. Use run_di_sql_statement with a filtered INFORMATION_SCHEMA or catalog query if you only need a subset.
- **`parse_di_lineage_mapping`** — Reads a comma-delimited field-mapping CSV exported from a Data Governance tool (e.g. Collibra) and returns
- **`run_di_sql_statement`** — Executes a SQL statement against a configured Data Integrity connection via the CLI executor and returns result rows. Provide either connectionId or connectionName. limit (default 200) and offset (default 0) paginate results; when nextOffset is present, call again with offset=nextOffset (same limit) to fetch the next page. NOTE: pagination is applied client-side — the full result set is fetched from the database before slicing. For large tables, add LIMIT/OFFSET (or equivalent) directly in the SQL to avoid transferring unnecessary rows.

### workspace

- **`get_workspace_info`** — Returns information about the currently active workspace.
- **`get_current_selection`** — Returns the objects currently selected in the Commander UI. Each entry contains surrogateId, objectType (e.g. TestCase, Module), name (display name), and nodePath.
- **`get_object_info`** — Resolves one or more objects by surrogate ID or node path. Returns each object's surrogateId, type, name, nodePath, and an error field if resolution failed. Optional arg: include_parent_and_children (default false) adds the direct parent (or null for the workspace root) and direct children of the object; requires exactly one identifier. limit (default 200) and offset (default 0) paginate children; when nextOffset is present, call again with offset=nextOffset (same limit) to fetch the next page.
- **`set_object_selection`** — Selects an object in the workspace by surrogate ID or node path.
- **`get_attributes`** — Lists attributes of one or more Tosca objects. Optional arg: identifiers (array of surrogate IDs or node paths). If omitted or empty, uses the current Commander UI selection — at least one object must be selected. Returns a per-object result containing either the object's attributes (name, current value as string or null if unset, is_readonly flag, value_type as string/bool/int/float/enum/object, allowed_values as array of enum names or null) or an error message when an identifier cannot be resolved.
- **`set_attribute`** — Sets a single writable attribute on a Tosca object. To discover writable attributes first, call get_attributes — only attributes returned with is_readonly=false are accepted here. Args: identifier (surrogate id or node path; required), attribute_name, value (string). Returns an error if the attribute is unknown, hidden (Never visibility), read-only, or if the value cannot be converted to the attribute's type. Writes are in-memory; durability depends on the user saving the workspace. Returns the surrogate id, attribute name, the value before the write (old_value), and the read-back value aft...
- **`list_available_tasks`** — Returns tasks available for the currently selected object(s) in Commander, equivalent to the right-click context menu. Each entry includes the task name and its declared parameters (if any). Pass the name to `execute_task`.
- **`execute_task`** — Executes the named task against the currently selected object(s). The name must be one returned by `list_available_tasks`.
- **`save_workspace`** — Saves pending workspace changes.
- **`check_in_all`** — Checks in all objects currently checked out in the active workspace (Check In All, same as Ctrl+Shift+I).
- **`update_all`** — Pulls the latest object state from the common repository into the active workspace (Update All, same as Ctrl+Shift+U). Multi-user workspaces only; use save_workspace to persist local edits first.
- **`execute_drop_task`** — Programmatically performs a drag-and-drop operation by executing a drop task. Supply a target object, one or more source objects, an optional copy flag, and an optional task name.
- **`create_test_case`** — Creates a test case at the given folder path with optional test steps and requirement links in a single call. The first path segment must reference an existing top-level folder (e.g. 'TestCases'); intermediate segments below it are created automatically.
- **`execute_test_suite`** — Starts execution of a test case or execution list in the background and immediately returns a job ID (async). Supply identifier (surrogate ID or node path of the test case or execution list). Strictly sequential on the Commander UI thread — only one may run at a time; a concurrent call will be rejected.
- **`execute_test_suite_status`** — Polls the status of an execute_test_suite job. Supply jobId (string returned by execute_test_suite). Returns IsRunning (bool); when IsRunning is false, Result contains the execution outcome. Poll in a loop until IsRunning=false.
- **`create_api_module`** — Creates an API module at the given folder path. Supply name and path; returns the surrogate ID of the created module.

