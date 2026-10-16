# Safety and space policy

## Destructive operations

Confirm with the user before:

- `tosca_asset_folder_edit` Delete
- `tosca_playlist_edit` Delete
- `tosca_playlistrun_edit` Delete / hardCancel
- `tosca_testrun_edit` Delete
- `tosca_testcase_edit` Delete / `tosca_module_edit` Delete
- `tosca_apimessage_edit` Delete / Upsert (Upsert with `messageId` is a full replace)
- `tosca_testsheet_edit` Delete (including `force` on a referenced class) / AttributeDelete / RowDelete / attribute or row rename (AttributeUpsert / RowUpsert with a new `name`) / ClassReferenceDetach / ConvertToClass — linked templates and requirements match by path, row name or id
- `tosca_diconnection_edit` Delete
- `tosca_mobileconnection_edit` Delete (also deletes the linked capability sets)
- `tosca_mobilecapabilityset_edit` Delete / DeleteCapability
- `tosca_apiconnection_edit` Delete / Update (Update is a full replace)

## Secrets

This is the single secrets policy for every Tosca Cloud skill. Other files link here.

**Default:** never ask the user for a password, token, access key, or other secret, and never echo one back. Authentication to MCP itself is the Okta bearer token managed by the IDE.

**Never accepted by MCP:**

- Password TCPs on test cases and playlists — create an empty shell (omit `value`); the user sets the secret in the portal via the returned `url`.
- DI connections — use `connectionStringExpression` / `passwordExpression`; secrets stay in Connection Manager.

**Scoped exception** — `tosca_apiconnection_edit` (`{ "plainText": "..." }` password properties), `tosca_apimessage_edit` (Basic auth `username` / `password`), and `tosca_mobileconnection_edit` / `tosca_mobilecapabilityset_edit` (`secret=true` capabilities, credential-bearing Appium `server` with `serverIsSecret=true`) accept secret values. For these only:

1. Offer the safer route first: create the object without the secret and let the user fill it in the portal `url`, or reference an existing secret / expression.
2. Never ask for the secret. Forward a value only if the user supplied it on their own initiative.
3. Never echo, summarize, or log the value; refer to it as "the supplied secret".
4. Put it only in a secret slot so the backend encodes it: `{ "plainText": ... }` password properties, the API message `password` field, `secret=true` capabilities, `serverIsSecret=true`.
5. API message `headers` are **not** a secret slot — a bearer token or API key there is stored in clear text. Prefer a named API connection (`connectionId`) that holds the credential, or leave the header value for the user to fill in the portal.
6. Updates that cannot keep a stored secret (API message Update with inline Basic auth clears the password when `password` is omitted) — warn before confirming, update without it, and point the user to the portal `url` to set it again. Never ask for it to work around the gap.

## Read-only analysis

Journey skills for analyze/explain default to read-only. Hand off to `tosca-remediating-from-results` only when the user asks to apply fixes.

## Confidence rubric

| Score | Meaning |
|-------|---------|
| 0–3 | Speculative |
| 4–6 | Plausible |
| 7–8 | Strong evidence |
| 9–10 | Near-certain (clear signature) |

## Output template (shared across journey skills)

```
• Scope: <playlist / test case>     • Result: Failed | Passed
• Failing step: <step> — <message>
• Root-cause: <category> — <hypothesis>
• Remediation: 1) <ranked> 2) <alt>
• Confidence: <n>/10 — <why>
```
