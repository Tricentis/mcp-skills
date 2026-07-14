# Create test case

Code Mode sequence for `create_test_case`.

```text
Create test case:
- [ ] get_workspace_info
- [ ] get_object_info — verify parent folder
- [ ] Checkout parent if multi-user and tasks missing
- [ ] create_test_case
- [ ] get_object_info — verify creation
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `get_workspace_info` | — | Confirm workspace ready |
| 2 | `get_object_info` | folder node path | Verify parent folder exists |
| 3 | `create_test_case` | `folderPath`, `name`, optional `steps`, `requirements` | New test case created |
| 4 | `get_object_info` | new case path | Verify creation |

## Args notes

- `folderPath`: first segment must be an existing top-level folder (e.g. `TestCases/MyArea`); intermediate folders are created.
- `steps`: optional array of step definitions per tool schema.
- `requirements`: optional requirement links.

## Checkout

If creation fails due to checkout, insert before step 3:

```
list_available_tasks(objectIds=[parent folder id])
execute_task(Checkout, objectIds=[parent folder id])
```

`create_test_case` saves/checks in on success — do not call `save_workspace` unless the plan continues with more edits.
