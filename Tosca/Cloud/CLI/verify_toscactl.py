#!/usr/bin/env python3
"""Verify toscactl CLI availability and configuration."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path


def home_toscactl_config() -> Path:
    return Path.home() / ".config" / "toscactl" / "config.json"


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


def read_config(cli_path: str) -> dict:
    if not cli_path:
        return {"configured": False, "tenant_url": "", "workspace_name": ""}
    try:
        proc = subprocess.run(
            [cli_path, "config", "--json", "--silent"],
            capture_output=True,
            text=True,
            timeout=15,
        )
        if proc.returncode != 0:
            return {"configured": False, "tenant_url": "", "workspace_name": ""}
        data = json.loads(proc.stdout or "{}")
        return {
            "configured": bool(data.get("current_url") or data.get("workspace_id")),
            "tenant_url": data.get("current_url", ""),
            "workspace_name": data.get("workspace_name", ""),
            "workspace_id": data.get("workspace_id", ""),
        }
    except (json.JSONDecodeError, subprocess.TimeoutExpired, OSError):
        config_path = home_toscactl_config()
        if config_path.is_file():
            data = json.loads(config_path.read_text(encoding="utf-8"))
            return {
                "configured": bool(data.get("current_url")),
                "tenant_url": data.get("current_url", ""),
                "workspace_name": data.get("workspace_name", ""),
                "workspace_id": data.get("workspace_id", ""),
            }
        return {"configured": False, "tenant_url": "", "workspace_name": ""}


def main() -> int:
    cli = detect_toscactl()
    config = read_config(cli["path"])

    payload = {
        "ToscactlAvailable": cli["available"],
        "ToscactlPath": cli["path"],
        "ToscactlVersion": cli["version"],
        "ConfigPath": str(home_toscactl_config()),
        "LoggedIn": bool(config.get("tenant_url")),
        "TenantUrl": config.get("tenant_url", ""),
        "WorkspaceName": config.get("workspace_name", ""),
        "WorkspaceId": config.get("workspace_id", ""),
        "Ready": cli["available"] and config.get("configured"),
    }
    print(json.dumps(payload, indent=2))

    if not cli["available"]:
        print("Install toscactl per your Tricentis distribution and ensure it is on PATH.", file=sys.stderr)
        return 1
    if not config.get("configured"):
        print("Run: toscactl login --url <tenant>.my.tricentis.com", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
