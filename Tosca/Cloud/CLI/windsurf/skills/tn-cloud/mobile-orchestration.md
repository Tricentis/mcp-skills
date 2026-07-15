# Mobile orchestration — test connections and capabilities

Manage mobile test connections and capability sets in Tosca Cloud.

## Session checklist

```text
Mobile connection session:
- [ ] tosca_mobile_listConnections
- [ ] create or get connection by id
- [ ] capability sets configured before run (if required)
- [ ] confirm before delete*
```

## Tool sequence

| Goal | Tools |
|------|-------|
| List | `tosca_mobile_listConnections` |
| Read | `tosca_mobile_getConnection` |
| Create | `tosca_mobile_createConnection` |
| Update | `tosca_mobile_updateConnection` |
| Delete connection | `tosca_mobile_deleteConnection` (**destructive**) |
| Add capability set | `tosca_mobile_addCapabilitySet` |
| Set capability value | `tosca_mobile_setCapability` |
| Rename set | `tosca_mobile_renameCapabilitySet` |
| Remove set | `tosca_mobile_removeCapabilitySet` (**destructive**) |
| Delete capability | `tosca_mobile_deleteCapability` (**destructive**) |

## Rules

1. **List before get/update/delete** — resolve connection id from `tosca_mobile_listConnections`.
2. **Confirm destructive deletes** with the user before `deleteConnection`, `removeCapabilitySet`, `deleteCapability`.
3. Mobile connections are **space-scoped** — verify tenant MCP session before mutations.

## Related

- [reference/workflows/mobile-connection.md](reference/workflows/mobile-connection.md)
- [tool-orchestration.md](tool-orchestration.md)
