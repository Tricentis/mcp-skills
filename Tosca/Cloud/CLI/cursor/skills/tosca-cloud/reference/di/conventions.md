# Data Integrity conventions — Tosca Cloud

## Naming

Wire names follow `tosca_dataintegrity_{action}` per the A2A interoperability standard.

## Agent rules

1. Call `tosca_dataintegrity_workflow` before any other DI tool in a session.
2. Poll async check tools — do not assume immediate results.
3. Never echo connection passwords or secrets in responses.
4. Confirm destructive `tosca_dataintegrity_connection` delete operations with the user.
5. **Connections are managed in the Tosca Cloud UI** — MCP cannot create or update connections.

## Entitlements

DI tools may require product entitlements. Handle entitlement errors by reporting to the user.

## Row Key Rules
- Single key column: `"CustomerId"`
- Composite key: `"OrderId;LineNo"` (semicolon-separated)
- No natural key: `"All Source Columns"` — every source column becomes the match key; rows only match when every value is identical
- The RowKey column names must match exactly between source and target (after any renames).
- Schema results never include primary key metadata — ask the user if the PK is not obvious.

## SQL Statements (Database endpoints)
- SQL determines which rows and columns are fetched from each side.
- Both sides must return the same column name(s) for the RowKey.
- Prefer explicit column lists (`SELECT col1, col2`) over `SELECT *` — it avoids surprises when schemas differ slightly.

