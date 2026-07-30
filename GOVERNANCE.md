# Governance

How Tricentis MCP Skills are maintained and released.

## Scope

**Tricentis** maintains this open-source repository on GitHub.

It contains agent skill packs for **Tosca Commander** and **Tosca Cloud** — skills, IDE rules/instructions, install scripts, and user documentation under `Tosca/**`.

**In scope:** skill content, install helpers, and docs in this repository.

**Out of scope:** Tosca product installers, MCP server code, Commander/Cloud runtimes, and the `tn` or `toscactl` CLIs (separate products). Skills here tell IDE agents how to work with those tools once you have them.

Community contributions are welcome; **Tricentis maintainers** review pull requests and publish releases.

## Contribution paths

| Change | Route |
|--------|-------|
| Skill content, workflows, install scripts | Pull request to `main` — see [CONTRIBUTING.md](CONTRIBUTING.md) |
| Root LICENSE, NOTICE, governance docs | Pull request to `main` |
| CI workflows (`.github/**`) | Pull request to `main` |
| Bug reports and ideas | [GitHub Issues](https://github.com/Tricentis/mcp-skills/issues) |

## Releases

Product versions are recorded in each `Tosca/*/manifest.json`. When a manifest version changes on `main`, automation creates a Git tag and [GitHub Release](https://github.com/Tricentis/mcp-skills/releases):

- `tosca/commander/mcp/{version}`
- `tosca/commander/cli/{version}`
- `tosca/cloud/mcp/{version}`
- `tosca/cloud/cli/{version}`

Verify integrity with `SHA256SUMS` in each product directory and Authenticode signatures on `.ps1` / `.bat` installers where present.

## Review

Tricentis maintainers review pull requests before merge.

## Support

These materials are **not** covered by Tricentis product support contracts. Use [GitHub Issues](https://github.com/Tricentis/mcp-skills/issues) for community feedback. Security reports: [SECURITY.md](SECURITY.md).
