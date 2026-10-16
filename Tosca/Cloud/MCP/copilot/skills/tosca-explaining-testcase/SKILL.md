---
name: tosca-explaining-testcase
description: >-
  Explains what a Tosca Cloud test case does in plain language by reading its structure from
  inventory and testcase/teststep tools. Use when the user asks what a test case covers, how it
  works, or wants a walkthrough. Read-only. Does NOT cover execution failure diagnosis (use
  tosca-analyzing-execution-results).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Henry Fieglein | Fractal
  version: "1.16.0"
---

# Explain Tosca Cloud test case

Produce a plain-language summary of a test case's purpose and steps. **Read-only.**

**Prerequisite:** `tosca-cloud-basics`.

## Session checklist

```text
Explain Cloud test case:
- [ ] Resolve test case (inventory search)
- [ ] Read structure (tosca_testcase Get; tosca_teststep Get for values)
- [ ] Expand RTSB references (tosca_rtsb Get)
- [ ] Summarize purpose, preconditions, steps, verifications
- [ ] Present structured walkthrough
```

## Fast path

1. **Resolve test case** — `tosca_asset` Search (`artifactType: testCase`, `name`).
2. **Read structure** — `tosca_testcase` Get. For step values, `tosca_teststep` Get. See [references/read-path.md](references/read-path.md).
3. **Expand RTSB references** — when `items[]` contains `testStepFolderReference`, call `tosca_rtsb` Get with the referenced id to explain nested shared-action steps and business parameters.
4. **Summarize** — purpose, preconditions, step flow, key verifications.
5. **Report** — structured walkthrough for the user.

## Output template

```
## <Test case name>
**Purpose:** <one sentence>
**Preconditions:** <list>
**Steps:**
1. <action> — <expected>
2. ...
**Key verifications:** <list>
```

Read-only — do not mutate unless user asks to remediate.
