---
name: tosca-explaining-testcase
description: >-
  Explains what a Tosca Cloud test case does in plain language. Uses toscactl for discovery and tn
  for Builder step-tree read (CLI gap). Read-only. Does NOT cover execution failure diagnosis
  (use tosca-analyzing-execution-results).
license: Apache-2.0
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Explain Tosca Cloud test case

Plain-language summary of a test case's purpose and steps. **Read-only.** **Hybrid:** toscactl + tn.

**Prerequisite:** `tosca-cloud-connect`. For step tree: tn configured (`configure_tn_connection.py`).

Runtime: **tn** for Builder step-tree read — see [runtime-routing.md](../tosca-cloud/runtime-routing.md).

## Session checklist

```text
Explain Cloud test case:
- [ ] Resolve test case [toscactl]
- [ ] Read step structure [tn]
- [ ] Summarize purpose, steps, verifications
- [ ] Present structured walkthrough
```

## toscactl (default) — discovery

```bash
toscactl assets find --type testCase --name "<name>" --json --silent
```

Use returned metadata (name, id, tags, folder) in summary.

## tn (gap fallback) — step tree

```bash
echo "/tosca — Explain test case '<name>': resolve via inventory search, read Builder structure, summarize purpose and steps. Read-only." | tn
```

Requires tn + `/tosca`. See [references/read-path.md](references/read-path.md).

## Fast path

1. **[toscactl] Resolve** — `assets find --type testCase --name`
2. **[tn] Read structure** — inventory + `getModulesSummary` / Builder via `/tosca`
3. **Summarize** — purpose, preconditions, steps, verifications; state confidence when inferred
4. **Report** — structured walkthrough

## Output template

```
## <Test case name>
**Purpose:** <one sentence>
**Preconditions:** <list>
**Steps:**
1. <action> — <expected>
...
**Key verifications:** <list>
```

Read-only — do not mutate unless user asks to remediate.
