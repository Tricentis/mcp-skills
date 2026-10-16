# Mobile connection

Set up or change a mobile test connection and its capability sets.

```text
Mobile connection:
- [ ] tosca_mobileconnection List
- [ ] tosca_mobileconnection Get (before any update)
- [ ] Only the operation the user asked for (create / update / capability change / delete)
- [ ] tosca_mobileconnection Get (verify)
```

## Fork after List

| User / situation | Tools | Then |
|------------------|-------|------|
| Inspect a connection | `tosca_mobileconnection` Get → `{ connection, capabilitySets }` | Stop or List |
| Create from a configurator blob | `tosca_mobileconnection_edit` Upsert (no `connectionId`) with `capabilitySets[]` | Check `capabilitySetErrors`, then Get to verify |
| Create bare, add sets later | `tosca_mobileconnection_edit` Upsert → `tosca_mobilecapabilityset_edit` Upsert per set | Get to verify |
| Rename / repoint an existing connection | Get → `tosca_mobileconnection_edit` Upsert with `connectionId` | Get to verify |
| Add or change one capability | `tosca_mobilecapabilityset` List → `_edit` SetCapability | Get to verify |
| Delete a set | Confirm → `tosca_mobilecapabilityset_edit` Delete | Connection stays |
| Delete a connection | Confirm → `tosca_mobileconnection_edit` Delete | Linked sets go too |

## Create arguments

| `connectionType` | Required args |
|------------------|---------------|
| `Appium` (SauceLabs, BrowserStack, LambdaTest, HeadSpin, Perfecto) | `name`, `server` (full Appium URL), `serverIsSecret` (`true` when the URL embeds credentials) |
| `Tma` (Tricentis Mobile Assistant / local Appium) | `name`, `server` (e.g. `http://localhost:4723`); `serverIsSecret` ignored |

`capabilitySets[]` is **create only**: `{ name, capabilities[{ name, valueType, value, secret }] }`. On an existing connection use `tosca_mobilecapabilityset_edit`.

## Rules

- `connectionType` cannot be changed — delete and create a new connection.
- `serverIsSecret` must accompany `server` on an Appium update.
- Reads omit secret values → change capabilities one at a time with SetCapability, never by resubmitting `capabilities[]`.
- Every capability set operation needs `connectionId`.

Capability-set grouping, JSON capabilities, and secret rules: load **mobile-orchestration.md** from the skill root.
