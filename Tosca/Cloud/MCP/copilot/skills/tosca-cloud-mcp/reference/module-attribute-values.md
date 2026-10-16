# Module attribute values — `tosca_module_edit`

What you can set on User-assets modules via Upsert. Standard Objects are Get-only. Use **Scan** / **Rescan** on `tosca_module_edit` to kick off the Cloud scanner (launcher or portal link). After Scan, discover the module with Search `scope=UserAssets` `sort=Latest`. Upsert still edits metadata/defaults/attributes on existing modules.

## Module-level fields

| Field | Allowed | Default / notes |
|-------|---------|-----------------|
| `name` | string | Required on create |
| `description` | string | Optional |
| `businessType` | free string | Module root type (often empty/`String` for NonGui shells) |
| `interfaceType` | `Gui` \| `NonGui` | Create defaults to **NonGui** |
| `parentFolderId` | inventory folder id | Create only |
| `attributes[]` | tree | Omit on update = no change; if provided (incl. `[]`) **replaces** whole tree — keep `id`s when preserving nodes |

## Attribute fields (`attributes[]`)

| Field | Allowed values | Default |
|-------|----------------|---------|
| `id` | existing attribute id | Omit on create; keep on replace |
| `name` | string | Required |
| `description` | string | Optional |
| `businessType` | see [Business types](#business-types) | `String` if omitted |
| `defaultValue` | string | Applied when used in a test step |
| `defaultActionMode` | `Input` \| `Insert` \| `Verify` \| `Buffer` \| `WaitOn` \| `Select` \| `Constraint` \| `Exclude` \| `Output` \| `Delete` \| `Modify` | `Input` |
| `defaultDataType` | `String` \| `Date` \| `Numeric` \| `Boolean` \| `Password` \| `Secret` \| `RawString` | `String` |
| `cardinality` | `ZeroToOne` \| `ZeroToN` \| `OneToN` \| `ExactlyOne` | `ZeroToOne` |
| `interfaceType` | `Gui` \| `NonGui` | Optional on attribute |
| `isVisible` | bool | `true` |
| `parameters[]` | steering/technical props | See below |
| `attributes[]` | nested children | Recursive tree |

**Cardinality (UI labels):** ZeroToOne = 0–1 · ZeroToN = 0–n · OneToN = 1–n · ExactlyOne = 1. Required ExactlyOne attrs must get values when creating test steps.

**ActionMode note:** `Output` exists for legacy data; prefer Input/Verify/Buffer/WaitOn/Select/… for new work. Backend also accepts `I` (legacy alias) — do not use it in new modules.

## Parameter fields (`parameters[]` on an attribute)

Scanner-stored identification and steering live here (e.g. TechnicalId, Steering props).

| Field | Allowed | Default |
|-------|---------|---------|
| `id` | existing parameter id | Omit on create; keep on replace |
| `name` | string (property name) | Required |
| `value` | string | Optional |
| `type` | `Business` \| `Technical` \| `Steering` \| `Implementation` \| `BusinessId` \| `TechnicalId` \| `ReflectedId` \| `Transition` \| `Configuration` \| `SmartId` | `Technical` |

Typical scanner/Gui usage: `TechnicalId` / `BusinessId` / `ReflectedId` / `SmartId` for identification; `Steering` / `Technical` for engine properties. Manual NonGui shells often need few or no parameters.

## Business types

`businessType` is a string. Scanner/Gui controls commonly use these (Cloud FE `BusinessType`):

`Control`, `ControlGroup`, `HtmlFrame`, `HtmlDocument`, `Link`, `LinkGroup`, `Table`, `Row`, `Column`, `Cell`, `CheckBox`, `ComboBox`, `ComboEditBox`, `Button`, `ButtonGroup`, `TextBox`, `DatePicker`, `Label`, `Container`, `Document`, `RadioButton`, `RadioButtonGroup`, `GenericGUI`, `Window`, `ContextMenu`, `Tab`, `TabControl`, `Image`, `Menu`, `MenuItem`, `Slider`, `ListBox`, `ListItem`, `Tree`, `TreeNode`, `TableTree`, `ProgressIndicator`, `Expander`, `Parameter`, …

Mobile / PDF / JSON / XML / DB variants also appear (`MobileButton`, `MobileTextBox`, `PdfPage`, `JsonObject`, `XmlElement`, `Connection`, `DatabaseConnectionInfo`, …).

For **manual NonGui** shells, `String` (MCP default) or a simple descriptive type is fine. Prefer copying `businessType` from a similar existing User-assets or Standard Objects module via `tosca_module` Get when editing Gui modules.

## Practical guidance

1. Create empty NonGui shell: Upsert with `name` only → `interfaceType=NonGui`, `attributes=[]`.
2. Add attributes: Upsert with full `attributes[]` tree (replace); set `cardinality=ExactlyOne` for required fields.
3. Editing scanned Gui: Get first, keep attribute/parameter `id`s, only change what you intend — identification parameters come from scan.
4. Never invent steering parameter names — Get a similar module or keep scanner values.
5. After module Upsert, create steps with `tosca_testcase_edit` / `tosca_teststep_edit` using attribute **paths** from Get.
