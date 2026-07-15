# Changelog — tn-cloud

## 1.0.0

- Initial mcp-skills release at `Tosca/Cloud/CLI`
- Engineering skill `tn-cloud` plus 8 journey skills (`tn-cloud-connect`, `tn-cloud-basics`, analyze/author/remediate/explain)
- TN CLI execution modes: REPL, piped, `--loop`, `--robot`
- Consumer install via `Install-TnCloudPack.ps1` (Cursor, Claude, Windsurf, VS Code)
- Path detection via `Get-TnCloudPaths.py`; tenant config via `configure_tn_connection.py`
- Skill-authoring validators: `validate_skill.py`, `validate_activation.py`, `validate_journey_skills.py`
