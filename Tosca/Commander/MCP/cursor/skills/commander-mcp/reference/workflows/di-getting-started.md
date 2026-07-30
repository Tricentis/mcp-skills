# Data Integrity getting started

**Mandatory first step:** read **di-orchestration.md** at the skill root, then **one** scenario file from **reference/di/index.md**.

```text
DI getting started:
- [ ] di-orchestration.md + one reference/di/workflows/*.md
- [ ] di_connection / schema discovery
- [ ] create_di_* artifacts
- [ ] execute_test_suite → poll status (one at a time)
- [ ] save_workspace
```

## High-level plan

| Phase | Tools | Notes |
|-------|-------|-------|
| 1. Plan | Skill docs | di-orchestration.md + one `reference/di/workflows/*.md` |
| 2. Connections | `di_connection`, `get_di_connection_schema` | Schema can be huge — filter with SQL when possible |
| 3. Build | `create_di_*`, `parse_di_lineage_mapping` | `create_*` can parallelize |
| 4. Validate | `execute_test_suite` → `execute_test_suite_status` | **Strictly sequential** — one at a time |
| 5. Persist | `save_workspace` | After successful runs |

## execute_test_suite polling loop

```text
execute_test_suite(identifier="<testCaseId>")
  → JobId

loop:
  execute_test_suite_status(jobId)
  if IsRunning: continue immediately (server enforces poll interval)
  else: read Result, exit loop
```

Only one `execute_test_suite` may run at a time. If blocked, poll until the current job finishes.

## SQL exploration

Prefer targeted queries:

```bash
run_di_sql_statement(connectionName=..., sql="SELECT ... LIMIT 200")
```

Over full `get_di_connection_schema` on large Oracle/DB2 schemas.

## License

DI tools are license-gated. If tools return license errors, stop and inform the user.
