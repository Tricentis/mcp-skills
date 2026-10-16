# Trial run test case

Personal-agent debug run — same as the Builder **Run** button (Tosca Cloud trial runs).

```text
Trial run:
- [ ] tosca_testcase Get (optional verify)
- [ ] tosca_testrun_edit Create
- [ ] Open agentLink if returned; Create again
- [ ] tosca_testrun Get until terminal
```

## Plan

| Step | Tool | Args | Expected |
|------|------|------|----------|
| 1 | `tosca_testrun_edit` Create | `testCaseId`, optional `testStepIds[]` | `testRunId` **or** `needsAgent` + `agentLink` only |
| 2 | *(agent)* | Open `agentLink` if present | Personal agent registers |
| 3 | `tosca_testrun_edit` Create | same `testCaseId` | `testRunId` |
| 4 | `tosca_testrun` Get | `testRunId` | Poll until succeeded/failed/canceled |
| 5 | *(read)* | terminal payload | `portalUrl`, `testSteps`, `attachments[]` |

## Notes

- Optional: share `portalUrl` (results page) with the user. Fetch `attachments[]` when diagnosing or fixing a failure.
- Personal agent only — not a playlist/team run.
- Cheap fixture: TBox Wait Duration=1000.
- Find a run: `tosca_testrun` List (`name` contains, `state`, pagination). Hits include `personal=true/false`.
- Delete run: `tosca_testrun_edit` Delete — confirm first.
- For batch / scheduled runs → [run-playlist.md](run-playlist.md).
