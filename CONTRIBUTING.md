# Contributing

How to contribute to [Tricentis/mcp-skills](https://github.com/Tricentis/mcp-skills).

This repository is the **published distribution** for Tricentis MCP skills — consumer install trees, installers, and documentation. Skill content is authored in internal **source repositories**, validated, exported, and synced here through pull requests.

For approvers, audit trails, CODEOWNERS, and release gates, see **[GOVERNANCE.md](GOVERNANCE.md)**.

## Contribution model

| Kind of change | Where to work | How it lands here |
|----------------|---------------|-------------------|
| **Skill content** (SKILL.md, workflows, orchestration, MCP references) | Source maintainer repo (see table below) | Export → PR to `main` → 2 approvals + `validate-export` CI |
| **User-facing README / START-HERE** typos | This repo (direct PR) | 2 approvals; may be redirected to source if content is generated from a template |
| **Install scripts** at product export root | Source repo (consumer variants) | Same export → PR path as skill content |
| **Repository docs** (governance, CI, contributions) | This repo | Open-source approvers |
| **CI workflows** (`.github/workflows/`) | This repo | DevOps approvers; skill approvers if validation rules change |
| **Bug reports and ideas** | [GitHub Issues](https://github.com/Tricentis/mcp-skills/issues) | Maintainers triage; skill fixes usually go to source |

**Do not** edit skill trees under `Tosca/**` directly unless you are executing an approved export from the matching source repo. Direct edits are likely to be overwritten on the next sync and make audit provenance harder to trace.

## Source repositories

Each product path under `Tosca/` maps to one source repo and one orphan release branch:

| Published path | Source repo | Release branch | Tag prefix |
|----------------|-------------|----------------|------------|
| `Tosca/Commander/MCP/` | [Tricentis-Tosca/Tosca.Commander.MCP.Integration](https://github.com/Tricentis-Tosca/Tosca.Commander.MCP.Integration) | `1.0.0` | `tosca/commander/mcp/` |
| `Tosca/Cloud/MCP/` | [Tricentis-Tosca/Tosca.Cloud.MCP.integration](https://github.com/Tricentis-Tosca/Tosca.Cloud.MCP.integration) | `cloud-mcp-{version}` | `tosca/cloud/mcp/` |
| `Tosca/Commander/CLI/` | [Tricentis-Tosca/Tosca.Commander.IDE.integration](https://github.com/Tricentis-Tosca/Tosca.Commander.IDE.integration) | per manifest | `tosca/commander/cli/` |
| `Tosca/Cloud/CLI/` | [Tricentis-Tosca/Tosca.Cloud.IDE.integration](https://github.com/Tricentis-Tosca/Tosca.Cloud.IDE.integration) | per manifest | `tosca/cloud/cli/` |

Export manifests and validation scripts live in each **source repo** (for example `sync/mcp-skills-manifest.json`, `validate_pack.ps1`, `export_mcp_skills.ps1`). This repo ships the consumer tree only. The reusable end-to-end workflow is documented in the Commander MCP distribution plan linked from [GOVERNANCE.md](GOVERNANCE.md).

## Skill content workflow

1. **Author** in the source repo on `main` — edit `skills/`, run that repo’s validators (`validate_skill.py`, `validate_pack.py`, etc.).
2. **Export** — maintainer runs `export_mcp_skills.py` (or the repo’s GitHub Actions export workflow) to refresh the orphan release branch and open a PR here.
3. **Review** — PR touches only the target path under `Tosca/`; requires **two** CODEOWNERS approvals and a green **`validate-export`** check.
4. **Release** — after merge to `main`, automation tags `tosca/{product}/{interface}/{version}` and publishes a GitHub Release when `manifest.json` version changes.

Provenance for each drop is recorded in the product `manifest.json` (`sourceRepo`, `sourceBranch`, `sourceSha`, `syncedAt`).

## Direct contributions to this repo

Welcome without going through a source repo:

- Documentation fixes in root `README.md`, `CONTRIBUTING.md`, `docs/`, or product `README.md` / `START-HERE.md` when the change is clearly consumer-only.
- Issues for install problems, unclear docs, or missing coverage.
- Dependabot and workflow fixes scoped to this repository.

Open a pull request against `main`. Branch protection requires a PR, **two** approvals, CODEOWNERS review where applicable, and passing CI.

If a maintainer redirects your PR to a source repo, that keeps the export pipeline and audit trail consistent — not a rejection of the fix.

## License

Contributions are accepted under the [Apache License 2.0](LICENSE). By submitting a pull request, you agree your contribution is licensed under those terms.

## Support boundary

These materials are **not** covered by Tricentis product support contracts. Use GitHub Issues for community feedback. See [GOVERNANCE.md — Support](GOVERNANCE.md#support).

## Further reading

| Document | Purpose |
|----------|---------|
| [GOVERNANCE.md](GOVERNANCE.md) | Roles, CODEOWNERS, contribution paths, audit trail |
| [MAINTAINERS.md](MAINTAINERS.md) | Team roster |
| [docs/github-cicd-pipeline.md](docs/github-cicd-pipeline.md) | Sync and release automation |
| [docs/branch-protection.md](docs/branch-protection.md) | Branch protection checklist |
