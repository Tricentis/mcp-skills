"""Tenant URL helpers — aligned with ai-chat / tais-ide-bridge get-tenant-from-url."""

from __future__ import annotations

import re
from urllib.parse import urlparse

HOST_SUFFIX_BY_ENV = {
    "prod": "my.tricentis.com",
    "production": "my.tricentis.com",
    "stg": "my-test.tricentis.com",
    "staging": "my-test.tricentis.com",
    "dev": "my-dev.tricentis.com",
    "development": "my-dev.tricentis.com",
}

DEFAULT_ENV = "prod"
DEFAULT_SPACE = "default"


def normalize_env(value: str | None) -> str:
    if not value:
        return DEFAULT_ENV
    key = value.strip().lower()
    if key in HOST_SUFFIX_BY_ENV:
        mapped = HOST_SUFFIX_BY_ENV[key]
        if mapped == HOST_SUFFIX_BY_ENV["prod"]:
            return "prod"
        if mapped == HOST_SUFFIX_BY_ENV["stg"]:
            return "stg"
        return "dev"
    raise ValueError(f"Unknown environment '{value}'. Use prod, staging, or dev.")


def host_suffix_for_env(env: str) -> str:
    normalized = normalize_env(env)
    if normalized == "prod":
        return HOST_SUFFIX_BY_ENV["prod"]
    if normalized == "stg":
        return HOST_SUFFIX_BY_ENV["stg"]
    return HOST_SUFFIX_BY_ENV["dev"]


def get_tenant_from_url(url: str) -> str | None:
    try:
        hostname = urlparse(url.strip()).hostname or ""
    except ValueError:
        return None
    if not hostname:
        return None

    for suffix in HOST_SUFFIX_BY_ENV.values():
        token = f".{suffix}"
        if hostname.endswith(token):
            tenant = hostname[: -len(token)]
            return tenant.lower() if tenant else None
    return None


def normalize_tenant_input(value: str) -> str:
    trimmed = value.strip()
    if not trimmed:
        raise ValueError("Tenant name is required.")

    from_url = get_tenant_from_url(trimmed)
    if from_url:
        return from_url

    cleared = re.sub(r"[^a-zA-Z0-9-]", "", trimmed)
    if not cleared:
        raise ValueError("Tenant name must contain letters, numbers, or hyphens.")
    return cleared.lower()


def tenant_gateway_host(tenant: str, env: str = DEFAULT_ENV) -> str:
    tenant_name = normalize_tenant_input(tenant)
    suffix = host_suffix_for_env(env)
    return f"{tenant_name}.{suffix}"


def mcp_endpoint_url(tenant: str, space_id: str = DEFAULT_SPACE, env: str = DEFAULT_ENV) -> str:
    host = tenant_gateway_host(tenant, env)
    space = (space_id or DEFAULT_SPACE).strip().strip("/")
    return f"https://{host}/{space}/_mcp/api/mcp"
