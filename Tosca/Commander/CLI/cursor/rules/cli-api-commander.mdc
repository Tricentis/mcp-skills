---
description: >-
  Route Tosca Commander automation through the cli-api-commander skill
  (/cli-api-commander). Use for TCShell.exe, .tcs batch scripts, JumpToNode, TCAPI,
  workspace locked, checkout, checkinall, batch mode, .tws, execution lists, or GUI RC.
  Does NOT cover Data Integrity or in-process Commander automation.
alwaysApply: false
---

# Tosca Commander automation

When automating Tosca Commander locally:

1. Invoke the **cli-api-commander** skill (`/cli-api-commander`).
2. Run path detection — **`Get-CommanderAutomationPaths.ps1` or `.py`**, whichever executes; if neither runs, use the skill manual checklist. Read **`Runtimes`** before choosing hosts.
3. If `UserPromptRequired`, ask the user before proceeding.
4. **Headless TCShell** via cmd/batch when workspace unlocked — **no Python or PowerShell required**.
5. **TCAPI** only when `AvailableHosts` shows PowerShell or dotnet script.
6. **Remote Control** only when detection selects it, PowerShell is available, and user accepts GUI-attended work.

Architecture: **reference/architecture.md** in the cli-api-commander skill.
