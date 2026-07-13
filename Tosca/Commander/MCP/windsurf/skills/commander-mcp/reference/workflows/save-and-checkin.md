# Save and check in

Persistence patterns after MCP mutations.

```text
Persist mutations:
- [ ] save_workspace — always after mutation group
- [ ] check_in_all — multi-user only, when publishing
```

## Single-user workspace

| Step | Tool | When |
|------|------|------|
| 1 | `save_workspace` | After any `set_attribute`, `execute_task`, `create_test_case`, etc. |

## Multi-user workspace

| Step | Tool | When |
|------|------|------|
| 1 | `get_workspace_info` | Confirm multi-user mode |
| 2 | `update_all` | Optional — pull latest before editing |
| 3 | *(mutations)* | Checkout → edit → ... |
| 4 | `save_workspace` | Persist local workspace state |
| 5 | `check_in_all` | Publish checked-out objects to common repository |

## Notes

- `check_in_all` equals Ctrl+Shift+I in Commander.
- `update_all` equals Ctrl+Shift+U — use before long edit sessions to reduce conflicts.
- In-memory writes from `set_attribute` are lost if Commander closes without save.
