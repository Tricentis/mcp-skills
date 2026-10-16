---
name: tosca-remediating-from-results
description: >-
  Applies fixes to Tosca Cloud test artifacts based on execution failure analysis — test case edits,
  step renames/value updates, and related Builder updates. Use when the user asks to fix, update, or
  remediate failing tests after diagnosis. Requires explicit user approval for destructive changes.
  Does NOT cover read-only analysis (use tosca-analyzing-execution-results).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Henry Fieglein | Fractal
  version: "1.16.0"
---

# Remediate Tosca Cloud tests from results

Apply ranked fixes from analysis. **Mutating** — confirm scope before edits.

Prerequisite: diagnosis from `tosca-analyzing-execution-results` or user-provided failure detail.

## Session checklist

```text
Remediate Cloud tests:
- [ ] Confirm scope and get user approval
- [ ] Resolve artifacts (inventory search / testcase Get)
- [ ] Apply fix per remediation recipe
- [ ] Verify with tosca_testcase Get and/or re-run
- [ ] Report changes, run id, outcome, confidence
```

## Fast path

1. **Confirm scope** — which test cases / steps to fix; get user approval.
2. **Resolve artifacts** — `tosca_asset` Search and/or `tosca_testcase` Get.
3. **Apply fix** — fetch relevant run `attachments[]` / `logsUrl` / `testStepsUri*` first, then per recipe in [references/remediation-recipes.md](references/remediation-recipes.md). Common: `tosca_teststep_edit` Upsert (values/name), `tosca_testcase_edit` Upsert (tcp/metadata), `tosca_apimessage_edit` Upsert.
4. **Verify** — `tosca_testcase` Get; re-run via `tosca_testrun_edit` Create (trial) or `tosca_playlistrun_edit` Create.
5. **Report** — what changed, new run id, outcome.

## Persistence

Cloud mutations persist via API immediately. No save/check-in step.

## Destructive operations

Confirm before: `tosca_apimessage_edit` Delete, `tosca_playlist_edit` Delete, `tosca_testcase_edit` Delete, folder deletes, run Deletes.

See [references/editability-and-persistence.md](references/editability-and-persistence.md).
