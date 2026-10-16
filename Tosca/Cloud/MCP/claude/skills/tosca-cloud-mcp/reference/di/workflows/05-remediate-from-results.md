# DI workflow — remediate from results

Apply an approved non-UI fix from [04-analyze-execution-results.md](04-analyze-execution-results.md), then validate it.

Load **di-orchestration.md**, then this file. Cloud changes persist immediately; there is no checkout, save, or check-in step.

```text
Remediate DI failure:
- [ ] Start from a confidence-rated finding
- [ ] Confirm the exact target and change with the user
- [ ] Get the current test case / test step
- [ ] Apply the narrowest supported fix
- [ ] Re-read the artifact
- [ ] Re-run only after approval and poll until terminal
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | *(input)* | Finding from `04-analyze-execution-results` | Target asset, evidence, proposed change, confidence |
| 2 | `tosca_testcase` Get and/or `tosca_teststep` Get | Exact ids from the finding | Current values and module attribute paths |
| 3 | *(confirm)* | Before/after value and scope | Explicit user approval; no Cloud checkout is required |
| 4 | `tosca_teststep_edit` or `tosca_dataintegrity_createRowByRowComparison` | See the fix matrix below | Applied SQL-only patch, or replacement comparison with structured options |
| 5 | `tosca_testcase` Get | Changed/new testCaseId | Verify persisted structure and values |
| 6 | `tosca_testrun_edit` Create → `tosca_testrun` Get | testCaseId; poll until terminal | Per-step result proves whether the fix worked |

For a playlist-only reproduction, re-run with `tosca_playlistrun_edit` Create and poll `tosca_playlistrun` Get. Prefer `tosca_testrun_edit` Create → `tosca_testrun` Get for a focused single-test validation.

## Fix matrix

| Finding | Apply with | Rule |
|---------|------------|------|
| SQL text or ODBC connection name is wrong on an existing Complete Row by Row Comparison step | `tosca_teststep_edit` Upsert `values[]` | Get the step first; use exact module paths such as `Source.Database.ODBC.SQL Statement` |
| Numeric or DateTime tolerance / parse format is needed | `tosca_dataintegrity_createRowByRowComparison` with `tolerances` | Recreate the comparison; do not patch generated tolerance-file internals |
| Column remap, RowKey, cell transform, endpoint, or general option is wrong | `tosca_dataintegrity_createRowByRowComparison` | Recreate with the complete corrected configuration |
| Connection is unavailable | `tosca_dataintegrity_testConnection` → poll result | Fix connection/environment outside the test; never pass secrets through MCP |
| Expected business result genuinely changed | Appropriate test-step edit or recreated comparison | Require user confirmation that the requirement changed |
| Source/target data is defective | No test mutation | Report the defect; do not add tolerance/exclusion to mask it |
| UI module/locator failure | No DI mutation | Stop and report UI-module maintenance; MCP does not scan/rescan UI modules here |

See [../comparison-options-and-reports.md](../comparison-options-and-reports.md) for Cloud parameter shapes.

## Safety

- Confirm every mutation with exact test case, step, old value, and proposed value.
- Never invent a tolerance. State the observed difference and why the proposed threshold is justified.
- Prefer a per-column transform/tolerance over excluding the column.
- Do not set `explicitName` through `tosca_teststep_edit` to simulate column remaps.
- Do not delete the original test case automatically when a corrected comparison is recreated.
- Do not start a production/team playlist run without explicit approval.

## Validate and report

Poll the selected run Get tool until terminal. Then report:

```text
Changed: <artifact and exact configuration>
Validation run: <id and terminal state>
Outcome: <fixed / still failing>
Evidence: <step and message>
Next action: <stop / revised diagnosis>
Confidence: <0–10>
```

If validation still fails, return to [04-analyze-execution-results.md](04-analyze-execution-results.md) with the new evidence. Do not repeatedly broaden tolerances until the test passes.
