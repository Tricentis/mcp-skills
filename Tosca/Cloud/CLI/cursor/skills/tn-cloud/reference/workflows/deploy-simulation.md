# Deploy simulation

Create and deploy an API simulation to a simulator agent.

```text
Deploy simulation:
- [ ] tosca_simulation_listAgents
- [ ] tosca_simulation_create
- [ ] tosca_simulation_deploy
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_simulation_listAgents` | — | Agent ids and states |
| 2 | `tosca_simulation_create` | YAML simulation | Simulation artifact |
| 3 | `tosca_simulation_deploy` | agent id, simulation | Deployed |

Confirm target agent with user when multiple agents are available.
