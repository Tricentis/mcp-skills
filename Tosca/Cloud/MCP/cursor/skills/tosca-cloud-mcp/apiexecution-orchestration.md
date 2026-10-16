# API connection orchestration — connection CRUD

Manage Tosca Cloud **API connections** (HTTP, JMS brokers, Kafka, and other transports) used by API tests. Use noun tools only.

Copy and track progress:

```text
API connection workflow:
- [ ] tosca_apiconnection List (optional name filter)
- [ ] tosca_apiconnection Get (before any Update)
- [ ] tosca_apiconnection_edit Create / Update / Delete
- [ ] Confirm before Update (full replace) and Delete
```

## Tools

| Tool | Ops | Hints |
|------|-----|-------|
| `tosca_apiconnection` | Get, List | ReadOnly |
| `tosca_apiconnection_edit` | Create, Update, Delete | Destructive |

Both require the Automate API entitlement; without it the tools are not offered to the session.

## Read — `tosca_apiconnection`

**List** — optional `name` filter; omit for all. Returns slim rows: `id`, `name`, `endpoint`, `transportType`, `jmsType`, timestamps.

**Get** — requires `connectionId`. Returns full JSON (`properties`, `webserviceSecurity`). Use this as the input to Update. Surface backend errors as-is.

## Mutate — `tosca_apiconnection_edit`

**Create** — `request`: `name` (3–140 chars), `transportType`, optional `properties` / `webserviceSecurity`. Keys camelCase. Passwords: `{ "plainText": "..." }` — only under the scoped exception in [safety-and-space.md](../tosca-cloud-basics/references/safety-and-space.md#secrets); prefer omitting and letting the user set it in the portal. Returns a success string with a portal link (or “Portal link unavailable”).

**Update** — **full replacement**: every field overwritten; omit = cleared. Requires `connectionId` and `request`.

1. Call `tosca_apiconnection` Get first.
2. Carry forward every field the user is not changing (including password secret-id refs).
3. Confirm with the user before calling.

**Delete** — `connectionId`. Confirm first: deleting may break API messages and test cases that reference the connection. Cannot be undone.

## Hard rules

1. **List → Get before Update or Delete** — resolve `connectionId`, then inspect with Get.
2. **Update is not a merge** — omitting `properties` clears them.
3. **Confirm** Update and Delete unless the user asked explicitly.
4. Pair with API messages (`tosca_apimessage` Get / `tosca_apimessage_edit` Upsert/Delete) when authoring API tests — see [builder-orchestration.md](builder-orchestration.md).

## Related

- [reference/workflows/api-execution-connection.md](reference/workflows/api-execution-connection.md)
- [tool-orchestration.md](tool-orchestration.md)
