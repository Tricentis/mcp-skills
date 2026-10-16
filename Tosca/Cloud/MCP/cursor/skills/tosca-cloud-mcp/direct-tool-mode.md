# Direct tool mode — one MCP call per step

Use when the IDE exposes MCP tools but **no code execution sandbox**. Same orchestration rules as Code Mode — different execution surface.

Copy and track progress:

```text
Direct tool mode:
- [ ] Read when-to-use-mcp.md and intent orchestration doc
- [ ] Draft numbered plan table (all steps before step 1)
- [ ] Execute one tool per agent turn
- [ ] Replan on error — do not retry blindly
- [ ] Verify with a read tool after mutations
```

## Plan table template

| Step | Tool | Args (summary) | Expected |
|------|------|----------------|----------|
| 1 | `tosca_asset` Search | `artifactType`, `name` | Matching artifacts (`id`, `type`) |
| 2 | … | … | … |

## Rules

1. **Discover before mutate** — always Search/Get before create/update/delete.
2. **One domain focus per plan** — authoring, playlist, inventory, or DI; avoid mixing without reason.
3. **Poll async tools** — `tosca_testrun` / `tosca_playlistrun` Get until terminal; DI `check*Result` companions.
4. **Personal agent** — if Create returns `agentLink` / `needsAgent`, open the link and Create again.
5. **Destructive tools** — confirm with user before Delete / hardCancel.
6. **Cloud persistence model** — mutations persist via API immediately; no checkout or save step.
7. **Never invent module attribute paths** — Get the module first.
8. **Never ask for or echo secrets** — see [safety-and-space.md](../tosca-cloud-basics/references/safety-and-space.md#secrets) for the scoped exception.

## Related

- [code-mode.md](code-mode.md) — preferred when code execution is available
- [tool-orchestration.md](tool-orchestration.md) — per-tool guidance
