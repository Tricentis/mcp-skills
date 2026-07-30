# Commander version reference index

Pick the bundle that matches the customer's installed Commander version.

| Version | Verified outputs | Sample scripts | Path |
|---------|------------------|----------------|------|
| **24.1** (Tosca Commander 24.1) | 0 | 23 | `versions/24.1/` |
| **24.2** (Tosca Commander 24.2) | 0 | 23 | `versions/24.2/` |
| **25.1** (Tosca Commander 25.1) | 15 | 23 | `versions/25.1/` |
| **26.1** (Tosca Commander 26.1) | 30 | 23 | `versions/26.1/` |
| **master** (Tosca Commander master (development)) | 30 | 23 | `versions/master/` |

Default bundled reference (skill root): **26.1** — see `../commands.md`.

## Reference files

| File | Purpose |
|------|---------|
| `commands.md` | Full TCShell_Readme.txt — search one command; use `cli-from-source.md` for flags |
| `cli-from-source.md` | CLI flags from TCShell (incl. `-auth`, `-healthCheck`) |
| `examples-catalog.md` | Sample folder topic index |
| `scenarios-index.md` | Verified test → scenario map |
| `examples-index.md` | Full sample script contents — one `##` section via `examples-catalog.md` |
| `output-patterns.md` | Golden expected output — one scenario section via `scenarios-index.md` |

## Version detection

1. Ask the user which Commander version is installed, or read `%COMMANDER_HOME%` / install folder name.
2. Open `reference/versions/<version>/commands.md` when syntax differs; otherwise use root `reference/`.
3. For **24.1** and **24.2**, command reference matches later releases; golden output patterns are not shipped in source.
