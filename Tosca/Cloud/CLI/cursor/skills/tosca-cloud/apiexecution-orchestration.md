# API execution orchestration — connection CRUD

Manage API test execution connections in Tosca Cloud.

## Session checklist

```text
API execution connection session:
- [ ] tosca_apiexecution_listConnections
- [ ] get or mutate target connection
- [ ] confirm before delete*
```

## Tool sequence

| Goal | Tools |
|------|-------|
| List | `tosca_apiexecution_listConnections` |
| Read | `tosca_apiexecution_getConnection` |
| Create | `tosca_apiexecution_createConnection` |
| Update | `tosca_apiexecution_updateConnection` (**destructive** flag) |
| Delete | `tosca_apiexecution_deleteConnection` (**destructive**) |

## Rules

1. List connections before get/update/delete.
2. Confirm with user before delete or update flagged destructive.
3. Pair with Builder API messages (`tosca_builder_*ApiMessage`) when authoring API tests — see [builder-orchestration.md](builder-orchestration.md).

## Related

- [reference/workflows/api-execution-connection.md](reference/workflows/api-execution-connection.md)
