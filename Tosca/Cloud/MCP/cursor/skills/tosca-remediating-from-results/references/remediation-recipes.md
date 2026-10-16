# Remediation recipes — Tosca Cloud

| Fix type | Tools |
|----------|-------|
| Rename / edit step | `tosca_testcase` Get → `tosca_teststep_edit` Upsert (`name` / `values`) |
| Disable step | `tosca_teststep_edit` Upsert (`disabled: true`) |
| Add / remove steps | `tosca_teststep_edit` Upsert / Delete |
| Update TCPs / metadata | `tosca_testcase_edit` Upsert |
| Update API message | `tosca_apimessage` Get → `tosca_apimessage_edit` Upsert |
| Create replacement TC | `tosca_testcase_edit` Upsert (+ module Get for paths) |
| Move artifact to folder | `tosca_asset_folder_edit` Move |
| Re-run after fix (trial) | `tosca_testrun_edit` Create → `tosca_testrun` Get |
| Re-run after fix (playlist) | `tosca_playlistrun_edit` Create → `tosca_playlistrun` Get |

Always Search/Get for current ids before mutate. Never pass secrets through MCP.
