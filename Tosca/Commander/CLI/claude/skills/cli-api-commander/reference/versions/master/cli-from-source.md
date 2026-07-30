# TCShell CLI flags (from source)

> Commander version context: **master**
> Generated from supported Commander TCShell CLI releases.
> Generated at: 2026-06-25T21:10:13Z

Use this file for flags **missing from** `TCShell_Readme.txt` (see `commands.md`).
Always confirm the customer's Commander version before using version-specific flags.

## Universal flags (24.1, 24.2, 25.1, 26.1, master)

These flags are handled by the TCShell CLI for every supported release:

| Flag | Purpose |
|------|---------|
| `-auth` | PAT or `clientId:clientSecret` authentication |
| `-branchName` | Open workspace at branch (24.1–25.1; see version note below) |
| `-codepage` | Console input/output code page |
| `-firstadmin` | First admin user when creating new common repository |
| `-healthCheck` | Run health check with optional unload threshold |
| `-healthCheckQuick` | Quick health check variant |
| `-login` | Interactive or inline username/password auth |
| `-loglevel` | Set log level |
| `-newworkspace` | Create new workspace (see usage sections below) |
| `-perf` | Collect performance data |
| `-record` | Record TCShell session to script file |
| `-restoredbbackup` | Restore from database backup definition file |
| `-revision` | Open workspace at specific revision |
| `-slimWS` | Create slim workspace variant |
| `-subset` | Workspace template subset path |
| `-waitforcompacting` | Wait for background workspace compacting to finish |
| `-workspace` | Open existing workspace `.tws` (mandatory for open mode) |

### Documented in source but not in `TCShell_Readme.txt`

Agents should prefer this table over the readme for these flags:

- `-auth` — PAT or `clientId:clientSecret` authentication
- `-branchName` — Open workspace at branch (24.1–25.1; see version note below)
- `-firstadmin` — First admin user when creating new common repository
- `-healthCheck` — Run health check with optional unload threshold
- `-healthCheckQuick` — Quick health check variant
- `-loglevel` — Set log level
- `-perf` — Collect performance data
- `-restoredbbackup` — Restore from database backup definition file
- `-revision` — Open workspace at specific revision
- `-slimWS` — Create slim workspace variant
- `-subset` — Workspace template subset path

## Version-specific flags

| Flag | Supported versions | Notes |
|------|-------------------|-------|
| `-snapshotName` | 26.1, master | Replaces `-branchName` in ShowUsage for 26.1+ when snapshots feature is enabled |

## Branch vs snapshot (version-dependent)

- **This version (master)**: ShowUsage emphasizes **snapshot** naming in workspace-creation help.
- **24.1 – 25.1**: `-branchName` appears in `-newworkspace` usage text.
- **26.1 / master**: `-snapshotName` appears when snapshot support is enabled; `-branchName` still parsed in code.

**Before using `-branchName` or `-snapshotName`**, confirm Commander version with the user.

## ShowUsage output (from source)

```
Usage: 
Open existing workspace:
TCShell.exe
 -workspace <workspaceFile>
 [-login <username> <password> | -auth ( <personalAccessToken> | <clientId>:<clientSecret> )]
 [-healthCheck [<unloadThreshold>]]
 [-record <tcscriptPath>]
 [-loglevel <loglevel>]
 [-codepage <codepagenum>]
 [-waitforcompacting]
 [-Mode] ... otherwise FULL-Mode
 [<tcscriptPath>] ... otherwise INTERACTIVE-Mode
Create new workspace from existing common repository:
TCShell.exe
 -newworkspace <workspaceDirPath> (\"MS SQL Server\"|\"Oracle\"|\"DB2\") <connectionstring> [<schema>] [[-slimWS] | [-revision <revision>]] [-snapshotName <snapshot name>]
 -newworkspace <workspaceDirPath> SQLITE <commonRepoPath> [[-slimWS] | [-revision <revision>]] [-snapshotName <snapshot name>]
 -newworkspace <workspaceDirPath> \"Tricentis Server Repository\" <projectName> [[-slimWS] | [-revision <revision>]] [-snapshotName <snapshot name>] -auth ( <personalAccessToken> | <clientId>:<clientSecret> )
Create new workspace and new common repository:
TCShell.exe
 -newworkspace <workspaceDirPath> (\"MS SQL Server\"|\"Oracle\"|\"DB2\") <connectionstring> [<schema>] [-slimWS] -firstadmin <username> <password>
 -newworkspace <workspaceDirPath> SQLITE <commonRepoPath> [-slimWS] -firstadmin <username> <password>
Create new singleuser workspace:
TCShell.exe
 -newworkspace <workspaceDirPath> SQLITE
Use workspace template:
TCShell.exe
 -newworkspace <workspaceDirPath> SQLITE <commonRepoPath> -subset <templateDirPath>
Restore backup:
TCShell.exe
 -restoredbbackup <restoreDefFile>
```

## Invocation examples

```bat
TCShell.exe -workspace "C:\path\workspace.tws" -auth "<PAT>" script.tcs
TCShell.exe -workspace "C:\path\workspace.tws" -healthCheck
TCShell.exe -newworkspace "C:\path\new_ws" SQLITE
```
