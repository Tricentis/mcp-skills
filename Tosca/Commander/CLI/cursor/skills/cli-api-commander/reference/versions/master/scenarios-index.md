# TCShell scenarios — verified output index

> Commander version context: **master**
> Generated at: 2026-06-25T21:10:13Z

Maps unit-test golden outputs to agent scenarios. Pick one scenario below, then search `output-patterns.md` for the matching `## FixtureName` section only — do not load the entire file.

## Scenarios available for this version

| Scenario | Test fixture | Category |
|----------|--------------|----------|
| Change existing TCP datatype | `TcShellCommandTests.ChangeExistingConfigParameterDataType.verified` | Commands / TCP |
| Check out object tree | `TcShellCommandTests.CheckOutTree.verified` | Commands / TCP |
| Multiple invalid TCP datatypes (error case) | `TcShellCommandTests.MultipleWrongTcpDatatypes.verified` | Commands / TCP |
| Overwrite parent TCP datatype | `TcShellCommandTests.OverwriteDataTypeOfParentTcp.verified` | Commands / TCP |
| Overwrite inherited TCP datatype | `TcShellCommandTests.OverwriteDatatypeOfInheritedTcp.verified` | Commands / TCP |
| Inspect XModule via `print` | `TcShellCommandTests.PrintXModule.verified` | Commands / TCP |
| Run `Help` / script assistance output | `TcShellCommandTests.RunScriptHelp.verified` | Commands / TCP |
| Create test case and navigate by node path | `TcShellCommandTests.SetNewTestCaseAndJumpToItByNodePath.verified` | Commands / TCP |
| Create test configuration parameter (TCP) | `TcShellCommandTests.SetNewTestConfigParameter.verified` | Commands / TCP |
| TCP with invalid datatype (error case) | `TcShellCommandTests.SetNewTestConfigParameterInvalidDataType.verified` | Commands / TCP |
| Create TCP (short syntax) | `TcShellCommandTests.SetNewTestConfigParameterShortVersion.verified` | Commands / TCP |
| Create TCP with Boolean datatype | `TcShellCommandTests.SetNewTestConfigParameterWithDataType_dataType=BoOlEaN.verified` | Commands / TCP |
| Create TCP with Password datatype | `TcShellCommandTests.SetNewTestConfigParameterWithDataType_dataType=PaSsWoRd.verified` | Commands / TCP |
| Create TCP with String datatype | `TcShellCommandTests.SetNewTestConfigParameterWithDataType_dataType=StRiNg.verified` | Commands / TCP |
| TCP invalid datatype variant | `TcShellCommandTests.SetNewTestConfigParameterWithInvalidDataType.verified` | Commands / TCP |
| Set value on inherited TCP | `TcShellCommandTests.SetNewValueInheritedTcp.verified` | Commands / TCP |
| Multi-user WS + new common repository | `TcShellWorkspaceCreationTests.NewMultiUserWorkspaceAndNewCommonRepository.verified` | Workspace creation |
| SQL Server repo missing admin (fail) | `TcShellWorkspaceCreationTests.NewMultiUserWorkspace_And_NewSqlServerCommonRepository_MissingFirstAdmin_Fails.verified` | Workspace creation |
| Multi-user WS + SQL Server repo | `TcShellWorkspaceCreationTests.NewMultiUserWorkspace_And_NewSqlServerCommonRepository_WithFirstAdmin.verified` | Workspace creation |
| Multi-user WS missing first admin (fail) | `TcShellWorkspaceCreationTests.NewMultiUserWorkspace_And_NewSqliteCommonRepository_MissingFirstAdmin_Fails.verified` | Workspace creation |
| Multi-user WS + SQLite repo + first admin | `TcShellWorkspaceCreationTests.NewMultiUserWorkspace_And_NewSqliteCommonRepository_WithFirstAdmin.verified` | Workspace creation |
| Multi-user WS with existing SQLite repo | `TcShellWorkspaceCreationTests.NewMultiUserWorkspace_WithExistingSqliteCommonRepository.verified` | Workspace creation |
| Existing repo arbitrary db path | `TcShellWorkspaceCreationTests.NewMultiUserWorkspace_WithExistingSqliteCommonRepository_WithArbitraryDbFilePath.verified` | Workspace creation |
| Existing repo with .db path | `TcShellWorkspaceCreationTests.NewMultiUserWorkspace_WithExistingSqliteCommonRepository_WithDbFileEnding.verified` | Workspace creation |
| New repo path missing admin (fail) | `TcShellWorkspaceCreationTests.NewMultiUserWorkspace_WithNewSqliteCommonRepository_WithArbitraryDbFilePath_MissingFirstAdmin_Fails.verified` | Workspace creation |
| New repo arbitrary path + admin | `TcShellWorkspaceCreationTests.NewMultiUserWorkspace_WithNewSqliteCommonRepository_WithArbitraryDbFilePath_WithFirstAdmin.verified` | Workspace creation |
| Create SQLite single-user workspace | `TcShellWorkspaceCreationTests.NewSqliteSingleUserWorkspace.verified` | Workspace creation |
| Single-user WS on existing path (fail) | `TcShellWorkspaceCreationTests.NewSqliteSingleUserWorkspace_OnExistingWorkspace_Fails.verified` | Workspace creation |
| Verify single-user workspace structure | `TcShellWorkspaceCreationTests.NewSqliteSingleUserWorkspace_VerifyStructure.verified` | Workspace creation |
| Single-user WS invalid path (fail) | `TcShellWorkspaceCreationTests.NewSqliteSingleUserWorkspace_WithInvalidPath_Fails.verified` | Workspace creation |

## Scenario availability by Commander version

| Scenario | 24.1 | 24.2 | 25.1 | 26.1 | master |
|----------|---|---|---|---|---|
| Change existing TCP datatype | — | — | — | yes | yes |
| Check out object tree | — | — | — | yes | yes |
| Multiple invalid TCP datatypes (error case) | — | — | — | yes | yes |
| Overwrite parent TCP datatype | — | — | — | yes | yes |
| Overwrite inherited TCP datatype | — | — | — | yes | yes |
| Inspect XModule via `print` | — | — | yes | yes | yes |
| Run `Help` / script assistance output | — | — | — | yes | yes |
| Create test case and navigate by node path | — | — | — | yes | yes |
| Create test configuration parameter (TCP) | — | — | — | yes | yes |
| TCP with invalid datatype (error case) | — | — | — | yes | yes |
| Create TCP (short syntax) | — | — | — | yes | yes |
| Create TCP with Boolean datatype | — | — | — | yes | yes |
| Create TCP with Password datatype | — | — | — | yes | yes |
| Create TCP with String datatype | — | — | — | yes | yes |
| TCP invalid datatype variant | — | — | — | yes | yes |
| Set value on inherited TCP | — | — | — | yes | yes |
| Multi-user WS + new common repository | — | — | yes | yes | yes |
| SQL Server repo missing admin (fail) | — | — | yes | yes | yes |
| Multi-user WS + SQL Server repo | — | — | yes | yes | yes |
| Multi-user WS missing first admin (fail) | — | — | yes | yes | yes |
| Multi-user WS + SQLite repo + first admin | — | — | yes | yes | yes |
| Multi-user WS with existing SQLite repo | — | — | yes | yes | yes |
| Existing repo arbitrary db path | — | — | yes | yes | yes |
| Existing repo with .db path | — | — | yes | yes | yes |
| New repo path missing admin (fail) | — | — | yes | yes | yes |
| New repo arbitrary path + admin | — | — | yes | yes | yes |
| Create SQLite single-user workspace | — | — | yes | yes | yes |
| Single-user WS on existing path (fail) | — | — | yes | yes | yes |
| Verify single-user workspace structure | — | — | yes | yes | yes |
| Single-user WS invalid path (fail) | — | — | yes | yes | yes |

## See also

- Expected output text: [output-patterns.md](output-patterns.md) — search one `## FixtureName` section only
