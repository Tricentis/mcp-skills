# Explaining test case read path — Tosca Cloud

How to read test case structure for plain-language explanations.

## Preferred path

| Step | Tool | Purpose |
|------|------|---------|
| 1 | `tosca_asset` Search (`artifactType: testCase`, `name`) | Resolve test case id |
| 2 | `tosca_testcase` Get | Name, description, tcp[], items[] tree |
| 3 | `tosca_teststep` Get (`testStepContainerId` + `itemId`; type defaults to `testCase`) | Step `values[]` for detail |

## API-heavy tests

When steps reference API messages:

1. Read structure from `tosca_testcase` Get.
2. Search linked `apiMessage` artifacts: `tosca_asset` Search (`artifactType: apiMessage`).
3. Read bodies with `tosca_apimessage` Get.

## Confidence guidance

- `tosca_testcase` Get with resolved id → confidence 8–9 for step-level claims
- Inventory metadata only (no Get) → confidence 4–6
- Inferred from modules/tags without Get → state gaps explicitly
