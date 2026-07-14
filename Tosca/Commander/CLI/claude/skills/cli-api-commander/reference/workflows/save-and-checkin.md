# Save and check in

Persistence patterns after TCShell or TCAPI mutations.

```text
Persist mutations:
- [ ] save — always before batch exit
- [ ] checkinall — multi-user when publishing to common repo
```

## Single-user workspace

| Step | Command | When |
|------|---------|------|
| 1 | `save` | After any `task`, `set`, import, or delete |

Batch mode **closes without saving** if `save` is omitted.

## Multi-user workspace

| Step | Command | When |
|------|---------|------|
| 1 | `task "Update all"` | Optional — pull latest before long edit session |
| 2 | *(mutations)* | `Checkout` → edit → ... |
| 3 | `save` | Persist local workspace state |
| 4 | `checkinall` | Publish all checked-out objects (`task "Checkin all"` also works) |

## TCShell examples

```
# After edits in multi-user workspace
save
checkinall
```

```
# Checkout tree before bulk import (from interpreter samples)
checkouttree
# ... import / modify ...
checkinall
```

## TCAPI equivalent

`CheckIn`, `CheckInAll` on `TCObject` / `TCWorkspace` after mutations.

## Notes

- `checkinall` equals Ctrl+Shift+I in Commander.
- `updateall` equals Ctrl+Shift+U — reduces merge conflicts in team workspaces.
- See `workspace-checkout.md` (skill root) for lock and checkout rules.
