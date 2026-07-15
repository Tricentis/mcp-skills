---
name: tn-remediating-from-results
description: >-
  Applies fixes to Tosca Cloud test artifacts based on execution failure analysis — test case edits,
  playlist item renames, and Builder updates. Use when the user asks to fix, update, or remediate
  failing tests after diagnosis. Requires explicit user approval for destructive changes. Does NOT
  cover read-only analysis (use tn-analyzing-execution-results).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Remediate Tosca Cloud tests from results

Apply ranked fixes from analysis. **Mutating** — confirm scope before edits.

Prerequisite: diagnosis from `tn-analyzing-execution-results` or user-provided failure detail.

## TN invocation

**REPL (approval for mutations):**

```bash
tn
# /tosca — apply remediation for <test case>; confirm each destructive change with user
```

**Loop (batch fix + verify run):**

```bash
tn --loop "Activate /tosca. Remediate failing tests in playlist '<name>' per approved scope. Re-run playlist and report outcome. loop_complete when done."
```

## Session checklist

```text
Remediate Cloud tests:
- [ ] Confirm scope and get user approval
- [ ] Resolve artifacts (inventory search → entityIds)
- [ ] Apply fix per remediation recipe
- [ ] Re-run playlist or re-search artifact
- [ ] Report changes, run ID, outcome, confidence
```

## Fast path

1. **Confirm scope** — which test cases / playlist items to fix; get user approval.
2. **Resolve artifacts** — `tosca_inventory_search` → entityIds.
3. **Apply fix** — per recipe in [references/remediation-recipes.md](references/remediation-recipes.md). Common: playlist item rename (`analyzeTestCaseItems` → `applyTestCaseItemRenames`), API message update, scaffold replacement TC, re-run.
4. **Verify** — re-run playlist (`tosca_playlist_run`) or re-search artifact.
5. **Report** — what changed, new run ID, outcome.

## Persistence

Cloud mutations persist via API immediately. No save/check-in step.

## Destructive operations

Confirm before: `tosca_builder_deleteApiMessage`, `tosca_playlist_deleteById`, folder deletes.

See [references/editability-and-persistence.md](references/editability-and-persistence.md).
