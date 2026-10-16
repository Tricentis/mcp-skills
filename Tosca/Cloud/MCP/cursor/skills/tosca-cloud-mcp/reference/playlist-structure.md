# Playlist structure — TCPs, folders, paths

Exact shapes for `tosca_playlist` / `tosca_playlist_edit`. Use when the user asks about playlist parameters, overwrite hierarchy, or playlist folders.

## Mental model

```
Playlist
├── name, description, runMode, schedule, …
├── tcp[]                         # merged effective TCPs at playlist root (Get)
├── parameterSetIds[]
└── items[] (folders + test cases)
    ├── folder                    # path e.g. Checkout/Pay — has local parameters + tcp[]
    │   └── test case in playlist # path e.g. Checkout/{sourceId} — item locals + artifact TCPs
    └── test case (root)
```

Agent-facing config surface is **`tcp[]`** + **`tcpScope`** (same spirit as `tosca_testcase`). Raw `parameters` on the wire may still appear; prefer `tcp[]`.

**Playlist folders ≠ Builder test-step folders.** Test-step folders (`tosca_teststep_edit`) have **no** TCPs.

No `workspaceId` — tenancy comes from the MCP connection.

---

## Hierarchy (FE Configurations parity)

```
Tenant
  → Workspace
  → Test Case artifact          (Builder case-local TCPs; visible on playlist item Get only)
  → Playlist locals
  → Folder locals (outer → inner)
  → Test-case-in-playlist locals
```

Later source wins. Locals at the selected scope show `overwritten: true` when they override a name above.

| Layer | On Get | Writable via MCP |
|-------|--------|------------------|
| Tenant / Workspace | `inheritedFrom` | No |
| Test Case artifact | On **item** `tcp[]` as `inheritedFrom: "Test Case"` | Via `tosca_testcase_edit` only |
| Playlist locals | Root `tcp[]` | Upsert `tcp` + `tcpScope` `""`/omit |
| Folder locals | Item `tcp[]` | Upsert `tcpScope`=`Checkout/Pay` |
| Test-case-in-playlist | Item `tcp[]` | Upsert `tcpScope`=`Checkout/{sourceId}` |
| Parameter sets | `parameterSetIds[]` (ids only; not flattened into tcp[]) | Same scopes via `parameterSetIds` |

**Not** on `tosca_testcase` Get — playlist/folder overlays need playlist context.

---

## Get — `tosca_playlist` Get

| Field | Meaning |
|-------|---------|
| `url` | Portal `…/playlists/edit/{id}` |
| `tcp[]` | Merged root TCPs |
| `parameterSetIds[]` | Playlist-level set ids |
| `items[].path` | Path for `tcpScope` / Folder* ops |
| `items[].tcp[]` | Merged effective TCPs for that folder or TC item |
| `items[].sourceId` | Present on test-case items |
| Password values | Always null / redacted — never ask for secrets |

---

## Upsert TCPs — `tosca_playlist_edit` Upsert

| Call | Effect |
|------|--------|
| Omit `tcp` | No change |
| `tcp: []` | Clear **locals at tcpScope** |
| `tcp: […]` | **Replace** locals at that scope |
| `tcpScope` omit/`""` | Playlist root |
| `tcpScope`=`Checkout/Pay` | That folder |
| `tcpScope`=`Checkout/{sourceId\|itemId}` | That test-case-in-playlist |

Shape: `{ name, value?, dataType? }` — String \| Boolean \| Password (default String).

**TCP / secrets** — same as `tosca_testcase`: never pass password values (deny includes portal `url`); empty Password shell OK (omit value, then set the secret in the portal UI). MCP never exposes secret identifiers.

**Values** are opaque strings. Cross-TCP refs like `{CP[OtherName]}` are valid string values; the skill teaches them — MCP does not resolve them.

`inheritedFrom` / `overwritten` are Get-only; ignore on Upsert.

---

## Folders — `tosca_playlist_edit`

| Op | Args | Notes |
|----|------|--------|
| **FolderUpsert** create | `playlistId`, `folderName`, optional `parentPath` (empty=root), `runMode`, `disabled` | Creates empty folder |
| **FolderUpsert** update | `playlistId`, `folderPath`, optional `folderName` / `runMode` / `disabled` | Rename / flags |
| **FolderDelete** | `playlistId`, `folderPath`, `recursive?` | Non-empty requires `recursive: true` |
| **FolderMove** | `playlistId`, `folderPath`, `toParentPath`, `toIndex` | Cannot move into self/descendant |

`SetTestCases` `addToFolderPath` still requires the folder to **exist** — create it with FolderUpsert first.

---

## Recipes

### Override workspace URL for one playlist

```
tosca_playlist_edit Upsert
  playlistId, tcpScope: "" (or omit)
  tcp: [{ name: "URL", value: "https://staging.example", dataType: "String" }]
```

### Folder-level override

```
FolderUpsert create → parentPath "" folderName "Checkout"
Upsert tcpScope "Checkout" tcp: [{ name: "URL", value: "https://pay.example" }]
```

### Test-case-in-playlist override

```
SetTestCases add into Checkout (after FolderUpsert)
Upsert tcpScope "Checkout/{sourceId}" tcp: [{ name: "Browser", value: "Firefox" }]
```

Related: [testcase-structure.md](testcase-structure.md) · [playlist-orchestration.md](../playlist-orchestration.md)
