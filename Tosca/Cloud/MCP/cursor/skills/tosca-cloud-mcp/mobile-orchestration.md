# Mobile orchestration — connections and capability sets

A mobile connection points Tosca Cloud at an Appium endpoint: an **Appium** cloud provider (SauceLabs, BrowserStack, LambdaTest, HeadSpin, Perfecto) or **Tma** (Tricentis Mobile Assistant / local Appium). Appium capabilities live in named **capability sets** linked to a connection — a device, an app, a provider session. Use noun tools only.

Copy and track progress:

```text
Mobile connection workflow:
- [ ] tosca_mobileconnection List (resolve connectionId)
- [ ] tosca_mobileconnection Get (connection + its capability sets before editing)
- [ ] tosca_mobileconnection_edit Upsert (create with capabilitySets, or update name / server)
- [ ] tosca_mobilecapabilityset_edit Upsert / SetCapability (sets on an existing connection)
- [ ] tosca_mobileconnection Get (verify)
- [ ] Confirm before Delete / DeleteCapability
```

## Tools

| Tool | Ops | Hints |
|------|-----|-------|
| `tosca_mobileconnection` | Get, List | ReadOnly |
| `tosca_mobileconnection_edit` | Upsert, Delete | Destructive |
| `tosca_mobilecapabilityset` | Get, List | ReadOnly |
| `tosca_mobilecapabilityset_edit` | Upsert, Delete, SetCapability, DeleteCapability | Destructive |

All four require the mobile automation entitlement; without it the tools are not offered to the session.

## Read connections — `tosca_mobileconnection`

**Get** — requires `connectionId` (GUID). Returns `{ connection, capabilitySets }`: the connection plus every linked set and the capabilities in each. Inspect this before any update. Encoded/secret values are omitted by the backend.

**List** — no parameters. Returns `id`, `name` and connection type (`$type`: `AppiumConnection` | `TmaConnection`) for every connection in the space. **Unfiltered** — there is no name filter, so match names client-side.

## Mutate connections — `tosca_mobileconnection_edit`

**Upsert create** (omit `connectionId`):

| Arg | Notes |
|-----|-------|
| `name` | Required, e.g. `SauceLabs QA` |
| `connectionType` | Required — `Appium` \| `Tma` |
| `server` | Required. Appium: full server URL (`https://user:accessKey@ondemand.saucelabs.com/wd/hub`). Tma: TMA address (`http://localhost:4723`) |
| `serverIsSecret` | Required on Appium — `true` when the URL embeds credentials, `false` for a plain endpoint. Ignored for Tma (always plain text) |
| `capabilitySets` | Optional, **create only**. Omit or `[]` → connection with no sets |

**Upsert update** (with `connectionId`): omit/null field = no change. Pass `name` to rename, `server` to change the endpoint (`serverIsSecret` must come with `server` on an Appium connection). `connectionType` **cannot** be changed — delete and create instead. `capabilitySets` is rejected on update; add sets with `tosca_mobilecapabilityset_edit`.

Upsert returns `{ connection, capabilitySets, capabilitySetErrors }`.

**Delete** — `connectionId`; removes the connection **and its linked capability sets**. Cannot be undone; confirm first unless the user asked to delete.

## Capability sets — `tosca_mobilecapabilityset` / `_edit`

Capability sets are always addressed **through their connection**: every operation requires `connectionId`. There is no get-by-id without a connection and no space-wide list — use `tosca_mobileconnection` List to resolve `connectionId` first.

| Op | Args | Result |
|----|------|--------|
| `tosca_mobilecapabilityset` Get | `connectionId` + `capabilitySetId` | The set with its capabilities |
| `tosca_mobilecapabilityset` List | `connectionId` | Every set linked to that connection |
| `_edit` Upsert create | `connectionId` + `name` (+ `capabilities[]`, create only) | Set created and linked |
| `_edit` Upsert rename | + `capabilitySetId`, `name` (omit = no change) | Renamed set |
| `_edit` SetCapability | + `capabilitySetId`, `capability { name, valueType, value, secret }` | Set after the write; existing name is replaced |
| `_edit` DeleteCapability | + `capabilitySetId`, `capabilityName` | Set after the write |
| `_edit` Delete | + `capabilitySetId` | Set unlinked and deleted; connection untouched |

**One capability per call on an existing set.** Reads omit encoded (secret) values, so resubmitting a whole `capabilities[]` list would blank the secrets — use SetCapability instead.

`valueType`: `Text` | `Number` | `Boolean` | `Json`. `value` is always a string — `true`/`false` for Boolean, the numeric string for Number, valid JSON for Json.

## Configurator blob to capability sets

When the user pastes a capability blob from a provider's platform configurator:

1. **JSON capabilities are not sets.** Keys like `bstack:options`, `sauce:options`, `lt:options`, `appium:options` are capability **names** whose value is a nested object → one capability with `valueType=Json` and the object serialized as a JSON string. Never name a set after them.
2. **Group the flat capabilities by purpose**, naming each set after what it describes: a device set (`deviceName`, `platformName`, `platformVersion`, `appium:automationName`, `appium:udid`) named after the device; an app set (`appium:app`, `appium:bundleId`, `appium:appPackage`, `appium:appActivity`) named after the app; a session set (provider JSON capabilities plus leftovers) named `Session` or after the provider. A single set is fine for a small configurator.
3. **Always include `appium:automationName`** in the most fitting set (usually the device set) — `XCUITest` for iOS/iPadOS, `UIAutomator2` for Android. Infer the platform from the other capabilities; if it cannot be determined, use a placeholder and say so.
4. **Secrets:** follow the scoped exception in [safety-and-space.md](../tosca-cloud-basics/references/safety-and-space.md#secrets) — never ask for keys the user did not paste, never echo them back. `secret=true` for `accessKey`, `token`, `password`, `apiKey`, `key`, `secret`, `credentials`, `auth`, or a `userName` paired with a key (including a Json capability object holding them). `secret=false` for `deviceName`, `platformName`, `platformVersion`, app names/IDs, `osVersion`, `appiumVersion`, `browserName`, `appium:automationName`.
5. **Partial failure:** if some sets fail, the connection is still created and returned; `capabilitySetErrors` lists what failed. Retry those with `tosca_mobilecapabilityset_edit` Upsert.

## Hard rules

1. **List → Get before update or delete** — resolve `connectionId`, then inspect with Get.
2. Mobile connections are **space-scoped** — verify the tenant MCP session (`tosca_module` Search) before mutations.
3. **Confirm** Delete (connection or set) and DeleteCapability with the user; connection Delete also removes its sets.
4. `connectionType` is immutable — a type change means delete and re-create.
5. Never re-send `capabilities[]` for an existing set; SetCapability one at a time.

## Related

- [reference/workflows/mobile-connection.md](reference/workflows/mobile-connection.md)
- [tool-orchestration.md](tool-orchestration.md)
