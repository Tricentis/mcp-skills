# GitHub CI/CD pipeline

GitHub-only automation for syncing skills from internal source repos to **Tricentis/mcp-skills**.

## Flow

```text
integration main → export script → branch 1.0.0 (export only)
                                → PR to mcp-skills main
                                → 2 approvals + CI
                                → merge → production env → tag tosca/commander/mcp/{version}
```

## Source repo (`Tosca.Commander.MCP.Integration`)

| Workflow | File | Trigger |
|----------|------|---------|
| Export | `.github/workflows/export-mcp-skills.yml` | `workflow_dispatch`, tag `commander-mcp-*` |

**Jobs:**

1. `sync_mcp_packs.ps1` + `validate_skill.py`
2. `export_mcp_skills.ps1` — updates orphan branch **`1.0.0`**
3. Opens PR on `Tricentis/mcp-skills` (requires `MCP_SKILLS_SYNC_TOKEN` secret)

**Manual export (local):**

```powershell
pwsh -File scripts/export_mcp_skills.ps1 -Version 1.0.0 `
  -McpSkillsPath ~/Documents/GitHub/Tricentis/mcp-skills `
  -UpdateReleaseBranch
```

## This repo (`mcp-skills`)

| Workflow | File | Trigger |
|----------|------|---------|
| Validate | `.github/workflows/validate-export.yml` | Pull requests |
| Release | `.github/workflows/release.yml` | Push to `main` when `manifest.json` version changes |

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

1. Add export manifest in source repo under `sync/`.
2. Add `CODEOWNERS` line for the new `Product/...` path.
3. Add copy of manifest under `sync/manifests/` in mcp-skills.
4. Extend `validate-export.yml` forbidden-path checks if needed.

## Failure modes

| Failure | Action |
|---------|--------|
| Forbidden path in PR | Fix export allowlist in source repo; re-export |
| validate-export CI red | Fix diff locally; push to sync branch |
| Rejected PR | Close; fix source; re-run export workflow |
| Bad release | Revert merge PR on mcp-skills; re-sync from fixed source |
