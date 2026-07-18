# Security — Tricentis mcp-skills

Consumer repository for Tosca agent skills packs. Maintainer export tooling lives in the source integration repos — not in this tree.

## Reporting vulnerabilities

Report security concerns via your Tricentis support channel or a **private** [GitHub Security Advisory](https://github.com/Tricentis/mcp-skills/security/advisories) on this repository. Do not open public issues for exploitable findings.

## What ships here

| Path | Contents |
|------|----------|
| `Tosca/Cloud/MCP` | Hosted Cloud MCP skills (Cursor-first) |
| `Tosca/Cloud/CLI` | TN CLI skills + `configure_tn_connection.py` |
| `Tosca/Commander/MCP` | Local Commander MCP skills |
| `Tosca/Commander/CLI` | TCShell / TCAPI / Remote Control skills + helpers |

Each product directory includes its own `SECURITY.md` with IT review detail.

## Integrity verification

Every product directory with install scripts includes `SHA256SUMS` covering root-level `.ps1`, `.bat`, and `.py` installers/helpers.

```powershell
Get-FileHash -Path .\Install-ToscaCloudMcpPack.ps1 -Algorithm SHA256
# Compare to Tosca/Cloud/MCP/SHA256SUMS
```

Release tags (`tosca/cloud/mcp/{version}`, etc.) are created when `manifest.json` changes on `main`. Verify `sourceSha` in each product `manifest.json` against the integration-repo commit used to build the export.

## Code signing

Install scripts are **Authenticode-signed in private source repos** before export (SignPath via `export-mcp-skills.yml`). This public repo stores the signed bytes and `SHA256SUMS` for integrity checks.

**Do not configure SignPath secrets here.** Configure on each integration repo `production` environment:

| Secret / variable | Purpose |
|-------------------|---------|
| `SIGNPATH_API_TOKEN` | SignPath API key |
| `SIGNPATH_ORGANIZATION_ID` | SignPath org |
| `SIGNPATH_SIGNINGPOLICY_SLUG` | Policy for installer scripts |
| `SIGNPATH_PROJECT_SLUG` (variable) | SignPath project |

Verify locally or in CI:

```powershell
Get-AuthenticodeSignature .\Install-ToscaCloudMcpPack.ps1
Get-FileHash -Path .\Install-ToscaCloudMcpPack.ps1 -Algorithm SHA256
# Compare hash to Tosca/Cloud/MCP/SHA256SUMS
```

## Automated checks (CI)

| Workflow | Purpose |
|----------|---------|
| `validate-export.yml` | Consumer layout; leak grep; SHA256SUMS verification |
| `verify-signatures.yml` | Authenticode Valid on product `.ps1` / `.bat` installers |
| `pr-guard.yml` | Blocks fork PRs from modifying `.github/**` |
| `secret-scan.yml` | TruffleHog verified secrets scan on `Tosca/**` |
| GitGuardian | Org-level secret detection on pull requests |

### TruffleHog (verified secrets)

Scheduled on every pull request and push to `main`. Scope: `Tosca/**` only. Policy: **`--only-verified`** — unverified pattern matches (test fixtures, documentation examples) are excluded via `.trufflehog-exclude`.

**Last manual scan (2026-07-16):** no verified secrets detected in the consumer tree after remediating hardcoded Okta client material from exported Cloud CLI helpers.

## Product-specific security docs

- [Tosca/Cloud/MCP/SECURITY.md](Tosca/Cloud/MCP/SECURITY.md)
- [Tosca/Cloud/CLI/SECURITY.md](Tosca/Cloud/CLI/SECURITY.md)
- [Tosca/Commander/MCP/SECURITY.md](Tosca/Commander/MCP/SECURITY.md)
- [Tosca/Commander/CLI/SECURITY.md](Tosca/Commander/CLI/SECURITY.md)

## Agent permissions

Skills are Markdown instructions. They do not sandbox the IDE agent. Rules use `alwaysApply: false` unless noted in each product pack.
