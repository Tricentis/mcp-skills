# DI DB Expert test case

A **DI DB Expert test case is generated from the Standard Object `DI DB Expert module`**. Search that module, Get it, then create the test case from its `moduleId`. There is no `tosca_dataintegrity_createDiDbExpertTestcase` tool — do not call it.

This is not a row-by-row comparison. For source-vs-target compare use [01-row-by-row-comparison.md](../di/workflows/01-row-by-row-comparison.md).

```text
DI DB Expert (from Standard Object):
- [ ] tosca_diconnection List (connection name for the Connection attribute)
- [ ] tosca_module Search name="DI DB Expert module" scope=StandardObjects
- [ ] tosca_module Get
- [ ] tosca_testcase_edit Upsert — generate the test case from that moduleId
- [ ] tosca_testcase Get
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_diconnection` List | — | Connection **name** for the step (not the Ulid) |
| 2 | `tosca_module` Search | `name`: `DI DB Expert module`, `scope`: `StandardObjects` | Hit whose **name is exactly** `DI DB Expert module`. Not generic Database-pack `DB Expert`. |
| 3 | `tosca_module` Get | `moduleId` from Search | Attribute paths. Never hardcode the id. |
| 4 | `tosca_testcase_edit` Upsert | `name` + `steps[{ moduleId, values }]` | Test case **generated from** that Standard Object |
| 5 | `tosca_testcase` Get | `testCaseId` | One step from `DI DB Expert module`; Connection / SQL Statement set |

## Create example

`Connection` is ExactlyOne (must set). `SQL Statement` should be set when the user has SQL. After Get, use paths from the module:

```
tosca_testcase_edit Upsert {
  name: "DI DB Expert - <purpose>",
  steps: [{
    moduleId: "<id of Standard Object DI DB Expert module>",
    values: [
      { path: "Connection", value: "<connectionName from tosca_diconnection List>" },
      { path: "SQL Statement", value: "<sql>" }
    ]
  }]
}
```

Never pass a password or connection string. `Connection` is the DI connection **name**. If no usable connection exists, follow [di-connection.md](di-connection.md), then resume at List.

Optional run only if the user asked: [trial-run-testcase.md](trial-run-testcase.md).
