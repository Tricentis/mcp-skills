# toscactl building blocks

Always use `--json --silent` on every command unless noted.

## Discovery

```bash
toscactl workspaces list --json --silent
toscactl assets find --type testCase --name "Login" --json --silent
toscactl assets find --type module --tag smoke --json --silent
toscactl playlists find --name "Smoke" --results --json --silent
```

Asset types: `testCase`, `module`, `sharedAction`, `playlist`, `apiAction`, `apiMessage`, `folder`, `testCaseTemplate`.

## Execution

```bash
toscactl playlists run start "<playlist>" --wait --json --silent
toscactl playlists history "<playlist>" --page-size 5 --json --silent
toscactl playlists run view <run_id> --json --silent
toscactl executions attachments --type test-steps --run <run_id> --test-case <builder_id> --json --silent
toscactl executions attachments --type logs --run <run_id> --test-case <builder_id> --silent
```

## Agents and datasets

```bash
toscactl agents list --json --silent
toscactl datasets list --json --silent
```

See vendored skills `tosca-agents`, `tosca-datasets`.

## Builder / DI / mobile (gap — use tn)

Not available in toscactl today. See [mcp-building-blocks.md](mcp-building-blocks.md) and [runtime-routing.md](../../tosca-cloud/runtime-routing.md).

Command details: vendored **`toscactl-reference`** skill in this pack.
