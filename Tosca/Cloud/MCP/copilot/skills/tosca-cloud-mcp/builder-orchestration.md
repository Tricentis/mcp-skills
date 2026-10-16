# Builder orchestration — modules, test cases, test steps

Authoring maps to Tosca Cloud “Create tests”: reuse or create modules, design the test case (steps + folders + TCPs), then verify with Get. Prefer existing modules; if a UI module is missing, kick off **Scan** / **Rescan** via `tosca_module_edit` (returns a launcher or portal link — open it, wait for the user to finish the scanner, then Search Latest or Get). MCP can also create manual/NonGUI shells and edit metadata/attributes.

Copy and track progress:

```text
Authoring workflow:
- [ ] tosca_module Search / Get (learn attribute paths)
- [ ] tosca_testcase_edit Upsert (create or update container)
- [ ] tosca_teststep_edit Upsert / Move / Delete (items)
- [ ] tosca_testcase Get + tosca_teststep Get/List (verify)
- [ ] Optional: tosca_testrun_edit Create → tosca_testrun Get (trial run)
```

## Modules — `tosca_module` / `tosca_module_edit`

| Tool | Ops | Notes |
|------|-----|-------|
| `tosca_module` | Get, Search | ReadOnly. Search: `name?`, `scope` All \| StandardObjects \| UserAssets (default All), `sort` Name \| **Latest**. Cap ~100 hits. After Scan, use scope=UserAssets + sort=Latest. |
| `tosca_module_edit` | Upsert, Delete, **Scan**, **Rescan** | User assets only (Upsert/Delete/Rescan). Scan kicks off Cloud Scan (launcher / ME3.0 traviata / Salesforce portal). Rescan requires `isRescanEnabled`. Soft-load rejects Standard Objects. |

**Search**

- Empty/omit `name` → list slice; narrow with substring.
- Standard Objects hits include `packageId` / `packageName`.
- User assets: no packageId.

**Get** — full module definition + portal `url`. **Required before stepping:** note ExactlyOne / required attribute paths (e.g. TBox Wait `Duration`). Do not invent paths.

**Upsert create** (no `moduleId`): `name` required; defaults `interfaceType=NonGui`, empty `attributes[]`. Optional `description`, `businessType`, `parentFolderId`, `attributes[]`.

**Upsert update** (with `moduleId`): omit/null field = no change. If `attributes[]` is provided (including `[]`), it **replaces the whole tree** — keep attribute `id`s when preserving nodes.

**Delete** — hard delete User-asset module; warn first (usages not force-checked).

**Attribute / parameter values you can set:** see [reference/module-attribute-values.md](reference/module-attribute-values.md) (`defaultActionMode`, `defaultDataType`, `cardinality`, `businessType` control types, `parameters[].type`, Gui vs NonGui). Do not invent steering parameter names — Get a similar module or keep scanner values.

Cheap fixtures for smoke: Standard Objects `TBox Wait` (Duration **1000** ms), optionally `TBox Read/Create File`. Catalog: [standard-modules.md](reference/standard-modules.md).

## Test cases — `tosca_testcase` / `tosca_testcase_edit`

A test case is: `id` + `name` + `description` + `workState` (Planned \| InWork \| Completed) + `tcp[]` + `parameterSetIds` + `items[]` (ordered steps, folders, control flow, scenarios). Tenancy comes from the connection.

**Full parameter / hierarchy reference:** [reference/testcase-structure.md](reference/testcase-structure.md) (TCPs, inheritance, folders, Move/Delete, `values[]`, structure recipes).

| Tool | Ops | Notes |
|------|-----|-------|
| `tosca_testcase` | Get | ReadOnly. Requires `testCaseId`. Returns portal `url`, `workState`, merged tcp[], items[]. |
| `tosca_testcase_edit` | Upsert, Delete, UploadRecording | Create when no `testCaseId`; update when id set. |

**Upsert create:** `name` required. Optional `description`, `workState` (default `InWork`), `tcp[]`, `parameterSetIds`, `steps[]` (root steps only). `steps=[]` or omit → empty shell; add folders/steps via `tosca_teststep_edit`. Each step: `moduleId` + `values` for required attrs (mandatory attrs with a module default get it automatically).

**Upsert update:** omit/null = no change. `workState` sets Planned \| InWork \| Completed. `tcp=[]` clears case-local TCPs; `parameterSetIds=[]` clears sets. Step/folder mutations belong on `tosca_teststep_edit` (update does not accept `steps[]`).

**UploadRecording:** `recordingResult` (recorder ExecutionTask JSON, passed through unmodified). No `testCaseId` → new test case (+ optional `parentFolderId`); with `testCaseId` → replaces that test case's steps and modules in place — confirm first. `autoMerge: true` merges recorded modules into matching existing ones. Details: [testcase-structure.md](reference/testcase-structure.md#recorded-test-cases--tosca_testcase_edit-uploadrecording).

**Reusable test step blocks (RTSB):** `tosca_rtsb` Get (`rtsbId` from `tosca_asset` Search `artifactType=sharedAction`) → name, version, `businessParameters[]`, `items[]`. Create/update/delete the block with `tosca_rtsb_edit`; edit items with `tosca_teststep_edit`, `testStepContainerType=rtsb`, and `testStepContainerId` (see [Writing RTSBs](#writing-rtsbs)). Referenced in test cases as `kind: testStepFolderReference`.

**Test case templates:** `tosca_testcasetemplate` Get (`testCaseTemplateId` (the hit `id`) from `tosca_asset` Search `artifactType=testCaseTemplate`) → `portalUrl`, `workState`, merged `tcp[]`, `parameterSetIds`, `testSheetId`, `instantiationCondition`, `items[]`. Per-item `instantiationCondition` / `xlBasePath` appear only when set. Requires the TestCaseDesign entitlement. Do not call `tosca_testcase` Get for a template id. Get is read-only.

Edit the step tree with `tosca_teststep` / `tosca_teststep_edit` and `testStepContainerType=testCaseTemplate` (`testStepContainerId` = the template id). Same kinds, parentId rules, and Delete/Move as a test case. Optional `instantiationCondition` / `xlBasePath` on Upsert (empty string clears; omit = no change). Do not pass those fields on a test case or RTSB. Create-from-test-case / rename / link sheet / delete are not on this surface yet (`tosca_testcasetemplate_edit`). The sheet behind `testSheetId` can be read and edited with `tosca_testsheet` / `tosca_testsheet_edit` (see [Test sheets (TDM)](#test-sheets-tdm)); linking a sheet to a template is still portal-only.

| Question | Tool |
|----------|------|
| Find templates by name | `tosca_asset` Search `artifactType=testCaseTemplate` |
| Read a template's steps and TCD fields | `tosca_testcasetemplate` Get |
| Add / change / move / delete template steps | `tosca_teststep_edit` with `testCaseTemplate` |
| Read the template's test sheet | `tosca_testsheet` Get (`testSheetId` from the template) |

**Test outlines:** `tosca_testoutline` Get (`testCaseId`) or GetByExternalId (`externalTenantId` + `externalProjectId` + `externalTestCaseId`, e.g. qTest) → ordered groups of manual steps with `expectedResult`. Use as authoring input; "not found" means no outline yet (also how to poll for sync).

**TCP / secrets**

- Shape: `{ name, value?, dataType? }` — **String \| Boolean \| Password** only (default String). Secret → Password.
- Hierarchy: Tenant → Workspace → case-local (case wins). Get merges via the same `allParameters` source as Builder FE; Upsert writes **case-local only** (`tcp: []` clears locals; inherited remain).
- `inheritedFrom` / `overwritten` are Get metadata. `parameterSetIds` attach sets by id (not expanded into `tcp[]`).
- Password values are always null on Get. Never pass secrets through MCP; create empty Password shells only. On reject, surface the portal `url`.
- Details: [testcase-structure.md](reference/testcase-structure.md#tcps--tcp-test-configuration-parameters).

**Standard Objects:** prefer shipped modules (Wait, Buffer, File, Excel, …) over inventing NonGui shells — [standard-modules.md](reference/standard-modules.md). Search `scope=StandardObjects` then Get; never hardcode ids.

## Test steps / folders — `tosca_teststep` / `tosca_teststep_edit`

| Tool | Ops | Notes |
|------|-----|-------|
| `tosca_teststep` | Get, List | Get needs `testStepContainerId` + `itemId` (control-flow items return `branches[]`; scenarios return metadata + `childCount`). List needs `testStepContainerId` + `parentId` (container id for root, folderId, control-flow branch id, or scenarioId). Empty folders, branches, and scenarios included. `testStepContainerType`: `testCase` (default), `rtsb`, or `testCaseTemplate`. |
| `tosca_teststep_edit` | Upsert, Delete, Move | Never creates a parent artifact — create the TC, RTSB, or template first. |

**Upsert insert** (no `itemId`): `kind` = `testStep` \| `testStepFolder` \| `testStepFolderReference` \| `if` \| `while` \| `do` \| `else` \| `recoveryScenario` \| `cleanupScenario` (aliases `step`/`folder`/`recovery`/`cleanup`).  
- testStep → `moduleId` (+ optional name / values / disabled / position)  
- testStepFolder → `name` (+ optional disabled / position)  
- testStepFolderReference → `rtsbId` (the block to reuse; not the container id)  
- if → `name` (+ optional `includeElse`, disabled / position)  
- while / do → `name` (+ optional `maximumRepetitions` — `"30"` default, positive integer or `"{CP[Name]}"` expression)  
- else → `parentId` = the **if item id**; adds the ELSE branch  
- recoveryScenario → `name` (+ optional `retryLevel` TestStep \| TestStepValue \| TestCase, default TestStep; disabled / position)  
- cleanupScenario → `name` (+ optional disabled / position)  
`parentId` = testStepContainerId (root), folderId, a **scenarioId** (steps inside a scenario), or a control-flow **branch id** (`Condition` / `THEN` / `ELSE` / `Loop`, `kind: controlFlowCondition` in `items[]`) — this is how nested structures are built. The condition is expressed as steps (usually `Verify`) inside the `Condition` branch.

**Upsert update** (`itemId` set): optional name, disabled, `values[]` (steps only), `maximumRepetitions` (loops only), `retryLevel` (recovery scenarios only). On modify: omit `value` to leave; pass `null` to remove attribute node.

**Control flow details** (branch order, ELSE add/remove, retry/optional-path recipes, what isn't supported): [testcase-structure.md](reference/testcase-structure.md#control-flow--if--while--do--else-tosca_teststep_edit).

**Scenario details** (root/folder only, scenario-only positions, retryLevel): [testcase-structure.md](reference/testcase-structure.md#recovery-and-cleanup-scenarios-tosca_teststep_edit).

**values[]:** `{ path, value?, actionMode?, explicitName? }` — path is dot-separated from module root. actionMode: Input, Verify, Buffer, WaitOn, …

**Literal `{` and `"` in a value:** A single `"` starts a TBox quoted string, so double every `"` in the text (`"` → `""`). Wrap the whole value in `"` only when it also contains `{` — TBox treats `{` as a dynamic expression. `{ "name": "John Doe" }` is sent as `"{ ""name"": ""John Doe"" }"`. `LIKE '%Ma"k%'` (no braces) is sent as `LIKE '%Ma""k%'`, with no surrounding quotes. Unquoted `{` fails at run time with `Token is not valid in this context: "`. Details: [testcase-structure.md](reference/testcase-structure.md#literal-braces-and-quotes-in-step-values).

**Delete:** `itemIds[]`; `recursive: true` required for non-empty folders, control-flow blocks, ELSE branches, and scenarios (default false). An ELSE branch id removes only the ELSE; Condition / THEN / Loop go only with their block.

**Move:** `itemId` + `parentId` + `toIndex` (index within target container). A block can't move into itself or its own branches.

**Rename a step/folder:** Upsert with `itemId` + `name`.

**Structure recipes** (flat, nested Login/Checkout, disable section, password TCP): [testcase-structure.md](reference/testcase-structure.md#structure-recipes).

## API messages — `tosca_apimessage` / `tosca_apimessage_edit`

HTTP/JMS message definitions used by API tests. Automate API entitlement required. Full sequence: [reference/workflows/manage-api-message.md](reference/workflows/manage-api-message.md).

| Tool | Ops | Notes |
|------|-----|-------|
| `tosca_apimessage` | Get | ReadOnly. Requires `messageId`. Full JSON — use as input to Upsert. |
| `tosca_apimessage_edit` | Upsert, Delete | Destructive. Create: omit `messageId`. Update: with `messageId`, **full replacement** — Get first, confirm. Delete: confirm. |

**Create** (no `messageId`): `request` with `name`, `method` (GET, POST, PUT, PATCH, DELETE; default GET), and either `endpoint` or `connectionId` (from `tosca_apiconnection` List). If both are set, the named connection wins. Bearer tokens and API keys do not go in `headers` (clear text): prefer `connectionId`, or leave the header value for the user to fill in the portal. Portal link on success.

**Update** (with `messageId`): Get first; carry unchanged fields. Named connection: `tcProperties.DefaultConnection` → `connectionId`. Inline Basic auth: the stored password cannot be carried over — warn that the update clears it and send the user to the portal link; never ask for it. Confirm — may affect dependent test cases. Never delete+recreate to work around failure.

**Delete** — `messageId`. Confirm — dependent test cases fail at runtime if not adapted.

Pair with [apiexecution-orchestration.md](apiexecution-orchestration.md). Hand off full authoring journeys to `tosca-authoring-automated-testcase`.

## Reusable test step blocks (RTSBs)

RTSBs are reusable step sequences with business parameters. In inventory search, the artifact type wire name is `sharedAction`.

```
1. tosca_asset Search (artifactType: sharedAction, name: <substring>) — find candidates
2. tosca_rtsb Get (rtsbId) — read steps + businessParameters[]
```

| Question | Tool sequence |
|----------|---------------|
| Does an RTSB named X already exist? | `tosca_asset` Search with `artifactType: sharedAction` and `name` filter; compare hit names |
| Summarize an RTSB's steps and parameters | `tosca_rtsb` Get after resolving id via Search |
| What module steps does an RTSB contain? | `tosca_rtsb` Get → `items[]` (kind `testStep` has `moduleId`) |

Nested RTSBs appear in `items[]` as `kind: testStepFolderReference`. Do not call the Builder debug list endpoint — inventory search is the supported discovery path.

### Writing RTSBs

Two tools split the work, and the split is not arbitrary: a Builder write replaces the whole block, and the `tosca_rtsb` projection omits per-step internals (`XLBasePath` / instantiationCondition). Sending that projection back would silently drop them, so `tosca_rtsb_edit` does not accept an `items[]` tree at all. Recovery/cleanup scenarios and control-flow blocks (`controlFlowItem` / `controlFlowCondition`) are part of `items[]` on Get — edit them with `tosca_teststep_edit`, `testStepContainerType=rtsb`, and `testStepContainerId`.

| Goal | Tool |
|------|------|
| Create a block, rename it, edit its business parameters, delete it | `tosca_rtsb_edit` |
| Add, update, move or delete the steps, folders, control-flow blocks, and recovery / cleanup scenarios inside it | `tosca_teststep_edit` with `testStepContainerType=rtsb` and `testStepContainerId` |

```
1. tosca_rtsb_edit Upsert (name) — create the shell, returns the new rtsbId
2. tosca_teststep_edit Upsert (testStepContainerType: rtsb, testStepContainerId: <rtsb id>, parentId: <rtsb id>, kind: testStep, moduleId, values) — fill it
3. tosca_rtsb Get (rtsbId) — confirm
```

`tosca_teststep` and `tosca_teststep_edit` take `testStepContainerType` (`testCase` default, `rtsb`, or `testCaseTemplate`) plus `testStepContainerId`; `parentId` means the root when it equals that id.

**Business parameters** — supplying `businessParameters[]` replaces the whole tree. Parameters whose names are unchanged keep their ids, so the steps bound to them stay bound. To rename one without breaking those bindings, pass its existing id (from `tosca_rtsb` Get) alongside the new name.

**Deleting** — Idempotent: a missing id still returns `deleted: true`. Builder hard-deletes and does not check references, so `tosca_rtsb_edit` Delete looks them up first. If any test case or other RTSB still uses the block it deletes nothing and returns `deleted: false` with a `usages[]` list to work through. `force: true` overrides this and leaves the remaining references dangling — only use it when the consumers are being removed too.

## Test sheets (TDM)

Test sheets hold the test data that test case templates instantiate: an attribute tree, each attribute's instances (possible values), and generated test case instances (rows). Classes are reusable attribute blocks that sheets embed as class references. TestCaseDesign entitlement required. Concepts, paths, limits and downstream impact: [reference/testsheet-structure.md](reference/testsheet-structure.md).

| Tool | Ops | Notes |
|------|-----|-------|
| `tosca_testsheet` | List, Get, ListInstances | ReadOnly. List: name contains-filter, `includeClasses`. Get: tree with dotted `path`s, instances, portal `url`. ListInstances: rows, paged (≤200). Not searchable via `tosca_asset`. |
| `tosca_testsheet_edit` | Upsert, Delete, AttributeUpsert, AttributeDelete, InstanceUpsert, InstanceDelete, ClassReferenceAdd, ClassReferenceDetach, ConvertToClass, AssignChildInstance, UnassignChildInstance, GenerateRows, RowUpsert, RowDelete | Destructive. Exactly one of id or path/name per target. Structural writes return the re-read sheet. |

### Writing test sheets

One write tool covers the whole sheet, grouped by prefix (sheet, `Attribute*`, `Instance*`, `ClassReference*` / `ConvertToClass`, `*ChildInstance`, `Row*` / `GenerateRows`). Writes inside a class reference are rejected — edit the class instead.

| Goal | Operation |
|------|-----------|
| New sheet with its attributes and instances | Upsert (no id) with `attributes[]` — one call; rolled back if the tree fails |
| Change the tree | AttributeUpsert / AttributeDelete / InstanceUpsert / InstanceDelete |
| Reuse or extract a class | ClassReferenceAdd / ClassReferenceDetach / ConvertToClass |
| Rows | GenerateRows (preview first) / RowUpsert / RowDelete |

```
1. tosca_testsheet Get (testSheetName) — resolve paths and ids
2. tosca_testsheet_edit <operation> — confirm first when it is on the list in manage-testsheet.md
3. Check the returned sheet (or tosca_testsheet ListInstances for rows)
```

**Rows** — GenerateRows (`linearExpansion` \| `orthogonal`) previews by default; `preview: false` appends and never replaces existing rows. Row ids feed `tosca_requirement_edit` LinkTestSheet.

**Deleting** — Sheet Delete is permanent and breaks template instantiation; confirm. A class still referenced by test sheets is not deleted: the result has `deleted: false` and `references[]`. `force: true` detaches those sheets first (they keep local copies), then deletes — separate confirmation. Never delete and recreate a sheet to work around an error.

Full sequences: [inspect-testsheet.md](reference/workflows/inspect-testsheet.md), [manage-testsheet.md](reference/workflows/manage-testsheet.md).

## Related

- [reference/workflows/create-testcase.md](reference/workflows/create-testcase.md)
- [reference/workflows/manage-testsheet.md](reference/workflows/manage-testsheet.md)
- [reference/testsheet-structure.md](reference/testsheet-structure.md)
- [reference/workflows/manage-api-message.md](reference/workflows/manage-api-message.md)
- [reference/workflows/trial-run-testcase.md](reference/workflows/trial-run-testcase.md)
- [reference/testcase-structure.md](reference/testcase-structure.md)
- [reference/module-attribute-values.md](reference/module-attribute-values.md)
- [reference/standard-modules.md](reference/standard-modules.md)
- [execution-orchestration.md](execution-orchestration.md)
