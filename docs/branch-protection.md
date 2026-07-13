# Branch protection

Apply these settings on **Tricentis/mcp-skills** → **Settings → Branches** → rule for `main`.

| Setting | Value |
|---------|-------|
| Require pull request before merging | Yes |
| Required approving reviews | **2** |
| Require review from Code Owners | Yes |
| Dismiss stale pull request approvals | Yes |
| Require status checks to pass | `validate-export` |
| Require branches to be up to date | Yes |
| Restrict pushes that create files | No (bot PRs need write) |
| Allow force pushes | No |
| Allow deletions | No |
| Bypass list | Empty |

## production Environment

**Settings → Environments → production**

- Required reviewers: configure when teams exist (individuals OK while private).
- Deployment branches: `main` only.
- Used by `.github/workflows/release.yml` on every automated release.

See [github-cicd-pipeline.md](github-cicd-pipeline.md) for the full pipeline.
