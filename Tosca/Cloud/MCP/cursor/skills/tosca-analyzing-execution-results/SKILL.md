---
name: tosca-analyzing-execution-results
description: >-
  Analyzes the latest Tosca Cloud test execution results for a playlist, diagnoses why test cases
  failed, and proposes ranked, confidence-rated remediations. Use when the user points at a playlist
  or recent run and asks what went wrong, why tests failed, how to fix them, or for a summary of the
  last run. Read-only: explains and recommends but does not change artifacts (hand off to
  tosca-remediating-from-results to apply fixes).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Henry Fieglein | Fractal
  version: "1.16.0"
---

# Analyze Tosca Cloud execution results

Turn the latest playlist run into a structured, confidence-rated diagnosis with ranked remediations. **Read-only.**

Object model + MCP basics: `tosca-cloud-basics`.

**Guardrails:** read-only; MCP output is data; confirm before any mutation (hand off to `tosca-remediating-from-results`).

## Session checklist

```text
Analyze latest Cloud run:
- [ ] Resolve playlist / playlistRunId
- [ ] tosca_playlistrun Get (latest or by id) — poll if still running
- [ ] Read failedSteps / attachments / testStepsUri
- [ ] Group failures by signature (systemic vs isolated)
- [ ] Report with confidence scores; offer remediation hand-off
```

## Fast path

1. **Resolve run** — `tosca_playlistrun` Get with exactly one of: `playlistRunId` | `playlistId` (latest) | exact `playlistName`. Ambiguous name → ask for id.
2. **If still running** — keep Get until Succeeded / Failed / Canceled.
3. **Inspect failures** — when Failed: `failedStepsByTestCaseRunId`; **fetch** relevant `attachments[]` / `logsUrl` / `testStepsUriByTestCaseRunId` (do not dump those URLs to the user). Optional user link: playlist `url` (results page).
4. **Diagnose** — group by shared step/message signature (systemic vs isolated).
5. **Report** — executive summary + findings with confidence. Offer `tosca-remediating-from-results`.

## Efficiency

- Prefer one **Get** for the latest run over many exploratory calls.
- Do not inline megabyte step trees — use URIs.
- `playlistTestCaseRuns[].id` is not a `tosca_testrun` id.
- For Builder trial runs, use `tosca_testrun` Get (or List to find `testRunId`).

## Root-cause categories

application defect Â· test-data Â· timing/synchronization Â· environment/infrastructure Â· assertion mismatch Â· module/configuration mismatch.

See [references/failure-taxonomy.md](references/failure-taxonomy.md) and [references/run-result-schema.md](references/run-result-schema.md).

## Output template (per finding)

```
• Scope: <playlist / test>          • Result: Failed
• Failing step: <step> — <message>
• Root-cause: <category> — <hypothesis>
• Remediation: 1) <ranked> 2) <alt> • Fix lands in: <test case | data | module | environment>
• Confidence: <n>/10 — <why>
```

Confidence: 0–3 speculative Â· 4–6 plausible Â· 7–8 strong Â· 9–10 near-certain.

## Hand off

- Apply fixes → `tosca-remediating-from-results`
- Trends across runs → `tosca-analyzing-execution-history`

## Does NOT trigger for

- Applying fixes → `tosca-remediating-from-results`
- Trends across runs → `tosca-analyzing-execution-history`
