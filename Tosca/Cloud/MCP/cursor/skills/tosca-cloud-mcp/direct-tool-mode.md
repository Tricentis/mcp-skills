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
| 1 | `tosca_organization_listWorkspaces` | — | Workspace list |
| 2 | `tosca_inventory_search` | `artifactType`, `artifactName` | Matching artifacts |
| 3 | … | … | … |

## Rules

1. **Discover before mutate** — always search before create/update/delete.
2. **One domain focus per plan** — inventory, playlist, builder, or DI; avoid mixing without reason.
3. **Poll async tools** — DI schema/test-connection and some execution reads need follow-up check tools.
4. **Destructive tools** — confirm with user when `Destructive=true` in catalog.
5. **Cloud persistence model** — mutations persist via API immediately; no checkout or save step.

## Related

- [code-mode.md](code-mode.md) — preferred when code execution is available
- [tool-orchestration.md](tool-orchestration.md) — per-tool guidance
