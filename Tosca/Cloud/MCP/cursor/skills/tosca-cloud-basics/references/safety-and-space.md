# Safety and space policy

## Destructive operations

Tools marked `Destructive=true` in the catalog require explicit user confirmation:

- `tosca_inventory_deleteFolder`
- `tosca_playlist_deleteById`
- `tosca_builder_deleteApiMessage`
- `tosca_dataintegrity_connection` (delete mode)
- Mobile and API execution connection deletes

## Read-only analysis

Journey skills for analyze/explain default to read-only. Hand off to `tosca-remediating-from-results` only when the user asks to apply fixes.

## Confidence rubric

| Score | Meaning |
|-------|---------|
| 0–3 | Speculative |
| 4–6 | Plausible |
| 7–8 | Strong evidence |
| 9–10 | Near-certain (clear signature) |

## Output template (shared across journey skills)

```
• Scope: <playlist / test case>     • Result: Failed | Passed
• Failing step: <step> — <message>
• Root-cause: <category> — <hypothesis>
• Remediation: 1) <ranked> 2) <alt>
• Confidence: <n>/10 — <why>
```
