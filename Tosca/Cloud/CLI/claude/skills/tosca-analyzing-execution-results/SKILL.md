---
name: tosca-analyzing-execution-results
description: >-
  Analyzes the latest Tosca Cloud playlist run via toscactl, diagnoses failures, and proposes
  confidence-rated remediations. Use when the user asks what went wrong or why tests failed.
  Read-only via toscactl. Does NOT apply fixes (hand off to tosca-remediating-from-results).
license: Apache-2.0
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Analyze Tosca Cloud execution results

Turn the latest playlist run into a structured diagnosis. **Read-only** — use **`toscactl`**.

**Prerequisite:** `tosca-cloud-connect`. Object model: `tosca-cloud-basics`.

## Session checklist

```text
Analyze latest Cloud run:
- [ ] verify_toscactl.py succeeds
- [ ] Resolve playlist [toscactl]
- [ ] Fetch latest run + state [toscactl]
- [ ] Fetch failed test steps [toscactl]
- [ ] Report with confidence scores
```

## toscactl (default)

```bash
toscactl playlists find --name "<name>" --results --json --silent
toscactl playlists history "<playlist_id>" --page-size 5 --json --silent
toscactl playlists run view <latest_run_id> --json --silent
toscactl executions attachments --type test-steps --run <run_id> --test-case <builder_id> --json --silent
```

Stop if latest run state is `Succeeded`. Fetch attachments only for failed test cases.

## Fast path [toscactl]

1. **Resolve playlist** — `playlists find --name`
2. **Recent runs** — `playlists history --page-size 5`
3. **Run details** — `playlists run view` for per-TC status
4. **Failures** — `executions attachments --type test-steps` per failed TC
5. **Diagnose** — group by signature (systemic vs isolated)
6. **Report** — confidence-rated findings; offer remediation hand-off

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

- Apply fixes → `tosca-remediating-from-results`
- Trends → `tosca-analyzing-execution-history`
