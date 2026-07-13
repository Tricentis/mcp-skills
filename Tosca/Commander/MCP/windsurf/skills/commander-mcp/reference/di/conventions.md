# DI conventions — rowKey and walkthrough notation

IDs and names shown are illustrative — real values come from
your workspace. `►` marks a tool call; `◄` marks the response. Arrows (`→`) show how a value
flows into the next call. Tool calls are illustrative pseudo-calls, not C# or raw JSON; when
invoking an MCP tool, pass the same argument names and values using your client's structured
argument format.

> **rowKey selection.** `rowKey` is the column(s) used to match a source row to a target row.
> In most cases the primary key is the right choice, but it can be any column (or combination)
> that uniquely identifies a row across both sides (e.g., a business key like `OrderNumber`,
> `Email`, or `SKU`). `get_di_connection_schema` never returns PK info — if you want to use the
> PK, query the database for it (see each example). If the user names a different unique key,
> use that instead.

> **rowKey separator:** when matching on multiple columns, separate them with **semicolons** (`;`),
> not commas. Example: `rowKey="OrderId;LineItemId"`

> **rowKey = `"All Source Columns"`** is a valid literal value. It makes the comparison treat
> every source column as part of the row key, so rows only match when every column matches.
> Useful for "exact replica" checks where you want any differing column to count as an unmatched row.

---
