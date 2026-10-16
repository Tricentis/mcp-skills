# Locate execution results (no search tool)

Resolve which run the user means when they name a test, a night, or nothing at all. Read-only.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `(input)` | node path given · "the selected one" · neither | Path → step 3; selection → step 2; neither → step 6 |
| 2 | `get_current_selection` | — | `ExecutionList` / `ExecutionEntry` / an execution log selected → step 7; empty → step 6 |
| 3 | `get_object_info` | the named path, no `include_parent_and_children` | Resolves → step 7; per-object `error` → path is wrong, step 4 |
| 4 | `get_object_info` | the top-level Execution folder, `include_parent_and_children=true` | First page of children — read the root's own name from this listing; it is project- and locale-specific, never hardcode it |
| 5 | `get_object_info` | one candidate child, `include_parent_and_children=true`, then `offset=nextOffset` while set | Descend **breadth-first by name, one level per call**; **stop after 3 levels** with no match → step 6 |
| 6 | `(ask user)` | node path, or ask them to select it in Commander | No search tool, no TQL results ever come back, and no reverse lookup from a `TestCase` to its runs — do not guess a path. Ask and stop |
| 7 | `get_attributes` | the resolved `ExecutionList` | Aggregate counters + name/timestamps confirm this is the run meant |

## Notes

- `include_parent_and_children=true` accepts exactly **one** identifier per call — one call per
  level. Walk upward via the returned `parent`; see `execution-object-model.md` under `reference/`
  for the full log object tree.
- That same call returns a `references` map — on an `ExecutionEntry`, the `testCase` role is a
  free hop to the executed test case, and it does not work in reverse.
- Collision suffixes (`_1`, `_2`) flag a duplicate name, **not** which sibling is the run wanted —
  read `StartTime` before choosing.
- Report: the resolved run path and which counters it carries, then continue with
  [analyze-execution-results.md](analyze-execution-results.md).
