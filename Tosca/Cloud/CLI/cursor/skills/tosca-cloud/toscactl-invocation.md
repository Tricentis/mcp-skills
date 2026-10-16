# toscactl invocation patterns

IDE agents drive Tosca Cloud via **`toscactl`** in the workspace terminal. Always append **`--json --silent`** unless fetching plain-text logs or JUnit (`--silent` only).

**Prerequisite:** `toscactl` on PATH; run `toscactl login --url <tenant>.my.tricentis.com` and `toscactl workspaces set`. Verify with `python3 verify_toscactl.py`.

Full command reference: [toscactl-reference](../tosca-commands/toscactl-reference/SKILL.md) and [tosca-cli README](https://github.com/Tricentis-Tosca/tosca-cli#commands).

## Connect and workspace

```bash
toscactl login --url mytenant.my.tricentis.com
toscactl workspaces list --json --silent
toscactl workspaces set "My Workspace" --json --silent
toscactl config --json --silent
```

## Search

```bash
toscactl assets find --type testCase --name "Login" --json --silent
toscactl playlists find --name "Smoke" --results --json --silent
```

## Run and diagnose

```bash
toscactl playlists run start "Smoke Tests" --wait --json --silent
toscactl playlists history "Smoke Tests" --page-size 5 --json --silent
toscactl playlists run view <run_id> --json --silent
toscactl executions attachments --type test-steps --run <run_id> --test-case <builder_id> --json --silent
```

## JSON piping (chain without shell variables)

```bash
toscactl playlists history --page-size 1 --json --silent "My Playlist" \
  | jq '{"0": .[0].id}' \
  | toscactl playlists run view --json --silent
```

See [JSON Piping](https://github.com/Tricentis-Tosca/tosca-cli#json-piping).

## CI flags

- `--wait` — poll until terminal state
- `--assert-success` — non-zero exit if run did not succeed (requires `--wait`)
- `--report junit --report-path report.xml` — write JUnit after run
- `--workspace "Name"` — one-shot workspace override (not persisted)

## Agents and datasets

```bash
toscactl agents list --json --silent
toscactl datasets list --json --silent
```

Vendored skills: `tosca-agents`, `tosca-datasets`, `tosca-import-dataset`, `tosca-export-dataset`.

## When to use tn instead

For CLI gaps (Builder read/write, DI, mobile, loop/robot), see [runtime-routing.md](runtime-routing.md) and [tn-invocation.md](tn-invocation.md).
