# GitHub CI/CD pipeline

GitHub-only automation for syncing skills from internal source repos to **Tricentis/mcp-skills**.

**Full workflow (all skills repos):** [Tosca.Commander.MCP.Integration `docs/mcp-skills-distribution-plan.md`](https://github.com/Tricentis-Tosca/Tosca.Commander.MCP.Integration/blob/main/docs/mcp-skills-distribution-plan.md) — Phases 0–8 from skill-authoring audit through export by target path.

## Flow

```text
integration main → sync + validate → ConsumerExport staging
                → orphan release branch (export only)
                → manual PR to mcp-skills main
                → 2 approvals + validate-export CI
                → merge → production env → tag + SignPath-signed installer zip
```

Release zip (`pack_release.ps1`) and mcp-skills git tree are built from the **same** `ConsumerExport.ps1` staging — they must stay identical.

## Source repo (`Tosca.Commander.MCP.Integration`)

| Workflow | File | Trigger |
|----------|------|---------|
| Export | `.github/workflows/export-mcp-skills.yml` | `workflow_dispatch`, tag `commander-mcp-*` |

**Jobs:**

1. `sync_mcp_packs.ps1` + `validate_skill.py` + `validate_pack.ps1`
2. `export_mcp_skills.ps1` — updates orphan release branch via `git worktree add --orphan`
3. Maintainer opens PR on `Tricentis/mcp-skills` (no long-lived PAT in this repo)

**Manual export (local):**

```powershell
pwsh -File scripts/validate_pack.ps1
pwsh -File scripts/pack_release.ps1                    # zip + SHA256 (parity check)
pwsh -File scripts/export_mcp_skills.ps1 `
  -McpSkillsPath <local-clone-of-Tricentis/mcp-skills> `
  -UpdateReleaseBranch
```

Version defaults to `skills/commander-mcp/metadata.json` when `-Version` is omitted.

## This repo (`mcp-skills`)

Consumer-only: skills, user documentation, and install scripts under `Tosca/**`. No `scripts/` or `sync/` trees — export validation runs in source repos before a PR is opened.

| Workflow | File | Trigger |
|----------|------|---------|
| Validate | `.github/workflows/validate-export.yml` | Pull requests touching `Tosca/**` — inline shell only |
| PR guard | `.github/workflows/pr-guard.yml` | Blocks fork PRs from modifying `.github/**` |
| Secret scan | `.github/workflows/secret-scan.yml` | TruffleHog verified-only on `Tosca/**` |
| Release | `.github/workflows/release.yml` | Push to `main` when `manifest.json` version changes |
| Sign | `.github/workflows/sign-installers.yml` | After GitHub Release published — SignPath Authenticode zip |

## License

Entire repository and all product trees: **Apache License 2.0** (`Apache-2.0`). SPDX in `manifest.json` and plugin manifests.

## Branch protection checklist (`main`)

Configure in **Settings → Branches → Branch protection rules**:

| Rule | Value |
|------|-------|
| Require pull request | Yes |
| Required approvals | **2** |
| Require review from CODEOWNERS | Yes |
| Require status checks | `validate-export`, `trufflehog` |
| Dismiss stale reviews | Yes |
| Restrict force pushes | Yes |
| Allow bypass | Nobody |

## `production` Environment

**Settings → Environments → production**

| Setting | Value |
|---------|-------|
| Required reviewers | Skill approvers (individuals OK while private) |
| Deployment branches | `main` only |
| Used by | `release.yml`, `sign-installers.yml` |

Creates Git tag `tosca/commander/mcp/{version}`, GitHub Release, and SignPath-signed installer bundle.

## Secrets

| Secret | Repo | Purpose |
|--------|------|---------|
| `SIGNPATH_API_TOKEN` | mcp-skills (`production` env) | Authenticode signing via SignPath |
| `GITHUB_TOKEN` | mcp-skills | Default token for release tagging (scoped by environment) |

Export PRs to mcp-skills are opened by maintainers from local clones or release branches — **no** sync PAT stored in integration repos. Prefer a GitHub App if automated PR creation is added later.

## Auditor playbook

1. Customer reports skill version `1.0.0`.
2. Find tag [`tosca/commander/mcp/1.0.0`](https://github.com/Tricentis/mcp-skills/tags).
3. Open the PR merged for that sync — note **2 approvers** in review timeline.
4. Read PR body: source branch @ SHA, workflow run URL.
5. Verify `Tosca/Commander/MCP/manifest.json` `sourceSha` matches.
6. Download signed installer zip from the GitHub Release assets.

## Adding a new product path

Follow **Part 6** in the [distribution plan](https://github.com/Tricentis-Tosca/Tosca.Commander.MCP.Integration/blob/main/docs/mcp-skills-distribution-plan.md):

1. Add `sync/mcp-skills-manifest.json` (or product-specific manifest) in **source repo**.
2. Add `sync/templates/{skill-id}-user-README.md` and `skill-LICENSE.md` if needed.
3. Extend `sync_mcp_packs.ps1` / `validate_pack.ps1` for the new skill.
4. Add `CODEOWNERS` line for the new `Tosca/{Product}/**` path in **mcp-skills**.
5. Add repository map row to mcp-skills root `README.md`.
6. Tag pattern is automatic: `tosca/{product}/{interface}/{version}` from export path (for example `Tosca/Cloud/MCP` → `tosca/cloud/mcp/{version}`).
7. Run `validate_pack.ps1`, `pack_release.ps1`, and `export_mcp_skills.ps1` before first PR.

**Per-skill invariants:**

| Invariant | Enforcement |
|-----------|-------------|
| `evaluations/` not in consumer tree | `sync_mcp_packs.ps1` + `validate_pack.ps1` |
| Zip ≡ export tree | Shared `ConsumerExport.ps1` |
| `forbiddenPaths` not at staging root | `Build-ConsumerStaging` throws |
| Version alignment | `metadata.json` → plugins → `manifest.json` |
| License | Apache 2.0 at root, product path, and skill LICENSE pointers |

## Failure modes

| Failure | Action |
|---------|--------|
| Forbidden path in PR | Fix export allowlist in source repo; re-export (forbiddenPaths enforced before PR opens) |
| `sync/` or `scripts/` in consumer repo | Remove — maintainer assets belong in source repos only |
| `evaluations/` in pack | Re-run `sync_mcp_packs.ps1`; verify `validate_pack.ps1` |
| validate-export CI red | Fix diff locally; push to sync branch |
| Rejected PR | Close; fix source; re-run export workflow |
| Bad release | Revert merge PR on mcp-skills; re-sync from fixed source |
| Zip ≠ export mismatch | Fix `ConsumerExport.ps1`; rebuild both artifacts |
| Sign job failed | Verify `SIGNPATH_API_TOKEN` and `mcp-skills-installers` policy in SignPath |
