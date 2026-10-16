# Deploy simulation

Create and deploy an API simulation to a simulator agent.

```text
Deploy simulation:
- [ ] tosca_simulator List
- [ ] tosca_simulator_edit Upsert
- [ ] tosca_simulator_edit Deploy
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_simulator` List | — | Agent ids and states |
| 2 | `tosca_simulator_edit` Upsert | `simulation` (YAML), `name` | Simulation file (id on name conflict too) |
| 3 | `tosca_simulator_edit` Deploy | `simulatorId`, `simulationFileId` | Deployed |

Confirm target agent with user when multiple agents are available.
