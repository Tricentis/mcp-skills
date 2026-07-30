# TCShell Task Names

> **Hand-authored** — maintained against TCShell task registrations in supported Commander releases.

Tasks are run with `task "Task Name"`. The interpreter matches case-insensitively with spaces stripped.

## Name resolution

```
NormalizedKey = FullTaskName.ToLower().Replace(" ", "")
FullTaskName  = Category.Name + " " + task.Name   (when Category.UseForFullTaskName == true)
FullTaskName  = task.Name                          (when Category.UseForFullTaskName == false, e.g. TaskCategory.Default)
```

Consequence: `task "Check Out"` and `task "Checkout"` resolve to the same task — spaces in the argument don't matter.

## Task names

### Create tasks (category prefix = "Create")

All create tasks create the object with a **default name** and jump to it — none prompt for input. Set the name immediately after with `set Name "..."`.

| FullTaskName | TCShell example | Applies to |
|---|---|---|
| `Create Folder` | `task "Create Folder"` | Any TCFolder (TestCases, Modules, ExecutionLists, TestStepFolder) |
| `Create TestCase` | `task "Create TestCase"` | TCFolder under TestCases |
| `Create Manual XTestStep` | `task "Create Manual XTestStep"` | TestCase, TestStepFolder |
| `Create ExecutionList` | `task "Create ExecutionList"` | ExecutionListFolder |
| `Create XModule` | `task "Create XModule"` | TCFolder under Modules |
| `Create TemplateInstance` | `task "Create TemplateInstance"` | Template TestCase |

**Standard create pattern:**
```
task "Create TestCase"
set Name "MyTestCaseName"
```

### Lifecycle tasks (no category prefix — TaskCategory.Default)

| FullTaskName | TCShell example | Applies to | Notes |
|---|---|---|---|
| `Delete` | `task "Delete"` | Any persistable object | — |
| `Copy` | `task "Copy"` | Any | — |
| `Paste` | `task "Paste"` | Any | — |
| `Rename` | `task "Rename"` | Any | Prompts for new name |
| `Disable` | `task "Disable"` | TestCaseItem, ExecutionListItem | — |
| `Enable` | `task "Enable"` | TestCaseItem, ExecutionListItem | — |
| `Compare` | `task "Compare"` | Any | — |
| `Reinstantiate Instance` | `task "Reinstantiate Instance"` | TemplateInstance | No prompt |

### Team workspace tasks (versioned workspaces only)

| FullTaskName | Aliases | Applies to |
|---|---|---|
| `Checkout` | `Check Out` | OwnedItem |
| `Checkin` | `Check In` | OwnedItem |
| `Checkout Tree` | `Check Out Tree` | OwnedItem folder |
| `Checkin Tree` | `Check In Tree` | OwnedItem folder |
| `Checkin all` | — | Project |
| `Revert CheckOut` | — | OwnedItem |
| `Update` | — | OwnedItem |
| `Update all` | — | Project |

### Execution tasks

| FullTaskName | TCShell example | Applies to | Notes |
|---|---|---|---|
| `Run` | `task "Run"` | ExecutionList, ExecutionEntry | No prompt |
| `Create Execution Report` | `task "Create Execution Report"` | ExecutionList | Prompts yes/no for detail level |

### Backup and restore tasks

| FullTaskName | TCShell example | Applies to | Notes |
|---|---|---|---|
| `Backup Project` | `task "Backup Project"` | Project root | Prompts for output directory |
| `Restore Project` | `task "Restore Project"` | Project root | Prompts for .tcb file path |
| `Import Subset` | `task "Import Subset"` | TCFolder / Project | Prompts for .tce file path |
| `Export Subset` | `task "Export Subset"` | TCFolder | Prompts for output path |

### Manual testing tasks (AddIn)

| FullTaskName | TCShell example | Notes |
|---|---|---|
| `Import Manual TestCases` | `task "Import Manual TestCases"` | Prompts for file paths; end list with `<EOL>` |
| `Import Manual CheckList Result` | `task "Import Manual CheckList Result"` | Prompts for file paths; end list with `<EOL>` |
| `Export Manual CheckList` | `task "Export Manual CheckList"` | Prompts for export folder path |

## Task input patterns

**Create tasks** — no prompt. Use `set Name` on the newly-created current object:
```
task "Create TestCase"
set Name "MyTestCaseName"
```

**Import tasks** — prompt for file paths; end the list with `<EOL>`:
```
task "Import Manual TestCases"
"C:\path\file1.doc"
"C:\path\file2.doc"
<EOL>
```

**Backup/Restore** — prompt for a single path on the next line:
```
task "Backup Project"
"C:\backups\output"
```

## Discovering tasks on an object

In interactive TCShell mode, navigate to an object and run `task` with no argument to see available tasks:

```
JumpToNode "/TestCases/MyTestCase"
task
```

Output lists all tasks valid for the current object. Via Remote Control, call `GetInfos` after sending the `task` command to read the list.

## Notes on built-in TCShell commands vs tasks

Some operations have both a built-in TCShell command **and** a task form:

| Built-in command | Task equivalent |
|---|---|
| `checkInAll` | `task "Checkin all"` |
| `save` | — (no task; call directly) |
| `print` | — (inspection only) |

Prefer built-in commands when available — they bypass the task dispatch overhead.
