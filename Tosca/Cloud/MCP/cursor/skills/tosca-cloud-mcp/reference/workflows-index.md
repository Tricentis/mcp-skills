# MCP workflow patterns

Curated **Code Mode** sequences — plan the full chain before calling tools.

For when/how per tool, load **tool-orchestration.md** from the skill root. For space and tenant context, load **space-orchestration.md**.

| Workflow | File | Use when |
|----------|------|----------|
| Connect tenant | [connect-tenant.md](workflows/connect-tenant.md) | Configure hosted MCP URL and verify Okta session |
| Inspect space | [inspect-space.md](workflows/inspect-space.md) | User asks what artifacts or playlists exist |
| Search artifacts | [search-artifacts.md](workflows/search-artifacts.md) | Find test cases, modules, folders by criteria |
| Manage folder | [manage-folder.md](workflows/manage-folder.md) | Create, modify, or delete folders |
| Create playlist | [create-playlist.md](workflows/create-playlist.md) | New playlist with test case items |
| Run playlist | [run-playlist.md](workflows/run-playlist.md) | Execute a playlist and poll run status |
| Analyze failures | [analyze-run-failures.md](workflows/analyze-run-failures.md) | Diagnose failed steps from recent runs |
| Rename playlist items | [rename-playlist-items.md](workflows/rename-playlist-items.md) | Semantic rename of playlist test case items |
| Scaffold test case | [scaffold-test-case.md](workflows/scaffold-test-case.md) | Create a test case with optional steps at creation |
| Manage API message | [manage-api-message.md](workflows/manage-api-message.md) | CRUD Builder API messages |
| Data Integrity intro | [di-getting-started.md](workflows/di-getting-started.md) | DI connections, schema, comparison |
| DI DB Expert testcase | [di-db-expert-testcase.md](workflows/di-db-expert-testcase.md) | DB Expert DI test case |
| Mobile connection | [mobile-connection.md](workflows/mobile-connection.md) | Mobile test connection setup |
| API execution connection | [api-execution-connection.md](workflows/api-execution-connection.md) | API test execution connection |
| Deploy simulation | [deploy-simulation.md](workflows/deploy-simulation.md) | Deploy API simulation to agent |

**Data Integrity reference** (read one file at a time): [di/index.md](di/index.md)

Cloud mutations are persisted immediately via API — there is no separate save/check-in step.
