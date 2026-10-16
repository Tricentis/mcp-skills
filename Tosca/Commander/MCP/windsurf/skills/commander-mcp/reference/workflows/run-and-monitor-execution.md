# Run and monitor an execution

Start a scratchbook validation or an execution-list run, poll it to completion, and read the durable result.

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `(input)` | target + how many runs | `TestCase` or `TestStep` → scratchbook. `ExecutionList`, `ExecutionEntryFolder`, `ExecutionEntry`, or `TestEvent` → list run. **Only one run at a time, workspace-wide** |
| 2 | `get_object_info` | target path or id | Confirm the type before choosing arguments |
| 3 | `save_workspace` | — | A run executes the current workspace state; unsaved edits are not included |
| 4 | `execute_test_suite` | Scratchbook: `test_case_id` + `is_validation_run=true`. List or event: `execution_list_id` + `is_validation_run=false` | `{ jobId, errorMessage }`. `errorMessage` set → **not started** (pre-validation failed, or another run in progress) → stop and report; do not retry blindly |
| 5 | `execute_test_suite_status` | `jobId` | `{ jobFound, isRunning, nextPollInSeconds, result }`. `isRunning=true` → the server already waited `nextPollInSeconds` — **call again immediately**. `jobFound=false` → id unknown or discarded — **not** a failure and **not** a test result |
| 6 | `get_object_info` + `get_attributes` | `references.ActualExecutionLog` on the list | Durable outcome. Polled `result.logs` are the run rows. For a `TestEvent`, `result.message` says the event was only enqueued and those rows are the last known logs, not the remote run |
| 7 | `execute_task` | Exact `Archive actual ExecutionLog` name from `list_available_tasks`, **between** repeat runs on the same list | The next run replaces `ActualExecutionLog`. Archive it (or read its aggregates) before starting the next, or the earlier run is gone. Then loop 4→7 **sequentially** |

## Notes

- Step 5 is a tight silent loop — one call, read, call again. Client-side sleeps and backoff are
  wrong; the server paces it. **Ask the user nothing until `isRunning=false`.**
- Scratchbook (`is_validation_run=true`) runs a `TestCase` or `TestStep` and returns per-step
  pass/fail. A list run (`is_validation_run=false`) returns one row per `ExecutionEntry`.
- A long run can hit the MCP request timeout while Commander is still working — treat a timeout
  as **unknown**, verify via `references.ActualExecutionLog`, and do **not** start a second run.
- Report: per run, pass/fail/NotExecuted counts + duration, then the cross-run trend. Diagnose
  failures with [analyze-execution-results.md](analyze-execution-results.md); a run that stopped
  early with [diagnose-incomplete-run.md](diagnose-incomplete-run.md).
