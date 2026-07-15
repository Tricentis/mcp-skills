# API execution connection

Create or manage an API test execution connection.

```text
API execution connection:
- [ ] tosca_apiexecution_listConnections
- [ ] create / get / update
- [ ] confirm before delete*
```

## Plan

| Step | Tool | Expected |
|------|------|----------|
| 1 | `tosca_apiexecution_listConnections` | Connection ids |
| 2 | `tosca_apiexecution_createConnection` | New connection |
| 3 | `tosca_apiexecution_getConnection` | Read config |
| 4 | `tosca_apiexecution_updateConnection` | Update (**destructive** flag) |

Use with [manage-api-message.md](manage-api-message.md) for message definitions.
