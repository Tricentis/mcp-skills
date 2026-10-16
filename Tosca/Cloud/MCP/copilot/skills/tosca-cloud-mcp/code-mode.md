# Code Mode — programmatic MCP orchestration

**Code Mode** means the agent **writes code** that calls Tosca Cloud MCP tools as functions, instead of chaining one direct tool call per chat turn.

Copy and track progress:

```text
Code Mode workflow:
- [ ] 0. Read orchestration guides for intent
- [ ] 1. Restate goal in Cloud terms (ids, run ids)
- [ ] 2. Write orchestration script (full sequence)
- [ ] 3. Review with user if destructive or wide-reaching
- [ ] 4. Execute in code sandbox; handle errors in code
- [ ] 5. Return summaries only — not full JSON dumps
```

**MCP tool names:** `tosca-cloud:tosca_asset` when multiple MCP servers are connected; bare names otherwise.

## Why Code Mode

Cloud workflows are multi-step (module Get → testcase Upsert → trial run poll; playlist Create → playlistrun poll). Code Mode:

- Determines the **entire tool sequence upfront**
- Keeps **intermediate results** (ids) in the execution environment
- Uses **loops** for pagination and run status polling
- Handles **needsAgent** retry without asking the user

## Pattern — create Wait test case and trial-run

```typescript
const modules = JSON.parse(await mcp.call("tosca_module", {
  operation: "Search",
  name: "TBox Wait",
  scope: "StandardObjects",
}));
const waitId = modules[0].id;
const mod = JSON.parse(await mcp.call("tosca_module", {
  operation: "Get",
  moduleId: waitId,
}));
// Use attribute paths from mod — do not invent them.

const created = JSON.parse(await mcp.call("tosca_testcase_edit", {
  operation: "Upsert",
  name: "MCP-VAL/Wait-1000",
  steps: [{ moduleId: waitId, values: [{ path: "Duration", value: "1000" }] }],
}));
const testCaseId = created.id;

let run = JSON.parse(await mcp.call("tosca_testrun_edit", {
  operation: "Create",
  testCaseId,
}));
if (run.agentLink && !run.testRunId) {
  // Open agentLink; wait for registration; Create again.
  run = JSON.parse(await mcp.call("tosca_testrun_edit", {
    operation: "Create",
    testCaseId,
  }));
}
const testRunId = run.testRunId;
for (;;) {
  const status = JSON.parse(await mcp.call("tosca_testrun", {
    operation: "Get",
    testRunId,
  }));
  if (["succeeded", "failed", "canceled"].includes(String(status.state).toLowerCase())) {
    console.log(status.state, status.portalUrl);
    break;
  }
  await sleep(2000);
}
```

## Pattern — playlist run and inspect failures

```typescript
const playlists = JSON.parse(await mcp.call("tosca_playlist", {
  operation: "Search",
  name: "Smoke",
}));
const playlistId = playlists.items[0].id;

const started = JSON.parse(await mcp.call("tosca_playlistrun_edit", {
  operation: "Create",
  playlistId,
  runOnAPersonalAgent: false,
}));
if (started.needsAgent) {
  // Open started.agentLink; retry Create.
}
const playlistRunId = started.playlistRunId;

for (;;) {
  const result = JSON.parse(await mcp.call("tosca_playlistrun", {
    operation: "Get",
    playlistRunId,
  }));
  const state = result.playlistRun?.state ?? result.state;
  if (["Succeeded", "Failed", "Canceled"].includes(state)) {
    console.log(state, result.url, result.failedStepsByTestCaseRunId);
    break;
  }
  await sleep(3000);
}
```

## Pattern — DI async companions

Keep existing DI `check*Result` polling loops from [di-orchestration.md](di-orchestration.md).

## Rules in Code Mode

1. Parse JSON string returns.
2. Never hard-code module attribute paths — Get the module.
3. Treat `playlistTestCaseRuns[].id` as distinct from `tosca_testrun` ids.
4. Summarize for the user; do not dump megabyte step trees (use URIs from playlistrun Get).
