# Connect Tosca Cloud MCP

Help the user connect Cursor to their **hosted** Tosca Cloud MCP server (not TAIS, not local Commander).

## Steps

1. Confirm **skills are installed** (plugin, installer, or manual copy). This pack does not configure MCP.
2. Ask for **tenant name** (e.g. `acme` from `https://acme.my.tricentis.com`) and **space id** (default `default`).
3. Guide the user: **Settings → MCP → Add server** with URL:

   `https://{tenant}.my.tricentis.com/{space}/_mcp/api/mcp`

4. User **reloads Cursor** and completes **sign-in** when the IDE opens the browser.
5. Verify: call `tosca_organization_listWorkspaces`.
6. Load skill **tosca-cloud-basics**, then the task skill from `AGENTS.md`.

## Do not

- Generate or merge `mcp.json` with scripts from this pack.
- Route through TAIS or chatbot delegation.
- Use `my-dev` URLs unless the user is on an internal dev tenant.
- Ask the user to paste JWTs into chat.

## Reference

Skill: `tosca-cloud-connect` · Workflow: `tosca-cloud-mcp/reference/workflows/connect-tenant.md`
