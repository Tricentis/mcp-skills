# Remediation recipes — Tosca Cloud

| Fix type | Tools |
|----------|-------|
| Rename playlist items | `tosca_playlist_analyzeTestCaseItems` → `tosca_playlist_applyTestCaseItemRenames` |
| Update API message | `tosca_builder_getApiMessage` → `tosca_builder_updateApiMessage` |
| Scaffold replacement TC | `tosca_builder_scaffoldTestCase` |
| Move artifact to folder | `tosca_inventory_move` |
| Re-run after fix | `tosca_playlist_run` → `tosca_playlist_getRecentRuns` |

Always search for current entityId before mutate.
