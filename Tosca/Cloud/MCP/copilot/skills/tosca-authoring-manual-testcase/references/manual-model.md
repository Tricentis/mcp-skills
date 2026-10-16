# Manual test model — Tosca Cloud

Manual specs map to a **test case container** (`name` + `description` + optional folder items) via:

- `tosca_testcase_edit` Upsert
- `tosca_teststep_edit` Upsert with `kind=testStepFolder` for sections

Executable automated steps still need modules (`tosca_module` Search/Get + step `moduleId` + `values`). Prefer `tosca-authoring-automated-testcase` when modules exist.
