# Tool orchestration — when and how to call each MCP tool

Use with [code-mode.md](code-mode.md) or [direct-tool-mode.md](direct-tool-mode.md).

**Progressive disclosure:** load domain orchestration companions for detail — do not read the full catalog at session start.

Catalog (parameters): [reference/tools-catalog.md](reference/tools-catalog.md) — open only for tools in your plan.

## Mandatory orchestration loop

```
READINESS  →  PLAN  →  DISCOVER  →  ACT  →  VERIFY
```

| Phase | Tools | Rule |
|-------|-------|------|
| **Readiness** | `tosca_module` Search | Once per session or after token refresh (bounded; not a full inventory dump) |
| **Plan** | *(no tools)* | Code Mode table before mutations |
| **Discover** | `tosca_asset` Search, `tosca_module` Search, `tosca_playlist` Search | Before every write; Get modules for attribute paths |
| **Act** | `*_edit` / Create ops | One plan row at a time |
| **Verify** | Get / Search / poll run Get | When user needs confirmation |

Cloud mutations persist immediately — no save / check-in step.

---

## By intent

### Read-only: understand space

```
tosca_asset Search / AdvancedSearch
tosca_playlist Search
tosca_module Search
```

### Navigate and resolve identity

| Need | Tool |
|------|------|
| Artifact / folder id | `tosca_asset` Search / AdvancedSearch |
| Module id + attribute paths | `tosca_module` Search → Get |
| Playlist id | `tosca_playlist` Search → Get |
| Test case structure | `tosca_testcase` Get; items via `tosca_teststep` List/Get |

**Rule:** Resolve IDs once, reuse. Prefer names in conversation; pass ids in tools. Disambiguate collisions with the user.

### Inventory mutations

[inventory-orchestration.md](inventory-orchestration.md)

```
tosca_asset Search → id
tosca_asset_folder Get (omit folderId = root)
tosca_asset_folder_edit Upsert | Delete | Move
```

### Authoring (modules / test cases / steps)

[builder-orchestration.md](builder-orchestration.md)

```
tosca_module Search/Get
tosca_testcase_edit Upsert
tosca_teststep_edit Upsert|Move|Delete
tosca_testcase Get / tosca_teststep Get|List
```

### Trial run (personal agent)

[execution-orchestration.md](execution-orchestration.md)

```
tosca_testrun_edit Create → (agentLink?) → Create again → tosca_testrun Get until terminal
```

### Playlist + batch run

[playlist-orchestration.md](playlist-orchestration.md)

```
tosca_playlist_edit Upsert|SetTestCases|SetSchedule
tosca_playlistrun_edit Create → tosca_playlistrun Get (poll)
```

### Data Integrity / Mobile / API / Simulation

| Domain | Doc |
|--------|-----|
| DI | [di-orchestration.md](di-orchestration.md) |
| Mobile | [mobile-orchestration.md](mobile-orchestration.md) |
| API connection | [apiexecution-orchestration.md](apiexecution-orchestration.md) |
| API message | [builder-orchestration.md](builder-orchestration.md) |
| Simulation | [simulation-orchestration.md](simulation-orchestration.md) |

---

## Pagination and search

`tosca_asset` Search / AdvancedSearch, playlist/playlistrun Search, and `tosca_testrun` List support `pageToken` / `pageSize`. Loop until the target is found or the user narrows criteria.

---

## By entity summary

| Entity | Read tool | Edit / run tool |
|--------|-----------|-----------------|
| module | `tosca_module` Get/Search | `tosca_module_edit` Upsert/Delete |
| testcase | `tosca_testcase` Get | `tosca_testcase_edit` Upsert/Delete |
| teststep | `tosca_teststep` Get/List | `tosca_teststep_edit` Upsert/Delete/Move |
| testrun | `tosca_testrun` Get/List | `tosca_testrun_edit` Create/Delete |
| testsheet | `tosca_testsheet` List/Get/ListInstances | `tosca_testsheet_edit` Upsert/Delete/Attribute*/Instance*/ClassReference*/ConvertToClass/*ChildInstance/GenerateRows/Row* |
| playlist | `tosca_playlist` Get/Search | `tosca_playlist_edit` |
| playlistrun | `tosca_playlistrun` Get/Search | `tosca_playlistrun_edit` |
| diconnection | `tosca_diconnection` List/Get | `tosca_diconnection_edit` Create/Update/Delete |
| apiconnection | `tosca_apiconnection` Get/List | `tosca_apiconnection_edit` Create/Update/Delete |
| apimessage | `tosca_apimessage` Get | `tosca_apimessage_edit` Upsert/Delete |
| simulator | `tosca_simulator` List | `tosca_simulator_edit` Upsert/Deploy |
| mobileconnection | `tosca_mobileconnection` Get/List | `tosca_mobileconnection_edit` Upsert/Delete |
| asset | `tosca_asset` Search/AdvancedSearch | — |
| asset folder | `tosca_asset_folder` Get | `tosca_asset_folder_edit` Upsert/Delete/Move |

---

## Error recovery

| Error | Action |
|-------|--------|
| 401 Unauthorized | Re-auth — see `tosca-cloud-connect` |
| Entitlement missing | Report; do not retry |
| `McpException` / validation | Parse message; replan with corrected ids |
| Empty search | Broaden criteria or ask user |
| `needsAgent` / `agentLink` | Open link; wait; Create again |
| Async DI pending | Poll `check*Result` |

---

## Anti-patterns

| Avoid | Why |
|-------|-----|
| Mutate without Get/Search | Ids and attribute paths are opaque |
| Invent module attribute paths | Always Get the module first |
| Cross-wire testrun ↔ playlistTestCaseRun ids | Different run systems |
| Ask for or echo secrets / pass Password TCP values | Denied; use portal url. Scoped exception: [safety-and-space.md](../tosca-cloud-basics/references/safety-and-space.md#secrets) |
| Stop polling while Running | Keep Get until terminal |
| Load full tools catalog at start | Progressive disclosure |
| Parallel destructive deletes | Confirm each target |
