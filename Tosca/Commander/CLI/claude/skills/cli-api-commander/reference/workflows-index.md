# TCShell workflow patterns

Curated end-to-end sequences — plan the full `.tcs` script or TCAPI chain before invoking.

For path and runtime selection, load **path-selection.md** from the skill root. For checkout and persist rules, load **workspace-checkout.md**.

| Workflow | File | Use when |
|----------|------|----------|
| Inspect workspace | [inspect-workspace.md](workflows/inspect-workspace.md) | Read-only audit, "what's in my workspace" |
| Create test case | [create-test-case.md](workflows/create-test-case.md) | New test case under TestCases folder |
| Add manual step | [add-manual-step.md](workflows/add-manual-step.md) | Append manual step to existing TC |
| Execute task | [execute-task.md](workflows/execute-task.md) | Context-menu task on selection |
| Persist changes | [save-and-checkin.md](workflows/save-and-checkin.md) | After mutations; multi-user check-in |
| Run execution list | [run-execution-list.md](workflows/run-execution-list.md) | Execute EL and optional report |
| Create workspace | [create-workspace.md](workflows/create-workspace.md) | Bootstrap new SQLite workspace |

**Intent router:** [journeys-index.md](../journeys-index.md)

Always end mutation workflows with `save`. In multi-user workspaces, add `checkinall` when publishing to the common repository.

**Data Integrity** is not available via TCShell, TCAPI, or Remote Control.
