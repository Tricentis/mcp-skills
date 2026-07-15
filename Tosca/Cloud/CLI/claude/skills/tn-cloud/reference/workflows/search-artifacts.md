# Search artifacts

Find test cases, modules, playlists, or folders by criteria.

```text
Search artifacts:
- [ ] tosca_inventory_search with artifactType
- [ ] narrow with artifactName, tags, dates, folderEntityId
- [ ] capture EntityId for follow-up steps
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_inventory_search` | `artifactType`, `artifactName` | Candidate list |
| 2 | `tosca_inventory_search` | add `folderEntityId` or `tags` | Refined list |

Valid types: `*`, `folder`, `testCase`, `module`, `sharedAction`, `apiMessage`, `playlist`.
