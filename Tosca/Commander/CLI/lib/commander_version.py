"""Commander version detection and TCAPI compatibility (24.1–26.1, master)."""

from __future__ import annotations

import json
import os
import re
from pathlib import Path
from typing import Any

SUPPORTED_VERSION_KEYS = ("24.1", "24.2", "25.1", "26.1", "master")

_VERSION_PATH_TOKENS: dict[str, tuple[str, ...]] = {
    "24.1": ("24.1", "241", ".241"),
    "24.2": ("24.2", "242", ".242"),
    "25.1": ("25.1", "251", ".251"),
    "26.1": ("26.1", "261", ".261"),
    "master": ("master",),
}


def get_repo_root() -> Path:
    return Path(__file__).resolve().parent.parent.parent


def _load_json(relative: str) -> dict[str, Any]:
    path = get_repo_root() / relative
    if not path.is_file():
        raise FileNotFoundError(f"Missing manifest: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def load_commander_versions_manifest() -> dict[str, Any]:
    return _load_json("commander-versions.json")


def load_tcapi_compatibility_manifest() -> dict[str, Any]:
    return _load_json("tcapi-compatibility.json")


def read_commander_version_from_ide_env() -> str | None:
    profile = os.environ.get("USERPROFILE") or os.environ.get("HOME")
    if not profile:
        return None
    for name in (".tricentis/tcshell-ide.env", ".tricentis\\tcshell-ide.env"):
        path = Path(profile) / name
        if not path.is_file():
            continue
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            m = re.match(r"^COMMANDER_VERSION=(.+)$", line.strip())
            if m:
                return m.group(1).strip()
    return None


def resolve_commander_version_key(
    commander_home: str | None = None,
    explicit_version: str | None = None,
) -> str:
    manifest = load_commander_versions_manifest()
    default = manifest.get("defaultVersion", "26.1")
    versions = manifest.get("versions", {})

    for candidate in (
        explicit_version,
        os.environ.get("COMMANDER_VERSION"),
        read_commander_version_from_ide_env(),
    ):
        if candidate and candidate in versions:
            return candidate

    if commander_home:
        normalized = commander_home.lower().replace("\\", "/")
        for key in ("24.1", "24.2", "25.1", "26.1", "master"):
            for token in _VERSION_PATH_TOKENS[key]:
                if token in normalized:
                    return key
        # Dev / unversioned install folder: .../ToscaCommander/ (no version token in path)
        if re.search(r"toscacommander/?$", normalized) and not re.search(
            r"24\.|25\.|26\.|241|242|251|261", normalized
        ):
            return "master"

    return default


def get_tcapi_version_profile(version_key: str) -> dict[str, Any]:
    manifest = load_tcapi_compatibility_manifest()
    default = manifest.get("defaultVersion", "26.1")
    versions = manifest.get("versions", {})
    key = version_key if version_key in versions else default
    profile = versions.get(key) or versions[default]
    doc = profile.get("devCornerDocVersion", "2026.1")
    return {
        "VersionKey": key,
        "Label": profile.get("label", key),
        "TcApiTargets": list(profile.get("tcApiTargets", [])),
        "DotNetDesktopRuntime": str(profile.get("dotnetDesktopRuntime", "")),
        "DevCornerDocVersion": doc,
        "HostGuidance": profile.get("hostGuidance", ""),
        "DocBaseUrl": f"https://documentation.tricentis.com/devcorner/{doc}/tcapi/webindex.html",
    }


def get_skill_reference_path(version_key: str) -> str:
    return f"reference/versions/{version_key}/"


def get_recommended_powershell_host(
    version_profile: dict[str, Any],
    runtimes: dict[str, Any],
) -> str:
    targets = version_profile.get("TcApiTargets") or []
    needs_netfx = "net48" in targets
    needs_modern = any(re.match(r"^net[89]|^net10", t) for t in targets)

    ps_core = runtimes.get("PowerShellCore") or {}
    win_ps = runtimes.get("WindowsPowerShell") or {}

    if needs_netfx and not needs_modern:
        if win_ps.get("Available"):
            return "windows-powershell"
        if ps_core.get("Available") and ps_core.get("Edition") == "Desktop":
            return "powershell"
        return "windows-powershell"

    if needs_netfx and needs_modern:
        if ps_core.get("Available") and ps_core.get("Edition") == "Core":
            return "pwsh"
        if win_ps.get("Available"):
            return "windows-powershell"
        if ps_core.get("Available"):
            return "pwsh"
        return "windows-powershell"

    if ps_core.get("Available") and ps_core.get("Edition") == "Core":
        return "pwsh"
    if win_ps.get("Available"):
        return "windows-powershell"
    if ps_core.get("Available"):
        return "pwsh"
    return "none"


def get_tcapi_host_availability(
    commander_home: str | None,
    runtimes: dict[str, Any],
    version_key: str,
) -> dict[str, Any]:
    profile = get_tcapi_version_profile(version_key)
    home = commander_home or ""
    dll_present = (
        bool(home)
        and (Path(home) / "TCAPI.dll").is_file()
        and (Path(home) / "TCAPIObjects.dll").is_file()
    )

    ps_exe = (runtimes.get("PowerShellCore") or {}).get("Executable") or (
        runtimes.get("WindowsPowerShell") or {}
    ).get("Executable")
    dotnet = runtimes.get("DotNet") or {}
    dotnet_script = (runtimes.get("DotNetScript") or {}).get("Available", False)
    desktop_runtimes = dotnet.get("DesktopRuntimes") or []
    required_runtime = profile.get("DotNetDesktopRuntime", "")
    desktop_ok = required_runtime in desktop_runtimes

    recommended_ps = get_recommended_powershell_host(profile, runtimes)
    ps_usable = bool(ps_exe and recommended_ps != "none")

    # 24.1 net48: prefer Windows PowerShell when pwsh-only would fail Add-Type on net48 DLL
    targets = profile.get("TcApiTargets") or []
    if "net48" in targets and recommended_ps == "windows-powershell":
        ps_usable = bool((runtimes.get("WindowsPowerShell") or {}).get("Available"))

    hosts = {
        "PowerShell": bool(dll_present and ps_usable),
        "DotNetScript": bool(dll_present and dotnet_script and desktop_ok),
        "DllPresent": dll_present,
        "RequiredDesktopRuntime": required_runtime,
        "DesktopRuntimeInstalled": desktop_ok,
        "RecommendedPowerShellHost": recommended_ps,
    }
    preferred = None
    if hosts["PowerShell"]:
        preferred = "PowerShell"
    elif hosts["DotNetScript"]:
        preferred = "DotNetScript"
    return {
        "AvailableHosts": hosts,
        "PreferredHost": preferred,
        "VersionProfile": profile,
    }
