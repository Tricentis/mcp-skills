# Module sourcing — automated test authoring

## Resolve modules

1. **`tosca_module` Search** — `name` substring; `scope` All \| StandardObjects \| UserAssets.
2. **`tosca_module` Get** — full definition + attribute paths (required before setting step values).
3. **`tosca_asset` Search (`artifactType: module`, …)** — when inventory filters (folder/tags) help narrow candidates.

## Before creating steps

- Confirm module choice with the user when Search returns multiple hits.
- If no module matches, offer `tosca_module_edit` **Scan** (or **Rescan**): open the returned launcher/portal link, wait for the user to finish the Cloud scanner, then `tosca_module` Search `scope=UserAssets` `sort=Latest` → Get. Report a gap only if Scan is declined or unsupported (e.g. Salesforce still needs manual Cloud UI via the portal URL).
- Optional: `tosca_module_edit` Upsert can create a **NonGui** empty shell (User assets only).

## After creating the test case

- **`tosca_teststep_edit` Upsert** — insert/update steps (`moduleId` + `values[]`) or folders.
- **`tosca_testcase` Get** / **`tosca_teststep` Get|List** — verify structure.

## Name collisions

When multiple modules share a name, present Search hits and let the user choose before Upsert.
