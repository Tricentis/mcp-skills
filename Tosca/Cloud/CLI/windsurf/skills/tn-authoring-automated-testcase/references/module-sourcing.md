# Module sourcing — Tosca Cloud

## Discovery

1. `tosca_builder_getModulesSummary` — summarized module list
2. `tosca_inventory_search(artifactType: module, artifactName)` — find by name

## Rules

- **No UI scanning** — agents cannot scan applications to create new UI modules
- Present module candidates to user for selection
- Prefer reusing existing modules over creating new ones
- **Name collisions** — when multiple modules share a name, `tosca_builder_scaffoldTestCase` uses the first inventory match. Search with `tosca_inventory_search(artifactType: module)` and confirm with the user before scaffolding.
- **Steps at creation only** — provide all module-backed steps in `testSteps` when calling `tosca_builder_scaffoldTestCase`. There is no MCP tool to append a step to an existing test case.
