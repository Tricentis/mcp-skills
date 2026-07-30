---
name: tosca-authoring-automated-testcase
description: >-
  Creates an automated test case in Tosca Cloud from a description, reusing modules. Module discovery
  via toscactl; scaffold via tn (CLI gap). Does NOT cover manual-only tests or UI module scanning.
license: Apache-2.0
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Author automated test case — Tosca Cloud

Build automated tests from existing Cloud modules. **Hybrid:** toscactl discovery + tn scaffold.

**Prerequisite:** `tosca-cloud-connect`. tn configured for scaffold step.

Runtime: **tn** for Builder scaffold — see [runtime-routing.md](../tosca-cloud/runtime-routing.md).

## Guardrails

- **Reuse existing modules only.** No UI scanning — report gaps.
- **Confirm** folder/name and module sources before scaffolding.
- **All steps at creation** — include full `testSteps` in scaffold call.

## Session checklist

```text
Author automated Cloud test:
- [ ] Understand scenario
- [ ] Find modules [toscactl]
- [ ] Match steps to modules (report gaps)
- [ ] scaffoldTestCase [tn]
- [ ] Verify [toscactl or tn]
```

## toscactl (default) — module discovery

```bash
toscactl assets find --type module --name "<partial>" --json --silent
toscactl assets find --type folder --name "<folder>" --json --silent
```

Present candidates to user before scaffolding.

## tn (gap fallback) — scaffold

```bash
tn --loop "Activate /tosca. Create automated test '<name>' reusing modules from folders <folders>. Report module gaps. loop_complete when done."
```

## Fast path

1. **Understand goal** — user description → test flow
2. **[toscactl] Find modules** — `assets find --type module`
3. **User picks modules** — present candidates
4. **[tn] Scaffold** — `tosca_builder_scaffoldTestCase` with module references
5. **[toscactl] Verify** — `assets find --type testCase --name "<name>"`

See [references/module-sourcing.md](references/module-sourcing.md), [references/action-modes-and-buffering.md](references/action-modes-and-buffering.md).

## Hand off

Manual test first → `tosca-authoring-manual-testcase`.

API-heavy tests → `tosca-cloud` → `reference/workflows/manage-api-message.md` (tn).
