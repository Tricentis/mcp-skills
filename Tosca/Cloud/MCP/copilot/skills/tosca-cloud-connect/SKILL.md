---
name: tosca-cloud-connect
description: >-
  Verifies hosted Tosca Cloud MCP connectivity and routes to the right Cloud skills.
  Use when the user is setting up Cloud MCP, fixing 401 errors, or before other Tosca Cloud skills.
  Does NOT configure MCP servers — the user adds their tenant in the host (IDE settings or Copilot CLI `copilot mcp add`).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Henry Fieglein | Fractal
  version: "1.16.0"
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
- [ ] User added MCP server (IDE settings or Copilot CLI `copilot mcp add`) with their tenant URL
- [ ] User completed browser sign-in when IDE prompted
- [ ] Verify: tosca_module Search
- [ ] Load tosca-cloud-basics, then task-specific skill
```

## Configure MCP (user action)

Do **not** run scripts to generate MCP config on the user's machine unless IT explicitly requires it — this pack does not ship connection automation.

### Cursor

1. **Settings → MCP → Add server** (or edit an existing Tosca Cloud entry).
2. Set the server URL to the tenant pattern above (include `spaceId` in the path).
3. **Reload** Cursor if needed.
4. On first connect, complete **Okta / SSO** in the browser when the IDE opens it.

### Claude Code

1. Add the same tenant URL in Claude Code MCP settings.
2. Reload Claude Code; complete sign-in when prompted.

### GitHub Copilot CLI

1. `copilot mcp add --transport http tosca-cloud "https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp"`
2. Start `copilot`. If the server shows `needs-auth`, run `/mcp auth tosca-cloud`.
3. Confirm skills with `copilot skill list` or `/skills info tosca-cloud-connect`.

Copilot CLI reads `~/.copilot/mcp-config.json` (`mcpServers`). It does **not** read `.vscode/mcp.json`.

### VS Code Copilot Chat

1. Command Palette → **MCP: Add Server** (HTTP) with the tenant URL.
2. Reload the window; complete Okta sign-in when prompted.

Personal skills live in `~/.copilot/skills` (shared with Copilot CLI). Workspace skills live in `.github/skills`.

## Verify connectivity

After the user connects in IDE settings:

```
tosca_module Search
```

| Result | Action |
|--------|--------|
| Search result returned | Proceed — load `tosca-cloud-basics` or task skill |
| 401 / unauthorized | User re-authenticates via Settings → MCP (toggle off/on or re-add server) |
| Connection refused | Confirm URL, space id, network/VPN with user |
| Error | Confirm space id with user |

## Navigating many MCP tools

After connect, do **not** load the full tool catalog at once.

| User goal | Start here |
|-----------|------------|
| First time in Cloud | `tosca-cloud-basics` |
| Find artifacts | `tosca-cloud-mcp` → search-artifacts workflow |
| Run / diagnose playlist | `tosca-analyzing-execution-results` |
| Author test case | `tosca-authoring-manual-testcase` or `tosca-authoring-automated-testcase` |
| Raw tool order / Code Mode | `tosca-cloud-mcp` engineering skill |
| Data Integrity | `tosca-cloud-mcp` → `di-orchestration.md`, then one DI reference file |

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
