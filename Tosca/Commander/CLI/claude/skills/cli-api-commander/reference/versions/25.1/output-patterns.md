# TCShell Expected Output Patterns

> Commander version: 25.1 (Tosca Commander 25.1)
> Generated from `UnitTests/TCShell/*.verified.txt`


> **Agent navigation:** Do **not** load this entire file — it can exceed 1400 lines. Use [scenarios-index.md](scenarios-index.md) to pick one scenario, then search this file for the matching `## FixtureName` section only.
## TcShellCommandTests.PrintXModule.verified

```
﻿TCProject:Guid_1 > TCFolder:Modules > [#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Search all ambiguously named ObjectMaps'
[#]='Search all tables with specialized Ktx'
[#]='Search all attached files'
[#]='Search all references'
[#]='Search'
[#]='Rename'
[#]='Modify Name'
[#]='Modify SynchronizationPolicy'
[#]='Modify Description'
[#]='Modify OwningGroupName'
[#]='Modify ViewingGroupName'
[#]='Purge missing references'
[#]='Jump to Object in TCProject'
[#]='Drag this object'
[#]='Create Test configuration parameter'
[#]='Export Subset'
[#]='Attach File'
[#]='Show distribution by object type in local workspace'
[#]='Create XModule'
XModule:<New XModule> > '<New XModule>' [XModule]
  (R)NodePath='/Modules/<New XModule>'
  (R)CreatedBy='Admin'
  (R)CreatedAt='DateTime_Scrubbed'
  (R)ModifiedBy='Unknown'
  (R)ModifiedAt='Unknown'
  (R)HasMissingReferences='False'
  (R)UniqueId='Ulid_1'
     Name='<New XModule>'
     SynchronizationPolicy='CustomizableDefaultIsOn'
     Description=''
  (R)Revision='0'
     OwningGroupName='All Users (inherited)'
     ViewingGroupName='<NO VIEWING GROUP>'
  (R)IsCheckedOutByMe='False'
     InterfaceType='NonGUI'
     ImplementationType=''
     TechnicalId=''
     IsAbstract='False'
     ValueRange=''
     BusinessType=''
     SpecialIcon=''
  (R)IsTBoxModule='True'
  (R)AutomationFramework='Generic'
  CreatedByUser[TCUser] : 'Admin'
  ModifiedByUser[TCUser] : <NULL>
  ConfigurationLinks[TCConfigurationLink] : {}
  ParentFolder[OwnedFolder] : 'Modules'
  LockedBy[TCUser] : 'Admin'
  DirectOwner[TCUserGroup] : <NULL>
  DirectViewingGroup[TCUserGroup] : <NULL>
  AttachedFiles[OwnedFile] : {}
  Generalization[XModule] : <NULL>
  Specializations[XModule] : {}
  Attributes[XModuleAttribute] : {}
  ReferencingAttributes[XModuleAttribute] : {}
  UsedAsDefaultSpecializationIn[XModuleAttribute] : {}
  TestSteps[XTestStep] : {}
  UsedAsSpecializationIn[XTestStepValue] : {}
XModule:<New XModule> > XModule:<New XModule> > XModule:<New XModule> >
```

## TcShellWorkspaceCreationTests.NewMultiUserWorkspaceAndNewCommonRepository.verified

```
﻿
```

## TcShellWorkspaceCreationTests.NewMultiUserWorkspace_And_NewSqlServerCommonRepository_MissingFirstAdmin_Fails.verified

```
﻿>TCShell.exe -newworkspace "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace" "MS SQL Server" "Server=(localdb)\mssqllocaldb;Integrated Security=true;Initial Catalog=TestDb"
Error: Could not create new Workspace in '{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace'
Please provide a valid username and password for the first admin.
Press <ENTER> to continue > 

Directory Structure:
Nothing found.
```

## TcShellWorkspaceCreationTests.NewMultiUserWorkspace_And_NewSqlServerCommonRepository_WithFirstAdmin.verified

```
﻿>TCShell.exe -newworkspace "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace" "MS SQL Server" "Server=(localdb)\mssqllocaldb;Integrated Security=true;Initial Catalog=TestDb" "-firstadmin" "TestAdmin" "TestPassword"
Creating new Workspace and new Common!
New Project with Default-Folders created!
Checkin all: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkin all: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkin all: Connecting to Common Repository succeeded
Checkin all: Connecting to Common Repository succeeded
BeforeTeamTaskCommit
Checkin all finalizing ...
Checkin all finished
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Collecting objects ... 
BeforeTeamTaskCommit
Checkout Tree finalizing ...
Checkout Tree finished
Workspace '{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Workspace.tws' created successfully!


Directory Structure:
Workspace
Workspace\Log_Scrubbed.txt
Workspace\Log_Scrubbed.txt
Workspace\Repository
Workspace\Repository\.base
Workspace\Repository\.base\base.db
Workspace\Repository\.base\base.db-journal
Workspace\Repository\Workspace.db
Workspace\Repository\Workspace.db-journal
Workspace\Workspace.tws
Workspace\Workspace.tws.txt

Workspace\Workspace.tws contents:
<?xml version="1.0" encoding="utf-8"?>
<TCWorkspace xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <WorkspaceRepository>
    <RepoClass>SQLiteRepository</RepoClass>
    <DatabasePathAndName>.\Repository\Workspace.db</DatabasePathAndName>
    <Database>{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Repository\Workspace.db</Database>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </WorkspaceRepository>
  <CommonRepository>
    <RepoClass>MSSQLRepository</RepoClass>
    <ConnectionData>Ulid_1Ulid_2Ulid_3Ulid_4Ulid_58Ulid_6Ulid_7Ulid_8Ulid_9Ulid_10Ulid_110000</ConnectionData>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </CommonRepository>
  <DefaultUser>
    <UserName>TestAdmin</UserName>
    <UserSurrogate>Ulid_12</UserSurrogate>
  </DefaultUser>
  <TCWorkspaceID>Guid_2</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_3</TCCommonRepositoryID>
  <TCWorkspaceDescription />
</TCWorkspace>
```

## TcShellWorkspaceCreationTests.NewMultiUserWorkspace_And_NewSqliteCommonRepository_MissingFirstAdmin_Fails.verified

```
﻿>TCShell.exe -newworkspace "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace" "SQLITE" "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Common"
Error: Could not create new Workspace in '{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace'
Please provide a valid username and password for the first admin.
Press <ENTER> to continue > 

Directory Structure:
Nothing found.
```

## TcShellWorkspaceCreationTests.NewMultiUserWorkspace_And_NewSqliteCommonRepository_WithFirstAdmin.verified

```
﻿>TCShell.exe -newworkspace "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace" "SQLITE" "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Common" "-firstadmin" "TestAdmin" "TestPassword"
Creating new Workspace and new Common!
New Project with Default-Folders created!
Checkin all: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkin all: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkin all: Connecting to Common Repository succeeded
Checkin all: Connecting to Common Repository succeeded
BeforeTeamTaskCommit
Checkin all finalizing ...
Checkin all finished
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Collecting objects ... 
BeforeTeamTaskCommit
Checkout Tree finalizing ...
Checkout Tree finished
Workspace '{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Workspace.tws' created successfully!


Directory Structure:
Common
Common\CommonRepository
Common\CommonRepository\CommonRepository.db
Common\CommonRepository\CommonRepository.db-journal
Workspace
Workspace\Log_Scrubbed.txt
Workspace\Repository
Workspace\Repository\.base
Workspace\Repository\.base\base.db
Workspace\Repository\.base\base.db-journal
Workspace\Repository\Workspace.db
Workspace\Repository\Workspace.db-journal
Workspace\Workspace.tws

Workspace\Workspace.tws contents:
<?xml version="1.0" encoding="utf-8"?>
<TCWorkspace xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <WorkspaceRepository>
    <RepoClass>SQLiteRepository</RepoClass>
    <DatabasePathAndName>.\Repository\Workspace.db</DatabasePathAndName>
    <Database>{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Repository\Workspace.db</Database>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </WorkspaceRepository>
  <CommonRepository>
    <RepoClass>SQLiteRepository</RepoClass>
    <DatabasePathAndName>{TempPath}TcShellWorkspaceCreationTests\Guid_1\Common\CommonRepository\CommonRepository.db</DatabasePathAndName>
    <Database>{TempPath}TcShellWorkspaceCreationTests\Guid_1\Common\CommonRepository\CommonRepository.db</Database>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </CommonRepository>
  <DefaultUser>
    <UserName>TestAdmin</UserName>
    <UserSurrogate>Ulid_1</UserSurrogate>
  </DefaultUser>
  <TCWorkspaceID>Guid_2</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_3</TCCommonRepositoryID>
  <TCWorkspaceDescription />
</TCWorkspace>
```

## TcShellWorkspaceCreationTests.NewMultiUserWorkspace_WithExistingSqliteCommonRepository.verified

```
﻿>TCShell.exe -newworkspace "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace" "SQLITE" "{TempPath}TcShellWorkspaceCreationTests\Guid_2\Common"
Creating new Workspace to existing Common!
Create new Workspace from Common: Connecting to Common Repository (timeout in 5 seconds) ... 
Create new Workspace from Common: Connecting to Common Repository (timeout in 5 seconds) ... 
Create new Workspace from Common: Connecting to Common Repository succeeded
Create new Workspace from Common: Connecting to Common Repository succeeded
Create new Workspace from Common: No top-objects found to update
BeforeTeamTaskCommit
Create new Workspace from Common... finalizing Workspace (this may take some minutes!)
Create new Workspace from Common finished
Create new Workspace from Common finalizing ...
Create new Workspace from Common finished
Workspace '{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Workspace.tws' created successfully!


Directory Structure:
Workspace
Workspace\Log_Scrubbed.txt
Workspace\Repository
Workspace\Repository\.base
Workspace\Repository\.base\base.db
Workspace\Repository\.base\base.db-journal
Workspace\Repository\Workspace.db
Workspace\Repository\Workspace.db-journal
Workspace\Workspace.tws

Workspace\Workspace.tws contents:
<?xml version="1.0" encoding="utf-8"?>
<TCWorkspace xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <WorkspaceRepository>
    <RepoClass>SQLiteRepository</RepoClass>
    <DatabasePathAndName>.\Repository\Workspace.db</DatabasePathAndName>
    <Database>{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Repository\Workspace.db</Database>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </WorkspaceRepository>
  <CommonRepository>
    <RepoClass>SQLiteRepository</RepoClass>
    <DatabasePathAndName>{TempPath}TcShellWorkspaceCreationTests\Guid_2\Common\CommonRepository\CommonRepository.db</DatabasePathAndName>
    <Database>{TempPath}TcShellWorkspaceCreationTests\Guid_2\Common\CommonRepository\CommonRepository.db</Database>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </CommonRepository>
  <DefaultUser>
    <UserName>NONE</UserName>
    <UserSurrogate />
  </DefaultUser>
  <TCWorkspaceID>Guid_3</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_4</TCCommonRepositoryID>
  <TCWorkspaceDescription />
</TCWorkspace>
```

## TcShellWorkspaceCreationTests.NewMultiUserWorkspace_WithExistingSqliteCommonRepository_WithArbitraryDbFilePath.verified

```
﻿>TCShell.exe -newworkspace "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace" "SQLITE" "{TempPath}TcShellWorkspaceCreationTests\Guid_2\Common\Arbitrary.db"
Creating new Workspace to existing Common!
Create new Workspace from Common: Connecting to Common Repository (timeout in 5 seconds) ... 
Create new Workspace from Common: Connecting to Common Repository (timeout in 5 seconds) ... 
Create new Workspace from Common: Connecting to Common Repository succeeded
Create new Workspace from Common: Connecting to Common Repository succeeded
Create new Workspace from Common: All objects have been updated
BeforeTeamTaskCommit
Create new Workspace from Common... finalizing Workspace (this may take some minutes!)
Create new Workspace from Common finished
Create new Workspace from Common finalizing ...
Create new Workspace from Common finished
Workspace '{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Workspace.tws' created successfully!


Directory Structure:
Workspace
Workspace\Log_Scrubbed.txt
Workspace\Repository
Workspace\Repository\.base
Workspace\Repository\.base\base.db
Workspace\Repository\.base\base.db-journal
Workspace\Repository\Workspace.db
Workspace\Repository\Workspace.db-journal
Workspace\Workspace.tws

Workspace\Workspace.tws contents:
<?xml version="1.0" encoding="utf-8"?>
<TCWorkspace xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <WorkspaceRepository>
    <RepoClass>SQLiteRepository</RepoClass>
    <DatabasePathAndName>.\Repository\Workspace.db</DatabasePathAndName>
    <Database>{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Repository\Workspace.db</Database>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </WorkspaceRepository>
  <CommonRepository>
    <RepoClass>SQLiteRepository</RepoClass>
    <DatabasePathAndName>{TempPath}TcShellWorkspaceCreationTests\Guid_2\Common\Arbitrary.db</DatabasePathAndName>
    <Database>{TempPath}TcShellWorkspaceCreationTests\Guid_2\Common\Arbitrary.db</Database>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </CommonRepository>
  <DefaultUser>
    <UserName>NONE</UserName>
    <UserSurrogate />
  </DefaultUser>
  <TCWorkspaceID>Guid_3</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_4</TCCommonRepositoryID>
  <TCWorkspaceDescription />
</TCWorkspace>
```

## TcShellWorkspaceCreationTests.NewMultiUserWorkspace_WithExistingSqliteCommonRepository_WithDbFileEnding.verified

```
﻿>TCShell.exe -newworkspace "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace" "SQLITE" "{TempPath}TcShellWorkspaceCreationTests\Guid_2\Common\CommonRepository\CommonRepository.db"
Creating new Workspace to existing Common!
Create new Workspace from Common: Connecting to Common Repository (timeout in 5 seconds) ... 
Create new Workspace from Common: Connecting to Common Repository (timeout in 5 seconds) ... 
Create new Workspace from Common: Connecting to Common Repository succeeded
Create new Workspace from Common: Connecting to Common Repository succeeded
Create new Workspace from Common: All objects have been updated
BeforeTeamTaskCommit
Create new Workspace from Common... finalizing Workspace (this may take some minutes!)
Create new Workspace from Common finished
Create new Workspace from Common finalizing ...
Create new Workspace from Common finished
Workspace '{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Workspace.tws' created successfully!


Directory Structure:
Workspace
Workspace\Log_Scrubbed.txt
Workspace\Repository
Workspace\Repository\.base
Workspace\Repository\.base\base.db
Workspace\Repository\.base\base.db-journal
Workspace\Repository\Workspace.db
Workspace\Repository\Workspace.db-journal
Workspace\Workspace.tws

Workspace\Workspace.tws contents:
<?xml version="1.0" encoding="utf-8"?>
<TCWorkspace xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <WorkspaceRepository>
    <RepoClass>SQLiteRepository</RepoClass>
    <DatabasePathAndName>.\Repository\Workspace.db</DatabasePathAndName>
    <Database>{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Repository\Workspace.db</Database>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </WorkspaceRepository>
  <CommonRepository>
    <RepoClass>SQLiteRepository</RepoClass>
    <DatabasePathAndName>{TempPath}TcShellWorkspaceCreationTests\Guid_2\Common\CommonRepository\CommonRepository.db</DatabasePathAndName>
    <Database>{TempPath}TcShellWorkspaceCreationTests\Guid_2\Common\CommonRepository\CommonRepository.db</Database>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </CommonRepository>
  <DefaultUser>
    <UserName>NONE</UserName>
    <UserSurrogate />
  </DefaultUser>
  <TCWorkspaceID>Guid_3</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_4</TCCommonRepositoryID>
  <TCWorkspaceDescription />
</TCWorkspace>
```

## TcShellWorkspaceCreationTests.NewMultiUserWorkspace_WithNewSqliteCommonRepository_WithArbitraryDbFilePath_MissingFirstAdmin_Fails.verified

```
﻿>TCShell.exe -newworkspace "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace" "SQLITE" "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Common\Arbitrary.db"
Error: Could not create new Workspace in '{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace'
Please provide a valid username and password for the first admin.
Press <ENTER> to continue > 

Directory Structure:
Nothing found.
```

## TcShellWorkspaceCreationTests.NewMultiUserWorkspace_WithNewSqliteCommonRepository_WithArbitraryDbFilePath_WithFirstAdmin.verified

```
﻿>TCShell.exe -newworkspace "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace" "SQLITE" "{TempPath}TcShellWorkspaceCreationTests\Guid_1\Common\Arbitrary.db" "-firstadmin" "TestAdmin" "TestPassword"
Creating new Workspace and new Common!
New Project with Default-Folders created!
Checkin all: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkin all: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkin all: Connecting to Common Repository succeeded
Checkin all: Connecting to Common Repository succeeded
BeforeTeamTaskCommit
Checkin all finalizing ...
Checkin all finished
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository (timeout in 5 seconds) ... 
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Connecting to Common Repository succeeded
Checkout Tree: Collecting objects ... 
BeforeTeamTaskCommit
Checkout Tree finalizing ...
Checkout Tree finished
Workspace '{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Workspace.tws' created successfully!


Directory Structure:
Common
Common\CommonRepository.db
Common\CommonRepository.db-journal
Workspace
Workspace\Log_Scrubbed.txt
Workspace\Repository
Workspace\Repository\.base
Workspace\Repository\.base\base.db
Workspace\Repository\.base\base.db-journal
Workspace\Repository\Workspace.db
Workspace\Repository\Workspace.db-journal
Workspace\Workspace.tws

Workspace\Workspace.tws contents:
<?xml version="1.0" encoding="utf-8"?>
<TCWorkspace xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <WorkspaceRepository>
    <RepoClass>SQLiteRepository</RepoClass>
    <DatabasePathAndName>.\Repository\Workspace.db</DatabasePathAndName>
    <Database>{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Repository\Workspace.db</Database>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </WorkspaceRepository>
  <CommonRepository>
    <RepoClass>SQLiteRepository</RepoClass>
    <DatabasePathAndName>{TempPath}TcShellWorkspaceCreationTests\Guid_1\Common\CommonRepository.db</DatabasePathAndName>
    <Database>{TempPath}TcShellWorkspaceCreationTests\Guid_1\Common\CommonRepository.db</Database>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </CommonRepository>
  <DefaultUser>
    <UserName>TestAdmin</UserName>
    <UserSurrogate>Ulid_1</UserSurrogate>
  </DefaultUser>
  <TCWorkspaceID>Guid_2</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_3</TCCommonRepositoryID>
  <TCWorkspaceDescription />
</TCWorkspace>
```

## TcShellWorkspaceCreationTests.NewSqliteSingleUserWorkspace.verified

```
﻿>TCShell.exe -newworkspace "{TempPath}TcShellWorkspaceCreationTests\Guid_1" "SQLITE"
Creating new Workspace!
New Project with Default-Folders created!
Workspace '{TempPath}TcShellWorkspaceCreationTests\Guid_1\Guid_1.tws' created successfully!


Directory Structure:
Guid_1.tws
Log_Scrubbed.txt
Repository
Repository\.base
Repository\Guid_1.db
Repository\Guid_1.db-journal
```

## TcShellWorkspaceCreationTests.NewSqliteSingleUserWorkspace_OnExistingWorkspace_Fails.verified

```
﻿>TCShell.exe -newworkspace "{TempPath}TCShellCommandTests\Guid_1" "SQLITE"
Error: Could not create new Workspace in '{TempPath}TCShellCommandTests\Guid_1'
Workspace-Directory is not empty!
Press <ENTER> to continue > 

Directory Structure:
Guid_1.tws
Log_Scrubbed.txt
Repository
Repository\.base
Repository\Guid_1.db
Repository\Guid_1.db-journal
```

## TcShellWorkspaceCreationTests.NewSqliteSingleUserWorkspace_VerifyStructure.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > print
'Guid_1' [TCProject]
  (R)NodePath=''
  (R)CreatedBy='Unknown'
  (R)CreatedAt='DateTime_Scrubbed'
  (R)ModifiedBy='Admin'
  (R)ModifiedAt='DateTime_Scrubbed'
  (R)HasMissingReferences='False'
  (R)UniqueId='Ulid_1'
     Name='Guid_1'
     SynchronizationPolicy='CustomizableDefaultIsOn'
     Description=''
  (R)Revision='0'
     OwningGroupName='All Users'
     ViewingGroupName='<NO VIEWING GROUP>'
  (R)IsCheckedOutByMe='False'
     SpecialProjectName=''
  CreatedByUser[TCUser] : <NULL>
  ModifiedByUser[TCUser] : 'Admin'
  ConfigurationLinks[TCConfigurationLink] : {}
  ParentFolder[OwnedFolder] : <NULL>
  LockedBy[TCUser] : 'Admin'
  DirectOwner[TCUserGroup] : 'All Users'
  DirectViewingGroup[TCUserGroup] : <NULL>
  AttachedFiles[OwnedFile] : {}
  Items[OwnedFolder] : {'Modules','TestCases','Execution','Issues','Configurations'}
  Groups[TCUserGroup] : {'All Users','Admins'}
  Users[TCUser] : {'Admin'}
  UserBookmarks[TCUserBookmarks] : {'Admin Bookmarks'}
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > print
'TestCases' [TCFolder]
  (R)NodePath='/TestCases'
  (R)CreatedBy='Admin'
  (R)CreatedAt='DateTime_Scrubbed'
  (R)ModifiedBy='Admin'
  (R)ModifiedAt='DateTime_Scrubbed'
  (R)HasMissingReferences='False'
  (R)UniqueId='Ulid_2'
     Name='TestCases'
     SynchronizationPolicy='CustomizableDefaultIsOn'
     Description=''
  (R)Revision='0'
     OwningGroupName='All Users (inherited)'
     ViewingGroupName='<NO VIEWING GROUP>'
  (R)IsCheckedOutByMe='False'
  CreatedByUser[TCUser] : 'Admin'
  ModifiedByUser[TCUser] : 'Admin'
  ConfigurationLinks[TCConfigurationLink] : {}
  ParentFolder[OwnedFolder] : <NULL>
  LockedBy[TCUser] : 'Admin'
  DirectOwner[TCUserGroup] : <NULL>
  DirectViewingGroup[TCUserGroup] : <NULL>
  AttachedFiles[OwnedFile] : {}
  Items[OwnedItem] : {}
  ExecutionEntryFolders[ExecutionEntryFolder] : {}
TCFolder:TestCases > cn ..
TCProject:Guid_1 > cn Modules
TCFolder:Modules > print
'Modules' [TCFolder]
  (R)NodePath='/Modules'
  (R)CreatedBy='Admin'
  (R)CreatedAt='DateTime_Scrubbed'
  (R)ModifiedBy='Admin'
  (R)ModifiedAt='DateTime_Scrubbed'
  (R)HasMissingReferences='False'
  (R)UniqueId='Ulid_3'
     Name='Modules'
     SynchronizationPolicy='CustomizableDefaultIsOn'
     Description=''
  (R)Revision='0'
     OwningGroupName='All Users (inherited)'
     ViewingGroupName='<NO VIEWING GROUP>'
  (R)IsCheckedOutByMe='False'
  CreatedByUser[TCUser] : 'Admin'
  ModifiedByUser[TCUser] : 'Admin'
  ConfigurationLinks[TCConfigurationLink] : {}
  ParentFolder[OwnedFolder] : <NULL>
  LockedBy[TCUser] : 'Admin'
  DirectOwner[TCUserGroup] : <NULL>
  DirectViewingGroup[TCUserGroup] : <NULL>
  AttachedFiles[OwnedFile] : {}
  Items[OwnedItem] : {}
  ExecutionEntryFolders[ExecutionEntryFolder] : {}
TCFolder:Modules > cn ..
TCProject:Guid_1 > cn ExecutionLists
No object found with node '/ExecutionLists'!
TCProject:Guid_1 > print
'Guid_1' [TCProject]
  (R)NodePath=''
  (R)CreatedBy='Unknown'
  (R)CreatedAt='DateTime_Scrubbed'
  (R)ModifiedBy='Admin'
  (R)ModifiedAt='DateTime_Scrubbed'
  (R)HasMissingReferences='False'
  (R)UniqueId='Ulid_1'
     Name='Guid_1'
     SynchronizationPolicy='CustomizableDefaultIsOn'
     Description=''
  (R)Revision='0'
     OwningGroupName='All Users'
     ViewingGroupName='<NO VIEWING GROUP>'
  (R)IsCheckedOutByMe='False'
     SpecialProjectName=''
  CreatedByUser[TCUser] : <NULL>
  ModifiedByUser[TCUser] : 'Admin'
  ConfigurationLinks[TCConfigurationLink] : {}
  ParentFolder[OwnedFolder] : <NULL>
  LockedBy[TCUser] : 'Admin'
  DirectOwner[TCUserGroup] : 'All Users'
  DirectViewingGroup[TCUserGroup] : <NULL>
  AttachedFiles[OwnedFile] : {}
  Items[OwnedFolder] : {'Modules','TestCases','Execution','Issues','Configurations'}
  Groups[TCUserGroup] : {'All Users','Admins'}
  Users[TCUser] : {'Admin'}
  UserBookmarks[TCUserBookmarks] : {'Admin Bookmarks'}
TCProject:Guid_1 > TCProject:Guid_1 > 

Directory Structure:
Guid_1.tws
Log_Scrubbed.txt
Log_Scrubbed.txt
Repository
Repository\.base
Repository\Guid_1.db
Repository\Guid_1.db-journal
```

## TcShellWorkspaceCreationTests.NewSqliteSingleUserWorkspace_WithInvalidPath_Fails.verified

```
﻿>TCShell.exe -newworkspace "Z:\NonExistent\Path" "SQLITE"
Error: Could not create new Workspace in 'Z:\NonExistent\Path'
Could not find a part of the path 'Z:\NonExistent\Path'.
Press <ENTER> to continue > 

Directory Structure:
Nothing found.
```
