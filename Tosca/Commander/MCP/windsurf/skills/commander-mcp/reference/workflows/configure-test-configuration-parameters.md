# Configure Test Configuration Parameters

Read and replace local Test Configuration Parameters (TCPs) without UI selection or context-menu tasks.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `get_object_info` | target path or id | Resolve target id |
| 2 | `list_test_configuration_parameters` | `identifiers=[targetId]`, `includeInherited=true` | Local and inherited parameters with source/read-only metadata |
| 3 | (plan) | Build complete desired **local** parameter set | Preserve wanted local values; inherited values are read-only here |
| 4 | `create_test_configuration_parameters` | `targets=[{id: targetId, parameters: [...]}]` | Local set replaced and persisted |

## Replacement semantics

- `parameters` is the complete desired local set: omitted local names are removed, existing names are updated, and new names are created.
- List first whenever existing local parameters must survive.
- Never copy inherited parameters into the local set unless the user explicitly wants an override.
- Existing read-only, Password, or Secret local parameters cannot be modified or removed; leave them untouched.
- Never use `execute_task` for Create Test Configuration Parameter.
- The write tool saves successful single-user changes and checks in successful multi-user changes.
