# MCP tool planning guide

Use with [code-mode.md](code-mode.md), [tool-orchestration.md](tool-orchestration.md), and [reference/tools-catalog.md](reference/tools-catalog.md) — open the catalog only for tools in your plan.

## Planning checklist

```text
Plan checklist:
- [ ] Goal stated in Cloud terms (tenant, space, artifact, playlist, run)
- [ ] Readiness: tosca_module Search
- [ ] Discover before every mutation (Search/Get; module Get for paths)
- [ ] Async poll steps identified (testrun / playlistrun / DI)
- [ ] Personal-agent gate planned (agentLink / needsAgent)
- [ ] Destructive steps flagged for user confirmation
- [ ] Verify step at end
```

## Planning primitives

### Resolve identity

```
tosca_asset Search(artifactType, name, folderId?)
tosca_asset AdvancedSearch(...)       # searchTerm / sort / filters / includeAncestors; paginated
tosca_module Search / Get             # modules + attribute paths
tosca_playlist Search / Get           # playlists
tosca_testcase Get                    # TC structure
```

### Authoring chain

```
tosca_module Search → Get
tosca_testcase_edit Upsert(name, steps?)
tosca_teststep_edit Upsert|Move|Delete
tosca_testcase Get / tosca_teststep List|Get
```

### Trial run polling

```
tosca_testrun_edit Create(testCaseId)
  → testRunId | needsAgent + agentLink
tosca_testrun Get(testRunId) until terminal
# optional: tosca_testrun List(name?, state?, pageSize?, pageToken?)
```

### Playlist run polling

```
tosca_playlist_edit Upsert|SetTestCases|SetSchedule
tosca_playlistrun_edit Create(playlistId, runOnAPersonalAgent?)
  → playlistRunId | needsAgent
tosca_playlistrun Get(playlistRunId) until Succeeded|Failed|Canceled
```

### DI async chain

```
tosca_diconnection List / Get
tosca_dataintegrity_runSql → launcher / notification   # schema = dialect catalog SELECT
tosca_dataintegrity_checkSqlResult → poll until complete
tosca_dataintegrity_createRowByRowComparison
# optional: tosca_diconnection_edit; testConnection → checkTestConnectionResult
# optional run: tosca_testrun_edit Create → tosca_testrun Get — only if the user asked
```

## Output shape for plans

Numbered rows: tool + operation + required args + expected id/field captured for the next row.
