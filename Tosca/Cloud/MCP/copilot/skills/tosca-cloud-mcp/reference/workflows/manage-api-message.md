# Manage API message

Create, read, update, or delete Tosca Cloud API messages (HTTP/JMS request-response definitions used by API tests). Use noun tools only.

```text
API message:
- [ ] tosca_asset Search (optional — locate message / id)
- [ ] tosca_apiconnection List (when using a named connection)
- [ ] tosca_apimessage Get (before any Upsert update or Delete)
- [ ] Only the operation the user asked for (create / update / delete)
- [ ] tosca_apimessage Get (verify) after create / update
```

## Fork

| User / situation | Tools | Then |
|------------------|-------|------|
| Read a message | `tosca_apimessage` Get (`messageId`) | Stop |
| Create | `tosca_apimessage_edit` Upsert — omit `messageId`, pass `request` | Surface portal link; Get to verify |
| Update | Get → `_edit` Upsert with `messageId` + **full** `request` | Confirm; Get to verify |
| Delete | Confirm → `_edit` Delete (`messageId`) | Inventory search / Get to confirm gone |

## Create / Update `request`

| Field | Notes |
|-------|-------|
| `name` | Required. If missing, derive from method+resource (e.g. `GET /v1/orders`), propose, confirm |
| `method` | GET, POST, PUT, PATCH, DELETE. Default GET — state the assumption |
| `endpoint` **or** `connectionId` | One required. `connectionId` from `tosca_apiconnection` List. Inline `endpoint` is the base URL (scheme included) without the resource path |
| `resource` | Relative path, e.g. `/v1/orders/{id}` |
| `headers` / `queryParameters` / `pathParameters` | Optional lists. Omit when unused — do not pass `[null]` |
| `requestBody` | Optional raw string |
| `username` / `password` | Basic auth only. Other auth → prefer a named API connection (`connectionId`) that holds the credential. If a header is required, leave the token value for the user to fill in the portal (`headers` are stored in clear text; see hard rule 4 in the skill's `SKILL.md`). Never invent auth. Secret values only under the scoped secrets exception |
| `attributes` | Optional request/response steering (`Module` request \| response). Omit when unused — do not pass `[null]` |
| `jmsSettings` | Named JMS/messaging connections only; ignored for inline endpoint |

If both `connectionId` and inline endpoint/auth are set, the named connection wins and inline values are ignored.

**Update is a full replacement** — omit = cleared. Get first. Named connection on an existing message: `tcProperties.DefaultConnection` → `connectionId` (else `apiConnectionProperties.properties.endpoint` → `endpoint`). Reconstruct `jmsSettings` from `modules[0].tcProperties` / `apiProperties.messageProperties` when present.

**Stored Basic-auth password on Update** — an existing password cannot be carried over: `request.password` takes plain text only, and omitting it clears the stored one. When an inline-endpoint message has Basic auth and the user changes something else, do **not** ask for the password. Before confirming, warn that the update clears it, then send the update without `password` and point the user to the returned portal link to set it again. Messages on a named `connectionId` are not affected — the credential lives on the connection.

## Rules

- Both tools require the Automate API entitlement; without it they are not offered.
- Confirm before Upsert (update) and Delete — changing or deleting a message can break test cases that use its modules.
- Never delete+recreate to work around an update failure.
- Surface the portal link returned on create/update.
- Pair with `tosca_apiconnection` when tests execute against a named connection.

Use with [api-execution-connection.md](api-execution-connection.md) for connection CRUD.
