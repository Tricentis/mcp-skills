# MCP workflow patterns

Curated **Code Mode** sequences — plan the full chain before calling tools.

For when/how per tool, load **tool-orchestration.md** from the skill root. For checkout and persist rules, load **workspace-orchestration.md**.

| Workflow | File | Use when |
|----------|------|----------|
| Inspect workspace | [inspect-workspace.md](workflows/inspect-workspace.md) | User asks what is open, project structure |
| Create test case | [create-test-case.md](workflows/create-test-case.md) | New test case with optional steps |
| Add step to existing test case | [add-step-to-existing-test-case.md](workflows/add-step-to-existing-test-case.md) | Appending a step after creation (not supported by `create_test_case`) |
| Author manual test case | [author-manual-test-case.md](workflows/author-manual-test-case.md) | Written manual definition → Tosca manual test case |
| Author automated test case | [author-automated-test-case.md](workflows/author-automated-test-case.md) | Build an automated test from a description; module sourcing, buffering, validation |
| Explain a test case | [explain-test-case.md](workflows/explain-test-case.md) | Summarize what a test case does (steps, values, target apps) |
| Analyze execution results | [analyze-execution-results.md](workflows/analyze-execution-results.md) | Diagnose why the latest run failed; ranked remediations + confidence |
| Analyze execution history | [analyze-execution-history.md](workflows/analyze-execution-history.md) | Trends, flakiness, recurring errors across many runs |
| Remediate from results | [remediate-from-results.md](workflows/remediate-from-results.md) | Apply a non-UI fix to a test / data / module and validate |
| Run Commander task | [execute-task.md](workflows/execute-task.md) | Context menu task on selection |
| Persist changes | [save-and-checkin.md](workflows/save-and-checkin.md) | After mutations in multi-user workspace |
| Data Integrity intro | [di-getting-started.md](workflows/di-getting-started.md) | DI connections, schema, comparison |

**Data Integrity reference** (read one file at a time): [di/index.md](di/index.md)

Always end mutation workflows with `save_workspace` (single-user) or `check_in_all` (multi-user) when publishing changes.
