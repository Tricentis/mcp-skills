# Standard Objects (standard modules)

Pre-built modules shipped with Tosca Cloud. **Get-only** via MCP — `tosca_module_edit` rejects Standard Objects. Prefer these over inventing User-asset NonGui shells when the action already exists.

## Resolution protocol (always)

1. Pick a candidate name from the catalog below (or a close synonym).
2. `tosca_module` Search with `scope=StandardObjects` and that `name` substring.
3. `tosca_module` Get on the chosen `moduleId` — learn required attribute paths (e.g. TBox Wait → `Duration`).
4. Reference that `moduleId` from `tosca_teststep_edit` Upsert.

**Never hardcode module ids** — they are tenant/space-local. Never invent attribute paths. Search may return ≤ ~100 hits; narrow the query.

Cheap smoke fixture: **TBox Wait** with `Duration` = `1000` (milliseconds).

## When to reach for Standard Objects

| Need | Prefer | Avoid |
|------|--------|-------|
| Wait / sync delay | TBox Wait | Sleeping in agent code |
| Capture / reuse values | TBox Set Buffer, Name to Buffer, Partial Buffer | Ad-hoc User NonGui “buffer” modules |
| Launch / close apps | TBox Start Program, Close Program | OS-specific custom modules unless required |
| File / folder ops | TBox File / Folder modules | Custom file helpers when SO covers it |
| Excel / JSON / XML / DB / mail / PDF | Matching tech pack below | Reimplementing parsers in test logic |
| SAP / Mobile / HTML extras | Matching tech pack | Only when User XScan modules don’t already cover the UI |

User-scanned Gui modules still win for **application-specific controls**. Standard Objects win for **cross-cutting automation and tech helpers**.

## Automation tools (technology-agnostic)

### Timing

| Module | Useful for |
|--------|------------|
| **TBox Wait** | Fixed delay between steps (ms). Smoke / sync while UI settles. |
| **TBox Start Timer** / **TBox Stop Timer** | Measure duration within one test case; optional Verify on max duration. |

### Buffers

| Module | Useful for |
|--------|------------|
| **TBox Set Buffer** | Write a named buffer value for later steps. |
| **TBox Name to Buffer** | Buffer a control’s name / identity. |
| **TBox Partial Buffer** | Slice / partial extract into a buffer. |
| **TBox Delete Buffer** | Clear buffers. |
| **TBox Iterate Array** / **TBox Array Operation** | Walk or transform buffer arrays. |

### Files & folders

| Module | Useful for |
|--------|------------|
| **TBox File Existence** / **TBox Folder Existence** | Preconditions / Verify before IO. |
| **TBox Copy File** / **Move/Rename File** / **Delete File** | File lifecycle on the agent machine. |
| **TBox Read/Create file** / **TBox Append File** | Create or append text content. Double every `"` in `Text`; wrap the value in quotes only when it contains `{` — see [literal braces and quotes](testcase-structure.md#literal-braces-and-quotes-in-step-values). |
| **TBox File Compare** / **TBox Image Compare** | Diff files or images. |
| **TBox Zip File** / **TBox Unzip File** | Archive handling. |
| **TBox Create / Copy / Delete Folder** | Folder lifecycle. |

### Process, windows, input

| Module | Useful for |
|--------|------------|
| **TBox Start Program** / **TBox Close Program** | Launch or terminate processes on the agent. |
| **TBox Send Keys** | Keyboard input to the focused UI. |
| **TBox Window Operation** / **Scroll Window Operation** | Activate, maximize, scroll windows. |
| **TBox Dialog** / **TBox Context Menu** / **TBox Save As** | Common OS dialogs / menus. |
| **TBox Clipboard** | Read/write clipboard. |
| **TBox Take Screenshot** | Capture evidence mid-run. |

### Expression, numeric, resources, unit tests

| Module | Useful for |
|--------|------------|
| **TBox Evaluation Tool** | Evaluate expressions (conditions, calculations). |
| **TBox Convert Decimal** | Numeric format conversion. |
| **TBox Delete Resource** | Clean up named resources created earlier in the run. |
| **TBox Run Test Scripts** | Run unit-test style scripts from the agent. |

### Test data (TDM-style)

Modules named **Test data - …** (Create/Find/Update/Delete/Export/Import/Move/Rename/Expert). Use when the space uses Tosca test-data sets and you need row lifecycle from a step — not for arbitrary DB SQL (see Database pack).

## Technology-specific packs

Search `scope=StandardObjects` with the pack keyword (Excel, SAP, JSON, …) when the user’s app stack matches.

| Pack | Representative modules | Useful for |
|------|----------------------|------------|
| **Database** | DB Open/Close Connection, DB Run SQL Statement, DB Expert, DB Current Connection | SQL against a configured DB connection on the agent. **Data Integrity DB Expert** is a different module: Search **`DI DB Expert module`** (see [di-db-expert-testcase.md](workflows/di-db-expert-testcase.md)). |
| **Excel** | Open / Close/Save Workbook, Define/Manipulate/Clear Range, Create/Delete/Update Worksheet, Run Macro, 1:1 File Compare | Spreadsheet steering and compare |
| **File (resources)** | Open file, Open/Save file Resource | File resources vs TBox file path ops |
| **JSON** | Open/Create JSON file, Create/Save JSON Resource, JSON Schema Validation | API / config payload checks |
| **XML** | Open/Create XML, Create/Save Resource, Verify XML, Evaluate XPath, Get XML from Connection | XML assert and XPath |
| **HTML** | Execute / Verify JavaScript, Open embedded Chrome/Chromium, Start/Stop HTML Log Monitoring | Browser helpers beyond scanned modules |
| **Mail** | Connect (Cloud / Mail Server), Send Mail, Receive Mail Simple/Expert | Inbox/outbox verification |
| **PDF** | PDF 1:1 Compare, Check PDF for Broken Links | Document compare / link checks |
| **Mobile** | Open Mobile Connection/App, Switch App, Send Text Input, Upload/Download File, Appium Context | Device/session glue around mobile Gui modules |
| **SAP** | SAP Logon/Login, Menu, Toolbar, Statusbar, TreeView, ContextMenu, … | Classic SAP GUI steering helpers |
| **SAP Fiori** | Tile, Message Toast, WaitForBusyIndicator | Fiori shell waits / tiles |
| **SAP Netweaver / SuccessFactors** | Netweaver logon helpers; SuccessFactors Search Box | Pack-specific entry points |
| **Host** | Host Send Keys, Host Change Session | Mainframe/host sessions |
| **Java** | Java Security Information | Java runtime security prompts |
| **Oracle** | Oracle InputSearch | Oracle Forms-style search |
| **Testim** | Run Testim Test / Suite / Plan, Wait for Testim Test | Delegate to Testim from a Tosca step |
| **TextStream** | (pack modules via Search `TextStream`) | Stream read/write helpers |

Data Integrity has its **own** DI modules and MCP DI tools — do not confuse DI comparison modules with the generic Database pack above. See [di/index.md](di/index.md).

## Authoring tips

- **Name match:** Search uses substring; try `TBox Wait`, `Wait`, `Excel`, `SAP Login`.
- **Required attrs:** After Get, Prefer ExactlyOne / required leaves; empty optional branches are fine.
- **Duration units:** TBox Wait `Duration` is **milliseconds** (1000 = 1s).
- **Agent machine:** File/process/Excel modules run on the **execution agent**, not the MCP host.
- **Do not edit SO:** Clone behavior by referencing SO from steps; only User-assets modules are Upsert/Delete targets.

Related: [module-attribute-values.md](module-attribute-values.md) · [builder-orchestration.md](../builder-orchestration.md) · [workflows/create-testcase.md](workflows/create-testcase.md)
