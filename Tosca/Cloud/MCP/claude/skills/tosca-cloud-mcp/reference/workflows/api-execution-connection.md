# API connection

Create or manage a Tosca Cloud API connection (HTTP, JMS, Kafka, …).

```text
API connection:
- [ ] tosca_apiconnection List
- [ ] tosca_apiconnection Get (before any Update)
- [ ] Only the operation the user asked for (create / update / delete)
- [ ] tosca_apiconnection Get (verify) after Create / Update
```

## Fork after List

| User / situation | Tools | Then |
|------------------|-------|------|
| Inspect a connection | `tosca_apiconnection` Get | Stop or List |
| Create | `tosca_apiconnection_edit` Create (`request`) | Get to verify; surface portal link |
| Update | Get → `_edit` Update with **full** `request` (carry unchanged fields) | Get to verify |
| Delete | Confirm → `_edit` Delete | List to confirm gone |

## Create / Update `request`

| Field | Notes |
|-------|-------|
| `name` | Required, 3–140 characters |
| `transportType` | Required, case-sensitive (Http, Kafka, RabbitMq, …) |
| `properties` | Optional camelCase transport config. Passwords: `{ "plainText": "..." }` — only under the scoped secrets exception (hard rule 4 in the skill's `SKILL.md`) |
| `webserviceSecurity` | Optional SOAP/WS-Security |

Update is a **full replacement** — omit = cleared. Never call Update without Get.

Use with [manage-api-message.md](manage-api-message.md) for message definitions.
