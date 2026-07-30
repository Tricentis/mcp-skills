---
name: tosca-cloud-connect
description: >-
  Connects toscactl to Tosca Cloud — login, workspace selection, and connectivity check. Use when
  setting up toscactl, fixing auth errors, or before any other Tosca Cloud skill. For tn gap
  workflows only, also run configure_tn_connection.py. Does NOT cover direct IDE MCP.
license: Apache-2.0
metadata:
  author: Tricentis
  version: "1.0.0"
---

# Connect toscactl to Tosca Cloud

Configure **`toscactl`** for the user's tenant. Primary runtime for all non-gap journeys.

Install **toscactl** per your Tricentis distribution (must be on PATH).

## Setup checklist

```text
Connect Tosca Cloud (toscactl):
- [ ] Install toscactl on PATH
- [ ] toscactl login --url <tenant>.my.tricentis.com
- [ ] toscactl workspaces list / set
- [ ] python3 verify_toscactl.py succeeds
- [ ] Load tosca-cloud-basics, then task-specific skill
```

## toscactl (default)

```bash
toscactl login --url mytenant.my.tricentis.com
toscactl workspaces list --json --silent
toscactl workspaces set "My Workspace" --json --silent
toscactl config --json --silent
python3 verify_toscactl.py
```

Headless / CI: set `TOSCA_CLIENT_ID` and `TOSCA_CLIENT_SECRET`, or `toscactl login --headless`.

## Verify connectivity

| Result | Action |
|--------|--------|
| Workspace list in config | Proceed — load `tosca-cloud-basics` or task skill |
| Auth error | Re-run login; check tenant URL format |
| toscactl not found | Install toscactl per your Tricentis distribution; ensure it is on PATH |

## tn (gap workflows only)

Required before invoking gap skills (author, remediate, explain step tree, DI). See [runtime-routing.md](../tosca-cloud/runtime-routing.md).

```bash
python3 configure_tn_connection.py --tenant acme --space default --output ~/.tn/mcp.json
tn --setup
echo "Switch to /tosca mode and call tosca_organization_listWorkspaces" | tn
```

## Hand off

- Object model → `tosca-cloud-basics`
- Tool orchestration → `tosca-cloud` engineering skill
- Runtime choice → `runtime-routing.md`
