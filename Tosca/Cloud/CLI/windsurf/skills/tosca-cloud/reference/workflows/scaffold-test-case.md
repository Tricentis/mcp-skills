# Scaffold test case

Create a test case skeleton in Builder with optional steps at creation time.

```text
Scaffold test case:
- [ ] tosca_builder_getModulesSummary (if using module references)
- [ ] tosca_inventory_search (resolve module names when ambiguous)
- [ ] tosca_builder_scaffoldTestCase (name, description, testSteps)
- [ ] tosca_inventory_search (verify)
- [ ] tosca_inventory_move (optional — place in target folder)
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_builder_getModulesSummary` | — | Module candidates (when steps reference modules) |
| 2 | `tosca_inventory_search` | `artifactType: module`, `artifactName` | Disambiguate when multiple modules share a name |
| 3 | `tosca_builder_scaffoldTestCase` | `name`, optional `description`, optional `testSteps` | Created test case ID |
| 4 | `tosca_inventory_search` | `artifactType: testCase`, name | Verify artifact exists |
| 5 | `tosca_inventory_move` | test case entityId + folder entityId | Artifact in target folder (optional) |

## Args notes

- `testSteps`: optional array of `{ name, moduleName? }` — each step summarizes the action; `moduleName` links an existing module when known.
- **Steps at creation only** — `tosca_builder_scaffoldTestCase` accepts `testSteps` at creation time. There is no MCP tool to append a step to an existing test case. To add steps later, use the Cloud Builder UI or scaffold a new test case with the full step list.
- **Module name collisions:** when multiple modules match `moduleName`, the tool uses the first inventory hit. Search with `tosca_inventory_search` first and confirm the correct module with the user before scaffolding.

For full authoring journeys, use `tosca-authoring-manual-testcase` or `tosca-authoring-automated-testcase`.
