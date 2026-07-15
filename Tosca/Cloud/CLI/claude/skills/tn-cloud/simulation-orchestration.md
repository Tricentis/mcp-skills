# Simulation orchestration — deploy API simulations

Create and deploy API simulation files to simulator agents.

## Session checklist

```text
Simulation deploy session:
- [ ] tosca_simulation_listAgents
- [ ] tosca_simulation_create (YAML)
- [ ] tosca_simulation_deploy
- [ ] verify agent state if needed
```

## Tool sequence

| Step | Tool | Notes |
|------|------|-------|
| 1 | `tosca_simulation_listAgents` | Pick target agent id and state |
| 2 | `tosca_simulation_create` | YAML simulation definition |
| 3 | `tosca_simulation_deploy` | Deploy to selected agent |

## Rules

1. **Read agents first** — deployment requires a valid simulator agent id.
2. Simulation YAML must match product schema — validate with user before deploy.
3. No delete/update simulation tools in current MCP surface — recreate or use portal for lifecycle beyond deploy.

## Related

- [reference/workflows/deploy-simulation.md](reference/workflows/deploy-simulation.md)
