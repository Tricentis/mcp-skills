# GitHub CI/CD pipeline

GitHub-only automation for syncing skills from internal source repos to **Tricentis/mcp-skills**.

**Full workflow (all skills repos):** [Tosca.Commander.MCP.Integration `docs/mcp-skills-distribution-plan.md`](https://github.com/Tricentis-Tosca/Tosca.Commander.MCP.Integration/blob/main/docs/mcp-skills-distribution-plan.md) — Phases 0–8 from skill-authoring audit through export by target path.

## Flow

```text
integration main → sync + validate → ConsumerExport staging
                → orphan branch 1.0.0 (export only)
                → PR to mcp-skills main
                → 2 approvals + validate-export CI
                → merge → production env → tag {product}/{interface}/{skill}/{version}
```

Release zip (`pack_release.ps1`) and mcp-skills git tree are built from the **same** `ConsumerExport.ps1` staging — they must stay identical.

## Source repo (`Tosca.Commander.MCP.Integration`)

| Workflow | File | Trigger |
|----------|------|---------|
| Export | `.github/workflows/export-mcp-skills.yml` | `workflow_dispatch`, tag `commander-mcp-*` |

**Jobs:**

1. `sync_mcp_packs.ps1` + `validate_skill.py` + `validate_pack.ps1`
2. `export_mcp_skills.ps1` — updates orphan branch **`1.0.0`** via `git worktree add --orphan`
3. Opens PR on `Tricentis/mcp-skills` (requires `MCP_SKILLS_SYNC_TOKEN` secret)

**Manual export (local):**

```powershell
pwsh -File scripts/validate_pack.ps1
pwsh -File scripts/pack_release.ps1                    # zip + SHA256 (parity check)
pwsh -File scripts/export_mcp_skills.ps1 `
  -McpSkillsPath ~/Documents/GitHub/Tricentis/mcp-skills `
  -UpdateReleaseBranch
```

Version defaults to `skills/commander-mcp/metadata.json` when `-Version` is omitted.

## This repo (`mcp-skills`)

| Workflow | File | Trigger |
|----------|------|---------|
| Validate | `.github/workflows/validate-export.yml` | Pull requests |
| Release | `.github/workflows/release.yml` | Push to `main` when `manifest.json` version changes |

## License

Entire repository and all product trees: **Apache License 2.0** (`Apache-2.0`). SPDX in `manifest.json` and plugin manifests.

## Branch protection checklist (`main`)

Configure in **Settings → Branches → Branch protection rules**:

| Rule | Value |
|------|-------|
| Require pull request | Yes |
| Required approvals | **2** |
| Require review from CODEOWNERS | Yes |
| Require status checks | `validate-export` |
| Dismiss stale reviews | Yes |
| Restrict force pushes | Yes |
| Allow bypass | Nobody |

## `production` Environment

**Settings → Environments → production**

| Setting | Value |
|---------|-------|
| Required reviewers | Skill approvers (individuals OK while private) |
| Deployment branches | `main` only |
| Used by | `release.yml` on **every** automated release |

Creates Git tag `tosca/commander/mcp/{version}` and GitHub Release.

## Secrets

| Secret | Repo | Purpose |
|--------|------|---------|
| `MCP_SKILLS_SYNC_TOKEN` | Integration | Scoped token to open PRs on mcp-skills |

Prefer a GitHub App (`tricentis-mcp-skills-sync`) over a user PAT.

## Auditor playbook

1. Customer reports skill version `1.0.0`.
2. Find tag [`tosca/commander/mcp/1.0.0`](https://github.com/Tricentis/mcp-skills/tags).
3. Open the PR merged for that sync — note **2 approvers** in review timeline.
4. Read PR body: source branch `1.0.0` @ SHA, workflow run URL.
5. Verify `Tosca/Commander/MCP/manifest.json` `sourceSha` matches.

## Adding a new product path

Follow **Part 6** in the [distribution plan](https://github.com/Tricentis-Tosca/Tosca.Commander.MCP.Integration/blob/main/docs/mcp-skills-distribution-plan.md):

1. Add `sync/mcp-skills-manifest.json` (or product-specific manifest) in **source repo**.
2. Add `sync/templates/{skill-id}-user-README.md` and `skill-LICENSE.md` if needed.
3. Extend `sync_mcp_packs.ps1` / `validate_pack.ps1` for the new skill.
4. Copy manifest to `sync/manifests/` in **mcp-skills**.
5. Add `CODEOWNERS` line for the new `{Product}/**` path.
6. Add repository map row to mcp-skills root `README.md`.
7. Define tag pattern: `{product}/{interface}/{skill}/{version}`.
8. Run `validate_pack.ps1`, `pack_release.ps1`, and `export_mcp_skills.ps1` before first PR.

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
| Forbidden path in PR | Fix export allowlist in source repo; re-export |
| `evaluations/` in pack | Re-run `sync_mcp_packs.ps1`; verify `validate_pack.ps1` |
| validate-export CI red | Fix diff locally; push to sync branch |
| Rejected PR | Close; fix source; re-run export workflow |
| Bad release | Revert merge PR on mcp-skills; re-sync from fixed source |
| Zip ≠ export mismatch | Fix `ConsumerExport.ps1`; rebuild both artifacts |
