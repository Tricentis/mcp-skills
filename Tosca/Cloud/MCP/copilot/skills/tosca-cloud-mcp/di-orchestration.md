# Data Integrity orchestration — Cloud DI tools

DI tools have **strict ordering**, **entitlement gating**, and **async polling**. There is no separate DI journey skill — route all DI user stories through **`tosca-cloud-mcp`** (this file + one reference doc).

Copy and track progress:

```text
DI workflow:
- [ ] Phase 1 — This file + one reference/di/*.md or workflow
- [ ] Phase 2 — Connections (List/Get; optional Create/Test) then five-step schema
- [ ] Phase 3 — createRowByRowComparison (default write)
- [ ] Phase 4 — tosca_testcase Get
- [ ] Phase 5 — Optional validation via tosca_testrun_edit Create → tosca_testrun Get when requested
- [ ] Phase 6 — Analyze/remediate via DI workflows 04/05 when a run fails
```

## Contents

- [Step 0 — Route before any DI tool](#step-0--route-before-any-di-tool)
- [DI orchestration phases](#di-orchestration-phases)
- [Phase 2 — Connection lifecycle vs schema](#phase-2--connection-lifecycle-vs-schema)
- [Phase 3 — Create comparison artifacts](#phase-3--create-comparison-artifacts)
- [Phase 5–6 — Validate, analyze, remediate](#phase-56--validate-analyze-remediate)
- [Async polling](#async-polling)
- [Scenario → reference file](#scenario--reference-file)
- [When to prompt the user](#when-to-prompt-the-user)
- [Anti-patterns](#anti-patterns)

## Step 0 — Route before any DI tool

1. Confirm MCP readiness ([when-to-use-mcp.md](when-to-use-mcp.md) — `tosca_module` Search).
2. Read this file (phases + gates).
3. Open [reference/di/index.md](reference/di/index.md) and pick **one** supplemental doc or workflow.

**Do not call** `tosca_diconnection`, `tosca_dataintegrity_runSql`, `tosca_dataintegrity_createRowByRowComparison`, or other DI tools until you have read the routing doc for your scenario.

Do **not** call `tosca_dataintegrity_listConnections`, `tosca_dataintegrity_connection`, `tosca_dataintegrity_getConnectionSchema`, `tosca_dataintegrity_checkSchemaResult`, or `tosca_dataintegrity_workflow`.

## DI orchestration phases

```
Phase 1  Read skill docs           → this file + one reference/di/*.md
Phase 2  Connections / schema     → List/Get; optional Create/Test; five-step runSql recipe
Phase 3  Build test artifacts     → createRowByRowComparison (default)
Phase 4  Verify                   → tosca_testcase Get
Phase 5  Optional validation      → tosca_testrun_edit Create → tosca_testrun Get only if requested
Phase 6  Failed-run loop          → analyze (04) → confirm → remediate (05) → validate
```

Cloud mutations persist immediately — there is no save/check-in step.

## Phase 2 — Connection lifecycle vs schema

**Default:** a usable connection already exists. Stay on List → Get → schema. Create / update / test is **optional** (not Story 2 AC).

| Tool | When | Orchestration note |
|------|------|-------------------|
| `tosca_diconnection` List | Start of every DI flow | Unfiltered space list; user picks source/target |
| `tosca_diconnection` Get | Full row + `allowAiQueries` + `metadata.databaseCategory` | Use inner Ulid `id.id` / `connectionId` |
| `tosca_diconnection_edit` Create / Update / Delete | User asked, or List has no usable connection | See [di-connection.md](reference/workflows/di-connection.md). Secrets stay in Connection Manager. Confirm Delete. |
| `tosca_dataintegrity_testConnection` | User asked “does this connection work?” | Optional. Does **not** need `allowAiQueries`. Poll `checkTestConnectionResult`. |
| Five-step schema | Before writing SQL | Canonical recipe in [conventions.md](reference/di/conventions.md). `runSql` **does** need `allowAiQueries`. |

If List is empty and the user did not ask to create a connection: offer Create (or the Cloud UI), then resume at List. Do not invent SQL.

## Phase 3 — Create comparison artifacts

| Tool | When |
|------|------|
| `tosca_dataintegrity_createRowByRowComparison` | **Default write** — new comparison TC, remaps, tolerances, cell settings, File/Olap/Sap |
| `tosca_teststep_edit` | Narrow fallback: **SQL text only** on an existing Complete Row by Row Comparison step |

Fill the create request: `sqlStatement`, `connectionName`, `rowKey`, and `sourceOptions.columnRenames` / `targetOptions.columnRenames` when names differ. Confirm SQL, RowKey, remaps, and connection **names** before create.

DB Expert test cases are **generated from** the Standard Object **`DI DB Expert module`**: Search → Get → `tosca_testcase_edit` Upsert with that `moduleId`. [di-db-expert-testcase.md](reference/workflows/di-db-expert-testcase.md).

## Phase 5–6 — Validate, analyze, remediate

For a single test case, `tosca_testrun_edit` Create → `tosca_testrun` Get is the Cloud equivalent of Commander `execute_test_suite` → `execute_test_suite_status`. Poll until terminal. For a playlist, use `tosca_playlistrun_edit` Create → `tosca_playlistrun` Get.

When a DI run fails:

1. Read [04-analyze-execution-results.md](reference/di/workflows/04-analyze-execution-results.md) for read-only diagnosis.
2. Group shared step/message signatures and distinguish real data defects from test/environment configuration.
3. Report ranked fixes with confidence 0–10.
4. If the user approves a fix, read [05-remediate-from-results.md](reference/di/workflows/05-remediate-from-results.md).
5. Apply the narrowest fix and validate again.

Cloud changes persist immediately. Commander checkout, `save_workspace`, and `check_in_all` have no Cloud equivalent.

## Async polling

`runSql` and `testConnection` are **async**:

1. Start tool returns `notificationId` (and often `launcherLink`)
2. Open `launcherLink` on the user’s machine
3. Poll `tosca_dataintegrity_checkSqlResult` or `tosca_dataintegrity_checkTestConnectionResult`
4. Proceed when complete — do not narrate pending polls

## Scenario → reference file

| User goal | Read |
|-----------|------|
| List / create / update / test a DI connection | [workflows/di-connection.md](reference/workflows/di-connection.md) |
| Row-by-row DB comparison | [workflows/01-row-by-row-comparison.md](reference/di/workflows/01-row-by-row-comparison.md) |
| File vs DB or file vs file | [workflows/02-file-comparison.md](reference/di/workflows/02-file-comparison.md) |
| Business rules / NL / pseudo-code → SQL comparison | [workflows/03-business-rules-to-sql.md](reference/di/workflows/03-business-rules-to-sql.md) |
| Analyze a failed DI run / suggest fixes | [workflows/04-analyze-execution-results.md](reference/di/workflows/04-analyze-execution-results.md) |
| Apply an approved DI fix and validate | [workflows/05-remediate-from-results.md](reference/di/workflows/05-remediate-from-results.md) |
| Field-mapping / lineage CSV (e.g. Collibra) to DI test cases | [workflows/06-lineage-csv.md](reference/di/workflows/06-lineage-csv.md) |
| Tolerances, transforms, reporting | [comparison-options-and-reports.md](reference/di/comparison-options-and-reports.md) |
| DB Expert testcase | [di-db-expert-testcase.md](reference/workflows/di-db-expert-testcase.md) — generated from Standard Object `DI DB Expert module` |
| Tool list | [overview.md](reference/di/overview.md) |
| Schema recipe, RowKey, remaps | [conventions.md](reference/di/conventions.md) |
| Short Code Mode plan | [workflows/di-getting-started.md](reference/workflows/di-getting-started.md) |
| Optional trial run after create | [workflows/trial-run-testcase.md](reference/workflows/trial-run-testcase.md) |

## When to prompt the user

| Situation | Ask |
|-----------|-----|
| Entitlement error | User may need DI license — report and stop |
| `allowAiQueries` false | Enable **Allow AI queries** in Connection Manager, then retry Get |
| DBMS unclear | Which DBMS does this connection target? |
| Custom ODBC / catalog query fails | Describe tables/columns so SQL can still be written |
| RowKey unclear | Which column(s) uniquely identify a row? |
| No usable connection / user asked to create | Offer `tosca_diconnection_edit` (see di-connection.md) — do not invent SQL |
| Destructive connection delete | Confirm before `tosca_diconnection_edit` Delete |
| User asked to run the test case | Follow trial-run (`tosca_testrun_edit` Create → `tosca_testrun` Get). Do **not** start a run unprompted. |
| Proposed remediation | Confirm the exact target and before/after value before mutation |

## Anti-patterns

| Avoid | Why |
|-------|-----|
| Load all `reference/di/` files | Progressive disclosure — one scenario at a time |
| `listConnections` / `getConnectionSchema` / `workflow` | Hidden or gone on V2 |
| Skip the five-step schema recipe | Wrong dialect, `runSql` refused, failed comparisons |
| `teststep_edit` + `explicitName` for remaps | Use `columnRenames` on `createRowByRowComparison` |
| Create/Test inside the five schema steps | Optional branches — not part of schema |
| Start `tosca_testrun_edit` Create unprompted | Optional; not Story 2 AC |
| Use generic playlist diagnosis alone for a DI failure | Load DI workflow 04 for SQL/tolerance/data-defect classification |
| Broaden tolerances until the test passes | Masks defects; require evidence and the narrowest justified change |

## Related

- [reference/di/index.md](reference/di/index.md)
- [reference/workflows/di-getting-started.md](reference/workflows/di-getting-started.md)
- [tool-orchestration.md](tool-orchestration.md)
