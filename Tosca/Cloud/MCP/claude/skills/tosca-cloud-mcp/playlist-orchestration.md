# Playlist orchestration — definition, schedule, batch runs

Playlists group test cases for batch / unattended runs (Tosca Cloud “Run your tests”). Use noun tools only.

**TCP / folders bible:** [reference/playlist-structure.md](reference/playlist-structure.md) — full hierarchy, `tcpScope`, FolderUpsert/Delete/Move.

Copy and track progress:

```text
Playlist workflow:
- [ ] tosca_playlist Search / Get (find definition; inspect tcp[] / paths)
- [ ] tosca_playlist_edit FolderUpsert (if folders needed) / Upsert tcp / SetTestCases / SetSchedule
- [ ] tosca_playlistrun_edit Create → capture playlistRunId
- [ ] tosca_playlistrun Get until Succeeded / Failed / Canceled
- [ ] Inspect failedSteps / attachments / testStepsUri when Failed
```

## Tools

| Tool | Ops | Hints |
|------|-----|-------|
| `tosca_playlist` | Get, Search | ReadOnly |
| `tosca_playlist_edit` | Upsert, Delete, SetTestCases, SetSchedule, FolderUpsert, FolderDelete, FolderMove | Destructive |
| `tosca_playlistrun` | Get, Search | ReadOnly |
| `tosca_playlistrun_edit` | Create, Cancel, Delete | Destructive |

## Find / read playlist — `tosca_playlist`

**Get** — requires `playlistId`. Full definition + portal `url` + **`tcp[]`** at root and on each folder/test-case item (merged inheritance with `inheritedFrom` / `overwritten`). Items include **`path`** (for `tcpScope` / Folder* ops). Password/secret values are redacted — never ask for secrets.

**Search** — curated summaries (**no** `url` on hits):

| Arg | Notes |
|-----|--------|
| `name?` | Contains on name |
| `description?` | Contains on description |
| `updatedAfter` / `updatedBefore`, `createdAfter` / `createdBefore` | Date filters |
| `sortField` / `sortDescending` | Default **updatedAt desc** |
| `pageToken` / `pageSize` | Pagination |

Exact-name resolution: Search then client-side exact match; ambiguous → use `playlistId`.

## Mutate playlist — `tosca_playlist_edit`

**Upsert create** (no `playlistId`): `name` required. Optional `description`, `testCaseIds[]`, `runMode` (Parallel \| Sequential \| SequentialOnSameAgent), `runOnlyOnCloudAgents`, `agentCharacteristics[]`, `tcp[]`, `parameterSetIds` (root only on create).

**Upsert update** (with `playlistId`): curated metadata, agent targeting, and/or **`tcp[]` + `tcpScope` + `parameterSetIds`**. Omit/null = no change; `tcp=[]` / `parameterSetIds=[]` clears that scope’s locals.

**Agent targeting:**

- `runOnlyOnCloudAgents: true` pins runs to Tricentis-hosted cloud agents; `false` clears that.
- `agentCharacteristics: [{ name, value }]` — pairs a team agent must report to be eligible (the agent's characteristics must be a superset). Omit = keep, `[]` = clear. The reserved `Agent-type=Cloud-agent` entry is managed only through `runOnlyOnCloudAgents`.

**tcpScope:** `""`/omit = playlist root; `"Checkout/Pay"` = folder; `"Checkout/{sourceId}"` = test-case-in-playlist. Details: [playlist-structure.md](reference/playlist-structure.md).

**FolderUpsert** — create (`parentPath` + `folderName`) or update (`folderPath` + name/runMode/disabled).

**FolderDelete** — `folderPath`; non-empty requires `recursive: true`.

**FolderMove** — `folderPath` + `toParentPath` + `toIndex`.

**SetTestCases** — `playlistId` + `testCaseIdsToAdd` / `testCaseIdsToRemove` / `addToFolderPath`. Folder must **already exist** (FolderUpsert first). Empty add+remove → no-op.

**SetSchedule** — `playlistId` + `cronExpression` (UTC). **null/empty clears** schedule.

**Delete** — confirm with user first.

**TCP / secrets** — same as testcase: non-empty Password values denied; empty Password shell OK (omit value — set secret in portal UI). Values may be `{CP[OtherName]}` strings.

## Start / cancel / delete runs — `tosca_playlistrun_edit`

**Create**

- Requires `playlistId`.
- `runOnAPersonalAgent` default **false** → team/cloud agents.
- Optional `testCaseIds[]` = **playlist item ids** for a partial run (omit = whole playlist).
- Success: `playlistRunId` + portal `url` (`…/runs/{id}`) + poll hint.
- Personal + no connected agent: returns `needsAgent` + `agentLink` — **no** `playlistRunId`. Open the link yourself, wait for registration, Create again.

**Cancel** — soft cancel OK when user asked to stop; `hardCancel` requires confirmation. Then poll Get until Canceled.

**Delete** — permanently delete run; confirm first.

## Read results — `tosca_playlistrun`

**Get** — exactly one of: `playlistRunId` | `playlistId` (latest) | `playlistName` (exact → latest). Ambiguous name → error; use id. Two selectors → error.

**Long-running:** poll Get with the same `playlistRunId` until Succeeded / Failed / Canceled. Do not stop or ask the user while Pending / Running / Canceling.

**Terminal payload**

- `playlistRun` + portal `url`
- `playlistTestCaseRuns[]` — **not** `tosca_testrun` ids
- When Failed: inline `failedStepsByTestCaseRunId`
- Failed/Succeeded: `testStepsUriByTestCaseRunId` (URI only — never inline full step trees)
- `attachments[]` / `logsUrl` when available (same idea as results-page tabs)

Optional: share portal `url` (`…/runs/{id}` results page) with the user instead of dumping download URLs. When diagnosing or fixing a failing test, fetch the relevant `attachments[]` / `logsUrl` / `testStepsUri*`.

**Search** — `playlistName?`, `state?`; newest-first; paginated summaries (**no** url).

## Hard rules

1. `playlistTestCaseRuns[].id` ≠ `tosca_testrun` ids — never cross-wire.
2. Never ask for or pass password/secret values through MCP.
3. Confirm before Delete / hardCancel.
4. Create playlist folders with FolderUpsert before `addToFolderPath`.
