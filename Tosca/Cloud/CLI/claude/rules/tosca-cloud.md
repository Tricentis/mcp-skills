---
description: Route Tosca Cloud work through toscactl (default) and tn for CLI gaps.
globs:
alwaysApply: false
---

When the user works with Tosca Cloud, use **toscactl** by default via **tosca-cloud** skill and journey skills in AGENTS.md. Use **tn** only for documented CLI gaps — see `runtime-routing.md`. Run `verify_toscactl.py` before default automation; run `Get-TnCloudPaths.py` before tn gap workflows. Do not call MCP tools directly unless user explicitly uses Tosca.Cloud.MCP.integration.
