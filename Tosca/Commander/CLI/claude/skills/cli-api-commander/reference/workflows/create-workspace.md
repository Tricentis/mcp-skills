# Create workspace

Headless bootstrap for a new single-user SQLite workspace.

```text
Create workspace:
- [ ] Confirm Commander closed (no lock on target path)
- [ ] TCShell.exe -newworkspace
- [ ] Verify structure with first script
```

## Single-user SQLite (CLI)

```bat
"%COMMANDER_HOME%\TCShell\TCShell.exe" -newworkspace "C:\TOSCA_Workspaces\MyWorkspace" SQLITE
```

Creates `{path}.tws` and local SQLite repository.

## Multi-user (advanced)

Multi-user workspace creation requires repository configuration and admin setup. See verified scenarios in [scenarios-index.md](../scenarios-index.md) → `WorkspaceCreation` entries and samples in `Samples/CreateNewWorkspace/`.

## First-session script

```
JumpToNode "/"
print
save
```

## Verified output

Match workspace creation fixtures via [scenarios-index.md](../scenarios-index.md) → one `##` section in [output-patterns.md](../output-patterns.md) for 25.1+ (30 scenarios). 24.1/24.2 have samples but no golden output fixtures.

## Notes

- Commander must not hold a lock on the target `.tws` path.
- For CLI flags (`-newworkspace` options, `-healthCheck`): [cli-from-source.md](../cli-from-source.md).
- After creation, run path detection before further automation.
