# Failure taxonomy — Tosca Cloud

| Category | Signals | Typical remediation |
|----------|---------|---------------------|
| Application defect | Unexpected UI/API response; reproducible on manual check | Raise defect; do not patch test |
| Test data | Wrong expected value; data-dependent assertion | Update test data or test case values |
| Timing | Intermittent; passes on retry | Add wait/sync; check environment load |
| Environment | Connection/auth failures; service unavailable | Fix environment config |
| Assertion mismatch | Expected ≠ actual at verify step | Update expected or fix application |
| Module/config | Wrong module reference; outdated API message | Update Builder artifact via remediate skill |

Map remediations to `tosca-remediating-from-results` recipes.
