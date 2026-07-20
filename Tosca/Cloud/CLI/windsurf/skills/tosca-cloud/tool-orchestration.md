# Tool orchestration — when and how to call each MCP tool

Use with [tn-invocation.md](tn-invocation.md) or [tn-invocation.md](tn-invocation.md). Wire names follow `tosca_{domain}_{action}`.

**Progressive disclosure:** load domain orchestration companions for detail — do not read the full catalog at session start.

Catalog (parameters): [reference/tools-catalog.md](reference/tools-catalog.md) — open only for tools in your plan.

## Contents

- [Mandatory orchestration loop](#mandatory-orchestration-loop)
- [By intent](#by-intent--which-tools-to-orchestrate)
- [Pagination and search](#pagination-and-search)
- [By domain summary](#by-domain-summary)
- [Error recovery](#error-recovery)
- [Anti-patterns](#anti-patterns)

## Mandatory orchestration loop

```
READINESS  →  PLAN  →  DISCOVER  →  ACT  →  VERIFY
```

| Phase | Tools | Rule |
|-------|-------|------|
| **Readiness** | `tosca_organization_listWorkspaces` | Once per session or after token refresh |
| **Plan** | *(no tools)* | tn loop or REPL table before mutations |
| **Discover** | `tosca_inventory_search`, `tosca_inventory_advancedSearch`, `tosca_playlist_searchByName` | Before every write |
| **Act** | Domain mutate tools | One plan row at a time |
| **Verify** | Re-search or run-status reads | When user needs confirmation |

Cloud mutations persist immediately — no `save_workspace` / check-in step.

---

## By intent — which tools to orchestrate

### Read-only: understand space

**When:** User asks what exists, audit inventory, list playlists.

```
tosca_organization_listWorkspaces
tosca_inventory_search(artifactType, artifactName, folderEntityId, tags)
tosca_inventory_advancedSearch          # complex filters only
tosca_playlist_searchByName             # playlists by name
```

**Do not** mutate. tn loop or REPL optional for simple reads.

---

### Navigate and resolve identity

**When:** Later steps need `entityId`.

| Tool | When | How |
|------|------|-----|
| `tosca_inventory_search` | User names artifact or folder | Capture `EntityId` from results |
| `tosca_inventory_advancedSearch` | Multi-criteria or pagination | Prefer when simple search insufficient |
| `tosca_playlist_searchByName` | Playlist by name fragment | Returns playlist id |
| `tosca_execution_getPlaylistIdsByName` | Id-only resolution | Read-only; max 50 matches |

**Rule:** Resolve IDs **once**, reuse in subsequent plan rows. Prefer names in conversation; pass `entityId` in tools.

**Name collisions:** multiple artifacts may share a name — disambiguate with folder, type, or ask the user.

---

### Inventory mutations

**Full orchestration:** [inventory-orchestration.md](inventory-orchestration.md)

```
tosca_inventory_search → entityId
tosca_inventory_createFolder | modifyFolder | move | deleteFolder
tosca_inventory_search → verify
```

`deleteFolder`: call without `ChildBehavior` first to learn allowed behaviors, then call again with user-confirmed behavior.

---

### Playlist and execution

**Full orchestration:** [playlist-orchestration.md](playlist-orchestration.md), [execution-orchestration.md](execution-orchestration.md)

```
tosca_playlist_searchByName
tosca_playlist_run → runId
tosca_playlist_getRecentRuns → poll until terminal state
tosca_playlist_getFailedTestSteps(runIds)   # Failed runs only
```

**Cheap signal first:** run state before expensive failure step attachments.

---

### Builder / test cases

**Full orchestration:** [builder-orchestration.md](builder-orchestration.md)

```
tosca_builder_getModulesSummary
tosca_inventory_search(artifactType: module)   # disambiguate moduleName
tosca_builder_scaffoldTestCase(name, testSteps?)
tosca_inventory_move → target folder
```

**Gap:** no append-step tool — include all `testSteps` at scaffold time or use Builder UI.

---

### Data Integrity

**Gate:** [di-orchestration.md](di-orchestration.md) + **one** `reference/di/workflows/*.md`

```
tosca_dataintegrity_workflow          # mandatory first
tosca_dataintegrity_listConnections
async: getConnectionSchema → checkSchemaResult
tosca_dataintegrity_createRowByRowComparison | createDiDbExpertTestcase
```

Connections are **UI-managed** — MCP lists/gets/deletes only.

---

### Mobile / API execution / simulation

| Domain | Orchestration doc |
|--------|-------------------|
| Mobile | [mobile-orchestration.md](mobile-orchestration.md) |
| API execution | [apiexecution-orchestration.md](apiexecution-orchestration.md) |
| Simulation | [simulation-orchestration.md](simulation-orchestration.md) |

List-before-mutate; confirm destructive deletes.

---

## Pagination and search

`tosca_inventory_advancedSearch` supports pagination and rich filters — use when `tosca_inventory_search` returns too many or too few results.

Loop with page tokens/offsets per tool schema until the target artifact is found or the user narrows criteria.

---

## By domain summary

| Domain | Primary tools | Destructive examples |
|--------|---------------|----------------------|
| organization | `listWorkspaces` | — |
| inventory | `search`, `advancedSearch`, `createFolder`, `move` | `deleteFolder` |
| playlist | `searchByName`, `run`, `getRecentRuns`, `getFailedTestSteps` | `deleteById` |
| execution | `getPlaylistIdsByName`, `getRecentRunLogs` | read-only |
| builder | `scaffoldTestCase`, `*ApiMessage` | `deleteApiMessage` |
| dataintegrity | `workflow`, `createRowByRowComparison` | `connection` delete |
| mobile | `listConnections`, `createConnection` | `deleteConnection` |
| apiexecution | `listConnections`, `createConnection` | `deleteConnection` |
| simulation | `listAgents`, `create`, `deploy` | — |

---

## Error recovery

| Error | Action |
|-------|--------|
| 401 Unauthorized | Re-auth — see `tosca-cloud-connect` |
| Entitlement missing | Report to user; do not retry |
| `McpException` | Parse message; replan with corrected entityIds |
| Empty search | Broaden criteria or ask user |
| Async DI job pending | Poll `check*Result` — do not skip |

---

## Anti-patterns

| Avoid | Why |
|-------|-----|
| Mutate without prior search | Entity IDs are opaque |
| Entity IDs vs paths | Cloud uses entity IDs from inventory search |
| Skip `tosca_dataintegrity_workflow` | DI tools expect workflow context |
| `getFailedTestSteps` on passed runs | Wasted call — no failed steps |
| Load full tools catalog at start | Use progressive disclosure |
| Parallel destructive deletes | Confirm each target |
