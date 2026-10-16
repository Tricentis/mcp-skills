# Connect tenant — hosted Tosca Cloud MCP

The user connects the IDE to their tenant's hosted MCP server. This pack does **not** write MCP config files.

```text
Connect tenant:
- [ ] Skills installed
- [ ] User added MCP server URL in the host (IDE Settings, VS Code MCP: Add Server, or Copilot CLI `copilot mcp add`)
- [ ] User signed in when prompted (`/mcp auth` in Copilot CLI if status is needs-auth)
- [ ] tosca_module Search
```

## Plan

| Step | Action | Expected |
|------|--------|----------|
| 1 | Resolve `tenant` from portal URL (`acme` from `acme.my.tricentis.com`) | Lowercase tenant slug |
| 2 | Confirm `spaceId` with user (default `default`) | Space segment in MCP URL |
| 3 | User adds HTTP MCP server with production URL below (Cursor/Claude/VS Code settings, or `copilot mcp add --transport http tosca-cloud <url>`) | Host shows server entry |
| 4 | User reloads / completes sign-in (`/mcp auth tosca-cloud` in Copilot CLI if needed) | Authenticated MCP session |
| 5 | `tosca_module` Search | Modules in the URL space |

## Production URL

```text
https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp
```

Staging: `my-test.tricentis.com`. Internal dev only: `my-dev.tricentis.com`.

Hand off to `tosca-cloud-basics` after step 5 succeeds.
