#!/usr/bin/env python3
"""Create git tags and GitHub releases for product trees whose manifest.json changed."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
MANIFESTS_DIR = REPO_ROOT / "sync" / "manifests"


def git(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=REPO_ROOT,
        check=check,
        text=True,
        capture_output=True,
    )


def changed_consumer_manifests() -> list[Path]:
    result = git("diff", "--name-only", "HEAD~1", "HEAD", check=False)
    if result.returncode != 0:
        result = git("diff", "--name-only", "HEAD", check=False)
    paths: list[Path] = []
    for line in result.stdout.splitlines():
        name = line.strip()
        if name.startswith("Tosca/") and name.endswith("/manifest.json"):
            paths.append(REPO_ROOT / name)
    return paths


def tag_prefix_for(target_path: str) -> str | None:
    if not MANIFESTS_DIR.is_dir():
        return None
    for path in sorted(MANIFESTS_DIR.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        if data.get("targetPath") == target_path:
            prefix = data.get("releaseTagPrefix", "").strip()
            if prefix:
                return prefix.rstrip("/")
    return None


def product_title(target_path: str) -> str:
    parts = target_path.split("/")
    if len(parts) >= 3:
        return f"{parts[0]} {parts[1]} {parts[2]}"
    return target_path.replace("/", " ")


def create_release(manifest_path: Path) -> None:
    rel = manifest_path.relative_to(REPO_ROOT)
    target_path = str(rel.parent).replace("\\", "/")
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    version = data.get("version", "").strip()
    if not version:
        raise SystemExit(f"Missing version in {rel}")

    prefix = tag_prefix_for(target_path)
    if not prefix:
        print(f"Skipping {rel}: no releaseTagPrefix in sync/manifests for {target_path}")
        return

    tag = f"{prefix}/{version}"
    source_repo = data.get("sourceRepo", "source repo")
    source_branch = data.get("sourceBranch", "unknown branch")
    notes = (
        f"Synced from {source_repo} branch {source_branch}. "
        f"See {target_path}/manifest.json for sourceSha."
    )
    title = f"{product_title(target_path)} {version}"

    if git("rev-parse", tag, check=False).returncode != 0:
        git("tag", "-a", tag, "-m", f"{title} from {source_repo}")
    else:
        print(f"Tag {tag} already exists locally")

    remote = git("ls-remote", "--exit-code", "--tags", "origin", f"refs/tags/{tag}", check=False)
    if remote.returncode != 0:
        git("push", "origin", tag)
        print(f"Pushed tag {tag}")
    else:
        print(f"Tag {tag} already on origin")

    view = subprocess.run(
        ["gh", "release", "view", tag],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
    )
    if view.returncode == 0:
        print(f"Release {tag} already exists")
        return

    subprocess.run(
        ["gh", "release", "create", tag, "--title", title, "--notes", notes],
        cwd=REPO_ROOT,
        check=True,
    )
    print(f"Created GitHub release {tag}")


def main() -> int:
    manifests = changed_consumer_manifests()
    if not manifests:
        print("No consumer manifest.json changes in this push")
        return 0
    for manifest_path in manifests:
        create_release(manifest_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
