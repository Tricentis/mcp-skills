---
description: >-
  PowerShell scripts must be ASCII-only. Unicode punctuation (em dashes, smart
  quotes) breaks signed installers when Windows PowerShell decodes with the ANSI
  code page.
globs: "**/*.{ps1,psm1,psd1}"
alwaysApply: false
---

# PowerShell scripts: ASCII only

When creating or editing `.ps1`, `.psm1`, or `.psd1` files in this repository (including installer scripts exported to mcp-skills):

## Required

- Use **ASCII only** in source. No em dashes, en dashes, arrows, smart quotes, ellipsis character, or non-breaking spaces.
- Replace:
  - em dash (U+2014) and en dash (U+2013) -> `-`
  - right arrow (U+2192) -> `->`
  - smart quotes -> `"` or `'`
  - ellipsis (U+2026) -> `...`
- Prefer a plain hyphen in comments and `Write-Host` strings. Do not copy Unicode punctuation from prose or chat output into script literals.

## Why

Signed installers ship to Windows users. Windows PowerShell decodes BOM-less `.ps1` files with the **ANSI code page**. A UTF-8 em dash inside a double-quoted string is misread and **breaks the string literal** (reported failure: `Install-CommanderMcpPack.ps1` line 128).

UTF-8 BOM is applied at export/sign time. That does not make non-ASCII safe in source.

## Before commit

```powershell
pwsh -File scripts/validate_powershell.ps1
```

Or `pwsh -File scripts/dev.ps1 -Task Validate`.

The validator fails on any non-ASCII character with file, line, column, and code point.
