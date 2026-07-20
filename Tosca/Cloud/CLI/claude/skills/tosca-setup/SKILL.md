---
name: tosca-setup
description: Set up toscactl authentication and workspace selection
user-invocable: true
disable-model-invocation: true
allowed-tools: Bash(toscactl *)
argument-hint: "[tenant-url]"
---

# Set Up toscactl

Authenticate with Tosca Cloud and select a workspace.

Always use `--json --silent` on every `toscactl` command.

## Steps

1. **Check current state.** Run `toscactl config --json --silent`.
   - If already logged in and a workspace is set, report the current configuration and ask if the user wants to change anything. If not, stop here.

2. **Login.** If not logged in, or the user provided a tenant URL in `$ARGUMENTS`:
   - Run `toscactl login --url <URL> --json --silent` where `<URL>` is `$ARGUMENTS` or the URL from the current config.
   - If no URL is available, ask the user for their tenant URL (format: `tenant.my.tricentis.com`).
   - Do not use `--headless` unless the user explicitly requests it.

3. **List workspaces.** Run `toscactl workspaces list --json --silent` and present the available workspaces to the user.

4. **Set workspace.** Ask the user which workspace to use, then run `toscactl workspaces set <chosen> --json --silent`.

5. **Confirm.** Run `toscactl config --json --silent` and show the final configuration.

## Error Handling

- If login fails, suggest checking the URL format (`tenant.my.tricentis.com`) and network connectivity.
- For CI/headless environments, mention that setting `TOSCA_CLIENT_ID` and `TOSCA_CLIENT_SECRET` environment variables enables non-interactive authentication.
- If `--headless` is needed, re-run login with `toscactl login --url <URL> --headless`.
