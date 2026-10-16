# Test sheet structure (TDM)

Test sheets model test data for template-based (data-driven) test cases. Read with `tosca_testsheet`, write with `tosca_testsheet_edit`. Both require the TestCaseDesign entitlement. Test sheets are not an `artifactType` of `tosca_asset` — find them with `tosca_testsheet` List.

## Sheet vs class

| Kind | What it is | Rows |
|------|------------|------|
| `testSheet` | Attribute tree + test case instances (rows) | yes |
| `class` | Reusable attribute block. Has one root attribute carrying the class name; renaming the class renames that root | no |

A sheet embeds a class as a `classReference` node (`ClassReferenceAdd`). Nodes **inside** a reference belong to the class: edit the class, not the sheet. Only row values, child-instance assignments and `ClassReferenceDetach` cross the reference. `ClassReferenceDetach` turns the reference into local attributes; `ConvertToClass` turns a first-level attribute of a sheet into a new class and references it.

## Nodes, paths and ids

- `nodeType`: `group` | `attribute` | `classReference`.
- `path` is dotted, exactly as `tosca_testsheet` Get returns it (`Customer.Tier`). Paths in a class include its root name. Attribute names can't contain `.`.
- Ids: sheet/class `TD-…`, attribute `TDA-…`, instance `TDI-…`, row `TCI-…`. Inside a class reference, attribute ids are `~` chains (`TDA-…~TDA-…`).
- Every `_edit` target takes **exactly one** of id or path/name. Prefer ids from the latest Get when names are ambiguous.

## Instances

`{ name, value, kind, isStraightThrough }`

- `value` defaults to `name` on create; renaming keeps the value.
- `kind`: `instance` (default) or `freetext`. All instances of one attribute share one kind.
- `isStraightThrough` marks the default / happy-path value. Setting it clears it on sibling instances unless the tenant allows several.

## Business relevance

`relevant` | `notRelevant` | `result` (expected outcome). A new child attribute inherits its parent's relevance. A group only accepts children whose relevance fits it.

## Instance hierarchy

`AssignChildInstance` makes an instance of a parent attribute select an instance of a descendant attribute (e.g. `Country=DE` → `Currency=EUR`). `UnassignChildInstance` removes that selection for one child attribute.

## Rows (test case instances)

- `GenerateRows` with `algorithm` `linearExpansion` or `orthogonal`. `preview` defaults to **true** (nothing saved). `preview: false` **appends** — existing rows are never replaced; generated names that already exist are listed in `skipped[]`.
- `RowUpsert`: `rows[{ rowId?, name?, values{ "Customer.Tier": "Gold" } }]`. Without `rowId` creates (name required); with `rowId` merges the given values into the row. `null` clears a cell. Max 1000 rows per call. Partial failures come back in `failed[]`.
- A sheet holds at most **1000 rows in total** (stored plus generated). Before `GenerateRows` `preview: false` on a large sheet, compare the preview count with `total` and tell the user if it would exceed the limit.
- `RowDelete`: `rowIds[]`.
- To *replace* rows: `RowDelete` (confirm) then `GenerateRows`.
- Row `id` = the `testSheetInstanceId` for `tosca_requirement_edit` LinkTestSheet.

## Downstream impact

| Change | Breaks |
|--------|--------|
| Rename / delete / move an attribute | Templates (`tosca_testcasetemplate` `testSheetId`) resolve `{XL[…]}` placeholders and instantiation conditions **by path** |
| Rename / delete a row | Test cases generated from linked templates are matched **by row name** and are orphaned; requirement links to the row are lost |
| Delete a sheet | A linked template can no longer be instantiated |
| Delete and recreate a sheet | Templates and requirements store the old id — never do this to work around an error |

## Feature flags

Some operations follow the TDM editor's tenant flags (reusable classes, free-text values, instance hierarchy, moving attributes, business relevance). A gated call fails with "… is not enabled for this tenant". Tell the user; don't retry another way.

## Limits and known behaviours

- Names 1–255 characters; duplicate names at one level are rejected.
- Max 1000 rows per sheet (stored plus generated).
- Max 50 nested levels. A tree deeper than about 30 levels can't be sent in one `Upsert` — build it in several `AttributeUpsert` calls.
- `ConvertToClass` with a `name` renames the attribute to the class name (its path changes); without `name` the path is kept.
- A class referenced only by another class can be deleted without `force` (TDM counts referencing test sheets only).
- Last writer wins — there is no locking. Get again before a follow-up change if the user may also be editing.
