# Connect tenant — hosted Tosca Cloud MCP

The user connects the IDE to their tenant's hosted MCP server. This pack does **not** write MCP config files.

```text
Connect tenant:
- [ ] Skills installed
- [ ] User added MCP server URL in IDE Settings
- [ ] User signed in when IDE prompted
- [ ] tosca_organization_listWorkspaces
```

## Plan

| Step | Action | Expected |
|------|--------|----------|
| 1 | Resolve `tenant` from portal URL (`acme` from `acme.my.tricentis.com`) | Lowercase tenant slug |
| 2 | Confirm `spaceId` with user (default `default`) | Space segment in MCP URL |
| 3 | User adds server in **Settings → MCP** with production URL below | IDE shows server entry |
| 4 | User reloads IDE; completes sign-in on first MCP session | Green MCP status |
| 5 | `tosca_organization_listWorkspaces` | Workspace list |

## Production URL

```text
https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp
```

Staging: `my-test.tricentis.com`. Internal dev only: `my-dev.tricentis.com`.

Hand off to `tosca-cloud-basics` after step 5 succeeds.
