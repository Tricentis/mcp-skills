---
name: tosca-authoring-manual-testcase
description: >-
  Creates a manual test case in Tosca Cloud from a written specification or user story. Use when the
  user provides manual test steps in prose and wants a Cloud test case created. Does NOT cover
  automated module-based authoring (use tosca-authoring-automated-testcase).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Henry Fieglein | Fractal
  version: "1.16.0"
---

# Author manual test case — Tosca Cloud

Convert written manual steps into a Cloud test case shell (name, description, structured folders/steps).

**Prerequisite:** `tosca-cloud-basics` + MCP connected.

## Session checklist

```text
Author manual Cloud test:
- [ ] Parse spec → name, steps, expected results
- [ ] inventory search — avoid duplicate names
- [ ] Find target folder (optional)
- [ ] tosca_testcase_edit Upsert (name + description; empty or folder structure)
- [ ] Optional: tosca_teststep_edit folders for sectioning
- [ ] tosca_testcase Get / inventory search to verify
- [ ] Report id and step summary
```

## Fast path

1. **Parse spec** — extract test name, steps, expected results from user input.
2. **Check for duplicates** — `tosca_asset` Search (`artifactType: testCase`, `name`); if a match exists, confirm with user before creating another.
3. **Find target folder** — `tosca_asset` Search (`artifactType: folder`) (optional).
4. **Create** — `tosca_testcase_edit` Upsert with `name` + `description` capturing the manual intent (empty `steps` shell OK). Use `tosca_teststep_edit` Upsert `kind=testStepFolder` to section the case if helpful.
5. **Verify** — `tosca_testcase` Get.
6. **Report** — id, portal `url`, step/folder summary.

## Model notes

Fully automated steps require modules — see [references/manual-model.md](references/manual-model.md). When the user wants executable automation, hand off to `tosca-authoring-automated-testcase`.

## Hand off

Automated module-based tests → `tosca-authoring-automated-testcase`.
