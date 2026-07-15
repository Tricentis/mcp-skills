# User journeys — intent router

Map user intent to the minimum doc chain. Load **one** workflow, journey skill, or orchestration doc per turn.

## Token budget

| Load | Max per session turn |
|------|----------------------|
| This file + one companion | 1 companion |
| One workflow template | 1 workflow |
| One journey skill SKILL.md | 1 journey |

## Session start (every automation)

| Step | Document | Why |
|------|----------|-----|
| 1 | [path-selection.md](path-selection.md) | Detect tn, config, best execution path |
| 2 | [tn-invocation.md](tn-invocation.md) | REPL / piped / loop / robot pattern |

## Journey skills (user stories)

| User says | Journey skill | TN pattern |
|-----------|---------------|------------|
| Connect / setup / 401 fix | `tn-cloud-connect` | `configure_tn_connection.py` + `tn --setup` |
| Object model / building blocks | `tn-cloud-basics` | `echo "..." \| tn` with `/tosca` |
| Why did latest run fail? | `tn-analyzing-execution-results` | piped or loop |
| Trends / flakiness over time | `tn-analyzing-execution-history` | loop (multi-query) |
| Apply a fix to test case | `tn-remediating-from-results` | REPL (approval) or loop |
| Written manual test → Cloud TC | `tn-authoring-manual-testcase` | loop |
| Description → automated TC | `tn-authoring-automated-testcase` | loop |
| Explain what a test case does | `tn-explaining-testcase` | piped |

## Engineering workflows (tool orchestration)

| User says | Read first | Workflow |
|-----------|------------|----------|
| What's in my space? | [inspect-space.md](reference/workflows/inspect-space.md) | piped |
| Search test cases / modules | [search-artifacts.md](reference/workflows/search-artifacts.md) | piped |
| Create / edit folders | [manage-folder.md](reference/workflows/manage-folder.md) | REPL or loop |
| Create playlist | [create-playlist.md](reference/workflows/create-playlist.md) | loop |
| Run playlist | [run-playlist.md](reference/workflows/run-playlist.md) | loop |
| Analyze failures (raw tools) | [analyze-run-failures.md](reference/workflows/analyze-run-failures.md) | piped |
| Rename playlist items | [rename-playlist-items.md](reference/workflows/rename-playlist-items.md) | REPL |
| Scaffold test case | [scaffold-test-case.md](reference/workflows/scaffold-test-case.md) | loop |
| Manage API messages | [manage-api-message.md](reference/workflows/manage-api-message.md) | loop |
| Data Integrity | [di-getting-started.md](reference/workflows/di-getting-started.md) | loop |
| DI DB Expert testcase | [di-db-expert-testcase.md](reference/workflows/di-db-expert-testcase.md) | loop |
| Mobile connection | [mobile-connection.md](reference/workflows/mobile-connection.md) | REPL |
| API execution connection | [api-execution-connection.md](reference/workflows/api-execution-connection.md) | REPL |
| Deploy simulation | [deploy-simulation.md](reference/workflows/deploy-simulation.md) | loop |
| Multi-step autonomous task | [loop-autonomous.md](reference/workflows/loop-autonomous.md) | `--loop` |
| Scheduled monitoring | [robot-monitoring.md](reference/workflows/robot-monitoring.md) | `--robot` |

## TN-only journeys (not in direct MCP pack)

| User says | Workflow | Why TN |
|-----------|----------|--------|
| "Run this end-to-end without my help" | loop-autonomous.md | `--loop` batches tool rounds |
| "Watch this playlist and alert me" | robot-monitoring.md | `--robot` yield/resume |
| "Write analysis to a file in repo" | loop-autonomous.md | tn `write_file` in loop |
| "Use our AI Hub provider" | path-selection.md | tn `appsettings.json` |

## Scope boundary

| Scenario | This skill |
|----------|------------|
| Hosted Tosca Cloud via tn | **Supported** — all MCP tool domains via `/tosca` |
| On-prem Commander | **Not supported** — use **Tosca.Commander.IDE.integration** |
| Direct IDE MCP (no tn) | **Not supported** — use **Tosca.Cloud.MCP.integration** |
| Data Integrity | **Supported** via tn `/tosca` MCP tools |

## Verify before reporting success

1. tn command exited 0 (or loop called `loop_complete`)
2. `/tosca` context was active
3. Re-read artifact or run state matches reported outcome
