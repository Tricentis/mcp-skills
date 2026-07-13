# Add a step to an existing test case

`create_test_case` only accepts `testSteps` at creation time. To append a step afterward, use `execute_drop_task` twice — this mirrors the two drags a user would do in the Commander UI (drag the module onto the test case, then drag an attribute onto the new step).

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `get_object_info` | test case id, module id | Resolve both surrogate/unique ids |
| 2 | `execute_drop_task` | `targetId=testCaseId`, `sourceIds=[moduleId]` | New step created from the module |
| 3 | `get_object_info` (`include_parent_and_children=true`, on test case) | test case id | Find the new step's id |
| 4 | `get_attributes` | module attribute candidates | If multiple candidates match, ask the user which attribute to use |
| 5 | `execute_drop_task` | `targetId=stepId`, `sourceIds=[attributeId]` | Attribute value added to the step |
| 6 | `set_attribute` | step-attribute value id, `attribute_name=Value`, `value` | Set the actual value |
| 7 | `save_workspace` | — | Persist |

## Notes

- Step 2 and step 5 are both drop tasks but with different target/source pairs — don't conflate them into one call.
- Repeat steps 4–6 per value you need on the step.
- If `execute_drop_task` fails because the parent isn't checked out, run plain `Checkout` on the owning object first (`list_available_tasks` → `execute_task`), then re-list and retry.
