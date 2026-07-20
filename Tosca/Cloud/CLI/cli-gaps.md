# toscactl CLI gaps — tn interim

Track gaps between **toscactl** (default runtime) and full journey coverage. **Interim:** skills use **tn** (`/tosca` MCP, `tn --loop`, `tn --robot`) for every row below until tosca-cli ships the suggested command surface.

**Exit criteria:** When a gap closes in [tosca-cli](https://github.com/Tricentis-Tosca/tosca-cli), migrate that skill step from tn → toscactl and remove the tn fallback for that step.

| Priority | Gap | In tn? | Interim (skills) | Blocks skill(s) | Suggested CLI surface | Issue |
|----------|-----|--------|------------------|-----------------|----------------------|-------|
| P0 | Test case / Builder read | Partial — inventory + getModulesSummary / getApiMessage | **tn** — piped `/tosca` for step tree; toscactl for `assets find` metadata | `tosca-explaining-testcase` | `toscactl builder view <id>` | TBD |
| P0 | Builder scaffold / edit | Yes — scaffoldTestCase, module summary, step/API edit MCP | **tn** — `tn --loop` | `tosca-authoring-automated-testcase`, `tosca-remediating-from-results` | `builder scaffold`, step edit | TBD |
| P0 | Manual test case creation | Yes — Builder/inventory MCP via `tn --loop` | **tn** — keep authoring invocation | `tosca-authoring-manual-testcase` | `assets create` or builder command | TBD |
| P1 | Playlist item rename / analyze | Yes — analyzeTestCaseItems, applyTestCaseItemRenames | **tn** — REPL/loop; toscactl for verify re-run | `tosca-remediating-from-results` | `playlists items analyze/rename` | TBD |
| P1 | Folder / artifact inventory mutations | Yes — inventory MCP create/rename/delete | **tn** — manage-folder workflow | Engineering workflows | `assets create/delete`, `folders *` | TBD |
| P1 | API message CRUD | Yes — tosca_builder_*ApiMessage* | **tn** — remediation + manage-api-message | Remediation + engineering | `builder api-messages *` | TBD |
| P2 | Data Integrity | Yes — full tosca_dataintegrity_* | **tn** — di-orchestration; toscactl `datasets *` for TDM-only | Engineering DI workflows | `di *` command group | TBD |
| P2 | Mobile connections | Yes — tosca_mobile_* | **tn** — mobile workflow | Engineering mobile | `mobile connections *` | TBD |
| P2 | API execution connections | Yes — apiexecution MCP | **tn** — apiexecution workflow | Engineering apiexecution | `api-execution connections *` | TBD |
| P2 | Simulation deploy | Yes — simulation MCP | **tn** — simulation workflow | Engineering simulation | `simulation deploy` | TBD |
| P3 | Single-asset detail view | Partial — search metadata only | **tn** for Builder depth; toscactl `assets find` for discovery | Explain, inspect-space | `assets view <id>` | TBD |
| P3 | Tag management | Partial — search/filter by tag | toscactl `assets find --tag`; **tn** if tag CRUD needed | Search/filter | `assets tags *` | TBD |

## tn-only orchestration (not MCP gaps)

| Capability | In tn? | Interim (skills) | toscactl status |
|------------|--------|------------------|-----------------|
| `tn --loop` | Yes | **tn** — author/remediate/DI batch | No equivalent |
| `tn --robot` | Yes | **tn** — robot-monitoring workflow | No equivalent |
| Multi-provider AI (`tn --setup`) | Yes | **tn** — required for gap workflows | N/A |

## Already on toscactl (no tn fallback)

Connect, search, run, diagnose, history, agents, datasets, CI flags (`--assert-success`, `--report junit`), `toscactl ui`.

See [runtime-routing.md](../packages/core/skills/tosca-cloud/runtime-routing.md) in the engineering skill.
