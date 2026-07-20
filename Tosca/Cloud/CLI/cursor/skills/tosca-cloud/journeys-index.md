# User journeys — intent router

Map user intent to the minimum doc chain. Load **one** workflow, journey skill, or orchestration doc per turn.

Default runtime: **toscactl**. Gap runtime: **tn** — see [runtime-routing.md](runtime-routing.md).

## Session start

| Step | Document | Why |
|------|----------|-----|
| 1 | [path-selection.md](path-selection.md) | Detect toscactl + tn |
| 2 | [runtime-routing.md](runtime-routing.md) | Pick runtime |
| 3 | [toscactl-invocation.md](toscactl-invocation.md) or [tn-invocation.md](tn-invocation.md) | Invocation pattern |

## Journey skills

| User says | Journey skill | Runtime |
|-----------|---------------|---------|
| Connect / setup / auth fix | `tosca-cloud-connect` | toscactl (+ tn for gaps) |
| Object model / building blocks | `tosca-cloud-basics` | toscactl (+ tn docs for gaps) |
| Why did latest run fail? | `tosca-analyzing-execution-results` | toscactl |
| Trends / flakiness | `tosca-analyzing-execution-history` | toscactl |
| Apply a fix | `tosca-remediating-from-results` | hybrid |
| Manual test → Cloud TC | `tosca-authoring-manual-testcase` | tn |
| Automated TC from modules | `tosca-authoring-automated-testcase` | hybrid |
| Explain test case | `tosca-explaining-testcase` | hybrid |

## Engineering workflows

| User says | Workflow | Runtime |
|-----------|----------|---------|
| Search / inspect / run | search-artifacts, inspect-space, run-playlist | toscactl |
| Analyze failures | analyze-run-failures | toscactl |
| Create playlist | create-playlist | toscactl |
| Folders / scaffold / DI / mobile | manage-folder, scaffold-test-case, di-*, mobile-* | tn |
| Autonomous / monitor | loop-autonomous, robot-monitoring | tn |

## Verify before reporting success

1. Correct runtime used per [runtime-routing.md](runtime-routing.md)
2. toscactl commands used `--json --silent` (unless logs/junit)
3. tn gap commands had `/tosca` context
4. Re-read artifact or run state matches reported outcome
