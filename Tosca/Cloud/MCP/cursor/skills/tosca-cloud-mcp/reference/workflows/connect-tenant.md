# Connect tenant — hosted Tosca Cloud MCP

Configure the IDE for **direct** connection to the tenant's cloud-hosted MCP server.

```text
Connect tenant:
- [ ] configure_mcp_connection.py (tenant, space, env)
- [ ] Reload IDE / enable tosca-cloud MCP
- [ ] Okta login on first use
- [ ] tosca_organization_listWorkspaces
```

## Plan

| Step | Action | Expected |
|------|--------|----------|
| 1 | Resolve `tenant` from portal URL (`acme` from `acme.my.tricentis.com`) | Lowercase tenant slug |
| 2 | Confirm `spaceId` with user (default `default`) | Space segment in MCP URL |
| 3 | Run `python3 scripts/configure_mcp_connection.py --tenant … --space … --output ~/.cursor/mcp.json` | `mcp.json` with `mcp-remote` → hosted URL |
| 4 | User reloads IDE; completes Okta on first MCP session | Green MCP status |
| 5 | `tosca_organization_listWorkspaces` | Workspace list |

## Production URL

```text
https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp
```

Internal dev only: `my-dev.tricentis.com`. Staging: `my-test.tricentis.com`.

Hand off to `tosca-cloud-basics` after step 5 succeeds.
