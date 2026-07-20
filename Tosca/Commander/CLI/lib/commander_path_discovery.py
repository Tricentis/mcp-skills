"""
Shared Commander automation path discovery.

Used by Get-CommanderAutomationPaths.py and Get-CommanderAutomationPaths.ps1
(parallel implementations). Agents may also apply the manual checklist in
path-selection.md when no detector script runs.
"""

from __future__ import annotations

import json
import os
import platform
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any

from commander_version import (
    SUPPORTED_VERSION_KEYS,
    get_skill_reference_path,
    get_tcapi_host_availability,
    load_commander_versions_manifest,
    resolve_commander_version_key,
)


def is_windows() -> bool:
    return platform.system() == "Windows" or os.environ.get("OS") == "Windows_NT"


def read_tcshell_ide_env() -> dict[str, str]:
    result: dict[str, str] = {}
    profile = os.environ.get("USERPROFILE") or os.environ.get("HOME")
    if not profile:
        return result
    for name in (".tricentis/tcshell-ide.env", ".tricentis\\tcshell-ide.env"):
        path = Path(profile) / name
        if not path.is_file():
            continue
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            m = re.match(r"^(COMMANDER_HOME|COMMANDER_VERSION|TOSCA_WORKSPACE)=(.+)$", line.strip())
            if m:
                result[m.group(1)] = m.group(2).strip()
    return result


def resolve_commander_home(explicit: str | None = None) -> str | None:
    ide = read_tcshell_ide_env()
    for candidate in (
        explicit,
        os.environ.get("COMMANDER_HOME"),
        ide.get("COMMANDER_HOME"),
    ):
        if candidate and Path(candidate).is_dir():
            return str(Path(candidate).resolve())

    candidates: list[Path] = []
    for root in (
        os.environ.get("ProgramFiles"),
        os.environ.get("ProgramFiles(x86)"),
    ):
        if not root:
            continue
        tricentis = Path(root) / "Tricentis"
        if tricentis.is_dir():
            candidates.extend(p for p in tricentis.iterdir() if p.is_dir())
    candidates.extend(
        [
            Path(r"C:\Program Files\Tricentis\Tosca Commander"),
            Path(r"C:\Program Files\Tricentis\ToscaCommander"),
            Path(r"C:\Program Files (x86)\Tricentis\ToscaCommander"),
        ]
    )
    seen: set[str] = set()
    for path in candidates:
        key = str(path).lower()
        if key in seen:
            continue
        seen.add(key)
        if (path / "TCShell" / "TCShell.exe").is_file() or (path / "TCAPI.dll").is_file():
            return str(path.resolve())
    return None


def resolve_workspace(explicit: str | None = None) -> str | None:
    ide = read_tcshell_ide_env()
    for candidate in (explicit, os.environ.get("TOSCA_WORKSPACE"), ide.get("TOSCA_WORKSPACE")):
        if candidate:
            return candidate.strip()
    return None


def get_tcshell_path(commander_home: str | None) -> str | None:
    if not commander_home:
        return None
    direct = Path(commander_home) / "TCShell" / "TCShell.exe"
    if direct.is_file():
        return str(direct)
    for candidate in (
        Path(r"C:\Program Files\Tricentis\Tosca Commander\TCShell\TCShell.exe"),
        Path(r"C:\Program Files\Tricentis\ToscaCommander\TCShell\TCShell.exe"),
        Path(r"C:\Program Files (x86)\Tricentis\ToscaCommander\TCShell\TCShell.exe"),
    ):
        if candidate.is_file():
            return str(candidate)
    return None


def get_workspace_lock_status(workspace: str | None) -> dict[str, Any]:
    if not workspace:
        return {"Checked": False, "Locked": False, "Holder": None, "LockFile": None}
    ws = Path(workspace)
    if not ws.is_file():
        return {
            "Checked": True,
            "Locked": False,
            "Holder": None,
            "LockFile": None,
            "Reason": f"Workspace file not found: {workspace}",
        }
    lock_file = Path(f"{workspace}.txt")
    if not lock_file.is_file():
        return {"Checked": True, "Locked": False, "Holder": None, "LockFile": str(lock_file)}
    try:
        holder = lock_file.read_text(encoding="utf-8", errors="replace").strip()
    except OSError:
        holder = None
    return {
        "Checked": True,
        "Locked": bool(holder),
        "Holder": holder or None,
        "LockFile": str(lock_file),
    }


def _which(name: str) -> str | None:
    return shutil.which(name)


def _run_version(exe: str, args: list[str]) -> str | None:
    try:
        proc = subprocess.run(
            [exe, *args],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        out = (proc.stdout or proc.stderr or "").strip()
        return out.splitlines()[0] if out else None
    except (OSError, subprocess.TimeoutExpired):
        return None


def detect_runtimes() -> dict[str, Any]:
    cmd_exe = None
    if is_windows():
        system_root = os.environ.get("SystemRoot", r"C:\Windows")
        candidate = Path(system_root) / "System32" / "cmd.exe"
        if candidate.is_file():
            cmd_exe = str(candidate)
        else:
            cmd_exe = _which("cmd")

    pwsh = _which("pwsh")
    powershell = _which("powershell")
    win_ps = None
    if is_windows():
        system_root = os.environ.get("SystemRoot", r"C:\Windows")
        candidate = Path(system_root) / "System32" / "WindowsPowerShell" / "v1.0" / "powershell.exe"
        if candidate.is_file():
            win_ps = str(candidate)

    dotnet = _which("dotnet")
    dotnet_script = False
    dotnet_version = _run_version(dotnet, ["--version"]) if dotnet else None
    desktop_runtimes: list[str] = []
    if dotnet:
        try:
            proc = subprocess.run(
                [dotnet, "script", "--version"],
                capture_output=True,
                text=True,
                timeout=10,
                check=False,
            )
            dotnet_script = proc.returncode == 0
        except (OSError, subprocess.TimeoutExpired):
            dotnet_script = False
        try:
            proc = subprocess.run(
                [dotnet, "--list-runtimes"],
                capture_output=True,
                text=True,
                timeout=10,
                check=False,
            )
            for line in (proc.stdout or "").splitlines():
                m = re.match(r"Microsoft\.WindowsDesktop\.App\s+(\d+\.\d+)", line)
                if m:
                    desktop_runtimes.append(m.group(1))
        except (OSError, subprocess.TimeoutExpired):
            pass

    def ps_version(exe: str | None) -> str | None:
        if not exe:
            return None
        return _run_version(exe, ["-NoProfile", "-Command", "$PSVersionTable.PSVersion.ToString()"])

    def ps_edition(exe: str | None) -> str | None:
        if not exe:
            return None
        return _run_version(exe, ["-NoProfile", "-Command", "$PSVersionTable.PSEdition"])

    python_on_path = shutil.which("python3") or shutil.which("python")
    python_exe = python_on_path or sys.executable or None

    any_powershell = bool(pwsh or powershell or win_ps)

    return {
        "Cmd": {
            "Available": bool(cmd_exe),
            "Executable": cmd_exe,
            "RequiredFor": ["HeadlessTCShell batch files", "Direct TCShell.exe invocation"],
        },
        "PowerShellCore": {
            "Available": bool(pwsh),
            "Executable": pwsh,
            "Version": ps_version(pwsh),
            "Edition": ps_edition(pwsh),
            "RequiredFor": ["TCAPI via .ps1", "Remote Control client script", "Full detection .ps1"],
        },
        "WindowsPowerShell": {
            "Available": bool(win_ps or powershell),
            "Executable": win_ps or powershell,
            "Version": ps_version(win_ps or powershell),
            "Edition": ps_edition(win_ps or powershell),
            "RequiredFor": ["TCAPI on Commander 24.1 (net48)", "Remote Control client when pwsh unavailable"],
        },
        "AnyPowerShell": {
            "Available": any_powershell,
            "RequiredFor": ["Invoke-TcApi.ps1", "TcShellRemoteControl.ps1", "Get-CommanderAutomationPaths.ps1"],
        },
        "DotNet": {
            "Available": bool(dotnet),
            "Executable": dotnet,
            "Version": dotnet_version,
            "DesktopRuntimes": sorted(set(desktop_runtimes)),
            "RequiredFor": ["TCAPI via dotnet script (.csx)"],
        },
        "DotNetScript": {
            "Available": dotnet_script,
            "RequiredFor": ["TCAPI via .csx without PowerShell"],
        },
        "Python": {
            "Available": bool(python_exe),
            "Executable": python_exe,
            "Version": platform.python_version() if python_exe == sys.executable else _run_version(python_exe, ["--version"]) if python_exe else None,
            "RequiredFor": ["Get-CommanderAutomationPaths.py (optional)", "Reference doc generation (dev)"],
        },
    }


def commander_gui_running() -> bool:
    if not is_windows():
        return False
    try:
        proc = subprocess.run(
            ["tasklist", "/FI", "IMAGENAME eq ToscaCommander.exe", "/NH"],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        return "ToscaCommander.exe" in (proc.stdout or "")
    except (OSError, subprocess.TimeoutExpired):
        return False


def dll_present(commander_home: str | None, name: str) -> bool:
    if not commander_home:
        return False
    return (Path(commander_home) / name).is_file()


def probe_remote_control_via_powershell(commander_home: str, runtimes: dict[str, Any]) -> tuple[bool, str]:
    ps = runtimes["PowerShellCore"]["Executable"] or runtimes["WindowsPowerShell"]["Executable"]
    if not ps:
        return False, "Remote Control session probe requires PowerShell or a custom .NET host loading RemoteControlObjects.dll."

    probe_script = Path(__file__).resolve().parent / "TcShellRemoteControl.ps1"
    try:
        proc = subprocess.run(
            [ps, "-NoProfile", "-File", str(probe_script), "-ProbeSession", "-CommanderHome", commander_home],
            capture_output=True,
            text=True,
            timeout=20,
            check=False,
        )
        if proc.returncode == 0 and "OK" in (proc.stdout or ""):
            return True, "Remote Control session active (Start Remote Control was used in Commander)."
        if commander_gui_running():
            return False, "Commander is running but Remote Control is not started. Use project menu → Start Remote Control."
        return False, "Remote Control not active. Open Commander, load workspace, start Remote Control."
    except (OSError, subprocess.TimeoutExpired):
        return False, "Could not probe Remote Control session."


def select_path(discovery: dict[str, Any], intent: str = "Auto") -> dict[str, Any]:
    paths = discovery["Paths"]
    locked = discovery["WorkspaceLock"]["Locked"]
    runtimes = discovery["Runtimes"]
    choices: list[dict[str, str]] = []
    prompt: str | None = None

    for path in paths:
        path["Score"] = 0

    by_id = {p["Id"]: p for p in paths}
    headless = by_id["HeadlessTCShell"]
    tcapi = by_id["TCAPI"]
    rc = by_id["RemoteControl"]

    if intent == "GuiAttended":
        if rc["Available"]:
            rc["Score"] = 100
    elif intent == "TypedApi":
        if not locked and tcapi["Available"]:
            tcapi["Score"] = 100
    elif intent == "HeadlessScript":
        if not locked and headless["Available"]:
            headless["Score"] = 100
    else:
        if not locked:
            if headless["Available"]:
                headless["Score"] += 80
            if tcapi["Available"]:
                tcapi["Score"] += 70
            if rc["Available"]:
                rc["Score"] += 20
        else:
            if rc["Available"]:
                rc["Score"] += 60

    ranked = sorted([p for p in paths if p["Available"]], key=lambda p: p["Score"], reverse=True)
    best = ranked[0]["Score"] if ranked else -1
    top = [p for p in ranked if p["Score"] == best and best >= 0]

    if not runtimes["AnyPowerShell"]["Available"] and headless["Available"]:
        headless["Score"] += 15

    if locked and headless.get("Details", {}).get("WouldBeAvailableWithoutLock"):
        prompt = (
            "The workspace is locked. Headless TCShell/TCAPI cannot open the same .tws while locked. "
            "Choose: close Commander for headless (cmd/batch + TCShell.exe), start Remote Control, "
            "or continue with GUI-attended Remote Control if already started."
        )
        choices.append({"Id": "CloseCommanderHeadless", "Label": "Close Commander → headless TCShell (cmd/batch, no PowerShell required)"})
        if rc["Available"]:
            choices.append({"Id": "RemoteControl", "Label": "Remote Control (requires PowerShell or .NET client)"})
        else:
            choices.append({"Id": "StartRemoteControl", "Label": "Start Remote Control in Commander, then re-run detection"})

    if not locked and headless["Available"] and tcapi["Available"] and intent == "Auto" and len(top) > 1:
        prompt = (
            "Both headless TCShell (cmd/batch, no PowerShell) and TCAPI are available. "
            "Prefer TCShell for .tcs scripts; prefer TCAPI only if a .NET host (PowerShell or dotnet script) is available."
        )
        choices.append({"Id": "HeadlessTCShell", "Label": "Headless TCShell (.tcs via cmd/batch)"})
        choices.append({"Id": "TCAPI", "Label": f"TCAPI via {tcapi['Details'].get('PreferredHost', 'dotnet')}"})

    if not discovery.get("Workspace") and (headless["Available"] or tcapi["Available"]):
        prompt = "Set workspace path (.tws) via TOSCA_WORKSPACE or ~/.tricentis/tcshell-ide.env before running automation."
        choices.append({"Id": "ProvideWorkspace", "Label": "Provide workspace .tws path"})

    if not runtimes["AnyPowerShell"]["Available"]:
        tcapi_hosts = tcapi.get("Details", {}).get("AvailableHosts", {})
        if not tcapi_hosts.get("DotNetScript") and tcapi_hosts.get("DllPresent"):
            if not prompt:
                prompt = (
                    "PowerShell is not available on this machine. "
                    "Use headless TCShell via cmd/batch (no PowerShell), or install pwsh / dotnet-script for TCAPI."
                )
            choices.append({"Id": "HeadlessTCShell", "Label": "Use TCShell.exe + .tcs (recommended without PowerShell)"})

    if not ranked:
        missing = []
        if not is_windows():
            missing.append("Windows + local Commander install")
        elif not discovery.get("CommanderHome"):
            missing.append("COMMANDER_HOME")
        if not runtimes["Cmd"]["Available"] and not runtimes["AnyPowerShell"]["Available"]:
            missing.append("cmd.exe or a shell to launch TCShell.exe")
        reason = "No Commander automation path is available."
        if missing:
            reason += " Missing: " + ", ".join(missing) + "."
        return {
            "Recommended": None,
            "Alternatives": [],
            "UserPromptRequired": True,
            "UserPrompt": reason,
            "Choices": choices,
            "Ranked": [],
        }

    user_prompt_required = bool(choices) and (
        intent == "Auto" or (locked and intent in ("HeadlessScript", "TypedApi"))
    )

    recommended = None
    if len(top) == 1 and not user_prompt_required:
        recommended = top[0]
    elif top and intent != "Auto":
        recommended = top[0]

    alternatives = [p for p in ranked if not recommended or p["Id"] != recommended["Id"]]
    return {
        "Recommended": recommended,
        "Alternatives": alternatives,
        "UserPromptRequired": user_prompt_required,
        "UserPrompt": prompt,
        "Choices": choices,
        "Ranked": ranked,
    }


def discover_commander_paths(
    commander_home: str | None = None,
    workspace: str | None = None,
    intent: str = "Auto",
    commander_version: str | None = None,
) -> dict[str, Any]:
    runtimes = detect_runtimes()
    resolved_home = resolve_commander_home(commander_home)
    resolved_workspace = resolve_workspace(workspace)
    version_key = resolve_commander_version_key(resolved_home, commander_version)
    tcapi_hosts_info = get_tcapi_host_availability(resolved_home, runtimes, version_key)
    version_profile = tcapi_hosts_info["VersionProfile"]
    tcapi_hosts = tcapi_hosts_info["AvailableHosts"]
    preferred_tcapi_host = tcapi_hosts_info["PreferredHost"]
    skill_reference_path = get_skill_reference_path(version_key)
    tcshell = get_tcshell_path(resolved_home)
    lock_status = get_workspace_lock_status(resolved_workspace)
    gui = commander_gui_running() if is_windows() else False

    headless_base = bool(is_windows() and tcshell and resolved_home)
    headless_available = headless_base and not lock_status["Locked"]
    headless_reason = "Requires Windows."
    if is_windows():
        if not resolved_home:
            headless_reason = "COMMANDER_HOME not found."
        elif not tcshell:
            headless_reason = "TCShell.exe not found under Commander install."
        elif lock_status["Locked"]:
            headless_reason = f"Workspace locked by {lock_status['Holder']}. Close Commander or use Remote Control."
        elif not resolved_workspace:
            headless_reason = "Available; set workspace path before running. Host: cmd/batch (PowerShell not required)."
        else:
            headless_reason = f"Ready via cmd/batch: {tcshell}"

    tcapi_dll = tcapi_hosts.get("DllPresent", False)
    tcapi_available = bool(
        not lock_status["Locked"]
        and tcapi_dll
        and (tcapi_hosts.get("PowerShell") or tcapi_hosts.get("DotNetScript"))
    )
    tcapi_reason = "TCAPI DLLs not found under COMMANDER_HOME."
    if tcapi_dll and lock_status["Locked"]:
        tcapi_reason = f"Workspace locked by {lock_status['Holder']}. TCAPI cannot open the same .tws."
    elif tcapi_dll and not tcapi_hosts.get("PowerShell") and not tcapi_hosts.get("DotNetScript"):
        required = tcapi_hosts.get("RequiredDesktopRuntime", "")
        tcapi_reason = (
            f"TCAPI.dll present for Commander {version_key} but no suitable host. "
            f"{version_profile.get('HostGuidance', '')} "
            f"Required .NET desktop runtime: {required}."
        ).strip()
    elif tcapi_available:
        tcapi_reason = f"Ready via {preferred_tcapi_host} (Commander {version_key})."

    rc_dll = dll_present(resolved_home, "RemoteControlObjects.dll")
    rc_available = False
    rc_reason = "Requires Windows."
    if is_windows():
        if not resolved_home:
            rc_reason = "COMMANDER_HOME not found."
        elif not rc_dll:
            rc_reason = "RemoteControlObjects.dll not found under COMMANDER_HOME."
        elif runtimes["AnyPowerShell"]["Available"]:
            rc_available, rc_reason = probe_remote_control_via_powershell(resolved_home, runtimes)
        else:
            rc_reason = (
                "RemoteControlObjects.dll present but session probe needs PowerShell or a .NET client. "
                "Headless TCShell via cmd/batch does not require PowerShell."
            )

    paths = [
        {
            "Id": "HeadlessTCShell",
            "Label": "Headless TCShell",
            "Available": headless_available,
            "Score": 0,
            "Reason": headless_reason,
            "HostRequired": "CmdOrBatch",
            "PowerShellRequired": False,
            "Details": {
                "TcShellPath": tcshell,
                "CommanderHome": resolved_home,
                "CommanderVersion": version_key,
                "WouldBeAvailableWithoutLock": headless_base,
                "ExampleHost": runtimes["Cmd"]["Executable"] or "cmd.exe",
                "SkillReferencePath": skill_reference_path,
            },
        },
        {
            "Id": "TCAPI",
            "Label": "TCAPI (.NET)",
            "Available": tcapi_available,
            "Score": 0,
            "Reason": tcapi_reason,
            "HostRequired": "PowerShellOrDotNetScript",
            "PowerShellRequired": False,
            "Details": {
                "CommanderHome": resolved_home,
                "CommanderVersion": version_key,
                "AvailableHosts": tcapi_hosts,
                "PreferredHost": preferred_tcapi_host,
                "VersionProfile": version_profile,
                "SkillReferencePath": skill_reference_path,
            },
        },
        {
            "Id": "RemoteControl",
            "Label": "Remote Control (GUI-attended)",
            "Available": rc_available,
            "Score": 0,
            "Reason": rc_reason,
            "HostRequired": "PowerShellOrDotNet",
            "PowerShellRequired": True,
            "Details": {
                "CommanderHome": resolved_home,
                "DllPresent": rc_dll,
                "PowerShellScript": (
                    "lib/TcShellRemoteControl.ps1"
                    if Path(__file__).resolve().parent.name == "lib"
                    and Path(__file__).resolve().parent.parent.name != "scripts"
                    else "lib/TcShellRemoteControl.ps1"
                ),
            },
        },
    ]

    discovery: dict[str, Any] = {
        "DetectionMethod": "python",
        "IsWindows": is_windows(),
        "CommanderHome": resolved_home,
        "CommanderVersion": version_key,
        "VersionProfile": version_profile,
        "SkillReferencePath": skill_reference_path,
        "SupportedCommanderVersions": list(SUPPORTED_VERSION_KEYS),
        "Workspace": resolved_workspace,
        "WorkspaceLock": lock_status,
        "CommanderGuiRunning": gui,
        "Intent": intent,
        "Runtimes": runtimes,
        "Paths": paths,
    }
    discovery["Selection"] = select_path(discovery, intent)
    return discovery


def main() -> int:
    import argparse

    parser = argparse.ArgumentParser(description="Detect Commander automation paths and runtimes.")
    parser.add_argument("--commander-home", default=os.environ.get("COMMANDER_HOME"))
    parser.add_argument("--workspace", default=os.environ.get("TOSCA_WORKSPACE"))
    parser.add_argument("--commander-version", default=os.environ.get("COMMANDER_VERSION"))
    parser.add_argument(
        "--intent",
        default="Auto",
        choices=["Auto", "HeadlessScript", "TypedApi", "GuiAttended"],
    )
    args = parser.parse_args()

    result = discover_commander_paths(
        args.commander_home,
        args.workspace,
        args.intent,
        args.commander_version,
    )
    print(json.dumps(result, indent=2))

    if not result["Selection"]["Recommended"] and result["Selection"]["UserPromptRequired"]:
        return 2
    if not any(p["Available"] for p in result["Paths"]):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
