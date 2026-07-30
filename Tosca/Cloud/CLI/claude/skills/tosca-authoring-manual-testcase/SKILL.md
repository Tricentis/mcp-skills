---
name: tosca-authoring-manual-testcase
description: >-
  Creates a manual test case in Tosca Cloud from a written specification. Uses tn for scaffold (CLI
  gap). Does NOT cover automated module-based authoring (use tosca-authoring-automated-testcase).
license: Apache-2.0
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Author manual test case — Tosca Cloud

Convert written manual steps into a Cloud test case. **tn only** until toscactl ships manual TC create.

**Prerequisite:** `tosca-cloud-connect` + tn gap setup (`configure_tn_connection.py`, `tn --setup`).

Runtime: **tn** for manual test case creation — see [runtime-routing.md](../tosca-cloud/runtime-routing.md).

## Session checklist

```text
Author manual Cloud test:
- [ ] Parse spec → name, steps, expected results
- [ ] Find target folder [tn]
- [ ] scaffoldTestCase [tn]
- [ ] Verify via inventory search [tn]
```

## tn (gap — primary until CLI ships)

```bash
tn --loop "Activate /tosca. Create manual test case '<name>' in folder '<folder>' from this spec: <paste steps>. Verify via inventory search. loop_complete when done."
```

## Fast path [tn]

1. **Parse spec** — name, steps, expected results
2. **Find folder** — `tosca_inventory_search(artifactType: folder)`
3. **Scaffold** — `tosca_builder_scaffoldTestCase` with manual steps
4. **Verify** — `tosca_inventory_search(artifactType: testCase)`
5. **Report** — entityId, step summary

See [references/manual-model.md](references/manual-model.md).

## Hand off

Automated module-based tests → `tosca-authoring-automated-testcase`.
