# Commander version compatibility

This skill supports **TCShell**, **TCAPI**, and **Remote Control** across these Commander releases:

| Version | Verified output fixtures |
|---------|--------------------------|
| **24.1** | None in source tree |
| **24.2** | None in source tree |
| **25.1** | 15 golden files |
| **26.1** | 30 golden files |
| **master** | 30 golden files (development) |

Manifests (bundled in this reference folder): [commander-versions.json](commander-versions.json), [tcapi-compatibility.json](tcapi-compatibility.json).

## What is the same across all versions

- TCShell command language (`CommandInterpreter` syntax)
- CLI flags (`-workspace`, `-login`, `-auth`, batch `.tcs` scripts)
- Remote Control IPC model (GUI-attended mode)
- **TCAPI** core API surface (`CreateInstance`, `OpenWorkspace`, `Search`, `Save`)

## TCAPI by Commander version

| Version | TCAPI .NET target | Agent host (no PS) | Agent host (PS optional) | DevCorner docs |
|---------|-------------------|--------------------|--------------------------|----------------|
| **24.1** | net48 + net8 | dotnet script + .NET 8 desktop | Windows PowerShell 5.1 or pwsh | 2024.1 |
| **24.2** | net8 | dotnet script + .NET 8 desktop | pwsh 7+ | 2024.2 |
| **25.1** | net8 | dotnet script + .NET 8 desktop | pwsh 7+ | 2025.1 |
| **26.1** | net10 | dotnet script + .NET 10 desktop | pwsh / dotnet script | 2026.1 |
| **master** | net10 | same as 26.1 | same as 26.1 | 2026.1 |

**Do not assume PowerShell or Python.** When `DotNetScript` is available in path detection output, use `dotnet script` with `.csx` examples. Otherwise prefer **Headless TCShell** via cmd.

## Version detection

Path detection resolves `CommanderVersion` from (in order):

1. Explicit `--commander-version` / `-CommanderVersion`
2. `COMMANDER_VERSION` env var or `%USERPROFILE%\.tricentis\tcshell-ide.env`
3. Install path tokens (e.g. `...\Tosca Commander 25.1\`, `...241`, unversioned Commander dev install folder → `master`)
4. Default: `26.1`

Use **whichever detector executes**, or read [commander-versions.json](commander-versions.json) directly when neither runs.

When installing with `-CommanderHome`, the installer writes `%USERPROFILE%\.tricentis\tcshell-ide.env`:

```ini
COMMANDER_HOME=C:\Program Files\Tricentis\Tosca Commander 25.1
COMMANDER_VERSION=25.1
SKILL_REFERENCE_PATH=reference/versions/25.1/
```

The skill uses `SKILL_REFERENCE_PATH` to pick the correct reference bundle.

## What differs by version

- **Verified output patterns** — only shipped from 25.1 onward in Commander source; 24.x bundles document this gap
- **TCAPI .NET target** — net48 on 24.1 may require Windows PowerShell 5.1 when using PS
- **master** may run ahead of released 26.1 patches — use `reference/versions/master/` for bleeding-edge builds

## Version bundles

Per-release TCShell reference: [versions/index.md](versions/index.md).
