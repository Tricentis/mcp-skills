#!/usr/bin/env python3
"""Generate or merge Cursor MCP config for hosted Tosca Cloud MCP (direct tenant connection)."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO_ROOT / "scripts/lib"))

from tenant_url import (  # noqa: E402
    DEFAULT_ENV,
    DEFAULT_OKTA_CLIENT_ID,
    DEFAULT_SPACE,
    build_mcp_server_entry,
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


def merge_mcp_config(target_path: Path, server_entry: dict) -> dict:
    if target_path.is_file():
        data = json.loads(target_path.read_text(encoding="utf-8"))
    else:
        data = {"mcpServers": {}}

    servers = data.setdefault("mcpServers", {})
    servers.update(server_entry)
    return data


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Configure IDE MCP connection to hosted Tosca Cloud MCP for a tenant."
    )
    parser.add_argument("--tenant", help="Tenant name or full portal URL")
    parser.add_argument("--space", default=DEFAULT_SPACE, help="Space id (default: default)")
    parser.add_argument(
        "--env",
        default=DEFAULT_ENV,
        choices=["prod", "staging", "dev"],
        help="Cloud environment (default: prod → tenant.my.tricentis.com)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Write merged mcp.json (default: print JSON to stdout)",
    )
    parser.add_argument(
        "--client-id",
        default=DEFAULT_OKTA_CLIENT_ID,
        help="Okta OAuth client_id for mcp-remote",
    )
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    tenant_raw = args.tenant or prompt(
        "Tenant name (or paste https://tenant.my.tricentis.com URL)"
    )
    try:
        tenant = normalize_tenant_input(tenant_raw)
        env = normalize_env(args.env)
        space = args.space.strip() or DEFAULT_SPACE
    except ValueError as exc:
        print(exc, file=sys.stderr)
        return 1

    endpoint = mcp_endpoint_url(tenant, space, env)
    server_entry = build_mcp_server_entry(
        tenant, space, env, client_id=args.client_id
    )
    merged = merge_mcp_config(args.output, server_entry) if args.output else {
        "mcpServers": server_entry
    }

    print(f"Tenant : {tenant}")
    print(f"Space  : {space}")
    print(f"Env    : {env}")
    print(f"MCP URL: {endpoint}")
    print()
    print("First connection: Cursor will launch mcp-remote and open Okta in your browser.")
    print("Complete login, then verify with tosca_organization_listWorkspaces in chat.")
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
