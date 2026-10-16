# Manage test sheet

Create and edit Tosca Cloud test sheets and classes (Test Data Management): attributes, instances, class references, instance hierarchy and rows. Concepts and downstream impact: [testsheet-structure.md](../testsheet-structure.md).

```text
Test sheet (write):
- [ ] tosca_testsheet List / Get (before any change — resolve ids and paths)
- [ ] Confirm with the user when the operation is on the confirmation list below
- [ ] Only the operation the user asked for
- [ ] Check the returned sheet / rows (structural writes return the re-read sheet)
- [ ] Surface the portal url
```

## Fork

| User / situation | Tools | Then |
|------------------|-------|------|
| Create a sheet with attributes | `tosca_testsheet_edit` Upsert — no sheet id, `name`, `attributes[]` tree in **one** call | Result is the new sheet; on failure the empty sheet is rolled back |
| Create a class | Upsert `kind: class` | Its root attribute carries the class name |
| Rename sheet / change description | Get → Upsert with `testSheetId` + `name` / `description` | Renaming a class renames its root |
| Add an attribute | Get → AttributeUpsert (`name`, `parentPath?`, `instances[]?`) | Child inherits parent relevance |
| Rename an attribute | Get → **confirm** → AttributeUpsert `attributePath` + `name` | Templates using the old path stop resolving |
| Move an attribute | Get → AttributeUpsert `attributePath` + `parentPath` (empty = root) | Path changes — same template impact as rename |
| Delete an attribute | Get → **confirm** → AttributeDelete | Removes children, instances and row cells |
| Add / change an instance | InstanceUpsert (`attributePath`, `name`, `value?`, `isStraightThrough?`, `instanceKind?`) | `value` defaults to `name` |
| Delete an instance | InstanceDelete (`attributePath`, `instanceName`) | — |
| Reuse a class | ClassReferenceAdd (`className`, `parentPath?`) | Nodes inside are read-only here |
| Unlink a class reference | **confirm** → ClassReferenceDetach (`attributePath` of the reference) | Becomes local attributes |
| Extract a class | **confirm** → ConvertToClass (first-level `attributePath`, `name?`) | With `name` the attribute is renamed |
| Instance hierarchy | AssignChildInstance / UnassignChildInstance (parent attribute + instance, child attribute + instance) | — |
| Generate rows | GenerateRows `algorithm` (preview) → show → GenerateRows `preview: false` | Appends; duplicates in `skipped[]` |
| Edit rows | RowUpsert `rows[]` (rename → **confirm**) | Merges values; partial failures in `failed[]` |
| Delete rows | ListInstances → **confirm** → RowDelete `rowIds[]` | Requirement links to those rows are lost |
| Delete a sheet | **confirm** → Delete | — |
| Delete a class | Delete → if `deleted: false`, show `references[]` → **confirm** → Delete `force: true` | Referencing sheets get local copies |

## Upsert tree (create)

```json
{
  "operation": "Upsert",
  "name": "Login data",
  "attributes": [
    { "name": "User", "instances": [
        { "name": "Admin", "isStraightThrough": true },
        { "name": "Guest" } ] },
    { "name": "Expected", "businessRelevance": "result",
      "instances": [ { "name": "Success" }, { "name": "Denied" } ] }
  ]
}
```

## Confirmation

Show the user the text and wait for a yes before calling:

| Operation | Text |
|-----------|------|
| Delete (sheet) | "The deletion is permanent. If the test sheet is linked to a test case template, you won't be able to instantiate the test case template again. Do you want to proceed?" |
| Delete (class, `force`) | "This converts all references to the class in the listed test sheets into local attributes and instances, then deletes the class. Changes to the class won't carry over to these test sheets. Do you want to proceed?" |
| AttributeDelete | "This also deletes its child attributes and instances and clears them from all test case instances. Test case templates that use this attribute path will stop resolving. Do you want to proceed?" |
| AttributeUpsert rename | "Renaming changes the attribute path. Test case templates that use the old path ({XL[…]} or instantiation conditions) will stop resolving. Do you want to proceed?" |
| RowDelete / RowUpsert rename | "Test cases generated from linked templates are matched by row name and will be orphaned; requirement links to these rows are lost. Rows: <names>. Do you want to proceed?" |
| ClassReferenceDetach / ConvertToClass | "This can't be undone through the MCP. Do you want to proceed?" |

## Rules

- Requires the TestCaseDesign entitlement; without it the tools are not offered.
- Get before every change; use paths exactly as Get returns them.
- Never delete and recreate a sheet to work around an error — templates and requirements store its id.
- Don't write inside a class reference — edit the class (`testSheetName` = the class) instead.
- `GenerateRows` never replaces rows. To replace: RowDelete (confirm), then GenerateRows.
- A "… is not enabled for this tenant" error is a tenant flag — report it, don't work around it.
- Build trees deeper than about 30 levels in several calls.

Use with [inspect-testsheet.md](inspect-testsheet.md) for reads.
