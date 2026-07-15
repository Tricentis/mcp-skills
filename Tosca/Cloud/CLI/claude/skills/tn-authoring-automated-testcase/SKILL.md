---
name: tn-authoring-automated-testcase
description: >-
  Creates an automated test case in Tosca Cloud from a description, reusing existing modules. Use when
  the user wants a new automated test built from available Cloud modules. Does NOT cover UI module
  scanning or manual-only tests (use tn-authoring-manual-testcase).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Author automated test case — Tosca Cloud

Build automated tests from existing Cloud modules.

**Prerequisite:** `tn-cloud-basics` + tn /tosca configured.

## TN invocation

**Loop (module search + scaffold):**

```bash
tn --loop "Activate /tosca. Create automated test '<name>' reusing modules from folders <folders>. Report module gaps. loop_complete when done."
```

## Guardrails (read first)

- **Reuse existing modules only.** No UI module scanning in Cloud MCP — if a step has no module, **report the gap** and stop for that step.
- **Confirm** target folder/name and module sources before scaffolding.
- **Steps at creation only** — Cloud MCP has no append-step tool; include all steps in `tosca_builder_scaffoldTestCase` or use Builder UI for later edits.

## Session checklist

```text
Author automated Cloud test:
- [ ] Understand scenario → ordered actions/verifications
- [ ] Ask user which module folders to search
- [ ] getModulesSummary + inventory search for modules
- [ ] Match steps to modules (report gaps)
- [ ] scaffoldTestCase with testSteps
- [ ] Verify via inventory search; summarize modules used
```

## Fast path

1. **Understand goal** — user description → test flow.
2. **Find modules** — `tosca_builder_getModulesSummary` + `tosca_inventory_search(artifactType: module)`.
3. **User picks modules** — present candidates; no UI scanning available.
4. **Scaffold** — `tosca_builder_scaffoldTestCase` with module references.
5. **Verify** — inventory search for created test case.

## Module sourcing

See [references/module-sourcing.md](references/module-sourcing.md). Agents must reuse existing modules — cannot scan applications.

## Action modes

See [references/action-modes-and-buffering.md](references/action-modes-and-buffering.md) for Input/Verify/WaitOn/Buffer conventions when editing step values via Builder APIs.

## Procedure

1. **Understand intent** — scenario or manual test → ordered atomic steps with concrete data.
2. **Ask module sources** — which folders/tags to search; do not guess broadly.
3. **Match modules** — per step, find module + attributes in allowed sources ([module-sourcing.md](references/module-sourcing.md)).
4. **Scaffold with all steps** — `tosca_builder_scaffoldTestCase` including `testSteps` array.
5. **Verify** — inventory search; report modules used, gaps, confidence score.

## Hand off

Manual test first → `tn-authoring-manual-testcase`.

## API-heavy tests

When the scenario needs HTTP/service calls, create or reuse API messages via `tn-cloud` → `reference/workflows/manage-api-message.md` workflow before scaffolding steps that reference them.
