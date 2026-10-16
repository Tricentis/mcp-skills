# Test case structure — TCPs, folders, steps, control flow, scenarios

Exact shapes supported by `tosca_testcase` / `_edit` and `tosca_teststep` / `_edit`. Use this when the user asks for a specific hierarchy, parameters, or step values.

## Mental model

```
Test case
├── name, description
├── workState                # Planned | InWork | Completed (create defaults to InWork)
├── tcp[]                    # test configuration parameters (case-local + inherited on Get)
├── parameterSetIds[]        # linked parameter-set ids
└── items[] (ordered tree)
    ├── testStep             # moduleId + values[]
    ├── testStepFolder       # nested items[]
    ├── controlFlowItem      # if / while / do — children live in branches (kind controlFlowCondition)
    │   ├── if    → Condition, THEN, [ELSE]
    │   ├── while → Condition, Loop
    │   └── do    → Loop, Condition
    ├── recoveryScenario     # root or folder only; steps run to recover after a failure (retryLevel)
    ├── cleanupScenario      # root or folder only; steps run to clean up after a failure
    └── (read-only kinds)    # testStepFolderReference (RTSB reference) may appear on Get — not creatable via MCP; read the block with tosca_rtsb
```

No `workspaceId` argument — tenancy comes from the MCP connection.

---

## Get payload — `tosca_testcase` Get

| Field | Meaning |
|-------|---------|
| `id` | Test case id |
| `url` | Portal link (Builder) |
| `name` / `description` | Metadata |
| `workState` | `Planned` \| `InWork` \| `Completed` |
| `tcp[]` | Merged TCPs (see below) |
| `parameterSetIds[]` | Linked sets |
| `items[]` | Depth-first summary of the tree |

### `items[]` summary row

| Field | Meaning |
|-------|---------|
| `index` | Position **within that item’s container** (root, folder, or control-flow branch) — same index `position` / `toIndex` use |
| `kind` | `testStep` \| `testStepFolder` \| `controlFlowItem` \| `controlFlowCondition` \| `recoveryScenario` \| `cleanupScenario` \| `testStepFolderReference` \| … |
| `id` | Item id (branch ids are usable as `parentId`) |
| `name` | Display name (branches: `Condition`, `THEN`, `ELSE`, `Loop`) |
| `parentFolderId` | `null` = under test case root; else parent folder id, branch id, or (for a branch row) its control-flow item id |
| `moduleId` | Set for `testStep` only |
| `disabled` | Skipped at run time when true |
| `valueCount` | Steps only |
| `itemCount` | Folders and branches (direct children) |
| `statementType` | `controlFlowItem` only: `If` \| `While` \| `Do` |
| `maximumRepetitions` | Loops only (string: `"30"` or an expression like `"{CP[MaxRetries]}"`); `null` on If |
| `hasElse` | `controlFlowItem` only |

Rows are depth-first: a `controlFlowItem` row is followed by one `controlFlowCondition` row per branch (index 0, 1, 2 within the item), each followed by that branch's children. Empty folders and branches are included. For a step’s full `values[]`, call `tosca_teststep` Get.

---

## TCPs — `tcp[]` (test configuration parameters)

Handled on the **test case** (same level as `name` / `description`), **not** on steps. Same model as Builder’s Configurations panel in Cloud (TTA.Frontend merges the same way).

### Hierarchy (what “from above” means)

```
Tenant parameters          ← space/tenant defaults (allParameters.tenant)
    ↓  same name: Workspace wins
Workspace parameters       ← workspace defaults (allParameters.workspace)
    ↓  same name: case-local wins (marked overwritten)
Case-local TCPs            ← stored on the test case; only layer Upsert writes
    ↓  (runtime / playlist UI — not expanded into tcp[] by MCP Get)
Linked parameter sets      ← parameterSetIds[] on the test case (ids only on Get)
Playlist / folder overlays ← FE run/playlist grids only; not on tosca_testcase Get
```

| Layer | Where defined | On `tosca_testcase` Get | On `tosca_testcase_edit` Upsert |
|-------|---------------|-------------------------|--------------------------------|
| Tenant | Tenant parameter store | Row with `inheritedFrom: "Tenant"` | **Cannot** write |
| Workspace | Workspace parameter store | Row with `inheritedFrom: "Workspace"` | **Cannot** write |
| Case-local | Test case document | Row with no inherit flags, **or** `inheritedFrom` + `overwritten: true` if it overrides a higher name | **Only** layer you write via `tcp[]` |
| Parameter sets | Sets attached by id | `parameterSetIds[]` only — set members are **not** flattened into `tcp[]` | Replace/clear via `parameterSetIds` |
| Playlist / folder | Playlist run / folder params in FE | Not included | Not supported |

**Precedence for a given name (MCP + Builder FE):** Workspace beats Tenant; case-local beats both. MCP Get merges Tenant + Workspace from `…/_parameters/api/v1/parameters/allParameters/` (same endpoint Builder uses), then overlays case-local — matching FE `mergeParameters` / `dedupeInheritedByName`.

If the parameters service is unavailable, Get still returns **case-local** TCPs only (no inherited rows).

### Shape

```json
{ "name": "Browser", "value": "Chrome", "dataType": "String" }
```

| Field | On Upsert | On Get |
|-------|-----------|--------|
| `name` | Required | Always |
| `value` | String/Boolean only; **omit** for Password | Always `null` for Password (local or inherited) |
| `dataType` | `String` (default) \| `Boolean` \| `Password` | Same; `Secret` normalizes to Password |
| `inheritedFrom` | Ignored if sent | `"Tenant"` \| `"Workspace"` when the name exists above the case (also set when `overwritten`) |
| `overwritten` | Ignored if sent | `true` when a **case-local** TCP overrides an inherited name; `false`/absent for pure inherited or pure local |

### How to read Get `tcp[]`

| What you see | Meaning | Effective value |
|--------------|---------|-----------------|
| No `inheritedFrom`, no `overwritten` | Case-local only | Case value |
| `inheritedFrom: "Tenant"` or `"Workspace"`, `overwritten` not true | Comes from above; not overridden on this case | Inherited value (Password → `null`) |
| `inheritedFrom` set **and** `overwritten: true` | Case-local row overrides that scope | Case value; higher default still exists if you clear the local row |
| Name only on tenant, also on workspace | One row: Workspace (tenant duplicate dropped) | Workspace value |

**Reset an override:** remove that name from the case-local list (Upsert `tcp` **without** that name — remember Upsert **replaces** the whole case-local list). Next Get shows the inherited row again (`overwritten` false).

### Semantics on `tosca_testcase_edit` Upsert

| Call | Effect |
|------|--------|
| Omit `tcp` | No change (update) / no local TCPs (create) |
| `tcp: []` | Clear **all case-local** TCPs — inherited Tenant/Workspace rows still appear on next Get |
| `tcp: […]` | **Replace** the entire case-local TCP list with this list (not a patch-by-name merge) |

Do **not** send inherited-only rows back on Upsert. Send only the case-local definitions you want stored. Metadata fields (`inheritedFrom`, `overwritten`) are Get-only; Upsert ignores them.

**Overwrite an inherited name:** Upsert a case-local TCP with the **same `name`**. Get will show case value + `inheritedFrom` + `overwritten: true`.

### Examples

**Get after merge**

```json
"tcp": [
  { "name": "ApiUrl", "value": "https://case.example", "dataType": "String",
    "inheritedFrom": "Workspace", "overwritten": true },
  { "name": "Browser", "value": "Chrome", "dataType": "String" },
  { "name": "Env", "value": "cloud-dev", "dataType": "String",
    "inheritedFrom": "Tenant", "overwritten": false }
]
```

- `Browser` — case-local only  
- `Env` — inherited from tenant, not overridden  
- `ApiUrl` — workspace default overridden by case-local value  

**Upsert case-local only**

```json
"tcp": [
  { "name": "Browser", "value": "Chrome", "dataType": "String" },
  { "name": "ApiUrl", "value": "https://case.example", "dataType": "String" }
]
```

### Secrets policy

- Password/Secret values are **never** readable or settable via MCP (local or inherited).
- You may create an empty Password shell: `{ "name": "Pwd", "dataType": "Password" }` (no `value`).
- If a non-empty password value is passed → error includes the portal `url` so a human sets it in the UI.
- Never ask the user for secrets to send through MCP.

### `parameterSetIds[]`

Linked **parameter sets** (named bundles of parameters). Separate from Tenant/Workspace inheritance and from `tcp[]`.

| Call | Effect |
|------|--------|
| Omit | No change |
| `[]` | Clear all linked sets |
| `[id, …]` | Replace linked parameter-set ids |

Get returns the ids only — it does **not** expand set members into `tcp[]`. At run time / in playlist UI, set parameters participate in the broader parameter stack; for authoring via MCP, treat sets as attach/detach by id and use `tcp[]` for case-local configuration you need to see and edit directly.

---

## Folders and hierarchy — `tosca_teststep_edit`

Folders are first-class items (`kind: testStepFolder`). They group steps; nested folders are allowed.

### Insert folder

```
operation: Upsert
testStepContainerId: <tc>     # testStepContainerType defaults to testCase
kind: testStepFolder          # aliases: folder, TestStepFolder
name: "Login"                 # required
parentId: <tcId or folderId>  # omit or = testStepContainerId for root
position: 0                   # optional index in that container
disabled: false               # optional; disables whole subtree at run time
```

### Insert step (into root or folder)

```
operation: Upsert
testStepContainerId: <tc>     # testStepContainerType defaults to testCase
kind: testStep                # aliases: step, TestStep; inferred if moduleId set and kind omitted
moduleId: <module>
parentId: <folderId>          # or testStepContainerId / omit for root
name: "Optional step name"    # defaults to module name
disabled: false
position: 1
values: [ { path, value, actionMode?, explicitName? } ]
```

Required attribute values must be provided on insert — taken from `tosca_module` Get. When an `ExactlyOne` or `OneToN` attribute has a module `defaultValue` and you pass no value, MCP fills in the default (same as the Builder UI). `ZeroToOne` / `ZeroToN` attributes stay unset. Mandatory attributes without a default still need a value.

### Insert an RTSB reference

`rtsbId` here is the block to reuse. It is not the container id.

```
operation: Upsert
testStepContainerId: <tc>     # testStepContainerType defaults to testCase
kind: testStepFolderReference
rtsbId: <block id>
parentId: <tcId or folderId>  # omit or = testStepContainerId for root
```

Edit steps inside that block with `testStepContainerType: rtsb` and `testStepContainerId` set to the block id.

### Update step or folder

```
operation: Upsert
testStepContainerId + itemId   # testStepContainerType defaults to testCase
name? / disabled?
values?                       # steps only; omit property = leave; null value = remove node
```

### Move

```
operation: Move
testStepContainerId, itemId    # testStepContainerType defaults to testCase
parentId: <testStepContainerId | folderId | branchId>   # required
toIndex: <int>                      # required — index in target container
```

### Delete

```
operation: Delete
testStepContainerId            # testStepContainerType defaults to testCase
itemIds: ["…"]                # or single itemId
recursive: false              # true required to delete a non-empty folder
```

### List / Get items

| Op | Args | Returns |
|----|------|---------|
| List | `testStepContainerId` + `parentId` (container id for root, folder id, or branch id). `testStepContainerType` defaults to `testCase` | Direct children (+ empty folders); control-flow rows carry `statementType` + `branchIds[]` |
| Get | `testStepContainerId` + `itemId` | Step with `values[]`; folder with `childCount`; control-flow item with `statementType`, `maximumRepetitions`, `hasElse`, `branches[] {id, name, childCount}`; branch (`kind: controlFlowCondition`, `parentId` = its control-flow item, `childCount`) |

---

## Control flow — if / while / do / else (`tosca_teststep_edit`)

Control-flow blocks are items like folders, but their children live in fixed **branches** (`TestStepFolderV2` under the hood). You never create branches directly — they come with the block. Put items into a branch by passing the **branch id** as `parentId`.

| Block | Branches (in order) | Runtime meaning |
|-------|---------------------|-----------------|
| `if` | `Condition`, `THEN`, optional `ELSE` | Condition steps pass → THEN; fail → ELSE (if present) |
| `while` | `Condition`, `Loop` | Check Condition, run Loop, repeat while it passes (up to `maximumRepetitions`) |
| `do` | `Loop`, `Condition` | Run Loop first, then check Condition, repeat while it passes (up to `maximumRepetitions`) |

The **condition is steps, not an expression**: put the checking steps (typically `actionMode: Verify` values) into the `Condition` branch.

### Insert a block

```
operation: Upsert
testStepContainerId: <tc>     # testStepContainerType defaults to testCase
kind: if | while | do
name: "If logged in"          # required
parentId: <tcId | folderId | branchId>   # blocks nest inside other branches
position: 0                   # optional
disabled: false               # optional
includeElse: true             # if only (default false)
maximumRepetitions: "5"       # while / do only (default "30")
```

- `maximumRepetitions`: positive whole number (`"5"`) **or** a value expression in braces (`"{CP[MaxRetries]}"`) — the Builder UI treats it as free text. Anything else (`"0"`, `"abc"`) is rejected. Passing it on `if`, or `includeElse` on a loop, is rejected.
- The response `items[]` already contains the new branch ids — no extra Get needed.

### Fill branches

```
1. Upsert kind=if name="If logged in" → note Condition / THEN / ELSE ids from items[]
2. Upsert kind=testStep moduleId=<verify module> parentId=<Condition id> values=[{path, value, actionMode: "Verify"}]
3. Upsert kind=testStep … parentId=<THEN id>
4. Upsert kind=testStep … parentId=<ELSE id>
```

### Add / remove ELSE later

| Goal | Call |
|------|------|
| Add ELSE | Upsert `kind: else`, `parentId: <if item id>` (not a branch id). Only on `if`; only one ELSE. |
| Remove ELSE | Delete `itemIds: [<ELSE branch id>]`; `recursive: true` if it has children. The if and its THEN stay. |

`Condition`, `THEN`, and `Loop` branches cannot be deleted on their own — delete the whole block (item id) or the items inside the branch.

### Update / Move / Delete

| Op | Behavior |
|----|----------|
| Upsert update | `itemId` = block id: `name`, `disabled`, `maximumRepetitions` (loops only). Upsert with no fields returns "No changes applied" and does not save. |
| Move | Blocks move like folders (`parentId` may be a branch id). Moving a block into itself or any of its own branches/sub-folders is rejected. Items move freely between branches, e.g. THEN → nested Loop. |
| Delete | Block id deletes the block with all branches; `recursive: true` required when any branch has children. `deleted[]` lists only the requested ids, not nested items. |

### Not supported

- **Instantiation conditions** — Builder rejects them on test-case items (template-only).
- **Runtime conditions** — reuseable test step block (RTSB) only. `tosca_rtsb_edit` and `tosca_teststep_edit` do not set them. Edit the block's items with `testStepContainerType=rtsb`.
- Changing a block's statement type (if ↔ while) — delete and re-create.

---

## Recovery and cleanup scenarios (`tosca_teststep_edit`)

Scenarios are containers of steps that run when something fails: a **recovery scenario** tries to bring the application back and retries; a **cleanup scenario** tidies up afterwards. They belong to the test case root or to a folder.

| Kind | Insert fields | Update fields |
|------|---------------|---------------|
| `recoveryScenario` (alias `recovery`) | `name` + optional `retryLevel`, `disabled`, `position` | `name`, `disabled`, `retryLevel` |
| `cleanupScenario` (alias `cleanup`) | `name` + optional `disabled`, `position` | `name`, `disabled` |

- `retryLevel`: `TestStep` (default) \| `TestStepValue` \| `TestCase` — what is retried after recovery. Rejected on cleanup scenarios and on any non-scenario item.
- `parentId` on insert: testStepContainerId (root) or a folderId. Branches and other scenarios can't hold scenarios.
- Scenarios are listed separately from steps and folders: their `position` / `toIndex` counts **scenarios only** within that parent.
- Add steps into a scenario with `parentId = <scenarioId>`. List with `tosca_teststep` List `parentId = <scenarioId>`; Get returns scenario metadata with `childCount`.
- Scenarios carry no `values[]` or `maximumRepetitions`.
- Delete by scenario id; `recursive: true` when it has steps. Move with `parentId` (root or folder) + `toIndex`.

```
1. Upsert kind=recoveryScenario name="Close error dialog" retryLevel=TestStep parentId=<tcId>
2. Upsert kind=testStep moduleId=<dialog module> parentId=<scenario id> values=[…]
3. Upsert kind=cleanupScenario name="Log out" parentId=<tcId>
```

---

## Step values — `values[]`

```json
{
  "path": "Duration",
  "value": "1000",
  "actionMode": "Input",
  "explicitName": null
}
```

| Field | Notes |
|-------|-------|
| `path` | Dot-separated from module root (`Connection`, `Source.Database.ODBC.SQL Statement`). **Get the module first — never invent paths.** |
| `value` | On create: required attrs must be set. On update: omit property = leave; `null` = remove attribute node. Double every `"` in the text; add outer quotes only when the value contains `{` — see below. |
| `actionMode` | `Input` \| `Insert` \| `Verify` \| `Buffer` \| `WaitOn` \| `Select` \| `Constraint` \| `Exclude` \| `Output` \| `Delete` \| `Modify` (default = module attribute default) |
| `explicitName` | For repeatable / named attribute instances |

### Literal braces and quotes in step values

TBox parses `{` as the start of a dynamic expression (`{CP[Name]}`, `{B[Buffer]}`, calculations), and a single `"` as the start of a quoted string.

- Double every `"` that belongs to the text (`"` → `""`). A single `"` is read as the start of a quoted string; the second `"` escapes it to a literal quote.
- Wrap the whole value in double quotes only when the text contains `{`. A value with no `{` stays unwrapped.

File content `{ "name": "John Doe", "age": 30 }` is stored on the step as:

```text
"{ ""name"": ""John Doe"", ""age"": 30 }"
```

SQL `SELECT * FROM Person.Person WHERE LastName LIKE '%Ma"k%'` has a `"` and no `{`, so it is stored unwrapped, with that quote doubled:

```text
SELECT * FROM Person.Person WHERE LastName LIKE '%Ma""k%'
```

The doubled quotes, and the outer quotes when `{` is present, are TBox syntax. The engine uses the original text. An unquoted `{` fails at run time (`Expression provided in test step item "…" could not be parsed` / `Token is not valid in this context: "`). The same rule applies to every step value, including **TBox Read/Create File** and **TBox Append File** `Text`.

---

## Create-time steps on `tosca_testcase_edit`

On **create** only, optional `steps[]` can seed root-level steps (no folders in this array):

```json
"steps": [
  { "moduleId": "…", "name": "Wait", "disabled": false, "values": [{ "path": "Duration", "value": "1000" }] }
]
```

- Omit / `[]` → empty shell; build folders/steps with `tosca_teststep_edit`.
- Update path does **not** accept `steps[]` — use `tosca_teststep_edit` for item mutations.
- `workState` (`Planned` \| `InWork` \| `Completed`) on create defaults to `InWork`; on update omit = no change.

## Recorded test cases — `tosca_testcase_edit` UploadRecording

Persists a TBox automation recording as modules + steps.

| Arg | Notes |
|-----|-------|
| `recordingResult` | Required. The recorder's own ExecutionTask JSON (with `$type` discriminators). Pass it through unmodified — never build or edit it. |
| `testCaseId` | Omit → create a new test case from the recording. Set → **replace** that test case's automated steps and modules in place (confirm with the user first). |
| `parentFolderId` | Create only — inventory folder for the new test case |
| `autoMerge` | `true` → match modules from the recording against existing modules and merge instead of duplicating |

---

## Structure recipes

### Flat smoke case

1. `tosca_module` Search/Get (`TBox Wait`)
2. `tosca_testcase_edit` Upsert with `name` + one `steps[]` entry (Duration=1000)
3. Optional `tcp: [{ "name": "Browser", "value": "Chrome", "dataType": "String" }]`

### Nested folders (e.g. Login → Checkout)

1. `tosca_testcase_edit` Upsert `{ name }` → empty shell
2. `tosca_teststep_edit` Upsert folder `Login` at root
3. Upsert steps with `parentId = Login folder id`
4. Upsert folder `Checkout` at root; add steps under it
5. `tosca_testcase` Get to verify `items[]` (`parentFolderId`, `index`)

### Reorder / regroup

- `Move` with `parentId` + `toIndex`
- Or Delete + re-insert (prefer Move)

### Retry until success (do loop)

1. Upsert `kind=do name="Retry save" maximumRepetitions="{CP[MaxRetries]}"` (or `"5"`)
2. Action steps → `parentId = Loop id`
3. Verify step that detects **failure** (loop repeats while Condition passes) → `parentId = Condition id`
4. Optionally add TCP `MaxRetries` on the test case

### Optional path (if / else)

1. Upsert `kind=if name="If cookie banner" includeElse=false`
2. Verify step for the banner → Condition; dismiss step → THEN
3. Need an alternative later? Upsert `kind=else parentId=<if id>`

### Disable a section

- Upsert folder or step with `disabled: true`

### Password TCP placeholder

```json
"tcp": [{ "name": "AppPassword", "dataType": "Password" }]
```

Then open returned `url` in the portal to set the secret.

---

## Out of MCP scope (today)

- Instantiation / runtime conditions on control-flow items (see [Control flow — Not supported](#not-supported))
- Fully automated unattended Scan (agent still opens the link and waits for the user to finish the scanner)
- Setting password/secret TCP **values**
- Inventory folder layout ≠ test-step folders (inventory uses `tosca_asset` / `tosca_asset_folder`; in-TC folders use `tosca_teststep_edit`)

Related: [module-attribute-values.md](module-attribute-values.md) · [standard-modules.md](standard-modules.md) · [workflows/create-testcase.md](workflows/create-testcase.md)
