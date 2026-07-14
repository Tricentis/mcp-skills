#!/usr/bin/env python3
"""Detect Commander automation paths, runtimes, and best route.

Optional entry point when Python is available. PowerShell alternative:
Get-CommanderAutomationPaths.ps1 (includes Remote Control session probe).
Neither script is required — use manual checklist in path-selection.md when both fail.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))

from commander_path_discovery import main

if __name__ == "__main__":
    raise SystemExit(main())
