# Contributing

How to contribute to [Tricentis/mcp-skills](https://github.com/Tricentis/mcp-skills).

This repository publishes Tosca agent skill packs — install trees under `Tosca/**`, installers, and user documentation. Contributions are welcome through GitHub Issues and pull requests.

## What to change where

| Kind of change | Where |
|----------------|-------|
| Skill content (SKILL.md, workflows, orchestration, references) | Pull request under the relevant `Tosca/...` path |
| Install scripts (`.ps1`, `.bat`, helpers at product root) | Same product path in a pull request |
| Product README, START-HERE, SECURITY | Same product path, or root docs for repo-wide policy |
| Root LICENSE, NOTICE, governance | Pull request at repository root |
| Bug reports and ideas | [GitHub Issues](https://github.com/Tricentis/mcp-skills/issues) |

## Pull request workflow

1. Fork or branch from `main`.
2. Make focused changes — one product or concern per PR when possible.
3. Open a pull request with a short summary and test notes (how you verified install steps or skill behavior).
4. Address review feedback; CI must pass before merge.

Changes under `Tosca/**` should stay within the product layout already in the repo (skills under `cursor/`, `claude/`, `windsurf/`, installers at the product root). Do not add maintainer-only trees such as `scripts/` or `sync/` at the repository root.

## Versioning

Each product records its release version in `Tosca/*/manifest.json` and skill `metadata.json` files. When your change is user-facing and releasable, bump the product version in `manifest.json` (and matching plugin metadata if applicable). Release tags follow:

- `tosca/commander/mcp/{version}`
- `tosca/commander/cli/{version}`
- `tosca/cloud/mcp/{version}`
- `tosca/cloud/cli/{version}`

See [GOVERNANCE.md](GOVERNANCE.md) for release mechanics.

## License

Contributions are accepted under the [Apache License 2.0](LICENSE). By submitting a pull request, you agree your contribution is licensed under those terms.

## Support boundary

These materials are **not** covered by Tricentis product support contracts. Use [GitHub Issues](https://github.com/Tricentis/mcp-skills/issues) for community feedback. Security: [SECURITY.md](SECURITY.md).

## Further reading

| Document | Purpose |
|----------|---------|
| [GOVERNANCE.md](GOVERNANCE.md) | Releases and project scope |
| [MAINTAINERS.md](MAINTAINERS.md) | How to reach maintainers |
| [SECURITY.md](SECURITY.md) | Vulnerability reporting and integrity checks |
