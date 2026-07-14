# Connect Tosca Cloud MCP

Help the user connect Cursor to their **hosted** Tosca Cloud MCP server (not TAIS, not local Commander).

## Steps

1. Ask for **tenant name** (e.g. `acme` from `https://acme.my.tricentis.com`) and **space id** (default `default`).
2. Run from Tosca.Cloud.MCP.integration repo:

```bash
python3 scripts/configure_mcp_connection.py --tenant <tenant> --space <space> --env prod --output ~/.cursor/mcp.json
```

On Windows use `%USERPROFILE%\.cursor\mcp.json` for `--output`.

3. Tell the user to **reload Cursor** and open **Settings → MCP** — enable **tosca-cloud**.
4. On first use, complete **Okta** in the browser when `mcp-remote` opens the login flow.
5. Verify: call `tosca_organization_listWorkspaces`.
6. Load skill **tosca-cloud-basics**, then the task skill from `AGENTS.md`.

## Do not

- Route through TAIS or chatbot delegation.
- Use `my-dev` URLs unless the user is on an internal dev tenant.
- Ask the user to paste JWTs into chat.

## Reference

Skill: `tosca-cloud-connect` · Workflow: `tosca-cloud-mcp/reference/workflows/connect-tenant.md`
