# Workspace, checkout, and automation paths

Commander exposes **three different ways** to automate a workspace. They are **not interchangeable**. The agent must pick based on whether Commander GUI is open, multi-user checkout state, and whether UI navigation is acceptable.

## Contents

- [Workspace lock constraint](#the-core-constraint-one-workspace-lock-per-process)
- [Multi-user checkout](#multi-user-checkout-objects-may-not-be-editable)
- [Three automation paths](#three-automation-paths-compared)
- [Decision tree](#decision-tree-for-agents)
- [Quick checks](#quick-checks)
- [Source references](#source-references-tricentistoscacommander)
- [Summary routing](#summary-for-skill-routing)

## The core constraint: one workspace lock per process

Opening a workspace creates an **exclusive lock** on `{workspace}.tws.txt` (`WorkspaceLock` in `Tricentis.TCCore.Base`).

| Client | How it opens | Lock initiator |
|--------|--------------|----------------|
| Commander GUI | `Workspace.Open(...)` | `ToscaManual` |
| TCShell.exe | `CommandInterpreter.OpenWorkspace` | `TCShell` |
| TCAPI | `TCAPINativeWorkspace` | `TCAPI` |

If Commander already has the workspace open, **headless TCShell and TCAPI cannot open the same `.tws`** — they fail with:

> `Workspace locked by another process` (`UnableToLockRepositoryException`)

So: **you cannot run TCAPI/TCShell against the same workspace file while the user has it open in Commander.** Use **Remote Control** (GUI-attended, with user consent) or ask the user to **close Commander** for headless automation. **In-process Commander automation is not available via this skill.**

## Multi-user checkout (objects may not be editable)

In **multi-user** workspaces, objects must be **checked out** before modification.

| Signal | Meaning |
|--------|---------|
| `ChangesAllowed == false` | Object is read-only — checkout required (or checked out by another user) |
| `CheckOutState` | `New`, `CheckedIn`, `CheckedOut`, `Hijacked` |
| Task `Checkout` / `CheckoutTree` | Check out before edit |
| `CheckIn` / `CheckInAll` | Persist to common repository |

TCShell examples (supported Commander releases):

```
# After open on multi-user workspace — checkout project tree before import/modify
checkouttree
# ... work ...
checkinall
```

TCAPI equivalent: call `Checkout` / `Checkin` / `CheckInAll` on `TCObject` / `TCWorkspace`.

**Agent rule:** Before create/update/delete, verify `ChangesAllowed` or run checkout. If checkout fails, report that another user holds the object.

Single-user workspaces skip team checkout but still use `save`.

## Three automation paths compared

### 1. Headless TCShell / TCAPI (preferred for agents)

| | |
|--|--|
| **Process** | Separate (`TCShell.exe` or TCAPI host) |
| **Workspace** | Opens its own lock on `.tws` |
| **UI** | None — no GUI contention |
| **When** | Commander **closed**, or different workspace, or CI |
| **DLLs** | `TCShell.exe`, `TCAPI.dll`, `TCAPIObjects.dll` |

Best for unattended automation. Same task/command layer as Commander; no `JumpTo` UI sync.

### 2. Remote Control (legacy external control — use sparingly)

| | |
|--|--|
| **Process** | **Inside running Commander** |
| **Workspace** | Shared `IBusinessObjectScope` with GUI |
| **UI** | **Every navigation command syncs the GUI** (`RemoteCommandInterpreter.CurrentObjectChanged` → `JumpTo`) |
| **Contention** | `TakeControllFromUser` greys out UI; not designed for parallel human + agent work |
| **When** | User explicitly wants "automate what I see" and accepts UI takeover |
| **DLLs** | `RemoteControlObjects.dll`, `RemoteControlAddIn.dll` |

Remote Control was built for **external test tools driving Commander**, not for always-on IDE agents. Support concern is valid: **UI contention and navigation side effects**.

**Do not default to Remote Control for IDE agents.**

### 3. Commander in-process automation (26.1+ — not this skill)

| | |
|--|--|
| **Process** | Inside running Commander |
| **Workspace** | Same scope as GUI — **no second lock** |
| **Access** | In-process protocol (not shell/stdio) |

This path exists in the product but is **outside the scope of this skill**, which uses shell/stdio only (TCShell, TCAPI, Remote Control).

**Note:** For Commander-open scenarios within this skill:

1. Ask user to **close Commander** and use headless TCShell/TCAPI, or
2. Remote Control only with **explicit user consent** for GUI-attended scenarios.

There is **no stdio path** for in-process Commander automation in this pack.

## Decision tree for agents

Run **path detection** (`.ps1`, `.py`, or manual checklist) first — see [path-selection.md](path-selection.md). Summary:

```
Need to modify Commander workspace?
├─ Run path detection (workspace path if known)
├─ UserPromptRequired? → ask user (Choices from detection output)
├─ Workspace locked?
│  ├─ Headless TCShell / TCAPI unavailable
│  └─ Remote Control if started, else prompt: close Commander or start RC
├─ Workspace unlocked?
│  └─ Prefer Headless TCShell or TCAPI (prompt if both equally valid)
└─ Multi-user repo?
   └─ Checkout before edit; checkin when done
```

## Quick checks

**TCAPI — is object editable?**

```powershell
# After Connect-TcApi + Open-TcApiWorkspace
$project = Get-TcApiProject
$tc = (Search-TcApi -Start $project -Tql '=>SUBPARTS:TestCase[Name=="MyTC"]')[0]
# Reflection or typed: $tc.ChangesAllowed, CheckOutState
```

**TCShell — multi-user checkout**

```
JumpToNode "/TestCases/MyFolder/MyTestCase"
print
# If ChangesAllowed is false in output, run checkout task first
task "Checkout"
save
```

## Implementation references

| Topic | Location |
|-------|----------|
| Workspace lock | `commander/Data/Base/WorkspaceLock.cs` |
| TCAPI lock failure | `commander/API/TCAPINativeConnector/Objects/TCAPINativeWorkspace.cs` |
| Remote Control + JumpTo | `commander/TCAddIns/RemoteControlAddIn/CommandHandling/RemoteCommandInterpreter.cs` |
| RC UI takeover | `commander/TCAddIns/RemoteControlAddIn/Remoting/RemoteControl.cs` (`TakeControllFromUser`) |
| AI in-process automation | `commander/TCAddIns/AI/McpServerAddIn/` (out of scope for this skill) |
| Checkout in TCShell | TCShell `CheckOutTreeTask` (supported Commander releases) |
| `ChangesAllowed` | `commander/API/TCAPIObjects/Objects/TCObject.cs` |

## Summary for skill routing

| Scenario | Use |
|----------|-----|
| Batch / CI / Commander closed | **Headless TCShell** or **TCAPI** |
| Multi-user edits | **Checkout** → modify → **CheckIn/save** |
| Commander open, avoid UI fights | **Do not use Remote Control by default**; prefer closing Commander for headless |
| "Automate what I'm looking at" | Remote Control **only with user consent**; warn about UI sync |
| Data Integrity | **Not available** via this skill |
