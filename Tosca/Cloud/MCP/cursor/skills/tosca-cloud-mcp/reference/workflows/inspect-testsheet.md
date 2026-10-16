# Inspect test sheet

Find and read Tosca Cloud test sheets (Test Data Management): attribute tree, instances, straight-through values and generated rows. Read-only. Concepts: [testsheet-structure.md](../testsheet-structure.md).

```text
Test sheet (read):
- [ ] tosca_testsheet List (name contains-filter; includeClasses when looking for a class)
- [ ] tosca_testsheet Get (one sheet: tree, instances, portal url)
- [ ] tosca_testsheet ListInstances (only when rows are needed; page with nextPageToken)
- [ ] Surface the portal url from Get
```

## Fork

| User / situation | Tools | Then |
|------------------|-------|------|
| "Which test sheets do we have?" | `tosca_testsheet` List | Stop, or Get the one the user picks |
| Explain a sheet | List → Get (`testSheetId`) | Summarize attributes by path, instances, straight-through, class references |
| Sheet behind a template | `tosca_testcasetemplate` Get → `testSheetId` → `tosca_testsheet` Get | Relate `{XL[…]}` / `xlBasePath` to attribute paths |
| Show the rows | Get → ListInstances (`pageSize` ≤200) | Keep paging until `nextPageToken` is null |
| Map rows to a requirement | ListInstances → pick rows → confirm → `tosca_requirement_edit` LinkTestSheet | Row `id` = `testSheetInstanceId` |
| Find a class | List `includeClasses: true` → Get | Classes have no rows |

## Reading the Get result

| Field | Meaning |
|-------|---------|
| `attributes[].path` | Dotted path — use it verbatim for `_edit` and row values |
| `nodeType` | `group` \| `attribute` \| `classReference` (`referencedClass` names the class) |
| `businessRelevance` | `relevant` \| `notRelevant` \| `result` |
| `instances[].isStraightThrough` | Present only when true — the default / happy-path value |
| `folderPath` | Omitted for sheets at the root |

## Rules

- Requires the TestCaseDesign entitlement; without it the tools are not offered.
- `tosca_asset` does not search test sheets — use `tosca_testsheet` List.
- Name lookups are exact and case-insensitive on Get; List's name is a contains-filter.
- Don't write while inspecting. Hand edits to [manage-testsheet.md](manage-testsheet.md).

Use with [manage-testsheet.md](manage-testsheet.md) for edits.
