#!/usr/bin/env python3
"""Detect toscactl and tn CLI availability; recommend runtime path."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path


def home_tn_dir() -> Path:
    return Path.home() / ".tn"


def detect_tn() -> dict:
    tn_path = shutil.which("tn")
    version = ""
    if tn_path:
        try:
            proc = subprocess.run(
                [tn_path, "--version"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            version = (proc.stdout or proc.stderr).strip()
        except (subprocess.TimeoutExpired, OSError):
            version = "unknown"
    return {"available": bool(tn_path), "path": tn_path or "", "version": version}


def detect_toscactl() -> dict:
    cli_path = shutil.which("toscactl")
    version = ""
    if cli_path:
        try:
            proc = subprocess.run(
                [cli_path, "--version"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            version = (proc.stdout or proc.stderr).strip()
        except (subprocess.TimeoutExpired, OSError):
            version = "unknown"
    return {"available": bool(cli_path), "path": cli_path or "", "version": version}


def read_mcp_config() -> dict:
    mcp_path = home_tn_dir() / "mcp.json"
    if not mcp_path.is_file():
        return {"configured": False, "path": str(mcp_path), "tosca": None}
    data = json.loads(mcp_path.read_text(encoding="utf-8"))
    servers = data.get("servers", {})
    tosca = servers.get("tosca")
    return {
        "configured": True,
        "path": str(mcp_path),
        "tosca": tosca,
        "tosca_url": (tosca or {}).get("url", ""),
    }


def read_appsettings() -> dict:
    apps_path = home_tn_dir() / "appsettings.json"
    if not apps_path.is_file():
        return {"configured": False, "path": str(apps_path), "active_provider": ""}
    data = json.loads(apps_path.read_text(encoding="utf-8"))
    active = data.get("AiProvider", {}).get("Active", "")
    return {"configured": bool(active), "path": str(apps_path), "active_provider": active}


def read_toscactl_config(cli_path: str) -> dict:
    if not cli_path:
        return {"ready": False, "tenant_url": "", "workspace_name": ""}
    try:
        proc = subprocess.run(
            [cli_path, "config", "--json", "--silent"],
            capture_output=True,
            text=True,
            timeout=15,
        )
        if proc.returncode != 0:
            return {"ready": False, "tenant_url": "", "workspace_name": ""}
        data = json.loads(proc.stdout or "{}")
        return {
            "ready": bool(data.get("current_url") and data.get("workspace_id")),
            "tenant_url": data.get("current_url", ""),
            "workspace_name": data.get("workspace_name", ""),
        }
    except (json.JSONDecodeError, subprocess.TimeoutExpired, OSError):
        return {"ready": False, "tenant_url": "", "workspace_name": ""}


def build_tn_paths(tn: dict, mcp: dict, apps: dict) -> list[dict]:
    ready = tn["available"] and mcp.get("tosca_url") and apps["configured"]
    return [
        {"id": "Repl", "available": ready, "runtime": "tn", "notes": "tn then /tosca"},
        {"id": "Piped", "available": ready, "runtime": "tn", "notes": "echo prompt | tn"},
        {"id": "Loop", "available": ready, "runtime": "tn", "notes": "tn --loop (gap workflows)"},
        {"id": "Robot", "available": ready, "runtime": "tn", "notes": "tn --robot"},
    ]


def recommend(toscactl: dict, tosca_cfg: dict, tn: dict, mcp: dict, apps: dict) -> dict:
    if toscactl["available"] and tosca_cfg.get("ready"):
        return {
            "pathId": "Toscactl",
            "runtime": "toscactl",
            "userPromptRequired": False,
            "reason": "Default: toscactl ready for connect/search/run/diagnose",
        }
    if toscactl["available"]:
        return {
            "pathId": None,
            "runtime": "toscactl",
            "userPromptRequired": True,
            "reason": "Run toscactl login and workspaces set",
        }
    if tn["available"] and mcp.get("tosca_url") and apps["configured"]:
        return {
            "pathId": "Piped",
            "runtime": "tn",
            "userPromptRequired": False,
            "reason": "toscactl missing; tn gap path available",
        }
    if not tn["available"]:
        return {"pathId": None, "runtime": None, "userPromptRequired": True, "reason": "Install toscactl or tn"}
    return {
        "pathId": None,
        "runtime": "tn",
        "userPromptRequired": True,
        "reason": "Configure toscactl or ~/.tn/mcp.json + tn --setup",
    }


def main() -> int:
    tn = detect_tn()
    toscactl = detect_toscactl()
    mcp = read_mcp_config()
    apps = read_appsettings()
    tosca_cfg = read_toscactl_config(toscactl["path"])
    tn_paths = build_tn_paths(tn, mcp, apps)
    selection = recommend(toscactl, tosca_cfg, tn, mcp, apps)

    payload = {
        "ToscactlAvailable": toscactl["available"],
        "ToscactlPath": toscactl["path"],
        "ToscactlVersion": toscactl["version"],
        "ToscactlReady": tosca_cfg.get("ready", False),
        "ToscactlTenantUrl": tosca_cfg.get("tenant_url", ""),
        "ToscactlWorkspace": tosca_cfg.get("workspace_name", ""),
        "TnAvailable": tn["available"],
        "TnPath": tn["path"],
        "TnVersion": tn["version"],
        "ConfigPath": str(home_tn_dir()),
        "ToscaMcpConfigured": bool(mcp.get("tosca_url")),
        "ToscaMcpUrl": mcp.get("tosca_url", ""),
        "ProviderConfigured": apps["configured"],
        "ActiveProvider": apps["active_provider"],
        "TnPaths": tn_paths,
        "Selection": selection,
    }
    print(json.dumps(payload, indent=2))

    if selection.get("runtime") == "toscactl" and tosca_cfg.get("ready"):
        return 0
    if selection.get("userPromptRequired"):
        return 2
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
