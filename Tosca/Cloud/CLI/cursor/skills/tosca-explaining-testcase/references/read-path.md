# Explaining test case read path — Tosca Cloud

How to read test case structure when no dedicated Builder read tool exists.

## Current MCP surface

| Available | Tool |
|-----------|------|
| Resolve by name | `tosca_inventory_search(artifactType: testCase)` |
| Module catalog | `tosca_builder_getModulesSummary` |
| API message bodies | `tosca_builder_getApiMessage` (when test uses API messages) |
| **Not available** | `tosca_builder_getTestCaseDetail` — planned cloud MCP outcome tool |

## Interim read path

1. **Search** — `tosca_inventory_search` returns entityId, name, tags, folder path, and metadata fields returned by inventory API.
2. **Infer steps from modules** — if the user names modules or tags on the test case, cross-reference `tosca_builder_getModulesSummary` and inventory search for `artifactType: module`.
3. **API-heavy tests** — search for linked `apiMessage` artifacts; read definitions with `tosca_builder_getApiMessage`.
4. **Gaps** — if step-level detail is not in inventory metadata, state clearly: "Step detail requires Builder UI or a future `getTestCaseDetail` MCP tool."

## Confidence guidance

- Inventory metadata only → confidence 4–6 for step-level claims
- Modules + API messages resolved → confidence 7–8 for flow summary
- User-provided context + inventory → adjust accordingly

## Future MCP tool

`tosca_builder_getTestCaseDetail` will replace the interim chain when published on the hosted Tosca Cloud MCP server.
