# Create / edit test case

Create an automated test case from existing modules (Tosca Cloud: design test case after modules exist).

**Parameter bible:** [testcase-structure.md](../testcase-structure.md) — TCP hierarchy (tenant → workspace → case), folders, Move/Delete, `values[]`, recipes.  
**Standard modules:** [standard-modules.md](../standard-modules.md).

```text
Create test case:
- [ ] tosca_module Search + Get (attribute paths)
- [ ] Decide structure: flat steps vs folders vs control flow (if/while/do); TCPs / parameterSetIds
- [ ] tosca_testcase_edit Upsert (name + optional tcp/steps)
- [ ] tosca_teststep_edit for folders / nested steps / Move
- [ ] tosca_testcase Get (verify items[] + tcp[])
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_module` Search | name substring, `scope` | Module id(s) |
| 2 | `tosca_module` Get | `moduleId` | Attribute paths for required ExactlyOne attrs |
| 3 | `tosca_testcase_edit` Upsert | `name`, optional `tcp[]`, `parameterSetIds`, `steps[]` | New `testCaseId` + portal url |
| 4 | `tosca_teststep_edit` Upsert | `testStepContainerId` (the new test case id), folders (`kind=testStepFolder`) then steps with `parentId` | Nested structure |
| 5 | `tosca_testcase` Get | `testCaseId` | Tree + merged tcp[] verified |

## Structure examples

**Flat + TCP**

```
tosca_testcase_edit Upsert {
  name: "Smoke/Wait",
  tcp: [{ name: "Browser", value: "Chrome", dataType: "String" }],
  steps: [{ moduleId: "<wait>", values: [{ path: "Duration", value: "1000" }] }]
}
```

**Nested folders**

```
1. Upsert TC name only (empty shell)
2. teststep_edit Upsert kind=testStepFolder name=Login parentId=<tcId>
3. teststep_edit Upsert kind=testStep moduleId=… parentId=<loginFolderId> values=…
4. teststep_edit Upsert kind=testStepFolder name=Checkout parentId=<tcId>
5. Get → items[] show parentFolderId + index
```

**Conditional / loop** — see [testcase-structure.md → Control flow](../testcase-structure.md#control-flow--if--while--do--else-tosca_teststep_edit)

```
1. teststep_edit Upsert kind=if name="If logged in" includeElse=true parentId=<tcId>
   → items[] rows kind=controlFlowCondition: Condition / THEN / ELSE ids
2. teststep_edit Upsert kind=testStep moduleId=… parentId=<Condition id> values=[{…, actionMode: "Verify"}]
3. teststep_edit Upsert kind=testStep moduleId=… parentId=<THEN id> / <ELSE id>
4. Loops: kind=while|do maximumRepetitions="5" (or "{CP[MaxRetries]}"); fill Loop + Condition branches
```

**Password TCP shell** — `{ name: "Pwd", dataType: "Password" }` (no value); set secret in portal via `url`.

## Notes

- Update metadata with `tosca_testcase_edit`; never pass `steps[]` on update — use `tosca_teststep_edit`.
- `tcp=[]` / `parameterSetIds=[]` clears those lists.
- Inventory folders ≠ in-test-case folders.
- Prove executable: [trial-run-testcase.md](trial-run-testcase.md).

Journey skill: `tosca-authoring-automated-testcase`.
