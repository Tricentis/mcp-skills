# MCP tool planning guide

Use with [code-mode.md](code-mode.md), [tool-orchestration.md](tool-orchestration.md), and [reference/tools-catalog.md](reference/tools-catalog.md) — open the catalog only for tools in your plan.

**Primary orchestration doc:** [tool-orchestration.md](tool-orchestration.md) — when/how to call each tool in Code Mode.

## Contents

- [Planning primitives](#planning-primitives)
- [Category-specific plans](#category-specific-plans)
- [Error recovery](#error-recovery)

## Planning primitives

### Resolve identity

Objects are addressed by **surrogate ID** or **node path** (e.g. `/TestCases/MyFolder/MyCase`).

```
get_object_info(identifiers=[path or id])
  → surrogateId for downstream tools
```

Prefer node paths when the user names folders; prefer surrogate IDs after first resolution (stable for the session).

### Selection vs explicit IDs

| Tool | Selection default | Explicit override |
|------|-------------------|-------------------|
| `get_attributes` | Current UI selection | `identifiers` array |
| `list_available_tasks` | Current selection | `objectIds` |
| `execute_task` | Current selection | `objectIds` |

When the plan targets specific objects, **always pass `objectIds` / `identifiers`** — do not rely on UI selection surviving between calls.

### Pagination

Tools returning `nextOffset`:

- `get_object_info` (`include_parent_and_children=true`) — default limit 200; paginate with `offset=nextOffset`
- `run_di_sql_statement` — default limit 200; prefer SQL-side LIMIT for large tables

Loop: call with `offset=nextOffset` until `nextOffset` is absent.

### Task execution chain

```
list_available_tasks(objectIds=[target])
  → pick task name exactly as returned
execute_task(name, objectIds=[target], ...taskParams)
```

If edit tasks are missing → parent not checked out → find and run checkout task on parent first.

### Attribute mutation chain

```
get_attributes(identifiers=[target])
  → confirm attribute exists, is_readonly=false, note value_type
set_attribute(identifier, attribute_name, value)
save_workspace
```

### Drop operations

```
execute_drop_task(target, sources[], copy?, taskName?)
```

Use when the UI equivalent is drag-and-drop with a drop task.

## Category-specific plans

### Workspace (read-only audit)

```
get_workspace_info
get_current_selection
get_object_info(identifiers=[parent], include_parent_and_children=true, limit=200, offset=0)  # paginate
get_attributes(identifiers=[...])
```

### Create test case

```
create_test_case(folderPath, name, steps?, requirements?)
save_workspace
get_object_info(node path)  # verify
```

See [reference/workflows/create-test-case.md](reference/workflows/create-test-case.md).

### Multi-user edit

```
get_workspace_info                    # confirm multi-user
update_all                            # optional: sync latest
execute_task(Checkout) on parent
set_attribute / execute_task(edit)
save_workspace
check_in_all
```

See [reference/workflows/save-and-checkin.md](reference/workflows/save-and-checkin.md).

### Data Integrity (mandatory entry)

Read skill docs first:

```
di-orchestration.md + one reference/di/workflows/*.md
get_di_connection_schema OR run_di_sql_statement
di_connection (list/create/update)
create_di_row_by_row_comparison / create_di_db_expert_module / ...
execute_test_suite(identifier)
execute_test_suite_status(jobId)      # poll until IsRunning=false
save_workspace
```

See [di-orchestration.md](di-orchestration.md) and [reference/di/index.md](reference/di/index.md).

**Never** call `di_connection`, `run_di_sql_statement`, or `create_di_*` before reading the DI skill docs for your scenario.

### Lineage CSV import

```
di-orchestration.md + reference/di/workflows/06-lineage-csv.md
parse_di_lineage_mapping(csvPath)
create_di_row_by_row_comparison (per group from mapping)
execute_test_suite ...
```

## Error recovery

| Error signal | Plan adjustment |
|--------------|-----------------|
| "not checked out" / unknown task name | Checkout correct object → re-run `list_available_tasks` |
| "object not found" | Re-resolve with `get_object_info` or paginated children |
| Task not in list | Re-run `list_available_tasks` after selection/checkout change |
| DI license | Stop; inform user DI is not licensed |
| Another execute_test_suite in progress | Poll `execute_test_suite_status` until complete |
