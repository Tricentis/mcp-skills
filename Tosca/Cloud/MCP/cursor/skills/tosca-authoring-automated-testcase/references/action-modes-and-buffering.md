# Action modes and buffering

When setting step `values[].actionMode` or module `defaultActionMode`:

| Mode | Purpose |
|------|---------|
| Input | Set value to send to application |
| Verify | Assert expected value |
| WaitOn | Wait for condition |
| Buffer | Store value for later steps |
| Select | Select (e.g. list/table) |
| Constraint | Constrain search/selection |
| Insert / Delete / Modify | Structural / table ops |
| Exclude | Exclude from consideration |
| Output | Legacy — avoid for new work |

Also valid data types on module attrs / TCP: String, Date, Numeric, Boolean, Password, Secret, RawString.

Apply via `tosca_teststep_edit` / `tosca_testcase_edit` / `tosca_module_edit`. Match conventions from existing modules (`tosca_module` Get). Full module attribute catalog: `tosca-cloud-mcp` → `reference/module-attribute-values.md`.
