# DI workflow — analyze execution results

Diagnose why a completed Data Integrity run failed and propose ranked, confidence-rated fixes. This workflow is read-only.

Load **di-orchestration.md**, then this file. For applying an approved fix, continue with [05-remediate-from-results.md](05-remediate-from-results.md).

```text
Analyze DI execution:
- [ ] Resolve the test case, playlist, or known run id
- [ ] Get the run until terminal
- [ ] Keep failed/error steps and their messages/details
- [ ] Group repeated step + message signatures
- [ ] Classify data defect vs test/environment configuration
- [ ] Report ranked fixes with confidence 0–10
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_asset` Search, `tosca_testcase` Get, or `tosca_playlist` Get | User-provided name/id | Resolve the test case or playlist without guessing ids |
| 2 | `tosca_testrun` Get or `tosca_playlistrun` Get | `testRunId`, or exactly one playlist-run selector | Poll until Succeeded, Failed, or Canceled; if Succeeded, report all-passed and stop |
| 3 | *(read result)* | `testSteps[]` or `playlistTestCaseRuns[]` / `failedStepsByTestCaseRunId` | Identify failing test case and step ids/names |
| 4 | *(filter)* | Step `State` in Failed/Error | Keep only relevant subtrees; use `testStepsUri` when a playlist step tree is too large |
| 5 | *(diagnose)* | `Message`, `Details`, and targeted `logsUrl` content when needed | Group signatures, classify causes, and propose fixes |

Do not start a new run merely to analyze an existing completed run. If the user asks to execute first, use `tosca_testrun_edit` Create for one test case or `tosca_playlistrun_edit` Create for a playlist, then poll the matching Get tool.

## Classification

Classify each finding as one of:

- **Application/data defect** — compared source and target genuinely disagree. Do not weaken the test to hide it.
- **Test data** — setup or expected data is stale/incomplete.
- **Test configuration** — SQL, connection name, row key, column mapping, format, tolerance, or transform is wrong.
- **Timing/synchronization** — transient availability or sequencing issue.
- **Environment/infrastructure** — agent offline, connection timeout, credentials, or service outage.
- **Assertion mismatch** — expected result no longer represents the approved requirement.

Group failures sharing the same step and normalized message signature. One repeated signature is one systemic finding, not one finding per test.

## DI patterns

| Signal | Likely class | First recommendation |
|--------|--------------|----------------------|
| Obligatory parameter `SQL Statement` missing | Test configuration | Inspect the comparison step; propose the exact source/target SQL value |
| Connection timeout / login / network error | Environment/infrastructure | Run `tosca_dataintegrity_testConnection`; do not rewrite SQL without evidence |
| DateTime parse error or equivalent values use different formats | Test configuration | Propose `dateTimeByColumn` with source/target format and the narrowest justified tolerance |
| Small numeric drift | Test configuration or genuine defect | Quantify the drift before proposing `numericByColumn`; never invent a business tolerance |
| Whitespace/casing representation mismatch | Test configuration | Propose a targeted cell transform, not a broad exclusion |
| Missing/unmatched rows or business-key mismatch | Application/data defect or row-key config | Verify RowKey/remaps; otherwise report as data defect |
| Many failures at one connection/reader step | Environment/infrastructure | Treat as one systemic failure |

## Output

For each finding report:

```text
Scope: <test case / step>
Result: <Failed / Error>
Evidence: <step + concise message>
Root cause: <classification + hypothesis>
Remediation: 1) <ranked fix> 2) <alternative>
Fix lands in: <test step / recreated comparison / connection / source data>
Confidence: <0–10> — <one-line reason>
```

Confidence: 0–3 speculative · 4–6 plausible · 7–8 strong · 9–10 near-certain.

Remain read-only. To apply a recommendation, get the user's approval and follow [05-remediate-from-results.md](05-remediate-from-results.md).
