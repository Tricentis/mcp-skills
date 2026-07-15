---
name: tn-explaining-testcase
description: >-
  Explains what a Tosca Cloud test case does in plain language by reading its structure from
  inventory and Builder. Use when the user asks what a test case covers, how it works, or wants a
  walkthrough. Read-only. Does NOT cover execution failure diagnosis (use
  tn-analyzing-execution-results).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Explain Tosca Cloud test case

Produce a plain-language summary of a test case's purpose and steps. **Read-only.**

**Prerequisite:** `tn-cloud-basics`.

## TN invocation

**Piped (read-only walkthrough):**

```bash
echo "/tosca — Explain test case '<name>': resolve via inventory search, summarize purpose and steps. Read-only." | tn
```

## Session checklist

```text
Explain Cloud test case:
- [ ] Resolve test case (inventory search)
- [ ] Read structure via Builder/inventory APIs
- [ ] Summarize purpose, preconditions, steps, verifications
- [ ] Present structured walkthrough
```

## Fast path

1. **Resolve test case** — `tosca_inventory_search(artifactType: testCase, artifactName)`.
2. **Read structure** — inventory metadata; `getModulesSummary` / `getApiMessage` where applicable. See [references/read-path.md](references/read-path.md) for interim path and MCP gaps.
3. **Summarize** — purpose, preconditions, step flow, key verifications. State confidence when step detail is inferred.
4. **Report** — structured walkthrough for the user.

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
