# Manage API message

Create, read, update, or delete Builder API messages.

```text
API message:
- [ ] tosca_inventory_search (optional — locate message)
- [ ] tosca_builder_getApiMessage / create / update / delete
- [ ] verify via get
```

## Plan

| Step | Tool | When |
|------|------|------|
| 1 | `tosca_builder_getApiMessage` | Read existing message |
| 2 | `tosca_builder_createApiMessage` | New message |
| 3 | `tosca_builder_updateApiMessage` | Edit (**destructive** flag — confirm) |
| 4 | `tosca_builder_deleteApiMessage` | Remove (**destructive** — confirm) |

Pair with `tosca_apiexecution_*` connections when tests execute against live APIs.
