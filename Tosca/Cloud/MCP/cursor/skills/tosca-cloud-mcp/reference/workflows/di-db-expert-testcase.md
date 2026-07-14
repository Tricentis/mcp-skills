# DI DB Expert test case

Create a Data Integrity DB Expert test case with a prefilled connection.

```text
DI DB Expert:
- [ ] tosca_dataintegrity_workflow
- [ ] tosca_dataintegrity_listConnections
- [ ] tosca_dataintegrity_createDiDbExpertTestcase
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_dataintegrity_workflow` | — | Read full DI guide |
| 2 | `tosca_dataintegrity_listConnections` | — | Connection id/name |
| 3 | `tosca_dataintegrity_createDiDbExpertTestcase` | per tool schema | Test case id/path |

Connections are created in the **Cloud UI** — MCP cannot create DI connections.

See also [01-row-by-row-comparison.md](../di/workflows/01-row-by-row-comparison.md).
