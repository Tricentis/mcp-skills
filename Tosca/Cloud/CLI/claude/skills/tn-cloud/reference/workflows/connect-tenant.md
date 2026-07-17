# Connect tenant — TN CLI

Configure **`tn`** for hosted Tosca Cloud MCP with native HTTP OAuth.

```text
Connect tenant:
- [ ] configure_tn_connection.py (tenant, space, env)
- [ ] tn --setup (AI provider)
- [ ] echo "/tosca" | tn — OAuth on first tool use
- [ ] tosca_organization_listWorkspaces via tn
```

## Plan

| Step | Action | Expected |
|------|--------|----------|
| 1 | Resolve `tenant` from portal URL | Lowercase tenant slug |
| 2 | Confirm `spaceId` (default `default`) | Space in MCP URL |
| 3 | `python3 configure_tn_connection.py --tenant … --output ~/.tn/mcp.json` | `tosca` server entry |
| 4 | `tn --setup` | `~/.tn/appsettings.json` |
| 5 | `echo "/tosca then list workspaces" \| tn` | Workspace list |

## Production URL

```text
https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp
```

Hand off to `tn-cloud-basics` after step 5 succeeds.
