---
name: tosca-cloud-connect
description: >-
  Connects the IDE to hosted Tosca Cloud MCP for a tenant — tenant URL, space, Okta login,
  and first connectivity check. Use when setting up Tosca Cloud MCP, fixing 401 errors,
  or before any other Tosca Cloud skill. Does NOT cover TAIS chatbot delegation.
license: LicenseRef-Tricentis-Internal
metadata:
  author: Tricentis
  version: "0.1.0"
---

# Connect Tosca Cloud MCP

Direct IDE connection to the **hosted** MCP server for the user's tenant. No local MCPServer process for customers.

## Hosted endpoint

```text
https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp
```

| Environment | Host pattern |
|---------------|--------------|
| Production (default) | `{tenant}.my.tricentis.com` |
| Staging | `{tenant}.my-test.tricentis.com` |
| Internal dev | `{tenant}.my-dev.tricentis.com` |

`tenant` is the name before `.my.tricentis.com` (same as the Tosca Cloud portal URL).

## Setup checklist

```text
Connect Tosca Cloud MCP:
- [ ] Know tenant name and space id
- [ ] Run configure_mcp_connection.py or install Cursor pack
- [ ] Enable tosca-cloud MCP in IDE settings
- [ ] Complete Okta browser login on first connect
- [ ] Verify: tosca_organization_listWorkspaces
- [ ] Load tosca-cloud-basics, then task-specific skill
```

## Configure connection

From **Tosca.Cloud.MCP.integration** repo:

```bash
python3 scripts/configure_mcp_connection.py \
  --tenant acme \
  --space default \
  --env prod \
  --output ~/.cursor/mcp.json
```

Or interactive (prompts for tenant):

```bash
python3 scripts/configure_mcp_connection.py --output ~/.cursor/mcp.json
```

Windows (Cursor user profile):

```powershell
python scripts/configure_mcp_connection.py --tenant acme --output "$env:USERPROFILE\.cursor\mcp.json"
```

Reload Cursor after saving `mcp.json`. First MCP use opens **Okta** via `mcp-remote` loopback OAuth.

## Verify connectivity

Call once after login or when tools fail with 401:

```
tosca_organization_listWorkspaces
```

| Result | Action |
|--------|--------|
| Workspace list returned | Proceed — load `tosca-cloud-basics` or task skill |
| 401 / unauthorized | Re-authenticate: toggle MCP off/on in settings or re-run configure |
| Connection refused | Check `mcp.json` URL matches tenant + space; confirm network/VPN if required |
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

Engineering skill routes by domain: inventory → playlist → builder → DI. Journey skills handle user stories.

## Security

- Never paste JWTs or refresh tokens into chat.
- OAuth tokens are managed by `mcp-remote` / the IDE MCP layer.
- Destructive tools still require user confirmation per `AGENTS.md`.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Wrong tenant in URL | Re-run configure with correct tenant or full portal URL |
| OAuth loop fails | Ensure loopback port `56874` is free; retry in browser |
| Tools missing | Check product entitlements; some tools are license-gated |

## Related

- Repo `docs/installation.md` — full install matrix
- `tosca-cloud-mcp/when-to-use-mcp.md` — readiness after connect
