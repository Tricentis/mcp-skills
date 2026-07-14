# Run execution list

TCShell sequence to execute an execution list and optionally create a report.

```text
Run execution list:
- [ ] JumpToNode — open execution list
- [ ] task "Run"
- [ ] save
- [ ] (optional) task "Create Execution Report"
```

## Plan

| Step | Command | Expected |
|------|---------|----------|
| 1 | `JumpToNode "/Execution/.../MyExecutionList"` | ExecutionList is current |
| 2 | `task "Run"` | Execution starts (may be long-running) |
| 3 | `save` | Persist run metadata |
| 4 | `task "Create Execution Report"` | Optional; prompts for detail level |

## Sample script

```
jumpToNode "/ExecutionListFolder/MyEL"
task "Run"
save
```

## Related samples

See [examples-catalog.md](../examples-catalog.md) → `Samples/Templates/` (`InstantiateRun.tcs`, `Report.tcs`).

## Notes

- `Run` applies to `ExecutionList` or `ExecutionEntry` objects.
- Long runs may time out in IDE terminal — consider splitting plan or running outside the agent session.
- For template instantiation before run, see `Samples/Templates/Instantiate.tcs` in [examples-index.md](../examples-index.md).
