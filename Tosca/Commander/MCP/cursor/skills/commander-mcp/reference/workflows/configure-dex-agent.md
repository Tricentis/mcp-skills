# Refresh DEX agents

Read which Distribution Agents the Distribution Server currently reports, using the Configurations root in a multi-user workspace.

Installing an agent, connecting it to the server, and unattended RDP are outside MCP. Do not invent installer, port, credential, or RDP steps. Tell the user that work happens on the agent machine.

```text
Refresh DEX agents:
- [ ] get_workspace_info — mode must be "multi"
- [ ] list_assets — TestConfigurationsRoot
- [ ] list_available_tasks — exact refresh task name
- [ ] execute_task — that name only
- [ ] get_object_info — agents and configuration links
- [ ] Do not save — refresh does not persist agents
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `get_workspace_info` | — | `mode` is `"multi"`. `"single"` cannot refresh agents; stop and say so |
| 2 | `list_assets` | `assetType` `TestConfigurationsRoot` | One Configurations root (Execution section). Its displayed name is Configurations |
| 3 | `list_available_tasks` | that id | **Gate.** Use the refresh task's exact name from this list. English UI label is `Refresh Agents`. Do not call `Update configurations from Server` — that updates configuration definitions, not connected agents |
| 4 | `execute_task` | name from step 3, that id | Pulls current agents from the Distribution Server into memory |
| 5 | `get_object_info` | Configurations id, `include_parent_and_children=true` | Direct children include `TestConfiguration` objects and transient `Agent` objects (name and type) |
| 6 | `get_attributes` | each `TestConfiguration` id | `NumberOfAgents` is the count of agents that matched that configuration |
| 7 | `get_object_info` | one `TestConfiguration` id, `include_parent_and_children=true` | Direct children include transient `AgentLink` objects for agents that matched it |
| 8 | `get_attributes` | `AgentLink` ids | Characteristic values the server returned, stored as properties. `State` is not a Tosca attribute — do not invent Idle / Executing / Failure / Pause from `get_attributes` |

## Outside MCP

No MCP tool installs `ToscaDistributionAgent.exe`, writes the Connect to server tab, reads Project settings, or checks RDP. If the user asks for those, say they are outside Commander MCP and stop. Do not guess ports, tokens, client secrets, or Windows passwords.

`execute_test_suite` on a `TestEvent` only enqueues a distributed run. It does not configure or refresh agents. Per-entry results from that call are the last known logs, not the remote run.

## Error handling

| Symptom | Cause | Action |
|---------|-------|--------|
| `mode` is `"single"` or the refresh task is absent | Refresh Agents exists only on `TestConfigurationsRoot` in a multi-user workspace. Checkout does not reveal it | Stop. Do not check out and do not call a name that was not in `list_available_tasks` |
| Task returns an error or a message box about the server | Distribution Server URL, certificate, or authentication | Report the task message. Do not invent a server address |
| No `Agent` children after a successful refresh | No agents are connected to the server | Say the refresh returned none. Do not debug the agent process from MCP |
| `NumberOfAgents` is 0 on a configuration the user expected | Agent characteristics did not match that configuration's parameters | Compare `AgentLink` parents and `get_attributes` properties with the user. There is no lookup from an agent to `TestEvent`s |

## Notes

- Agents and agent links are transient. The refresh restores the changed-flag and does not write them to the repository. Do not call `save_workspace` or `check_in_all` for this workflow.
- Task names are localized. The name passed to `execute_task` must match `list_available_tasks` exactly.
