# Manual test model — Tosca Cloud

Manual test cases in Cloud Builder contain human-readable step descriptions rather than XModule references.

## Scaffolding

`tosca_builder_scaffoldTestCase` accepts test case metadata and step definitions per API schema.

## Folder placement

Always resolve parent folder `entityId` via inventory search before scaffold.
