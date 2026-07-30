# TCShell CLI Flags & Startup Examples

> Commander version: 24.1 (Tosca Commander 24.1)


> **Agent navigation:** Do **not** load this entire file (~400 lines). Use [cli-from-source.md](cli-from-source.md) for CLI flags from TCShell source.
## Startup samples



-workspace "D:\TOSCA_Workspaces\TCShellSample\TCShellSample.tws" -login Admin "" "..\..\Sample2\Report.tcs"

-workspace "D:\TOSCA_Workspaces\TCShellSample\TCShellSample.tws" 

-workspace "C:\TOSCA_Workspaces\Tosca Tutorial\Tosca Tutorial.tws" "..\..\Tests\Manuellen TestCase anlegen.tcs"

-workspace "C:\TOSCA_Workspaces\Tosca Tutorial\Tosca Tutorial.tws" "..\..\Tests\Manuellen TestCase anlegen.tcs" -waitforcompacting

-workspace "D:\TOSCA_Workspaces\TCShellSample\TCShellSample.tws" -login Admin "" "..\..\Sample2\InstantiateRun.tcs" "..\..\Sample2\Report.tcs"

-workspace "D:\TOSCA_Workspaces\TCShellSample\TCShellSample.tws" -record "..\..\Record\Record.tcs"

-workspace "C:\TOSCA_Workspaces\Tosca Tutorial\Tosca Tutorial.tws" "..\..\Tests\Manuellen TestCase anlegen.tcs" -record "..\..\Tests\Manuelle TestCase anlegen.rec"

..\..\bin\Debug\TCShell -workspace "C:\TOSCA_Workspaces\Tosca Tutorial\Tosca Tutorial.tws" -record "Record.tcs"

-help 

-newworkspace "D:\playground\Oracle\Oracle_WS10" "Oracle" "dbserver2/XE" "TC" "TC"

-newworkspace "D:\TOSCA_Workspaces\SQLSever_WS1" "MS SQL Server" "Server=DBSERVER;Database=WhoTest;Uid=TC;Pwd=TC;" 

-workspace "D:\TOSCA_Workspaces\SQLite_DtBoerse\SQLite_DtBoerse.tws" -login "Admin" "" "D:\dev\trunk\csharp\TCCore\TCShell\Samples\CreateNewWorkspace\restoreDtBoerse.tcs"



## Readme (CLI section)


1. TCShell Commandline-Options:
===============================

 -help  			
	... show all possible Options

 -workspace <workspacePath> 	
	... MANDATORY: Path to the Workspace-File ("...\Name.tws")

 -login <username> <password>	
	... OPTIONAL: Login-Info, otherwise username and password are requested interactive (on demand)
	              
 -record <recordScriptPath>
	... OPTIONAL: Name of the script to record to

 { <tcscriptPath> }		
	... OPTIONAL: any number of TCShell-Script-Files, otherwise TCShell will start in INTERACTIVE-Mode

 -codepage <codepageNum> 
	... OPTIONAL: codepage to use for Console-Input and -Output (e.g. "850" for german characters if not set as default)

 -waitforcompacting
	... OPTIONAL: Tosca Commander is waiting for finishing compacting the TC workspace. Without applying this command Tosca Commander terminates the background compacting.

If no Script-File is provided TCShell will start in INTERACTIVE-Mode
In this mode the user gets special support on what commands are possible, what arguments are required ("?") and
finds the requested Information in the Command-Prompt

Alternative TCShell offers the possibility to create new Workspaces

-newworkspace <newWorkspaceDirPath> SQLITE [<commonRepoPath>] 
	.. if <commonRepoPath> is missing, a Singleuser-Workspace will be created

For different DB-Types (e.g. "Oracle","MS SQL Server","DB2") the following possibilities are supported:
-newworkspace <newWorkspaceDirPath> <dbRepoType> <datasource> <user> <password> 
 or
-newworkspace <newWorkspaceDirPath> <dbRepoType> <datasource> <user> <password> <schema> 
  or
-newworkspace <newWorkspaceDirPath> <dbRepoType> <connectionString> 
  or
-newworkspace <newWorkspaceDirPath> <dbRepoType> <connectionString> <schema>
DB-Type is the same name you find in the NewWorkspace-Wizard 


2. TCShell Syntax:
==================

(1) TCShell Commands are not case-sensitiv,  'JumpTo' und 'jumpto' are identical.

(2) Double Quotes (") can be used as Token-seperator, when WhiteSpaces (Space, Tab, NewLine) are used in the Tokens
 e.g.. > JumpToNode "/TestCaseFolder/Mustertestf�lle/Automatisierte Testf�lle"
or 
 e.g.. > Set Name = "This is
a multiline description 
to a \"manual\" Testcase "

(3) Backslash ("\") is used a Escape-Character, when Double Quotes 
or the Escape-Character itself is part of the Toke  

 e.g. > Search "->Items:TestCase[Name==\"TF1\"]" 1

(4) Comments start with "//" and tag the comment for the rest of the line

 
3. TCShell Commands:
==================

Command: 'Help' oder '?'
*******

Get the List of all possible commands


Command: 'Exit'
*******

Exit the current TCShell-Session. This is only relevant in INTERACTIVE-Mode.
If there are unsaved changes, the user will be asked to store the changes or 
exit anyway.

Command: 'Save'
*******

Save all changes made so far.

3.1. Current Object:
-----------------------

In a TCShell-Session there is always one current (active) object.
After opening a Workspace the Project-Object becomes the Current-Object
Also when the current object has been deleted the Project-Object becomes the Current-Object

To navigate (jump) to other Objects, the following commands are supported:

Command: 'JumpToProject'
*******

The Project-Object becomes the new Current-Object

Command: 'JumpToNode <NodePath>'
*******

Alle Objects have a NodePath-Property, which includes all the hirarchical positions (see Property-View in Tosca Commander).
With this command an Object can be selected by his NodePath and becomes the new Current Object

 e.g. > JumpToNode "/TestCaseFolder/Mustertestf�lle/Automatisierte Testf�lle"
makes the specified Folder the Current Object


Command: 'JumpTo <uniqueQueryString>'
*******

<uniqueQueryString> ist any TQL-QueryString, which returns exactly one Object 
  e.g. starting from the Project-Object search a TestCas with a specific name
		 "=>Items:TestCase[Name==\"TF1\"]"
  e.g. starting from TestStepValue jump to his TestStep
		 "->TestStep"

After this Command the Search-Result becomes the new Current Object

Command: 'ChangeNode ".."'
********

Change to Parent-Object in the NodePath-Hierarchy

z.B: Current-Object is "/TestCaseFolder/Folder/Subfolder"
> ChangeNode ".." 
switches to the Folder with NodePath "/TestCaseFolder/Folder"

Command: 'ChangeNode <RelativeNodePath>'
********

Change to a Object by specifying a relative NodePath from the Current Object

z.B: Current Object is "/TestCaseFolder/Folder/Subfolder"
> ChangeNode "TestCase/TestStep" 
changes to TestStep with NodePath "/TestCaseFolder/Folder/Subfolder/TestCase/TestStep"

z.B: Current Object is "/TestCaseFolder/Folder/Subfolder"
> ChangeNode "../OtherSubfolder" 
changes to another Folder with NodePath "/TestCaseFolder/Folder/OtherSubfolder"

Command: 'ChangeNode <AbsoluteNodePath>'
********

same as JumpToNode

Command:  'Search <queryString> <resultNum>'
********

This command is only usefull in INTERACTIVE-Mode when the user wants to select an object of a list of objects specified by a TQL-Query.

<querString> is any TQL-QueryString
<resultNum> is the number of the object shown in the resultlist or '0' when Current Object should not be changed.

Command:  'Print'
********

Print all Information (all Attributes and all Assiciations to other Objects) to the Current Object

Command: 'Get <attributeName>'
*******

Returns the Value of the specified Attribute. 
For ExtendableObjects also the value of a TCObjectProperty with that name can be retrieved with this statement 
For ObjectMaps and ObjectControls also the value of a ObectMapParam with that name can be retrieved with this statement 

Command: 'Set <attributeName> ["="] <attributeValue>'
*******

Change the Value of the specified Attributes unless it is changeable and change-rights allow this
For ExtendableObjects ObjectProperties can be changed (see "Get"-Command)
For ObjectMaps and ObjectControls ObjectMapParams can be changed (see "Get"-Command)

The Symbol "=" to express the assignment is optional (only "snytactic sugar")!


3.2 Marking Objects und Drag&Drop-Tasks
-----------------------------------------

For some Operatoins (e.g. Drop-Tasks) any number of Objects can be used als Arguments.
e.g. to move a set of TestCases from one Folder to an other.
This Operations are perfomed in Tosca Commander via Drag&Drop-operations.
To support all these operations also in TCShell Commands to mark and unmark specific objects and
to activate Drop-Task are provided

Command: 'Mark'
*******

The Current Object is added to the List of marked Objects

Command: 'ClearMarked'
*******

The list of marked Objects is cleared

Command: 'DropMarked'
*******

The spcified Drop-Task is applied to the Current Object, the List of marked Objects is used as the set of dropped Objects.
After this the list of marked Objects is cleared:

e.g. "Create 3 new TestSteps in a TestCase based on 3 existing Modules" 


> JumpToNode "/Modules/T Angebotsrechner"
> Mark
> JumpToNode "/Modules/T Fahrzeugdaten"
> Mark
> JumpToNode "/Modules/T Personendaten"
> Mark
> JumpToNode "/TestCaseFolder/Tutorial/Automatisierte Testf�lle/MyTestCase"
> DropMarked


3.3. Executing Tasks
------------------------

All in Tosca Commander via the Context-Menu of an Object provided Operations (=Tasks) 
can be executed in TCShell by the "Task"-Command


Command: 'Task <taskNum>' oder 'Task <taskName>'
*******

Task can be selected by an Index (usefull only in INTERACTIVE-Mode) or by the name of
the Task (as displayed in the GUI-Menue)

e.g. to create a TemplateInstance to a TestCase-Template 
	> 'Task "Create Template Instance" '

Tasks can require additional Decisions or Input form the User.
e.g. a File- or Directory-Path, a Strings, Confirmations ,...

In INTERACTIVE-Mode this requested information is shown with a prompt 
In BATCH-Mode this information must be provided in the script 

e.g. creating a TemplateInstance to a TestCase-Template 
 
> jumpToNode "/TestCaseFolder/Mustertestf�lle/Generierte Testf�lle/CheckKFZVers"
> task "Create Template Instance"
> // *** Input to "Create Template Instance"-Taks
> // DataSourcePath including Sheet =
> "C:\\Projects\\Tosca Tutorial\\BO_TF\\TF_Katalog_Web.xls\\TF_RS"
> // Instantiation Selector =
> "The first 10" 
> // Start instantiation later (not yet)
no
> // *** End of Input to "Create Template Instance"-Taks

3.4. Calling other Scripts
---------------------------

To modularize scripts TCShell offers the possibility to use different Script-Files and call
Scripts from within Scripts

Command: 'Call <scriptPath>'
*******

The ScriptPath can be priveded in an absolut oder relative way.
The relative specification is relative to the calling script.
The Current Object is not changed and is the same as before calling the Script.

3.5. Iterations
-----------------------------

to apply Operations to sets of Objects, the following commands are provided

Command: 'For <queryString> CallOnEach <scriptPath>'
*******

For every Object in the result-List of the Query, the specified Script will be called
The Object in the Result-List becomes the Current Object before calling the script


Command: 'For <queryString> MarkAll'
*******

All Objects in the result set will be added to the list of marked objects (see "Mark"-Command)


Command: 'For <queryString> TaskOnEach <taskName>'
*******

For every Object in the Result-List of the Query, the specified Task will be executed
The Object in the Result-List becomes the Current Object before calling the task

Command: 'For <queryString> TaskOnAll <taskName>'
*******

The specified Taks will be executed with all objects in the result-list selected.
This is only possible for MultiSelectable-Tasks

e.g. Disable many TestSteps be poviding the same Reason for all
>  For "=>Items:TestStep[Name==\"Pr�mie berechnen\"]" TaskOnAll "Disable"
> // Disable-Reason for all
> "Module is under construction"


3.6. MultiUser-Activities
-----------------------

In a MultiUser-Project Objects need to be checked out before changes can be applied 
and need to be checked in to make the changes available to other users on the same project

Command: 'CheckInAll'
*******

All checked out Objects by this User in this Workspace are checked in to the Common-Repository

Command: 'UpdateAll'
*******

The Workspace is updated to the latest information in the Common-Repository


3.7. Admin-Operatoins
-----------------------

Some operations are only available to Users which are members of Admin-Usergroups.
To activate and deactivate the Admin-Modus the following commands are provided.

Command: 'AdminModusOn'
*******

Command: 'AdminModusOff'
*******

ATTENTION: These commands are only available if the logged in user is a member of an Admin-Usergroup!

3.8. Undo/Redo
-----------------------

For INTERACTIVE Mode Undu-/Redo-Operations are also priveded in TCShell

Command: 'ShowUndoList'
*******

Displays all Entries in the Undo-List (like in the drop-down-list in the GUI)

Command: 'Undo <numSteps>'
*******

Undoes the last <numSteps> changes

Command: 'Redo <numSteps>'
*******

Redoes the <numSteps> changes

3.9. Options
-------------

Some Options that can be changed in the Options-Dialog in the GUI need to be changed (temporarily) also in TCShell.
Therefore the following commands are provided.

IMPORTANT: Options changed and saved by TCShell have no influence on the Options in the GUI (and reverse).
    TCShell and GUI have separate Settings..


Command: 'GetAllOptions'
*******

Output alle Options with its current Values


Command: 'GetOption <optionName>'
*******

Output only the Value of a specific Option  <optionName>


Command: 'SetOption <optionName> ["="] <optionValue>'
*******

Change the Option to a new value
ATTENTION: With this operation the change is only temporarliy for the TCShell-Session,
you need to save it explicitly (see below)

Command: 'SaveOptions'
*******

Saves all current Option-Values for future calls of TCShell.
ATTENTION: This Settings are stored in User-Settings of TCShell (in a user-specific Directory, e.g. "C:\Documents and Settings\<user>\....\TCShell..\user.config")





