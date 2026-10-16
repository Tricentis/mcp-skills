---
name: tosca-authoring-automated-testcase
description: >-
  Creates an automated test case in Tosca Cloud from a description, preferring existing modules and
  offering Scan/Rescan via tosca_module_edit when a UI module is missing. Use when the user wants a
  new automated test from Cloud modules. Does NOT cover manual-only tests (use
  tosca-authoring-manual-testcase).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Henry Fieglein | Fractal
  version: "1.16.0"
---

# Author automated test case — Tosca Cloud

Build automated tests from Cloud modules (reuse first; Scan/Rescan when needed).

**Prerequisite:** `tosca-cloud-basics` + MCP connected.

## Guardrails (read first)

- **Prefer existing modules.** If a step has no module, offer `tosca_module_edit` **Scan** (or Rescan) — open the returned link, wait for the user to finish, then Search UserAssets `sort=Latest` (or Get). Otherwise **report the gap**. Manual/NonGUI shells can still be created with Upsert when appropriate.
- **Confirm** target name and module sources before creating.
- **Get module before values** — never invent attribute paths.
- **Secrets** — never pass password values; empty Password TCP shells only.

## Session checklist

```text
Author automated Cloud test:
- [ ] Understand scenario → ordered actions/verifications
- [ ] tosca_asset Search (sharedAction) — check for existing RTSBs before creating duplicates
- [ ] tosca_module Search / Get per step
- [ ] tosca_testcase_edit Upsert (name + steps or empty shell)
- [ ] tosca_teststep_edit for additional steps/folders (optional)
- [ ] tosca_testcase Get to verify; summarize modules used
- [ ] Optional trial: tosca_testrun_edit Create → tosca_testrun Get
```

## Fast path

1. **Understand goal** — user description → test flow.
2. **Find modules** — `tosca_module` Search (`scope` All / StandardObjects / UserAssets); Get each chosen id. If missing, `tosca_module_edit` Scan/Rescan then Search UserAssets `sort=Latest`. See [references/module-sourcing.md](references/module-sourcing.md).
3. **Check existing RTSBs** — when the scenario matches a reuseable test step block (login, cookie accept, common navigation), `tosca_asset` Search with `artifactType: sharedAction` and a name filter; `tosca_rtsb` Get to inspect steps and business parameters before authoring new steps. When the same sequence recurs and no block covers it, create one with `tosca_rtsb_edit` Upsert and fill it via `tosca_teststep_edit` with `testStepContainerType=rtsb` and `testStepContainerId` — see [../tosca-cloud-mcp/builder-orchestration.md](../tosca-cloud-mcp/builder-orchestration.md).
4. **Create** — `tosca_testcase_edit` Upsert with `name` and `steps[{ moduleId, values }]`, or empty shell then `tosca_teststep_edit`.
5. **Extend** — `tosca_teststep_edit` Upsert inserts (`kind`: testStep | testStepFolder).
6. **Verify** — `tosca_testcase` Get; optional `tosca_testrun_edit` Create → `tosca_testrun` Get trial run.

## Module sourcing

See [references/module-sourcing.md](references/module-sourcing.md).

## Action modes

See [references/action-modes-and-buffering.md](references/action-modes-and-buffering.md) for Input/Verify/WaitOn/Buffer when setting `values[].actionMode`.

## Procedure

1. **Understand intent** — scenario → ordered atomic steps with concrete data.
2. **Ask module sources** — which folders/scopes to search; do not guess broadly.
3. **Match modules** — Search + Get; confirm collisions with the user.
4. **Upsert test case** — include required ExactlyOne values from the module definition.
5. **Verify** — Get; report modules used, gaps, confidence score.

## Hand off

Manual test first → `tosca-authoring-manual-testcase`.

## API-heavy tests

When the scenario needs HTTP/service calls, create or reuse API messages via `tosca-cloud-mcp` → `reference/workflows/manage-api-message.md` before stepping modules that depend on them.
