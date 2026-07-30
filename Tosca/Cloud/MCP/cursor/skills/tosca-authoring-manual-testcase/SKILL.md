---
name: tosca-authoring-manual-testcase
description: >-
  Creates a manual test case in Tosca Cloud from a written specification or user story. Use when the
  user provides manual test steps in prose and wants a Cloud test case created. Does NOT cover
  automated module-based authoring (use tosca-authoring-automated-testcase).
license: Apache-2.0
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Author manual test case — Tosca Cloud

Convert written manual steps into a Cloud test case.

**Prerequisite:** `tosca-cloud-basics` + MCP connected.

## Session checklist

```text
Author manual Cloud test:
- [ ] Parse spec → name, steps, expected results
- [ ] Find target folder (inventory search)
- [ ] scaffoldTestCase with manual step structure
- [ ] Verify via inventory search
- [ ] Report entityId and step summary
```

## Fast path

1. **Parse spec** — extract test name, steps, expected results from user input.
2. **Find target folder** — `tosca_inventory_search(artifactType: folder)`.
3. **Scaffold** — `tosca_builder_scaffoldTestCase` with manual step structure.
4. **Verify** — `tosca_inventory_search(artifactType: testCase, artifactName)`.
5. **Report** — entityId, portal link if returned, step summary.

## Model notes

Manual tests use descriptive steps rather than module references. See [references/manual-model.md](references/manual-model.md).

## Hand off

Automated module-based tests → `tosca-authoring-automated-testcase`.
