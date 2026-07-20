# Tosca Cloud object model

## Artifact types

| Type | `artifactType` value | Purpose |
|------|----------------------|---------|
| Folder | `folder` | Organizational container |
| Test case | `testCase` | Executable test definition |
| Module | `module` | Reusable automation building block |
| Shared action | `sharedAction` | Reusable step sequence |
| API message | `apiMessage` | API test message definition |
| Playlist | `playlist` | Collection of tests to run |

## Execution model

- **Playlist** — named collection of test case items
- **Run** — single execution of a playlist; has state (Passed, Failed, Running, …)
- **Failed test steps** — step-level detail attached to failed runs; retrieved via `tosca_playlist_getFailedTestSteps`

## Search fields

`tosca_inventory_search` supports: `artifactType`, `artifactName`, `createdFrom`/`createdTo`, `updatedFrom`/`updatedTo`, `createdBy`, `updatedBy`, `folderEntityId`, `tags`.

## Builder

`tosca_builder_scaffoldTestCase` creates test case skeletons. `tosca_builder_getModulesSummary` lists modules for automated authoring.
