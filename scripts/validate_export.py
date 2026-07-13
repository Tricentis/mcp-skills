#!/usr/bin/env python3
"""Fail CI if forbidden paths appear in a PR diff under product trees."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
MANIFEST = REPO_ROOT / "sync" / "manifests" / "Tosca-Commander-MCP.json"


def git_diff_names(base: str) -> list[str]:
    result = subprocess.run(
        ["git", "diff", "--name-only", f"{base}...HEAD"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        result = subprocess.run(
            ["git", "diff", "--name-only", "HEAD~1", "HEAD"],
            capture_output=True,
            text=True,
            check=True,
        )
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


def main() -> int:
    forbidden: list[str] = []
    if MANIFEST.exists():
        data = json.loads(MANIFEST.read_text(encoding="utf-8"))
        forbidden = data.get("forbiddenPaths", [])

    base = "origin/main"
    try:
        names = git_diff_names(base)
    except subprocess.CalledProcessError:
        names = git_diff_names("HEAD~1")

    violations = []
    for name in names:
        if not name.startswith("Tosca/"):
            continue
        for pattern in forbidden:
            pat = pattern.rstrip("/")
            if name == pat or name.startswith(pat + "/") or f"/{pat}/" in f"/{name}/":
                violations.append(name)
                break

    required = ["LICENSE", "README.md"]
    for req in required:
        if not (REPO_ROOT / req).exists():
            print(f"Missing required file: {req}")
            return 1

    if violations:
        print("Forbidden paths in product tree:")
        for v in sorted(set(violations)):
            print(f"  - {v}")
        return 1

    print("validate-export: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
