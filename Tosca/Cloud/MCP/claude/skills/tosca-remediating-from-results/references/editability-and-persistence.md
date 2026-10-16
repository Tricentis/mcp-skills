# Editability and persistence — Tosca Cloud

## Immediate persistence

All mutations commit via Cloud API. There is no draft/checkout model.

## Editability

- Confirm artifact exists via Search/Get before update
- `tosca_apimessage_edit` Upsert with `messageId` is full replacement — review payload and confirm
- Step renames/value fixes use `tosca_teststep_edit` Upsert
- Password/secret values cannot be set via MCP

## Re-validation

After fixes:

```
# Trial
tosca_testrun_edit Create → tosca_testrun Get until terminal

# Playlist
tosca_playlistrun_edit Create → tosca_playlistrun Get until terminal
```
