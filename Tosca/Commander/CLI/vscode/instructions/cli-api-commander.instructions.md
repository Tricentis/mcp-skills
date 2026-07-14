---
applyTo: "**/*.tcs"
---

# TCShell script conventions

When editing or generating `.tcs` batch scripts for Tosca Commander, load the **cli-api-commander** skill (`/cli-api-commander`).

- One command per line; batch mode is non-interactive.
- Always call `save` before `exit` in batch scripts.
- Use workspace-relative paths when possible.
- Prefer `-auth` or `-login` via environment variables — never hard-code credentials.
- If workspace is **locked**, read `workspace-checkout.md` in the skill before running.

For full command reference, read the cli-api-commander skill `reference/commands.md`.
