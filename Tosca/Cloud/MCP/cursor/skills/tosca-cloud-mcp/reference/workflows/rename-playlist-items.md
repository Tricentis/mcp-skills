# Rename test steps

Rename steps (or folders) on a test case. Playlist item rename verbs are not used — edit the test case items directly.

```text
Rename test steps:
- [ ] Resolve testCaseId
- [ ] tosca_testcase Get or tosca_teststep List
- [ ] User confirms rename map
- [ ] tosca_teststep_edit Upsert (name)
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_asset` Search | `artifactType: testCase` | `testCaseId` |
| 2 | `tosca_testcase` Get | `testCaseId` | items[] with ids + names |
| 3 | *(user)* | Review proposed renames | Confirmed map |
| 4 | `tosca_teststep_edit` Upsert | `testStepContainerId`, `itemId`, `name` (`testStepContainerType` defaults to `testCase`) | Renamed |

Journey handoff: `tosca-remediating-from-results` when fixing names after failed runs.
