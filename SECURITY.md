# Security — Tricentis mcp-skills

Open-source distribution of Tosca agent skill packs for IDE agents and CLI automation.

## Reporting vulnerabilities

Report security concerns via a **private** [GitHub Security Advisory](https://github.com/Tricentis/mcp-skills/security/advisories) on this repository. Do not open public issues for exploitable findings.

## What ships here

| Path | Contents |
|------|----------|
| `Tosca/Cloud/MCP` | Hosted Cloud MCP skills (Cursor-first) |
| `Tosca/Cloud/CLI` | TN CLI skills + helper scripts |
| `Tosca/Commander/MCP` | Local Commander MCP skills |
| `Tosca/Commander/CLI` | TCShell / TCAPI / Remote Control skills + helpers |

Each product directory includes its own `SECURITY.md` with IT review detail.

## Integrity verification

Every product directory with install scripts includes `SHA256SUMS` covering root-level `.ps1`, `.bat`, and `.py` installers/helpers.

```powershell
Get-FileHash -Path .\Install-ToscaCloudMcpPack.ps1 -Algorithm SHA256
# Compare to Tosca/Cloud/MCP/SHA256SUMS
```

Release tags (`tosca/cloud/mcp/{version}`, etc.) are created when `manifest.json` version changes on `main`.

## Code signing

Windows install scripts (`.ps1`, `.bat`) are **Authenticode-signed** by Tricentis. Default `.bat` launchers do **not** pass `-ExecutionPolicy Bypass` — see each product `SECURITY.md` for the documented fallback.

Verify locally:

```powershell
Get-AuthenticodeSignature .\Install-ToscaCloudMcpPack.ps1
Get-FileHash -Path .\Install-ToscaCloudMcpPack.ps1 -Algorithm SHA256
# Compare hash to Tosca/Cloud/MCP/SHA256SUMS
```

## Product-specific security docs

- [Tosca/Cloud/MCP/SECURITY.md](Tosca/Cloud/MCP/SECURITY.md)
- [Tosca/Cloud/CLI/SECURITY.md](Tosca/Cloud/CLI/SECURITY.md)
- [Tosca/Commander/MCP/SECURITY.md](Tosca/Commander/MCP/SECURITY.md)
- [Tosca/Commander/CLI/SECURITY.md](Tosca/Commander/CLI/SECURITY.md)

## Agent permissions

Skills are Markdown instructions. They do not sandbox the IDE agent. Rules use `alwaysApply: false` unless noted in each product pack.
