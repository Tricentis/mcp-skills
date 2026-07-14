#!/usr/bin/env python3
"""Fail CI if forbidden paths appear in a PR diff under product trees."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
MANIFESTS_DIR = REPO_ROOT / "sync" / "manifests"


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


def load_product_manifests() -> list[dict]:
    manifests: list[dict] = []
    if not MANIFESTS_DIR.is_dir():
        return manifests
    for path in sorted(MANIFESTS_DIR.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        target = data.get("targetPath", "").strip().rstrip("/")
        if target:
            data["_manifestPath"] = str(path)
            manifests.append(data)
    manifests.sort(key=lambda m: len(m["targetPath"]), reverse=True)
    return manifests


def manifest_for_path(name: str, manifests: list[dict]) -> dict | None:
    for manifest in manifests:
        target = manifest["targetPath"]
        if name == target or name.startswith(target + "/"):
            return manifest
    return None


def relative_to_target(name: str, target_path: str) -> str:
    prefix = target_path.rstrip("/") + "/"
    if name.startswith(prefix):
        return name[len(prefix) :]
    if name == target_path.rstrip("/"):
        return ""
    return name


def is_forbidden_relative(rel: str, pattern: str) -> bool:
    pat = pattern.rstrip("/")
    if not rel:
        return rel == pat
    return rel == pat or rel.startswith(pat + "/")


def main() -> int:
    manifests = load_product_manifests()
    if not manifests:
        print("No product manifests in sync/manifests/")
        return 1

    base = "origin/main"
    try:
        names = git_diff_names(base)
    except subprocess.CalledProcessError:
        names = git_diff_names("HEAD~1")

    violations: list[str] = []
    for name in names:
        if not name.startswith("Tosca/"):
            continue
        manifest = manifest_for_path(name, manifests)
        if not manifest:
            continue
        rel = relative_to_target(name, manifest["targetPath"])
        for pattern in manifest.get("forbiddenPaths", []):
            if is_forbidden_relative(rel, pattern):
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
