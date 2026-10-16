# When to use MCP — readiness and path selection

Before any Tosca Cloud automation via MCP: **confirm connectivity**, then enter **Code Mode** or **direct tool mode**. Do not call tools until readiness checks pass.

Copy and track progress:

```text
MCP readiness:
- [ ] Step 0 — Hosted MCP configured (tosca-cloud-connect if not yet connected)
- [ ] Step 1 — tosca_module Search succeeds
- [ ] Step 2 — Intent classified (read / author / trial / playlist / DI / journey)
- [ ] Step 3 — Mode picked (code-mode.md or direct-tool-mode.md)
- [ ] Step 4 — Plan drafted before first mutation
- [ ] Step 5 — Id + attribute-path rules applied
```

**Progressive disclosure:** read this file for routing; open companion docs only for the current intent.

## Step 1 — Verify MCP connectivity

Call once at the start of a session or after token refresh:

```
tosca_module Search
```

| Field / signal | Agent action |
|----------------|--------------|
| Search result returned | Proceed — tenant and space context are active |
| 401 / connection refused | Stop — re-auth via IDE MCP settings; see `tosca-cloud-connect` |
| Error | Confirm `spaceId` and tenant URL with user |

## Step 2 — Classify user intent

| Intent | Start with |
|--------|------------|
| "What's in my space?" / audit | `tosca_asset` Search / `tosca_playlist` Search |
| Find / create modules | [builder-orchestration.md](builder-orchestration.md) — `tosca_module` |
| Create / edit test case | [builder-orchestration.md](builder-orchestration.md) — `tosca_testcase_edit` |
| Trial run one test case | [execution-orchestration.md](execution-orchestration.md) — `tosca_testrun_edit` Create → `tosca_testrun` Get |
| Playlist / schedule / batch run | [playlist-orchestration.md](playlist-orchestration.md) |
| Edit folder / move artifact | [inventory-orchestration.md](inventory-orchestration.md) |
| API message management | [builder-orchestration.md](builder-orchestration.md) — `tosca_apimessage` Get / `_edit` |
| API simulation | [simulation-orchestration.md](simulation-orchestration.md) — `tosca_simulator` List / `_edit` Upsert / Deploy |
| Data Integrity | [di-orchestration.md](di-orchestration.md) |
| Mobile / API connection | Domain orchestration docs |
| Tester journey (diagnose, author) | Journey skill — see repo `AGENTS.md` |

## Step 3 — Pick execution mode

| IDE capability | Mode | Document |
|----------------|------|----------|
| Code execution / programmatic MCP | **Code Mode** | [code-mode.md](code-mode.md) |
| MCP tools only | **Direct tool mode** | [direct-tool-mode.md](direct-tool-mode.md) |

## Step 4 — Orchestrate

**Code Mode:** Implement the full sequence as code (loops for search pagination, run polling).

**Direct tool mode:** Draft a numbered plan table, then execute step-by-step.

## Step 5 — Rules

1. **Always plan multi-step work** before the first mutation tool.
2. **Resolve ids** via Search/Get before mutate.
3. **Get modules** before setting step `values[].path`.
4. **Poll** `tosca_testrun` / `tosca_playlistrun` Get until terminal.
5. **Personal agent:** open `agentLink` / `needsAgent` yourself; `tosca_testrun_edit` Create again.
6. **Never ask for or echo secrets** — see [safety-and-space.md](../tosca-cloud-basics/references/safety-and-space.md#secrets) for the scoped exception.
7. **DI gate** — read [di-orchestration.md](di-orchestration.md) before any `tosca_diconnection*` or `tosca_dataintegrity_*` tool.

## When to prompt the user

| Situation | Ask |
|-----------|-----|
| MCP not connected | Configure tenant URL, Okta token, and spaceId? |
| Multiple matching artifacts | Which test case / playlist / module? |
| Destructive Delete / hardCancel | Confirm before calling |
| Entitlement error | Report and stop |
| DI connection create needed | Optional: `tosca_diconnection_edit` — see di-orchestration + di-connection workflow. Secrets stay in Connection Manager. |

## Agent workflow (mandatory)

```
1. tosca_module Search  → MCP ready?
2. Classify intent
3. Draft Code Mode script OR plan
4. If ambiguous target → ask user
5. Execute plan step-by-step
6. Verify → Get / Search / poll run status
```

## Related

| Topic | Document |
|-------|----------|
| Code Mode template | [code-mode.md](code-mode.md) |
| Per-tool when/how | [tool-orchestration.md](tool-orchestration.md) |
| Authoring | [builder-orchestration.md](builder-orchestration.md) |
| Playlists | [playlist-orchestration.md](playlist-orchestration.md) |
| Trial / results | [execution-orchestration.md](execution-orchestration.md) |
| Journey skills | Repo root `AGENTS.md` |
