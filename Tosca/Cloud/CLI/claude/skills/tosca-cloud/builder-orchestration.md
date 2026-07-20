# Builder orchestration — test cases and API messages

Builder tools create and edit test artifacts in Tosca Cloud.

## Test case scaffolding

```
1. tosca_builder_getModulesSummary (when steps need modules)
2. tosca_inventory_search (module) — disambiguate name collisions
3. tosca_builder_scaffoldTestCase(name, description, testSteps?)
4. tosca_inventory_search (testCase, name) → verify created
5. tosca_inventory_move → place in target folder (optional)
```

`tosca_builder_scaffoldTestCase` accepts `testSteps` **only at creation**. There is no append-step MCP tool — agents cannot add steps to an existing test case via MCP today. Include all steps at scaffold time or use Builder UI.

## Module reuse

`tosca_builder_getModulesSummary` — read-only list of available modules before authoring automated steps.

When `moduleName` is provided in a test step scaffold, the tool resolves by exact name against inventory. If multiple modules share the name, the first match wins — search first and confirm with the user when ambiguous.

## API messages

| Tool | When | Destructive |
|------|------|-------------|
| `tosca_builder_createApiMessage` | New message | No |
| `tosca_builder_getApiMessage` | Read existing | Read-only |
| `tosca_builder_updateApiMessage` | Edit message | Flagged destructive |
| `tosca_builder_deleteApiMessage` | Remove message | **Yes** |

Hand off to `tosca-authoring-automated-testcase` for full authoring journeys.

## Related

- [reference/workflows/scaffold-test-case.md](reference/workflows/scaffold-test-case.md)
