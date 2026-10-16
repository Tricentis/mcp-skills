# Simulation orchestration — deploy API simulations

Create and deploy API simulation files to simulator agents.

## Session checklist

```text
Simulation deploy session:
        - [ ] tosca_simulator List
- [ ] tosca_simulator_edit Upsert (YAML)
- [ ] tosca_simulator_edit Deploy
- [ ] verify agent state if needed
```

## Tool sequence

| Step | Tool | Notes |
|------|------|-------|
| 1 | `tosca_simulator` List | Pick target agent id and state. |
| 2 | `tosca_simulator_edit` Upsert | YAML simulation + `name` (`.yaml` / `.yml`). Name conflict returns the existing file. |
| 3 | `tosca_simulator_edit` Deploy | `simulatorId` + `simulationFileId` (guid from Upsert) |

## Rules

1. **Read agents first** — deployment requires a valid simulator agent id from List.
2. Simulation YAML must match product schema — validate with user before deploy.
3. No delete/update simulation-file tools in the current MCP surface — recreate or use the portal for lifecycle beyond deploy.

## Related

- [reference/workflows/deploy-simulation.md](reference/workflows/deploy-simulation.md)
