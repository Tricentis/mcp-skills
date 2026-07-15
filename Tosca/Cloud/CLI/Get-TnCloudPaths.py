#!/usr/bin/env python3
"""Detect tn CLI availability and ~/.tn configuration."""

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


def build_paths(tn: dict, mcp: dict, apps: dict) -> list[dict]:
    ready = tn["available"] and mcp.get("tosca_url") and apps["configured"]
    paths = [
        {"id": "Repl", "available": ready, "hostRequired": "terminal", "notes": "tn then /tosca"},
        {"id": "Piped", "available": ready, "hostRequired": "terminal", "notes": "echo prompt | tn"},
        {"id": "Loop", "available": ready, "hostRequired": "terminal", "notes": "tn --loop"},
        {"id": "Robot", "available": ready, "hostRequired": "terminal", "notes": "tn --robot"},
    ]
    return paths


def recommend(paths: list[dict], tn: dict) -> dict:
    if not tn["available"]:
        return {"pathId": None, "userPromptRequired": True, "reason": "tn not on PATH"}
    available = [p for p in paths if p["available"]]
    if not available:
        return {"pathId": None, "userPromptRequired": True, "reason": "Configure ~/.tn/mcp.json and appsettings.json"}
    return {"pathId": "Piped", "userPromptRequired": False, "reason": "Default single-shot via piped tn"}


def main() -> int:
    tn = detect_tn()
    mcp = read_mcp_config()
    apps = read_appsettings()
    paths = build_paths(tn, mcp, apps)
    selection = recommend(paths, tn)

    payload = {
        "TnAvailable": tn["available"],
        "TnPath": tn["path"],
        "TnVersion": tn["version"],
        "ConfigPath": str(home_tn_dir()),
        "ToscaMcpConfigured": bool(mcp.get("tosca_url")),
        "ToscaMcpUrl": mcp.get("tosca_url", ""),
        "ProviderConfigured": apps["configured"],
        "ActiveProvider": apps["active_provider"],
        "Paths": paths,
        "Selection": selection,
    }
    print(json.dumps(payload, indent=2))

    if not tn["available"]:
        return 1
    if selection.get("userPromptRequired"):
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
