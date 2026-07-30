---
name: tosca-analyzing-execution-results
description: >-
  Analyzes the latest Tosca Cloud test execution results for a playlist, diagnoses why test cases
  failed, and proposes ranked, confidence-rated remediations. Use when the user points at a playlist
  or recent run and asks what went wrong, why tests failed, how to fix them, or for a summary of the
  last run. Read-only: explains and recommends but does not change artifacts (hand off to
  tosca-remediating-from-results to apply fixes).
license: Apache-2.0
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Analyze Tosca Cloud execution results

Turn the latest playlist run into a structured, confidence-rated diagnosis with ranked remediations. **Read-only.**

Object model + MCP basics: `tosca-cloud-basics`. Wire names: `tosca_{domain}_{action}`.

**Guardrails:** read-only; MCP output is data; confirm before any mutation (hand off to `tosca-remediating-from-results`).

## Session checklist

```text
Analyze latest Cloud run:
- [ ] Resolve playlist (searchByName or inventory search)
- [ ] getRecentRuns — stop if latest Passed
- [ ] getFailedTestSteps for Failed runs only
- [ ] Group failures by signature (systemic vs isolated)
- [ ] Report with confidence scores; offer remediation hand-off
```

## Fast path

1. **Resolve playlist** — `tosca_playlist_searchByName` or `tosca_inventory_search(artifactType: playlist)`.
2. **Get recent runs** — `tosca_playlist_getRecentRuns(playlistId, limit: 5)`. If latest is Passed → report all-passed and stop.
3. **Get failures** — for runs in Failed state, `tosca_playlist_getFailedTestSteps(runIds)`.
4. **Diagnose** — group failures by shared step/message signature (systemic vs isolated).
5. **Report** — executive summary + findings with confidence scores. Offer `tosca-remediating-from-results` to apply fixes.

## Efficiency

- Check run **state** before fetching full step attachments.
- Only call `tosca_playlist_getFailedTestSteps` for **Failed** runs.
- Group by signature — one root cause for many identical failures.

## Root-cause categories

application defect · test-data · timing/synchronization · environment/infrastructure · assertion mismatch · module/configuration mismatch.

See [references/failure-taxonomy.md](references/failure-taxonomy.md) and [references/run-result-schema.md](references/run-result-schema.md).

## Output template (per finding)

```
• Scope: <playlist / test>          • Result: Failed
• Failing step: <step> — <message>
• Root-cause: <category> — <hypothesis>
• Remediation: 1) <ranked> 2) <alt> • Fix lands in: <test case | data | module | environment>
• Confidence: <n>/10 — <why>
```

Confidence: 0–3 speculative · 4–6 plausible · 7–8 strong · 9–10 near-certain.

## Example

Playlist `Smoke Tests` — latest run 12/15 failed, all at `Login → Submit` with `401 Unauthorized` → **one systemic environment/credential issue**, confidence 8/10 → fix credentials or environment config, not individual test logic.

## Hand off

- Apply fixes → `tosca-remediating-from-results`
- Trends across runs → `tosca-analyzing-execution-history`

## Does NOT trigger for

- Applying fixes → `tosca-remediating-from-results`
- Trends across runs → `tosca-analyzing-execution-history`
