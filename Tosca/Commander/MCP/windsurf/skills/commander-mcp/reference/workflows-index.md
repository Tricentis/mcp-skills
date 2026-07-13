# MCP workflow patterns

Curated **Code Mode** sequences — plan the full chain before calling tools.

For when/how per tool, load **tool-orchestration.md** from the skill root. For checkout and persist rules, load **workspace-orchestration.md**.

| Workflow | File | Use when |
|----------|------|----------|
| Inspect workspace | [inspect-workspace.md](workflows/inspect-workspace.md) | User asks what is open, project structure |
| Create test case | [create-test-case.md](workflows/create-test-case.md) | New test case with optional steps |
| Add step to existing test case | [add-step-to-existing-test-case.md](workflows/add-step-to-existing-test-case.md) | Appending a step after creation (not supported by `create_test_case`) |
| Run Commander task | [execute-task.md](workflows/execute-task.md) | Context menu task on selection |
| Persist changes | [save-and-checkin.md](workflows/save-and-checkin.md) | After mutations in multi-user workspace |
| Data Integrity intro | [di-getting-started.md](workflows/di-getting-started.md) | DI connections, schema, comparison |

**Data Integrity reference** (read one file at a time): [di/index.md](di/index.md)

Always end mutation workflows with `save_workspace` (single-user) or `check_in_all` (multi-user) when publishing changes.
