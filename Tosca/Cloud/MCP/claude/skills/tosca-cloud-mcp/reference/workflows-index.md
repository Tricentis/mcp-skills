# MCP workflow patterns

Curated **Code Mode** sequences — plan the full chain before calling tools.

For when/how per tool, load **tool-orchestration.md** from the skill root. For space and tenant context, load **space-orchestration.md**.

| Workflow | File | Use when |
|----------|------|----------|
| Connect tenant | [connect-tenant.md](workflows/connect-tenant.md) | Configure hosted MCP URL and verify Okta session |
| Inspect space | [inspect-space.md](workflows/inspect-space.md) | User asks what artifacts or playlists exist |
| Search artifacts | [search-artifacts.md](workflows/search-artifacts.md) | Find test cases, modules, folders by criteria |
| Manage folder | [manage-folder.md](workflows/manage-folder.md) | Get, create, rename/recolor, move, or delete folders |
| Create / edit test case | [create-testcase.md](workflows/create-testcase.md) | Create test case from modules; edit steps |
| Trial run test case | [trial-run-testcase.md](workflows/trial-run-testcase.md) | Personal-agent Builder Run / trial run |
| Create playlist | [create-playlist.md](workflows/create-playlist.md) | New playlist, SetTestCases, SetSchedule |
| Run playlist | [run-playlist.md](workflows/run-playlist.md) | Start playlist run and poll until terminal |
| Analyze failures | [analyze-run-failures.md](workflows/analyze-run-failures.md) | Diagnose failed steps from playlist runs |
| Rename test steps | [rename-playlist-items.md](workflows/rename-playlist-items.md) | Rename steps via tosca_teststep_edit |
| Manage API message | [manage-api-message.md](workflows/manage-api-message.md) | CRUD API messages (`tosca_apimessage` / `_edit`) |
| Inspect test sheet | [inspect-testsheet.md](workflows/inspect-testsheet.md) | Find and read TDM test sheets, classes and rows (`tosca_testsheet`) |
| Manage test sheet | [manage-testsheet.md](workflows/manage-testsheet.md) | Create/edit TDM test sheets, classes, rows (`tosca_testsheet` / `_edit`) |
| Data Integrity intro | [di-getting-started.md](workflows/di-getting-started.md) | DI connections, schema, comparison |
| DI connection | [di-connection.md](workflows/di-connection.md) | List / Get / Create / Update / Test DI connections |
| DI DB Expert testcase | [di-db-expert-testcase.md](workflows/di-db-expert-testcase.md) | Generated from Standard Object `DI DB Expert module` |
| Mobile connection | [mobile-connection.md](workflows/mobile-connection.md) | Mobile test connection setup |
| API connection | [api-execution-connection.md](workflows/api-execution-connection.md) | API test connection (HTTP/JMS/Kafka) |
| Deploy simulation | [deploy-simulation.md](workflows/deploy-simulation.md) | Deploy API simulation (`tosca_simulator` / `_edit`) |

**Data Integrity reference** (read one file at a time): [di/index.md](di/index.md)

Cloud mutations are persisted immediately via API — there is no separate save/check-in step.
