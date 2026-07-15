# Data Integrity — overview

Read on demand when planning DI work. Load **di-orchestration.md** from the skill root first.

## Available Tools

| Tool | Purpose |
|------|---------|
| `tosca_dataintegrity_listConnections` | List available DI connections (name, id, type) |
| `tosca_dataintegrity_getConnectionSchema` | Step 1 of 2: start a schema retrieval via Tosca Launcher — returns launcherLink + notificationId |
| `tosca_dataintegrity_checkSchemaResult` | Step 2 of 2: poll for schema results — returns tables and columns |
| `tosca_dataintegrity_createRowByRowComparison` | Create a Row by Row Comparison test case |
| `tosca_dataintegrity_connection` | Get or delete a single DI connection by id |
| `tosca_dataintegrity_testConnection` | Step 1 of 2: test a DI connection via Tosca Launcher |
| `tosca_dataintegrity_checkTestConnectionResult` | Step 2 of 2: poll for test-connection result |

> **Connections are managed in the Tosca Cloud UI.** MCP tools cannot create or update connections.

---
