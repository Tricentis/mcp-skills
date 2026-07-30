# Parsing TCShell Text Output

TCShell does not emit JSON. Parse stdout/stderr as plain text.

## `print` output

Typical shape:

```
ObjectName (ObjectType)
  AttributeName: value
  PropertyName (P): value
  ReadOnlyAttr (R): value
  ConfigParam (CP): value
  =>AssociationName: TargetObjectName
```

Markers:

| Marker | Meaning |
|--------|---------|
| `(R)` | Read-only attribute |
| `(P)` | Property |
| `(CP)` | Test configuration parameter |

## `get` / `gettcparam` / `getOption`

One value per line:

```
AttributeName: value
```

## Errors

- Written to stderr.
- Batch mode prefix: `scriptName (Line N): Error: ...`
- Interactive mode: `Error: ...`

## Task lists (interactive)

Numbered list format:

```
[1]='TaskName'
[2]='Another Task'
```

## Exit codes

Treat non-zero exit code as failure. Read stderr for details.

## Golden reference files

Compare ambiguous output against golden fixtures — **do not load all of `reference/output-patterns.md`** (1400+ lines).

1. Open [reference/scenarios-index.md](reference/scenarios-index.md) and pick the matching scenario.
2. Note the test fixture name (e.g. `TcShellCommandTests.SetNewTestCaseAndJumpToItByNodePath.verified`).
3. Search `reference/output-patterns.md` for that fixture's `##` heading and read **only that section**.

Generated from Tosca Commander TCShell unit test verified output (`*.verified.txt`). Use the version bundle under `reference/versions/<version>/` when detection reports a non-default Commander version.

## Tips for agents

- Capture **full stdout and stderr** before parsing.
- After multi-command scripts, scan stderr first for `Error:` lines.
- `print` on a folder lists child associations — use `JumpToNode` or TQL to drill down.
- Do not assume JSON or XML in TCShell protocol output (task-generated reports may write files separately).
