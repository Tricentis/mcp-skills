# Trend and anomaly detection

## Metrics from recent runs

| Metric | Source |
|--------|--------|
| Pass rate | Count Succeeded vs Failed in `tosca_playlistrun` Search window |
| Failure recurrence | Same step signature across multiple `playlistRunId`s (Get detail) |
| New failure | Signature appears in latest run but not in prior N runs |
| Recovery | Failed → Succeeded without artifact change (flaky) |

## Anomaly report template

```
• Window: last N runs of <playlist>
• Pass rate: X% (trend: improving | stable | degrading)
• Flaky tests: <list with flip count>
• New failures: <signatures first seen in latest run>
• Recurring: <signatures in ≥3 runs>
• Confidence: <n>/10
```
