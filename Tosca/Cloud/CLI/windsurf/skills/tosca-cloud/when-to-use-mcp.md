# When to use MCP — readiness and path selection

Before any Tosca Cloud automation via MCP: **confirm connectivity**, then enter **tn loop or REPL** or **direct tool mode**. Do not call tools until readiness checks pass.

Copy and track progress:

```text
MCP readiness:
- [ ] Step 0 — tn configured (`tosca-cloud-connect` if not yet connected)
- [ ] Step 1 — tosca_organization_listWorkspaces succeeds
- [ ] Step 2 — Intent classified (read / mutate / playlist / builder / DI / journey)
- [ ] Step 3 — Mode picked (tn-invocation.md or tn-invocation.md)
- [ ] Step 4 — Plan drafted before first mutation
- [ ] Step 5 — Entity ID rules applied (search before mutate)
```

**Progressive disclosure:** read this file for routing; open companion docs only for the current intent.

## Step 1 — Verify MCP connectivity

Call once at the start of a session or after token refresh:

```
tosca_organization_listWorkspaces
```

| Field / signal | Agent action |
|----------------|--------------|
| Workspace list returned | Proceed — tenant context is active |
| 401 / connection refused | Stop — re-auth via `tn`; see `tosca-cloud-connect` |
| Empty workspace list | Confirm `spaceId` and tenant URL with user |

## Step 2 — Classify user intent

| Intent | Tool domain | tn loop or REPL? | Start with |
|--------|-------------|------------|------------|
| "What's in my space?" / audit | Inventory | Optional | `tosca_inventory_search` |
| Find test case / module | Inventory | Yes | `tosca_inventory_search` or `tosca_inventory_advancedSearch` |
| Edit folder / move artifact | Inventory | Yes | Search → `tosca_inventory_*` |
| Run playlist / check results | Playlist + Execution | Yes | `tosca_playlist_searchByName` → run → poll |
| Create / edit test case | Builder | Yes | `tosca_builder_scaffoldTestCase` |
| API message management | Builder | Yes | `tosca_builder_*ApiMessage` |
| Data Integrity comparisons | DataIntegrity | **Required** | [di-orchestration.md](di-orchestration.md) |
| Mobile connections | Mobile | Yes | `tosca_mobile_listConnections` |
| API execution connections | ApiExecution | Yes | `tosca_apiexecution_listConnections` |
| API simulation deploy | Simulation | Yes | `tosca_simulation_*` |
| Tester journey (diagnose, author) | Journey skill | Varies | See repo `AGENTS.md` |

## Step 3 — Pick execution mode

| IDE capability | Mode | Document |
|----------------|------|----------|
| Code execution / programmatic MCP | **tn loop or REPL** | [tn-invocation.md](tn-invocation.md) |
| MCP tools only | **Direct tool mode** | [tn-invocation.md](tn-invocation.md) |

## Step 4 — Orchestrate

**tn loop or REPL:** Implement the full sequence as code (loops for search pagination, run polling).

**Direct tool mode:** Draft a numbered plan table, then execute step-by-step.

## Step 5 — Entity ID rules

1. **Always plan multi-step work** before the first mutation tool.
2. **Search before mutate** — resolve `entityId` via `tosca_inventory_search` or `tosca_inventory_advancedSearch`.
3. **Pass explicit entity IDs** — Cloud artifacts use entity IDs from inventory search.
4. **Poll async operations** — DI schema/test-connection and playlist runs may need follow-up check tools.
5. **Respect entitlements** — some tools are gated; handle entitlement errors gracefully.
6. **DI gate** — read [di-orchestration.md](di-orchestration.md) before any `tosca_dataintegrity_*` tool.

## When to prompt the user

| Situation | Ask |
|-----------|-----|
| MCP not connected | Configure tenant URL, Okta token, and spaceId? |
| Multiple matching artifacts | Which test case / playlist by name? |
| Destructive tool (`Destructive=true`) | Confirm delete before `tosca_*_delete*` |
| Entitlement error | User may need product license — report and stop |
| DI connection create needed | Direct user to Cloud UI — MCP cannot create connections |

## Agent workflow (mandatory)

```
1. tosca_organization_listWorkspaces  → MCP ready?
2. Classify intent                    → read / mutate / playlist / builder / DI / journey
3. Draft tn loop or REPL script OR plan      → tn-invocation.md / tn-invocation.md
4. If ambiguous target                → ask user
5. Execute plan step-by-step
6. Verify                             → re-search or re-read run status
```

## Related

| Topic | Document |
|-------|----------|
| tn loop or REPL template | [tn-invocation.md](tn-invocation.md) |
| Per-tool when/how | [tool-orchestration.md](tool-orchestration.md) |
| Space and tenant context | [space-orchestration.md](space-orchestration.md) |
| Playlist runs | [playlist-orchestration.md](playlist-orchestration.md) |
| Execution logs | [execution-orchestration.md](execution-orchestration.md) |
| DI sequencing | [di-orchestration.md](di-orchestration.md) |
| Mobile / API execution / simulation | mobile / apiexecution / simulation orchestration docs |
| Journey skills | Repo root `AGENTS.md` |
