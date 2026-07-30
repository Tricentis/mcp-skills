---
name: tosca-cloud-connect
description: >-
  Verifies hosted Tosca Cloud MCP connectivity and routes to the right Cloud skills.
  Use when the user is setting up Cloud MCP, fixing 401 errors, or before other Tosca Cloud skills.
  Does NOT configure MCP servers — the user adds their tenant in IDE Settings -> MCP.
license: Apache-2.0
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Connect Tosca Cloud MCP

This skill pack **installs agent skills only**. Connecting to Tosca Cloud MCP works like any IDE plugin: the **user** (or IT) adds their tenant server in **Settings → MCP**. The IDE handles authentication on first use.

## Hosted endpoint (user-supplied)

Production URL pattern:

```text
https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp
```

| Environment | Host pattern |
|---------------|--------------|
| Production (default) | `{tenant}.my.tricentis.com` |
| Staging | `{tenant}.my-test.tricentis.com` |
| Internal dev | `{tenant}.my-dev.tricentis.com` |

`tenant` is the slug from the Tosca Cloud portal (`acme` from `https://acme.my.tricentis.com`). Confirm `spaceId` with the user (often `default`).

## Setup checklist

```text
Connect Tosca Cloud MCP:
- [ ] Skills installed (marketplace plugin, zip/git installer, or manual copy)
- [ ] User added MCP server in IDE Settings with their tenant URL
- [ ] User completed browser sign-in when IDE prompted
- [ ] Verify: tosca_organization_listWorkspaces
- [ ] Load tosca-cloud-basics, then task-specific skill
```

## Configure in Cursor (user action)

1. **Settings → MCP → Add server** (or edit an existing Tosca Cloud entry).
2. Set the server URL to the tenant pattern above (include `spaceId` in the path).
3. **Reload** Cursor if needed.
4. On first connect, complete **Okta / SSO** in the browser when the IDE opens it.

Do **not** run scripts to generate `mcp.json` on the user's machine unless IT explicitly requires it — this pack does not ship connection automation.

## Verify connectivity

After the user connects in IDE settings:

```
tosca_organization_listWorkspaces
```

| Result | Action |
|--------|--------|
| Workspace list returned | Proceed — load `tosca-cloud-basics` or task skill |
| 401 / unauthorized | User re-authenticates via Settings → MCP (toggle off/on or re-add server) |
| Connection refused | Confirm URL, space id, network/VPN with user |
| Empty workspaces | Confirm space id with user |

## Navigating many MCP tools

After connect, do **not** load the full tool catalog at once.

| User goal | Start here |
|-----------|------------|
| First time in Cloud | `tosca-cloud-basics` |
| Find artifacts | `tosca-cloud-mcp` → search-artifacts workflow |
| Run / diagnose playlist | `tosca-analyzing-execution-results` |
| Author test case | `tosca-authoring-manual-testcase` or `tosca-authoring-automated-testcase` |
| Raw tool order / Code Mode | `tosca-cloud-mcp` engineering skill |
| Data Integrity | `tosca_dataintegrity_workflow` first, then one DI reference file |

## Security

- Never paste JWTs or refresh tokens into chat.
- OAuth tokens stay in the IDE MCP client — not in this skill pack.
- Destructive tools still require user confirmation per `AGENTS.md`.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Wrong tenant in URL | User updates MCP server URL in IDE settings |
| OAuth fails | Retry sign-in from Settings → MCP; check corporate browser/SSO policy |
| Tools missing | Check product entitlements; some tools are license-gated |

## Related

- `tosca-cloud-mcp/reference/workflows/connect-tenant.md` — step-by-step for agents
- `tosca-cloud-mcp/when-to-use-mcp.md` — readiness after connect
