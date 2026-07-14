# TCShell Sample Scripts

> Commander version: 24.2 (Tosca Commander 24.2)
> Generated from `commander/TCCore/TCShell/Samples/**/*.tcs`


> **Agent navigation:** Do **not** load this entire file (~400 lines). Use [examples-catalog.md](examples-catalog.md) to pick one sample topic, then read only the matching `##` script section.
## `commander/TCCore/TCShell/Samples/CreateMissingDOMClicks/CreateDOMClickParam.tcs`

```
// Neuen Parameter auf dem Control/ObjectMap anlegen.
task "Create Param _New"
// Damit sind wir auf dem neuen Parameter und k�nnen dort gleich Label (=DisplayedName) und Value setzen
Set Label "DOMClick"
Set Value "Falsch"
```

## `commander/TCCore/TCShell/Samples/CreateMissingDOMClicks/CreateMissingDOMClicks.tcs`

```

cn "/Modules"

for "->AllOwnedSubItems:Module->CurrentObjectMap[ScreenType==\"HTML\"]->ObjectControls->COMPLEMENT(->SELF, ->return SELF->Params[Label == \"DOMClick\"])"
    CallOnEach CreateDOMClickParam.tcs
   
save
```

## `commander/TCCore/TCShell/Samples/CreateNewWorkspace/backup.tcs`

```
adminmoduson

backupProject
// Verzeichnis in das das Backup gestellt werden soll
"C:\\temp"
```

## `commander/TCCore/TCShell/Samples/CreateNewWorkspace/checkInAll.tcs`

```
checkInAll
```

## `commander/TCCore/TCShell/Samples/CreateNewWorkspace/restore.tcs`

```
adminmoduson

restoreProject
   OK  // confirm deletion of whole Workspace Directory
   "C:\\temp\\Backup_070725_1618.tcb"  // specify Backup-File
```

## `commander/TCCore/TCShell/Samples/CreateNewWorkspace/restoreDtBoerse.tcs`

```
adminmoduson

restoreProject
   OK  // confirm deletion of whole Workspace Directory
   "D:\\playground\\DeutscheB�rse\\Backup_070725_0817.tcb"  // specify Backup-File
```

## `commander/TCCore/TCShell/Samples/Dump/SampleRestoreDbBackup.tcs`

```
// Confirm warning
Ok

// Enter dumpfile
"C:\\TOSCA_Projects\\ObjectRev26_01\\Dump\\ObjectRev26_01_Dump_090403_1430.tdp"

// DB Type, Connection String & Schema (optional)
// "MS SQL Server 2005"
//"Server=.\\SQLEXPRESS;Database=JFDemo;Uid=TC;Pwd=TC;"
//""

// DB Type, Connection String & Schema (optional)
"SQLite"
"C:\\temp\\RestoreTest\\RestoreTest.db"
""
```

## `commander/TCCore/TCShell/Samples/ImportExport/importSubsetAndReplaceInMultiUserProject.tcs`

```

// (0) Optionen setzen
setOption UndoEnabled = False // Undo ausschalten

// (1) Import durchf�hren
task "Check Out" // Project ...
for "->Items" TaskOnAll "Check out" // ... und Top-Folder auschecken
task "Import Subset"
     "C:\\Temp\\MusterTestfaelleExecList.tce"   
save 
 
// (2) alle Zielfolder auschecken und Inhalte l�schen
// WICHTIG: "Check out Tree" nur m�glich, 
//   wenn Zielfolder auch tats�chlich Elemente enth�lt (vorher �berpr�fen).  
// .. f�r Testcases, Module und ExecutionLists
JumpToNode "/TestCases/Zielfolder"
task "Check out Tree" 
for "->Items" TaskOnAll "Delete" 

JumpToNode "/Modules/Zielfolder"
task "Check out Tree" 
for "->Items" TaskOnAll "Delete" 
  
JumpToNode "/ExecutionLists/Zielfolder"
task "Check out Tree" 
for "->Items" TaskOnAll "Delete" 
  
// (3) Inhalt der importierten Folder in die Zielfolder verschieben und Import-Folder wieder l�schen
// WICHTIG: es darf hier nur einen importierten Folder geben

JumpToNode "/TestCases"
 JumpTo "->Items[Name=~\"_import\"]"  // zum einzigen Import-Folder springen
 For "->Items" MarkAll  // alle Elemente darin markieren
 JumpToNode "/TestCases/Zielfolder"
 DropMarked  // und auf dem Zielfoder droppen, d.h. verschieben
 JumpToNode "/TestCases"
 JumpTo "->Items[Name=~\"_import\"]"
 task "Delete"  // leeren Import-Folder l�schen

JumpToNode "/Modules"
 JumpTo "->Items[Name=~\"_import\"]"  // zum einzigen Import-Folder springen
 For "->Items" MarkAll  // alle Elemente darin markieren
 JumpToNode "/Modules/Zielfolder"
 DropMarked  // und auf dem Zielfoder droppen, d.h. verschieben
 JumpToNode "/Modules"
 JumpTo "->Items[Name=~\"_import\"]"
 task "Delete"  // leeren Import-Folder l�schen

JumpToNode "/ExecutionLists"
 JumpTo "->Items[Name=~\"_import\"]"  // zum einzigen Import-Folder springen
 For "->Items" MarkAll  // alle Elemente darin markieren
 JumpToNode "/ExecutionLists/Zielfolder"
 DropMarked  // und auf dem Zielfoder droppen, d.h. verschieben
 JumpToNode "/ExecutionLists"
 JumpTo "->Items[Name=~\"_import\"]"
 task "Delete"  // leeren Import-Folder l�schen

Save
CheckInAll
```

## `commander/TCCore/TCShell/Samples/Manuelle Testfälle/Manuelle ExecutionList erzeugen.tcs`

```

jumpToNode /ExecutionListFolder
task "Create ExecutionList"
set Name "Manuelle ExecList"

jumpToNode "/TestCaseFolder/Tutorial/Manuelle Testf�lle"
for "->Items:TestCase" MarkAll

jumpToNode "/ExecutionListFolder/Manuelle ExecList"
dropMarked

save
```

## `commander/TCCore/TCShell/Samples/Manuelle Testfälle/Manuelle ExecutionResults importieren.tcs`

```
jumpToNode "/ExecutionListFolder/Manuelle ExecList"
task "Import Manual CheckList Result" 
  // Import from Files
  "C:\\TOSCA_Workspaces\\Tosca Tutorial\\Manuelle Testf�lle\\ResultFiles\\Ueberpr_Pflichtfelder_Personendaten.doc"
  "C:\\TOSCA_Workspaces\\Tosca Tutorial\\Manuelle Testf�lle\\ResultFiles\\Ueberpr_PKW_HVBerechnung.doc"
 <EOL>

save
```

## `commander/TCCore/TCShell/Samples/Manuelle Testfälle/Manuelle Testfaelle importieren.tcs`

```
﻿
jumpToNode "/TestCaseFolder/Tutorial/Manuelle Testfälle"
task "Import Manual TestCases" 
// Select Files to import
   "C:\\TOSCA_Workspaces\\Tosca Tutorial\\Manuelle Testfälle\\Erfassung\\Überpr. Pflichtfelder Personendaten.doc"
   "C:\\TOSCA_Workspaces\\Tosca Tutorial\\Manuelle Testfälle\\Erfassung\\Überpr. PKW HV-Berechnung.doc" 
 <EOL>

save
```

## `commander/TCCore/TCShell/Samples/Manuelle Testfälle/Manuelles ExecutionSet exportieren.tcs`

```
﻿jumpToNode "/ExecutionListFolder/Manuelle ExecList"
task "Export Manual CheckList" 
   // Export to Folder
   "C:\\TOSCA_Workspaces\\Tosca Tutorial\\Manuelle Testfälle\\ToDoFiles"
```

## `commander/TCCore/TCShell/Samples/Migration650to642/BackupMU.tcs`

```

AdminModusOn

BackupProject
"D:\\dev\\trunk\\csharp\\TCCore\\TCShell\\Samples\\Migration650to642\\Backups642"
```

## `commander/TCCore/TCShell/Samples/Migration650to642/RestoreAndBackupSU.tcs`

```

AdminModusOn

RestoreProject
"D:\\dev\\trunk\\csharp\\TCCore\\TCShell\\Samples\\Migration650to642\\DemoProject 651_Backup_090129_1545.tcbs"

BackupProject
"D:\\dev\\trunk\\csharp\\TCCore\\TCShell\\Samples\\Migration650to642\\Backups642"
```

## `commander/TCCore/TCShell/Samples/Migration650to642/RestoreMU.tcs`

```

AdminModusOn

RestoreProject
// Confirm deleting workspace dir after restore 
ok
// Specify the Backup-file to restore
"D:\\dev\\trunk\\csharp\\TCCore\\TCShell\\Samples\\Migration650to642\\DVAG_mit_Referenzen_Backup_090204_1443.tcbm"
// Conform deleting workpace dir now
c
```

## `commander/TCCore/TCShell/Samples/MigrationFromTEx/backup.tcs`

```
adminmoduson

backupProject
// Verzeichnis in das das Backup gestellt werden soll
"D:\\temp"
```

## `commander/TCCore/TCShell/Samples/MigrationFromTEx/checkInAll.tcs`

```
checkInAll
```

## `commander/TCCore/TCShell/Samples/Templates/CreateExecutionEntries.tcs`

```

// **** Create new ExecutionList
jumpToNode "/ExecutionListFolder/Tutorial"
task "Create ExecutionList"
set Name "Systemtest"
// ***

// **** Create new ExecutionEntry
jumpToNode "/TestCaseFolder/Mustertestf�lle/Generierte Testf�lle/CheckKFZVers: Einfach 3"
mark

// Jump to ExecutionList
jumpToNode "/ExecutionListFolder/Tutorial/Systemtest"
dropMarked // Create synchronized EntryFolder
// ***

save
```

## `commander/TCCore/TCShell/Samples/Templates/Instantiate.tcs`

```

// Jump to Template
jumpToNode "/TestCaseFolder/Mustertestf�lle/Generierte Testf�lle/CheckKFZVers"
task "Create Template Instance"

// *** Input to "Create Template Instance"-Taks
// DataSourcePath including Sheet =
"C:\\TOSCA_Workspaces\\Tosca Tutorial\\BO_TF\\TF_Katalog_Web.xls\\TF_RS"
// Instantiation Selector =
"Die ersten 10" 
// *** End of Input to "Create Template Instance"-Taks

// Jump to Template-Instance
jumpToNode "/TestCaseFolder/Mustertestf�lle/Generierte Testf�lle/TemplateInstance of CheckKFZVers"

set Name "CheckKFZVers: Einfach 3"
set DataSourcePath "C:\\TOSCA_Workspaces\\Tosca Tutorial\\BO_TF\\TF_Katalog_Web.xls\\TF_RS"
set InstantiationSelector ""   // instantiate all
set InstantiationSelector "einfach 3"   // instantiate a subset

task "Reinstantiate Instance"

save
```

## `commander/TCCore/TCShell/Samples/Templates/InstantiateRun.tcs`

```
call Instantiate.tcs
call CreateExecutionEntries.tcs
call Run.tcs
```

## `commander/TCCore/TCShell/Samples/Templates/Report.tcs`

```

// **** Report

// Jump to ExecutionList...
jumpToNode "/ExecutionListFolder/Tutorial"

// Execute "Report"-Task
task "Create Execution Report"
// ** TOSCA Commander: Create Execution Report **
// Include Details for PASSED TestCases ?                    
yes

save
```

## `commander/TCCore/TCShell/Samples/Templates/Run.tcs`

```

// **** Run

// Jump to ExecutionEntryFolder...
jumpToNode "/ExecutionListFolder/Tutorial/Systemtest/CheckKFZVers: Einfach 3"

// Execute "Run"-Task
task "Run"

save
```

## `commander/TCCore/TCShell/Samples/UpdateAll/UpdateAllSometimes.tcs`

```
 // (bis zu 1 Stunde warten)
 setOption CommonRepoLockTimeoutInSeconds = 3600

updateAll
```
