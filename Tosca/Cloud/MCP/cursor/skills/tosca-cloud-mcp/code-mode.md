# Code Mode — programmatic MCP orchestration

**Code Mode** means the agent **writes code** that calls Tosca Cloud MCP tools as functions, instead of chaining one direct tool call per chat turn.

Copy and track progress:

```text
Code Mode workflow:
- [ ] 0. Read orchestration guides for intent
- [ ] 1. Restate goal in Cloud terms (entityId, playlistId, runId)
- [ ] 2. Write orchestration script (full sequence)
- [ ] 3. Review with user if destructive or wide-reaching
- [ ] 4. Execute in code sandbox; handle errors in code
- [ ] 5. Return summaries only — not full JSON dumps
```

**MCP tool names:** `tosca-cloud:tosca_inventory_search` when multiple MCP servers are connected; bare names otherwise.

## Why Code Mode for Tosca Cloud MCP

Cloud workflows are multi-step (search → mutate → run playlist → poll failures; DI async schema checks). Code Mode:

- Determines the **entire tool sequence upfront** in one script
- Keeps **intermediate results** (entity IDs, run IDs) in the execution environment
- Uses **loops** for search pagination and run status polling
- Uses **conditionals** for entitlement and destructive-tool branches

## Pattern — search and inspect artifact

```typescript
const workspaces = await mcp.call("tosca_organization_listWorkspaces", {});
if (!workspaces.length) throw new Error("No workspaces — check tenant token");

const results = await mcp.call("tosca_inventory_search", {
  artifactType: "testCase",
  artifactName: "Login Test",
});
const matches = JSON.parse(results);
if (!matches.length) throw new Error("Test case not found");
console.log("Found:", matches[0].EntityId, matches[0].Name);
```

## Pattern — run playlist and get failures

```typescript
const playlists = await mcp.call("tosca_playlist_searchByName", { name: "Smoke" });
const [{ id: playlistId }] = JSON.parse(playlists);

const { runId } = await mcp.call("tosca_playlist_run", { playlistId });
const recent = await mcp.call("tosca_playlist_getRecentRuns", { playlistId, limit: 1 });
const runs = JSON.parse(recent);

const failures = await mcp.call("tosca_playlist_getFailedTestSteps", {
  runIds: [runId],
});
console.log(JSON.parse(failures));
```

## Pattern — DI async schema check

```typescript
await mcp.call("tosca_dataintegrity_workflow", {});
const job = await mcp.call("tosca_dataintegrity_getConnectionSchema", { connectionId });
for (;;) {
  const status = await mcp.call("tosca_dataintegrity_checkSchemaResult", { jobId: job.id });
  if (status.complete) break;
}
```

Adapt `mcp.call(...)` to your IDE's programmatic tool API.

## Related

- [direct-tool-mode.md](direct-tool-mode.md) — fallback for IDEs without code execution
- [tool-orchestration.md](tool-orchestration.md) — when/how per tool
- [reference/workflows-index.md](reference/workflows-index.md) — scenario templates
