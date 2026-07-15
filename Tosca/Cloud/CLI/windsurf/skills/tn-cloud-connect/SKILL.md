---
name: tn-cloud-connect
description: >-
  Connects TN CLI to hosted Tosca Cloud MCP for a tenant — mcp.json, AI provider setup,
  and first connectivity check via /tosca. Use when setting up tn, fixing 401 errors,
  or before any other TN Cloud skill. Does NOT cover direct IDE MCP (use Tosca.Cloud.MCP.integration).
license: LicenseRef-Tricentis-Internal
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Connect TN to Tosca Cloud

Configure **`tn`** (Tricentis TN CLI) for the user's tenant. TN uses **native HTTP OAuth** — no Node.js or `mcp-remote`.

## Hosted endpoint

```text
https://{tenant}.my.tricentis.com/{spaceId}/_mcp/api/mcp
```

| Environment | Host pattern |
|---------------|--------------|
| Production (default) | `{tenant}.my.tricentis.com` |
| Staging | `{tenant}.my-test.tricentis.com` |
| Internal dev | `{tenant}.my-dev.tricentis.com` |

## Setup checklist

```text
Connect TN Cloud:
- [ ] Install tn on PATH (dotnet tool, release binary, or dotnet run)
- [ ] Know tenant name and space id
- [ ] Run configure_tn_connection.py
- [ ] Run tn --setup for AI provider
- [ ] Verify: echo "/tosca then list workspaces" | tn
- [ ] Load tn-cloud-basics, then task-specific skill
```

## Configure connection

```bash
python3 scripts/configure_tn_connection.py \
  --tenant acme \
  --space default \
  --env prod \
  --output ~/.tn/mcp.json
```

Windows:

```powershell
python scripts/configure_tn_connection.py --tenant acme --output "$env:USERPROFILE\.tn\mcp.json"
```

Then:

```bash
tn --setup
```

## Verify connectivity

```bash
echo "Switch to /tosca mode and call tosca_organization_listWorkspaces" | tn
```

| Result | Action |
|--------|--------|
| Workspace list returned | Proceed — load `tn-cloud-basics` or task skill |
| 401 / unauthorized | Re-run tn; complete Okta in browser when prompted |
| tn not found | Install from Tricentis-UX/tn repo or release |

## IDE agent pattern

Outer IDE agent runs configure script + verification command in terminal. Does **not** call MCP tools directly — delegates to tn.

## Hand off

- Object model → `tn-cloud-basics`
- Tool orchestration → `tn-cloud` engineering skill
- Direct IDE MCP → **Tosca.Cloud.MCP.integration** (sibling repo)
