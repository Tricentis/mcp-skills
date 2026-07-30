# Runtime routing — toscactl vs tn

**Default:** use **`toscactl`**. Use **`tn`** only for workflows marked **`[tn]`** in journey skills or listed as tn-only in the decision table below.

## Decision table

| User intent | Runtime | Skill / doc |
|-------------|---------|---------------|
| Connect tenant | **toscactl** | `tosca-cloud-connect`, `tosca-setup` |
| Search assets / playlists | **toscactl** | `tosca-find`, `tosca-cloud-basics` |
| Run playlist, view history, diagnose latest run | **toscactl** | `tosca-run`, `tosca-status`, `tosca-execution`, analyze journey skills |
| Execution history / trends | **toscactl** | `tosca-analyzing-execution-history` |
| Agents, TDM datasets, CI run flags | **toscactl** | `tosca-agents`, `tosca-datasets` |
| Explain test case (step tree) | **toscactl** metadata → **tn** Builder read | `tosca-explaining-testcase` |
| Author manual / automated test case | **toscactl** module search → **tn** scaffold | author journey skills |
| Remediate (mutations) | **tn**; verify re-run **toscactl** | `tosca-remediating-from-results` |
| DI, mobile, simulation, API execution | **tn** | `di-orchestration.md`, mobile, simulation workflows |
| Autonomous multi-step / robot | **tn** | `tn-invocation.md`, loop/robot workflows |

## Prerequisites by runtime

| Runtime | Setup |
|---------|--------|
| **toscactl** | `toscactl login`; `python3 verify_toscactl.py` |
| **tn** (gaps) | `configure_tn_connection.py`; `tn --setup`; `echo "/tosca then list workspaces" \| tn` |

## Per-step tagging in journey skills

Journey skills mark steps with **`[toscactl]`** or **`[tn]`**. Follow the tag — do not substitute runtimes.

## Exit criteria

When **toscactl** supports a workflow previously routed to **tn**, update the skill step to `[toscactl]` only and remove the tn fallback for that step.
