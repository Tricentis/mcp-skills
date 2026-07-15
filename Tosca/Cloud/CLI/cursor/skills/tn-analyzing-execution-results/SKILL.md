---
name: tn-analyzing-execution-results
description: >-
  Analyzes the latest Tosca Cloud test execution results for a playlist via TN CLI,
  diagnoses failures, and proposes confidence-rated remediations. Use when the user asks
  what went wrong, why tests failed, or for a summary of the last run. Read-only via tn;
  Does NOT apply fixes (hand off to tn-remediating-from-results).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Analyze Tosca Cloud execution results (TN)

Turn the latest playlist run into a structured diagnosis. **Read-only** — delegate to **`tn`**.

Object model: `tn-cloud-basics`. Wire names: `tosca_{domain}_{action}` (via tn `/tosca` MCP).

## Session checklist

```text
Analyze latest Cloud run (TN):
- [ ] Verify tn + /tosca (tn-cloud-connect)
- [ ] Resolve playlist via tn
- [ ] getRecentRuns — stop if latest Passed
- [ ] getFailedTestSteps for Failed runs only
- [ ] Report with confidence scores
```

## TN invocation

**Piped (quick):**

```bash
echo "/tosca — Analyze playlist '<name>': get recent runs, if latest failed fetch failed steps, diagnose with confidence scores. Read-only." | tn
```

**Loop (report to file):**

```bash
tn --loop "Activate /tosca. Analyze playlist '<name>' latest run failures. Write structured report to execution-analysis.md. loop_complete when done."
```

## Fast path (tools via tn)

1. **Resolve playlist** — `tosca_playlist_searchByName` or `tosca_inventory_search`
2. **Recent runs** — `tosca_playlist_getRecentRuns(playlistId, limit: 5)`
3. **Failures** — `tosca_playlist_getFailedTestSteps` for Failed runs only
4. **Diagnose** — group by signature (systemic vs isolated)
5. **Report** — confidence-rated findings; offer remediation hand-off

## Efficiency

- Check run **state** before fetching attachments
- Group identical failures — one root cause

## Output template (per finding)

```
• Scope: <playlist / test>          • Result: Failed
• Failing step: <step> — <message>
• Root-cause: <category> — <hypothesis>
• Remediation: 1) <ranked> 2) <alt>
• Confidence: <n>/10 — <why>
```

See [references/failure-taxonomy.md](references/failure-taxonomy.md) and [references/run-result-schema.md](references/run-result-schema.md).

## Hand off

- Apply fixes → `tn-remediating-from-results`
- Trends → `tn-analyzing-execution-history`
