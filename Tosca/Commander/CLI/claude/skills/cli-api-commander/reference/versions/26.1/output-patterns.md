# TCShell Expected Output Patterns

> Commander version: 26.1 (Tosca Commander 26.1)
> Generated from `UnitTests/TCShell/*.verified.txt`


> **Agent navigation:** Do **not** load this entire file — it can exceed 1400 lines. Use [scenarios-index.md](scenarios-index.md) to pick one scenario, then search this file for the matching `## FixtureName` section only.
## TcShellCommandTests.ChangeExistingConfigParameterDataType.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam Test + string = ThisIsSomeStringValue
TestCase:<New TestCase> > gettcparam Test
ThisIsSomeStringValue
TestCase:<New TestCase> > settcparam Test + password = SecretPassword
TestCase:<New TestCase> > gettcparam Test
*****
TestCase:<New TestCase> > settcparam Test + string = ThisIsSomeStringValue
TestCase:<New TestCase> > gettcparam Test

TestCase:<New TestCase> > save
TestCase:<New TestCase> > TestCase:<New TestCase> >
```

## TcShellCommandTests.CheckOutTree.verified

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
 ** Checkout Tree ** 
Continue checkout of 10 objects ?

     1	TCProject 
     6	TCFolder 
     1	TCUserBookmarks 
     2	TCConfiguration 

yes/no > yes/no > Missing answer interpreted as 'No'
BeforeTeamTaskCommit
Checkout Tree finalizing ...
Checkout Tree finished
Workspace '{TempPath}TcShellWorkspaceCreationTests\Guid_1\Workspace\Workspace.tws' created successfully!
```

## TcShellCommandTests.MultipleWrongTcpDatatypes.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam Test + noType = notSet
Invalid datatype
TestCase:<New TestCase> > gettcparam Test
TestCase:<New TestCase> > settcparam Test + same = alsoNotSet
Invalid datatype
TestCase:<New TestCase> > gettcparam Test
TestCase:<New TestCase> > settcparam Test + string = ThisIsSomeStringValue
TestCase:<New TestCase> > gettcparam Test
ThisIsSomeStringValue
TestCase:<New TestCase> > save
TestCase:<New TestCase> > TestCase:<New TestCase> >
```

## TcShellCommandTests.OverwriteDataTypeOfParentTcp.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > settcparam tcp1 + password = my_secret
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Reset test configuration parameter tcp1'
[#]='Create Test configuration parameter'
[#]='Export Subset'
[#]='Attach File'
[#]='Show distribution by object type in local workspace'
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam tcp1 + password = secretToo
TestCase:<New TestCase> > cn ..
TCFolder:TestCases > settcparam tcp1 + string = bla
TCFolder:TestCases > gettcparam tcp1

TCFolder:TestCases > settcparam tcp1 + string = blabla
TCFolder:TestCases > gettcparam tcp1
blabla
TCFolder:TestCases > cn Modules
No object found with node '/TestCases/Modules'!
TCFolder:TestCases > gettcparam tcp1
blabla
TCFolder:TestCases > save
TCFolder:TestCases > TCFolder:TestCases >
```

## TcShellCommandTests.OverwriteDatatypeOfInheritedTcp.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > settcparam tcp1 + password = my_secret
TCFolder:TestCases > settcparam tcp2 + string = hey
TCFolder:TestCases > settcparam tcp3 + boolean = true
TCFolder:TestCases > gettcparam tcp1
*****
TCFolder:TestCases > gettcparam tcp2
hey
TCFolder:TestCases > gettcparam tcp3
true
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Reset test configuration parameter tcp1'
[#]='Reset test configuration parameter tcp2'
[#]='Reset test configuration parameter tcp3'
[#]='Create Test configuration parameter'
[#]='Export Subset'
[#]='Attach File'
[#]='Show distribution by object type in local workspace'
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam tcp1 + string = ho
TestCase:<New TestCase> > settcparam tcp2 + password = supersecret
Warning: This value is not stored as type Password, because the type of the parent Tcp is String.
TestCase:<New TestCase> > settcparam tcp3 + password = secretToo
Warning: This value is not stored as type Password, because the type of the parent Tcp is Boolean.
TestCase:<New TestCase> > gettcparam tcp1
*****
TestCase:<New TestCase> > gettcparam tcp2
supersecret
TestCase:<New TestCase> > gettcparam tcp3
secretToo
TestCase:<New TestCase> > save
TestCase:<New TestCase> > TestCase:<New TestCase> >
```

## TcShellCommandTests.PrintXModule.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn Modules
TCFolder:Modules > task "Create XModule"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
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
XModule:<New XModule> > print
'<New XModule>' [XModule]
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
XModule:<New XModule> > save
XModule:<New XModule> > XModule:<New XModule> >
```

## TcShellCommandTests.RunScriptHelp.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > TCProject:Guid_1 > ?
adminModusOff
adminModusOn
call <scriptPath>
changeNode {<AbsoluteNodePath>, <RelativeNodePath>, ".."}
cleanupfileservicecache
clearMarked
cn {<AbsoluteNodePath>, <RelativeNodePath>, ".."}
deltcparam <TestConfigurationParameterName>
dropMarked
dropMarkedWithCtrl
exit
for <queryString> (TaskOnEach <taskName> | TaskOnAll < taskName > | MarkAll | CallOnEach <scriptPath>)
get <attributeName>
getAllOptions
getOption <optionName>
gettcparam <TestConfigurationParameterName>
hc
healthCheck
help
jumpTo <UniqueQueryString>
jumpToNode <NodePath>
jumpToProject
mark
print
redo
renametcparam <TestConfigurationParameterName> <NewTestConfigurationParameterName>
save
saveAndUnloadAll
saveOptions
search <queryString> <resultNum>
set <attributeName> ["="] <attributeValue>
setOption <optionName> ["="] <optionValue>
setproperty <PropertyName> ["="] <Value>
settcparam <TestConfigurationParameterName> ["="] <Value>
showRedoList
showUndoList
task <taskNum> | task <taskName>
undo
```

## TcShellCommandTests.SetNewTestCaseAndJumpToItByNodePath.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > task "Rename" mytestcase1
[#]='Create Folder'
[#]='Convert to Template'
[#]='Run in ScratchBook'
[#]='Search all usages'
[#]='Search all used Modules'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
[#]='Search all attached files'
[#]='Search all references'
[#]='Search'
[#]='Cut'
[#]='Copy'
[#]='Modify Name'
[#]='Modify SynchronizationPolicy'
[#]='Modify Description'
[#]='Modify OwningGroupName'
[#]='Modify ViewingGroupName'
[#]='Modify Pausable'
[#]='Modify TestCaseWorkState'
[#]='Purge missing references'
[#]='Create TestCase (after this)'
[#]='Create Duplicate (after this)'
[#]='Jump to Object in TCFolder'
[#]='Drag this object'
[#]='Create Test configuration parameter'
[#]='Delete'
[#]='Rename'
[#]='Export Subset'
[#]='Attach File'
[#]='Create IF Statement'
[#]='Create DO Statement'
[#]='Create WHILE Statement'
[#]='Create Recovery Scenario Collection'
[#]='Create Manual XTestStep'
[#]='Search all used XModules'
DefaultValue set to "<New TestCase>" (enter "." to use this)
TestCase:mytestcase1 > jumpToProject
TCProject:Guid_1 > task "Jump to Object" "/TestCases/mytestcase1"
[#]='Search all attached files'
[#]='Search all references'
[#]='Search'
[#]='Rename'
[#]='Modify Name'
[#]='Modify SynchronizationPolicy'
[#]='Modify Description'
[#]='Modify OwningGroupName'
[#]='Modify ViewingGroupName'
[#]='Modify SpecialProjectName'
[#]='Purge missing references'
[#]='Drag this object'
[#]='Create Test configuration parameter'
[#]='Export Subset'
[#]='Search all lost objects'
[#]='Jump to Object'
[#]='Export Project Definitions'
[#]='Import Project Definitions'
[#]='Create UserGroup'
[#]='Synchronize LDAP Objects'
[#]='Sync Users from Tosca Server'
[#]='Create Project Settings'
[#]='Set Credentials for Managed Files Area'
[#]='Import Subset'
[#]='Import External Objects'
[#]='Create Component Folder'
[#]='Create property definition TestStep'
[#]='Create property definition XTestStep'
[#]='Create property definition TestStepFolder'
[#]='Create property definition ExecutionEntry'
[#]='Create property definition ExecutionEntryFolder'
[#]='Create property definition ExecutionTestCaseLog'
[#]='Create property definition ReuseableTestStepBlock'
[#]='Create Create Bookmarks folder for each User'
[#]='Show distribution by object type in local workspace'
TestCase:mytestcase1 > save
TestCase:mytestcase1 > TestCase:mytestcase1 >
```

## TcShellCommandTests.SetNewTestConfigParameter.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam Test = ThisIsSomeStringValue
TestCase:<New TestCase> > gettcparam Test
ThisIsSomeStringValue
TestCase:<New TestCase> > save
TestCase:<New TestCase> > TestCase:<New TestCase> >
```

## TcShellCommandTests.SetNewTestConfigParameterInvalidDataType.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam Test + InvalidType ThisIsSomeStringValue
Invalid datatype
TestCase:<New TestCase> > save
TestCase:<New TestCase> > TestCase:<New TestCase> >
```

## TcShellCommandTests.SetNewTestConfigParameterShortVersion.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam Test ThisIsSomeStringValue
TestCase:<New TestCase> > gettcparam Test
ThisIsSomeStringValue
TestCase:<New TestCase> > save
TestCase:<New TestCase> > TestCase:<New TestCase> >
```

## TcShellCommandTests.SetNewTestConfigParameterWithDataType_dataType=BoOlEaN.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam Test + BoOlEaN = ThisIsSomeStringValue
TestCase:<New TestCase> > gettcparam Test
ThisIsSomeStringValue
TestCase:<New TestCase> > save
TestCase:<New TestCase> > TestCase:<New TestCase> >
```

## TcShellCommandTests.SetNewTestConfigParameterWithDataType_dataType=PaSsWoRd.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam Test + PaSsWoRd = ThisIsSomeStringValue
TestCase:<New TestCase> > gettcparam Test
*****
TestCase:<New TestCase> > save
TestCase:<New TestCase> > TestCase:<New TestCase> >
```

## TcShellCommandTests.SetNewTestConfigParameterWithDataType_dataType=StRiNg.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam Test + StRiNg = ThisIsSomeStringValue
TestCase:<New TestCase> > gettcparam Test
ThisIsSomeStringValue
TestCase:<New TestCase> > save
TestCase:<New TestCase> > TestCase:<New TestCase> >
```

## TcShellCommandTests.SetNewTestConfigParameterWithInvalidDataType.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam Test + numeric = 439857349
Invalid datatype, must be string, password or boolean!
TestCase:<New TestCase> > gettcparam Test
TestCase:<New TestCase> > save
TestCase:<New TestCase> > TestCase:<New TestCase> >
```

## TcShellCommandTests.SetNewValueInheritedTcp.verified

```
﻿>TCShell.exe -workspace "{TempPath}TCShellCommandTests\Guid_1\Guid_1.tws"
TCProject:Guid_1 > cn TestCases
TCFolder:TestCases > settcparam tcp1 + password = my_secret
TCFolder:TestCases > settcparam tcp2 + string = hey
TCFolder:TestCases > settcparam tcp3 + boolean = true
TCFolder:TestCases > task "Create TestCase"
[#]='Create Folder'
[#]='Create Folder structure'
[#]='Create Virtual Folder'
[#]='Create TestCase'
[#]='Create Business TestCase'
[#]='Create TestStepLibrary'
[#]='Run in ScratchBook'
[#]='Search all not assigned Teststeps'
[#]='Search all not assigned Teststepvalues'
[#]='Search all disabled TestCase-Items'
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
[#]='Reset test configuration parameter tcp1'
[#]='Reset test configuration parameter tcp2'
[#]='Reset test configuration parameter tcp3'
[#]='Create Test configuration parameter'
[#]='Export Subset'
[#]='Attach File'
[#]='Show distribution by object type in local workspace'
[#]='Create Recovery Scenario Collection'
TestCase:<New TestCase> > settcparam tcp1 + password = secret
TestCase:<New TestCase> > settcparam tcp2 + string = ho
TestCase:<New TestCase> > settcparam tcp3 + boolean = false
TestCase:<New TestCase> > gettcparam tcp1
*****
TestCase:<New TestCase> > gettcparam tcp2
ho
TestCase:<New TestCase> > gettcparam tcp3
false
TestCase:<New TestCase> > cn ..
TCFolder:TestCases > gettcparam tcp1
*****
TCFolder:TestCases > gettcparam tcp2
hey
TCFolder:TestCases > gettcparam tcp3
true
TCFolder:TestCases > save
TCFolder:TestCases > TCFolder:TestCases >
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
    <ConnectionData>Ulid_1Ulid_2Ulid_3Ulid_4Ulid_58Ulid_6Ulid_7Ulid_89Ulid_99Ulid_10Ulid_1100000</ConnectionData>
    <DatabaseUser />
    <DatabasePwd />
    <DatabaseSchema />
  </CommonRepository>
  <DefaultUser>
    <UserName>TestAdmin</UserName>
    <UserSurrogate>Ulid_12</UserSurrogate>
  </DefaultUser>
  <TCWorkspaceID>Ulid_13</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_2</TCCommonRepositoryID>
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
  <TCWorkspaceID>Ulid_2</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_2</TCCommonRepositoryID>
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
  <TCWorkspaceID>Ulid_1</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_3</TCCommonRepositoryID>
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
  <TCWorkspaceID>Ulid_1</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_3</TCCommonRepositoryID>
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
  <TCWorkspaceID>Ulid_1</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_3</TCCommonRepositoryID>
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
  <TCWorkspaceID>Ulid_2</TCWorkspaceID>
  <TCCommonRepositoryID>Guid_2</TCCommonRepositoryID>
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
