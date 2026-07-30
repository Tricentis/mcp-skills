#!/usr/bin/env python3
"""Generate ~/.tn/mcp.json for tn gap workflows (Builder, DI, loop, robot). Primary runtime is toscactl."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
_lib = _SCRIPT_DIR / "lib"
if not (_lib / "tenant_url.py").is_file():
    raise SystemExit("tenant_url.py not found (expected lib/tenant_url.py beside installer)")
sys.path.insert(0, str(_lib))

from tenant_url import (  # noqa: E402
    DEFAULT_ENV,
    DEFAULT_SPACE,
    mcp_endpoint_url,
    normalize_env,
    normalize_tenant_input,
)


def prompt(label: str, default: str | None = None) -> str:
    suffix = f" [{default}]" if default else ""
    while True:
        answer = input(f"{label}{suffix}: ").strip()
        if answer:
            return answer
        if default is not None:
            return default
        print("  Required.")


def build_tn_tosca_server(tenant: str, space: str, env: str) -> dict:
    endpoint = mcp_endpoint_url(tenant, space, env)
    return {
        "tosca": {
            "type": "http",
            "url": endpoint,
            "modes": ["tosca"],
            "oauth": {
                # Okta OAuth client name for Tosca Cloud MCP (not a repository reference).
                "clientId": "MCPServer",
                "scopes": ["tta"],
            },
            "alwaysAllow": ["*"],
        }
    }


def merge_tn_config(target_path: Path, server_entry: dict) -> dict:
    if target_path.is_file():
        data = json.loads(target_path.read_text(encoding="utf-8"))
    else:
        data = {"servers": {}}

    servers = data.setdefault("servers", {})
    servers.update(server_entry)
    return data


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Configure TN mcp.json for hosted Tosca Cloud MCP (native OAuth)."
    )
    parser.add_argument("--tenant", help="Tenant name or full portal URL")
    parser.add_argument("--space", default=DEFAULT_SPACE)
    parser.add_argument("--env", default=DEFAULT_ENV, choices=["prod", "staging", "dev"])
    parser.add_argument("--output", type=Path, help="Write merged mcp.json (default: stdout)")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    tenant_raw = args.tenant or prompt("Tenant name (or paste portal URL)")
    try:
        tenant = normalize_tenant_input(tenant_raw)
        env = normalize_env(args.env)
        space = args.space.strip() or DEFAULT_SPACE
    except ValueError as exc:
        print(exc, file=sys.stderr)
        return 1

    endpoint = mcp_endpoint_url(tenant, space, env)
    server_entry = build_tn_tosca_server(tenant, space, env)
    merged = merge_tn_config(args.output, server_entry) if args.output else {"servers": server_entry}

    print(f"Tenant : {tenant}")
    print(f"Space  : {space}")
    print(f"Env    : {env}")
    print(f"MCP URL: {endpoint}")
    print()
    print("Next: tn --setup (AI provider), then echo '/tosca' | tn")
    print("First /tosca tool use opens Okta in browser (native TN OAuth).")
    print()

    payload = json.dumps(merged, indent=2)
    if args.dry_run:
        print(payload)
        return 0

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(payload + "\n", encoding="utf-8")
        print(f"Wrote {args.output}")
    else:
        print(payload)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
