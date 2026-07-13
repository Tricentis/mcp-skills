# Tool orchestration — when and how to call each MCP tool

Use with [code-mode.md](code-mode.md) (script) or [direct-tool-mode.md](direct-tool-mode.md) (step plan). This document defines **which tools, in what order, under what preconditions** — independent of execution surface.

**Progressive disclosure:** this file summarizes workspace and DI tools. For DI walkthroughs, read [di-orchestration.md](di-orchestration.md) and **one** file under [reference/di/](reference/di/index.md) — do not load the full catalog or all DI docs at once.

Catalog (parameters): [reference/tools-catalog.md](reference/tools-catalog.md) — open only when you need parameter details for a specific tool.

## Contents

- [Mandatory orchestration loop](#mandatory-orchestration-loop)
- [By intent](#by-intent--which-tools-to-orchestrate)
- [Tool reference](#tool-reference--when--how--then)
- [Pagination](#pagination-orchestration)
- [Error recovery](#error-recovery--replan-dont-retry-blindly)
- [Anti-patterns](#anti-patterns)

## Mandatory orchestration loop

Every multi-step session follows this loop:

```
READINESS  →  PLAN  →  DISCOVER  →  ACT  →  PERSIST  →  VERIFY
```

| Phase | Tools | Rule |
|-------|-------|------|
| **Readiness** | `get_workspace_info` | Once per session or after Commander restart |
| **Plan** | *(no tools)* | Code Mode table before mutations |
| **Discover** | `get_object_info`, `get_attributes`, `list_available_tasks` | Before every write or task |
| **Act** | `set_attribute`, `execute_task`, `create_*`, `execute_drop_task`, `di_*` | One plan row at a time |
| **Persist** | `save_workspace`, `check_in_all` | After all mutations in plan |
| **Verify** | `get_object_info`, `get_attributes` | When user needs confirmation |

---

## By intent — which tools to orchestrate

### Read-only: understand workspace

**When:** User asks what is open, structure, properties, selection.

**Orchestration:**

```
get_workspace_info
get_current_selection                                        # optional — may be empty
get_object_info([user-named path])                           # if specific object
get_object_info([parent], include_parent_and_children=true)  # paginate with nextOffset
get_attributes(identifiers=[...])                             # if properties needed
```

**Do not** call save/check-in. **Code Mode optional** for simple reads.

---

### Navigate and resolve identity

**When:** Later steps need surrogate IDs or confirmation of node paths.

| Tool | When to call | How |
|------|--------------|-----|
| `get_object_info` | User gives name/path; need surrogateId | Pass node path or id; handle per-object errors |
| `get_object_info` (`include_parent_and_children=true`) | Explore tree, or need parent for checkout/context | Single identifier only; paginate children with `limit`/`offset` |
| `set_object_selection` | User should **see** object in UI | Optional — still pass `objectIds` in later tools |

**Orchestration rule:** Resolve IDs **once**, reuse surrogate IDs in subsequent plan rows.

**Name-collision suffixes (`_1`, `_2`, ...):** generic uniqueness rule for any object type — flags a collision, not which sibling is correct. Investigate, don't infer from the suffix.

---

### Read attributes

**When:** Inspect state before edit or report to user.

```
get_attributes(identifiers=[target])   # prefer explicit ids
```

If `identifiers` omitted, current UI selection is used — **risky** if selection empty. Always pass identifiers when target is known.

---

### Mutate attributes

**When:** Change a property (name, description, etc.).

**Preconditions:** Multi-user → checkout on parent ([workspace-orchestration.md](workspace-orchestration.md)).

```
get_attributes(identifiers=[target])   # find writable attr; note value_type
set_attribute(identifier, name, value)
save_workspace                         # end of mutation group
```

**Do not** call `set_attribute` without prior `get_attributes` when attribute names are uncertain.

**Disambiguating collision candidates by attribute** (see name-collision suffixes above): `get_attributes` can't tell them apart (no action-mode/business-type field). Rule out `IsReadonly=true`; still unsure → validation run (`isValidationRun=true`), check the per-step result.

Password/Secret attributes: `set_attribute` returns an encrypted `new_value` — expected, not a failure.

---

### Execute context-menu tasks

**When:** User wants a Commander task (Create, Import, Checkout, module actions, etc.).

**Full orchestration:** [task-orchestration.md](task-orchestration.md)

```
list_available_tasks(objectIds=[target])
execute_task(taskName, parameters={}, objectIds=[target])
save_workspace                         # unless task persists internally
```

**Never** guess task names — always from `list_available_tasks`.

---

### Drag-and-drop operations

**When:** UI equivalent is dragging object A onto object B.

```
get_object_info([target, ...sources])
execute_drop_task(targetId, sourceIds, copy?, taskName?)
save_workspace
```

Call when `list_available_tasks` does not expose the needed action but a drop task exists.

**Append step to existing test case** (`create_test_case` only accepts steps at creation): apply this pattern twice — module→testcase (new step), then attribute→step (value). See [reference/workflows/add-step-to-existing-test-case.md](reference/workflows/add-step-to-existing-test-case.md).

---

### Create test case

**When:** New test case with optional steps and requirement links.

```
get_workspace_info                     # multi-user affects auto check-in
create_test_case(name, path, testSteps?, linkedRequirements?)
get_object_info([new case path])       # verify
```

`create_test_case` saves/checks in on success — **do not** duplicate save immediately unless plan continues with more edits.

See [reference/workflows/create-test-case.md](reference/workflows/create-test-case.md).

---

### Multi-user sync

**When:** Start of edit session or before check-in.

| Tool | When |
|------|------|
| `update_all` | Before editing — pull latest (Ctrl+Shift+U equivalent) |
| `save_workspace` | After local edits |
| `check_in_all` | Publish all checked-out objects (Ctrl+Shift+I) |

See [workspace-orchestration.md](workspace-orchestration.md).

---

### Data Integrity

**When:** Database comparison, validation, lineage import.

**Always start with the skill** — [di-orchestration.md](di-orchestration.md) and one file from [reference/di/index.md](reference/di/index.md).

---

## Tool reference — when / how / then

### Workspace tools

| Tool | Call when | How | Then |
|------|-----------|-----|------|
| `get_workspace_info` | Session start, after workspace switch | No args | Branch single vs multi-user plan |
| `get_current_selection` | User says "selected" / "what I have" | No args | Use ids in plan or resolve via `get_object_info` |
| `get_object_info` | Need id from path or verify existence | `identifiers[]` | Use `surrogateId` in plan |
| `set_object_selection` | Show object in UI for user | id or path | Still pass ids explicitly later |
| `get_object_info` (`include_parent_and_children=true`) | Traverse tree, or checkout target is parent | single id, paginate | Loop until no `nextOffset`; use returned `parent` for checkout |
| `get_attributes` | Before read report or `set_attribute` | `identifiers[]` | Check `is_readonly` |
| `set_attribute` | Writable attr confirmed | id, name, value | `save_workspace` at group end |
| `list_available_tasks` | **Before every** `execute_task` | `objectIds[]` | Pick exact task name |
| `execute_task` | Task name known from list | name, params, `objectIds[]` | Save; handle task messages |
| `execute_drop_task` | DnD scenario | targetId, sourceIds | Save |
| `create_test_case` | New TC in folder path | name, path, steps?, reqs? | Verify; tool may save/check-in |
| `create_api_module` | New API module | per tool schema | Verify; tool may save/check-in |
| `execute_test_suite` | Run test case/step (validation only¹) | `testCaseId`, `isValidationRun=true` | Get JobId; poll with execute_test_suite_status |
| `execute_test_suite_status` | After `execute_test_suite` | jobId | Call again immediately² until `IsRunning=false` |
| `save_workspace` | After mutation group | No args | Required before close |
| `update_all` | Multi-user, before edit | No args | Then checkout/mutate |
| `check_in_all` | Multi-user, publish ready | comment?, forceLargeCheckin? | After save; confirm large check-ins |

¹ `executionListId` runs not yet supported. ² Server paces the poll interval — no client-side backoff needed.

### Data Integrity tools

| Tool | Call when | How | Then |
|------|-----------|-----|------|
| `di_connection` | Manage connections | action per schema | After [di-orchestration.md](di-orchestration.md) read |
| `get_di_connection_schema` | Need full schema (small) | connection id/name | Prefer SQL if huge |
| `run_di_sql_statement` | Targeted schema/data query | SQL + pagination | Prefer SQL LIMIT |
| `create_di_*` | Build comparison TCs | per tool schema | Can parallelize creates |
| `parse_di_lineage_mapping` | CSV lineage import | csvPath | Per group → row comparison |

---

## Pagination orchestration

When response includes `nextOffset`:

```
get_object_info([parent], include_parent_and_children=true, limit=200, offset=0)
  → if nextOffset: get_object_info([parent], include_parent_and_children=true, offset=nextOffset)
  → repeat until done
```

Same pattern for `run_di_sql_statement`. Prefer SQL-side LIMIT for large tables.

---

## Error recovery — replan, don't retry blindly

On error: **stop**, diagnose, revise the plan — do not blindly retry the same tool call.

| Error | Replan step |
|-------|-------------|
| Object not found | `get_object_info` — fix path |
| No selection | Pass `objectIds` |
| Task not in list | Checkout parent → `list_available_tasks` again |
| Attribute read-only | Checkout or different attribute |
| `check_in_all` threshold | Ask user → `forceLargeCheckin=true` |
| DI license | Stop — inform user |
| Another `execute_test_suite` running | Poll until free |
| `ExecutionCancelledException`, no step detail | Ask user to check live app/browser state before further config changes |

---

## Anti-patterns

| Avoid | Do instead |
|-------|------------|
| Jump straight to `execute_task` | `list_available_tasks` first |
| Rely on UI selection across calls | Explicit `objectIds` |
| `set_attribute` without discovery | `get_attributes` first |
| Save after every single attribute | One save at mutation group end |
| Skip DI skill docs | Read [di-orchestration.md](di-orchestration.md) before DI tools |
| Parallel `execute_test_suite` | Strictly sequential + poll |
| MCP when Commander closed | IDE.integration TCShell/TCAPI |

---

## Related

| Document | Purpose |
|----------|---------|
| [when-to-use-mcp.md](when-to-use-mcp.md) | MCP vs headless path |
| [workspace-orchestration.md](workspace-orchestration.md) | Checkout / save / check-in |
| [task-orchestration.md](task-orchestration.md) | Task discovery and parameters |
| [di-orchestration.md](di-orchestration.md) | DI Code Mode sequences |
| [reference/workflows-index.md](reference/workflows-index.md) | Copy-paste plan templates |
