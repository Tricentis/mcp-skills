# Mobile connection

Create or update a mobile test connection.

```text
Mobile connection:
- [ ] tosca_mobile_listConnections
- [ ] tosca_mobile_createConnection or update
- [ ] tosca_mobile_getConnection (verify)
```

## Plan

| Step | Tool | Expected |
|------|------|----------|
| 1 | `tosca_mobile_listConnections` | Existing connections |
| 2 | `tosca_mobile_createConnection` | New connection id |
| 3 | `tosca_mobile_addCapabilitySet` | Capability set on connection |
| 4 | `tosca_mobile_setCapability` | Capability values |
| 5 | `tosca_mobile_getConnection` | Verify configuration |

**Destructive:** confirm before `tosca_mobile_deleteConnection`, `removeCapabilitySet`, `deleteCapability`.
