# TCShell sample scripts — topic catalog

> Commander version: **25.1**
> Generated at: 2026-06-25T21:10:13Z

Use this index to pick the closest sample folder before reading full scripts in `examples-index.md`.

| Topic | Folder | Summary | Scripts |
|-------|--------|---------|---------|
| Test case maintenance | `Samples/CreateMissingDOMClicks/` | Create missing DOM click modules in test cases. | `CreateDOMClickParam.tcs`, `CreateMissingDOMClicks.tcs` |
| Workspace lifecycle | `Samples/CreateNewWorkspace/` | Backup, restore, check-in; SQLite workspace bootstrap. | `backup.tcs`, `checkInAll.tcs`, `restore.tcs`, `restoreDtBoerse.tcs` |
| Backup / restore | `Samples/Dump/` | Database backup restore via `-restoredbbackup`. | `SampleRestoreDbBackup.tcs` |
| Workspace health | `Samples/HealthCheck/` | Run workspace health check (`-healthCheck` CLI or in-session). | _(batch wrappers only)_ |
| Import / export | `Samples/ImportExport/` | Subset import and replace in multi-user projects. | `importSubsetAndReplaceInMultiUserProject.tcs` |
| Manual test cases | `Samples/Manuelle Testfälle/` | Manual test case import, execution list, export/import results. | `Manuelle ExecutionList erzeugen.tcs`, `Manuelle ExecutionResults importieren.tcs`, `Manuelle Testfaelle importieren.tcs`, `Manuelles ExecutionSet exportieren.tcs` |
| Migration | `Samples/Migration650to642/` | Version-specific migration scripts (legacy). | `BackupMU.tcs`, `RestoreAndBackupSU.tcs`, `RestoreMU.tcs` |
| Migration | `Samples/MigrationFromTEx/` | Migrate from TEx to Tosca structures. | `backup.tcs`, `checkInAll.tcs` |
| Execution lists | `Samples/Templates/` | Template instantiate, run, report, execution entry creation. | `CreateExecutionEntries.tcs`, `Instantiate.tcs`, `InstantiateRun.tcs`, `Report.tcs` (+1 more) |
| Scheduled maintenance | `Samples/UpdateAll/` | Batch update-all workflow (scheduled task pattern). | `UpdateAllSometimes.tcs` |

## Related sample readmes

- `Samples/UpdateAll/Readme.txt` — scheduled task setup for UpdateAll batch
- Shipped tutorial: `commander/TCCore/TCShell/Tutorial/TCShell_Samples.zip` (legacy; prefer `Samples/` above)

## See also

- Full script contents: [examples-index.md](examples-index.md)
- CLI flags not in readme: [cli-from-source.md](cli-from-source.md)
