# Create or update test cases

Code Mode sequence for `create_test_cases`.

```text
Create test case:
- [ ] get_workspace_info
- [ ] get_object_info — verify parent folder
- [ ] Checkout parent if multi-user and tasks missing
- [ ] create_test_cases
- [ ] get_object_info — verify creation
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `get_workspace_info` | — | Confirm workspace ready |
| 2 | `get_object_info` | folder node path | Verify parent folder exists |
| 3 | `create_test_cases` | `test_cases=[{path, name, test_steps?, linked_requirements?}]` | Test cases created or updated |
| 4 | `get_object_info` | resulting case paths or ids | Verify saved state |

## Args notes

- `path`: first segment must be an existing top-level folder (e.g. `TestCases/MyArea`); intermediate folders are created.
- `test_steps`: optional array of step definitions per tool schema.
- `linked_requirements`: optional requirement links.
- `id`: omit to create; pass an existing writable test-case id to update in place. Updates fully replace steps and linked requirements, so do not use this tool to append one step.

## Checkout

If creation fails due to checkout, insert before step 3:

```
list_available_tasks(objectIds=[parent folder id])
execute_task("Checkout", objectIds=[parent folder id])
```

`create_test_cases` saves/checks in successful changes — do not call `save_workspace` unless the plan continues with more edits.
