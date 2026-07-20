# Editability and persistence — Tosca Cloud

## Immediate persistence

All Builder and inventory mutations commit via Cloud API. There is no draft/checkout model.

## Editability

- Confirm artifact exists via search before update
- `tosca_builder_updateApiMessage` is flagged destructive — review payload
- Playlist renames use analyze-then-apply pattern for semantic naming

## Re-validation

After fixes, run the playlist and compare run state:

```
tosca_playlist_run → tosca_playlist_getRecentRuns → tosca_playlist_getFailedTestSteps (if failed)
```
