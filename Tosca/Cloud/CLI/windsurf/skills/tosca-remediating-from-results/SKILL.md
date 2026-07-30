---
name: tosca-remediating-from-results
description: >-
  Applies fixes to Tosca Cloud test artifacts after failure analysis. Verify via toscactl; mutations
  via tn (Builder/playlist-item CLI gaps). Requires user approval for destructive changes. Does NOT
  cover read-only analysis (use tosca-analyzing-execution-results).
license: Apache-2.0
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Remediate Tosca Cloud tests from results

Apply ranked fixes from analysis. **Mutating** — confirm scope before edits. **Hybrid:** tn mutations, toscactl verify.

**Prerequisite:** diagnosis from `tosca-analyzing-execution-results` or user-provided failure detail. tn configured for mutation steps.

Runtime: **tn** for Builder mutations and playlist-item rename — see [runtime-routing.md](../tosca-cloud/runtime-routing.md).

## Session checklist

```text
Remediate Cloud tests:
- [ ] Confirm scope and user approval
- [ ] Apply fix [tn]
- [ ] Re-run playlist [toscactl]
- [ ] Report changes, run ID, outcome, confidence
```

## toscactl (default) — verify re-run

```bash
toscactl playlists run start "<name>" --wait --json --silent
toscactl playlists run view <run_id> --json --silent
```

## tn (gap fallback) — apply mutations

**REPL (approval for mutations):**

```bash
tn
# /tosca — apply remediation for <test case>; confirm each destructive change with user
```

**Loop (batch fix + verify):**

```bash
tn --loop "Activate /tosca. Remediate failing tests in playlist '<name>' per approved scope. loop_complete when done."
```

Then re-run with toscactl (above).

## Fast path

1. **Confirm scope** — user approval
2. **[tn] Resolve artifacts** — `tosca_inventory_search` → entityIds
3. **[tn] Apply fix** — [references/remediation-recipes.md](references/remediation-recipes.md): playlist item rename, API message update, scaffold replacement
4. **[toscactl] Verify** — `playlists run start --wait`
5. **Report** — changes, run ID, outcome, confidence

## Destructive operations

Confirm before: `tosca_builder_deleteApiMessage`, `tosca_playlist_deleteById`, folder deletes.

See [references/editability-and-persistence.md](references/editability-and-persistence.md).
