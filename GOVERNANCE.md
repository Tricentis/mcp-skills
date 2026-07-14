# Governance

How Tricentis MCP Skills are maintained, reviewed, and released.

## Roles

| Role | Responsibility | Mechanism |
|------|----------------|-----------|
| **Source maintainer** | Author skills in `Tricentis-Tosca/Tosca.Commander.MCP.Integration` on `main` | Write access on integration repo |
| **Export maintainer** | Review export snapshot on branch `1.0.0` before sync | Diff integration `1.0.0` vs prior export |
| **Sync automation** | Export and open PRs — never merges alone | GitHub Actions |
| **Skill approver** | **2 approvals** on PRs touching `Tosca/**` | CODEOWNERS + branch protection |
| **Release approver** | Gate on **every automated release** | `production` Environment |
| **Auditor** | Trace release → PR → approvers → source SHA | PR history + org audit log |

## CODEOWNERS (teams TBD until public launch)

| Path | Owner |
|------|-------|
| `Tosca/Commander/MCP/**` | `@Tricentis/tosca-commander-mcp-approvers` (TBD) |
| `/LICENSE`, `/NOTICE`, `/README.md` | `@Tricentis/open-source-approvers` (TBD) |
| `.github/**` | `@Tricentis/devops-approvers` (TBD) |

Replace placeholder teams with real GitHub teams before the repository is made public.

## Contribution paths

| Change | Route |
|--------|-------|
| Skill content | Internal integration repo → export → PR here → 2 approvals |
| User README typo | Direct PR to this repo |
| LICENSE / governance | Open-source approvers (TBD) |
| CI workflows | DevOps + skill approvers if validation rules change |

## Audit trail

To trace a published version:

1. Find Git tag `tosca/commander/mcp/{version}` on [Releases](https://github.com/Tricentis/mcp-skills/releases).
2. Open the merge PR for that sync — review timeline shows approvers.
3. Read PR provenance: source repo, branch `1.0.0`, commit SHA.
4. Cross-check `Tosca/Commander/MCP/manifest.json` fields `sourceSha`, `syncedAt`.

Org administrators with audit-log access can query `repo.merge` and `environment.*` events.

## Support

These materials are not covered by Tricentis product support contracts. Use [GitHub Issues](https://github.com/Tricentis/mcp-skills/issues) for community feedback.

See [docs/github-cicd-pipeline.md](docs/github-cicd-pipeline.md) for the full pipeline.

**Reusable plan (all skills):** [Tosca.Commander.MCP.Integration `docs/mcp-skills-distribution-plan.md`](https://github.com/Tricentis-Tosca/Tosca.Commander.MCP.Integration/blob/main/docs/mcp-skills-distribution-plan.md) — single workflow for skill-authoring audits, deployment, and export by target path.
