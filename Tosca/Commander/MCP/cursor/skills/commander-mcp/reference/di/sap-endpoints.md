# SAP endpoint reference

## SAP endpoint (`type: "sap"`) (`type: "sap"`) format

An endpoint with `type: "sap"` reads an SAP table through the SAP Custom Data Reader. It does NOT
use a DI connection and has NO `sql` — instead you supply logon details plus a `tablename`, and
optionally restrict rows/columns with `rowFilters`/`columnFilters`. The tool sets the test step's
Class Attribute Name to `SapReader` and writes each field below as an SAP Custom Data Reader
parameter. Either side (source or target) may be SAP.

| Field | Meaning | Required |
|-------|---------|----------|
| `systemNumber` | ABAP application server instance number (00-99) | yes |
| `applicationServer` | DNS name or IP address of the application server | yes |
| `client` | Client ID used to log into SAP (e.g. 200) | yes |
| `language` | Logon language (e.g. EN) | yes |
| `username` | SAP user name | yes |
| `tablename` | SAP table to read (case-sensitive, e.g. KNA1) | yes |
| `dataProvisioningTimeout` | Seconds to wait for SAP to deliver data (default 300) | no |
| `rowFilters` | Restrict which rows are read (syntax below) | no |
| `columnFilters` | Restrict which columns are returned (syntax below) | no |

The SAP **password** is not a parameter — it is never passed through MCP. After the test step is
created, open it in the Tosca UI and enter the password on the SAP Custom Data Reader (stored
encrypted as a Commander Password type, masked in the UI).

### Prerequisites — install the SAP Custom Data Reader (one-time, per machine)

SAP support is NOT part of the Tosca setup. Before SAP tests can run, the executing machine must
have the SAP .Net Connector installed into Tosca. **The MCP tools cannot install these for you** —
if they are missing, `create_di_row_by_row_comparison` still succeeds, but executing the test
(`execute_test_suite`, or running it in Commander) fails at runtime. Tell the user to:

1. Download the **SAP Connector for Microsoft.Net 3.1 for Windows 64bit compiled for .NET**
   (formerly .NET Core) from SAP — this is not shipped with Tosca.
   - [SAP .NET Connector download](https://support.sap.com/en/product/connectors/msnet.html)
2. Download the **ABAP AddOn** from the Tricentis support portal.
   - [ABAP AddOn download (Tricentis support portal)](https://support-hub.tricentis.com/open?id=csm_login&direct_download_link_number=DOW0009179)
3. Copy these six files from the SAP .Net Connector into
   `C:\Program Files (x86)\TRICENTIS\Tosca Testsuite\Data Integrity\Custom Data Readers\SAP`:

   | File | Version |
   |------|---------|
   | `cpc4n.dll` | 1.1.4.0 |
   | `ijwhost.dll` | 8.0.624.26715 |
   | `Microsoft.Win32.Registry.dll` | 5.0.20.51904 |
   | `sapnco.dll` | 3.1.5.0 |
   | `sapnco_utils.dll` | 3.1.5.0 |
   | `System.Configuration.ConfigurationManager.dll` | 8.0.23.53103 |

If a SAP comparison fails at execution with a missing-assembly / data-reader-load error, the most
likely cause is that these six DLLs are absent from the `Custom Data Readers\SAP` folder above —
surface this checklist to the user. (The tool sets the Class Attribute Name to `SapReader`
automatically; you do not need to set it.)

### `rowFilters` syntax

Pattern: `F[Field],O[Operator],L[Low],H[High],S[I|E]`
- `F` = field name, `O` = operator, `L` = low value, `H` = high value (only for `BT`), `S` = `I` include or `E` exclude.
- Low-value operators: `EQ` (equal), `NE` (not equal), `LT`, `LE`, `GT`, `GE`, `CP` (contains pattern, e.g. `Sm*th` matches `Smith`/`Smyth`; no regex).
- High+low operator: `BT` (between) — requires `H[...]`.
- Separate multiple filters with `;`.
- Combine with **OR**: repeat the same `F`, e.g. `F[NAME1],O[EQ],L[Anna],S[I];F[NAME1],O[EQ],L[Julia],S[I]`.
- Combine with **AND**: use different `F` (or different `S`), e.g. `F[AGE],O[BT],L[20],H[50],S[I];F[LAND1],O[EQ],L[DE],S[I]`.

Examples: `F[LAND1],O[EQ],L[DE],S[I]` (only German rows); `F[AGE],O[BT],L[20],H[50],S[I]` (ages 20-50).

### `columnFilters` syntax

Pattern: `F[Field]`, multiple separated by `;`. Example: `F[KUNNR];F[NAME1];F[LAND1]` returns only
those three columns. Omit `columnFilters` to read every column.

---
