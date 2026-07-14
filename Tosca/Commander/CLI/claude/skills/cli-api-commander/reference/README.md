# Reference bundle (generated)

Multi-version TCShell reference produced by `scripts/build_tcshell_skill_docs.py --all-versions`.

| File | Purpose |
|------|---------|
| `commands.md` | Full `TCShell_Readme.txt` — search one command; use `cli-from-source.md` for flags |
| `cli-flags.md` | Startup samples + readme CLI section — use `cli-from-source.md` for flags |
| **`cli-from-source.md`** | **CLI flags from `TCShellInterpreter.cs`** (incl. `-auth`, `-healthCheck`; version-aware) |
| **`examples-catalog.md`** | **Sample folder topic index** |
| **`scenarios-index.md`** | **Verified test → scenario map** (with per-version availability) |
| `examples-index.md` | Full sample script contents — one `##` section via `examples-catalog.md` |
| `output-patterns.md` | Golden expected output — load **one scenario section** via `scenarios-index.md`, not the full file |
| `tasks.md` | Hand-authored task name reference (not generated) |
| `versions/` | Per-release bundles (24.1, 24.2, 25.1, 26.1, master) |

Regenerate from local clones under `~/Documents/GitHub/Tricentis-Tosca`:

```bash
python3 scripts/build_tcshell_skill_docs.py --all-versions \
  --commander-base ~/Documents/GitHub/Tricentis-Tosca
```

See [commander-compatibility.md](commander-compatibility.md).
