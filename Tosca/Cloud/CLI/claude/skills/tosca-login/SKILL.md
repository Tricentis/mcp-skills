---
name: tosca-login
description: Log in to Tosca Cloud, detecting configured URL from current config or prompting for one
user-invocable: true
allowed-tools: Bash(toscactl *)
argument-hint: "[tenant-url]"
---

# Log In to Tosca Cloud

Authenticate with Tosca Cloud using browser-based login.

Always use `--json --silent` on every `toscactl` command.

## Steps

1. **Check current config.** Run `toscactl config --json --silent`.

2. **Determine the URL.**
   - If `$ARGUMENTS` contains a URL, use it directly — skip to step 3.
   - If the config output contains a tenant URL, show it to the user and ask: _"Use this URL to log in: `<url>`?"_
     - If the user confirms, use that URL.
     - If the user declines, ask them to provide a URL.
   - If no URL is in the config, ask the user: _"Enter your Tosca Cloud tenant URL (e.g. `tenant.my.tricentis.com`):"_

3. **Login.** Run `toscactl login --url <URL> --json --silent`.
   - Do **not** use `--headless` unless the user explicitly requests it — this opens the browser for PKCE authentication.

4. **Confirm.** Run `toscactl config --json --silent` and report the authenticated tenant and active workspace.

## Error Handling

- If login fails, suggest verifying the URL format (`tenant.my.tricentis.com`) and network connectivity.
- For CI/headless environments, mention that setting `TOSCA_CLIENT_ID` and `TOSCA_CLIENT_SECRET` environment variables enables non-interactive authentication.
