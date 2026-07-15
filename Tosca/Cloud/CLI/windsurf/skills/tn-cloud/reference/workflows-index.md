# MCP workflow patterns (via TN CLI)

Curated sequences — delegate to **`tn`** with `/tosca` active. Plan the full chain in the loop prompt or REPL session.

For tool order details, load orchestration docs from the skill root. Adapted from Tosca.Cloud.MCP.integration for TN invocation.

| Workflow | File | TN pattern |
|----------|------|------------|
| Connect tenant | [connect-tenant.md](workflows/connect-tenant.md) | `configure_tn_connection.py` + `tn --setup` |
| Inspect space | [inspect-space.md](workflows/inspect-space.md) | piped |
| Search artifacts | [search-artifacts.md](workflows/search-artifacts.md) | piped |
| Manage folder | [manage-folder.md](workflows/manage-folder.md) | REPL or loop |
| Create playlist | [create-playlist.md](workflows/create-playlist.md) | loop |
| Run playlist | [run-playlist.md](workflows/run-playlist.md) | loop |
| Analyze failures | [analyze-run-failures.md](workflows/analyze-run-failures.md) | piped → journey skill |
| Rename playlist items | [rename-playlist-items.md](workflows/rename-playlist-items.md) | REPL |
| Scaffold test case | [scaffold-test-case.md](workflows/scaffold-test-case.md) | loop |
| Manage API message | [manage-api-message.md](workflows/manage-api-message.md) | loop |
| Data Integrity intro | [di-getting-started.md](workflows/di-getting-started.md) | loop |
| DI DB Expert testcase | [di-db-expert-testcase.md](workflows/di-db-expert-testcase.md) | loop |
| Mobile connection | [mobile-connection.md](workflows/mobile-connection.md) | REPL |
| API execution connection | [api-execution-connection.md](workflows/api-execution-connection.md) | REPL |
| Deploy simulation | [deploy-simulation.md](workflows/deploy-simulation.md) | loop |
| Autonomous multi-step | [loop-autonomous.md](workflows/loop-autonomous.md) | `--loop` |
| Robot monitoring | [robot-monitoring.md](workflows/robot-monitoring.md) | `--robot` |

**Data Integrity reference:** [di/index.md](di/index.md)

Cloud mutations persist immediately via API — no save/check-in step.
