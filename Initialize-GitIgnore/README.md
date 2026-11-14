# Initialize-GitIgnore

## Problem Statement

Newly created local repositories often lack a standardized `.gitignore` file, increasing the risk of accidentally committing local utility scripts, environment secrets (`.env` files, API keys, credentials), Windows system thumbnails (`Thumbs.db`, `Desktop.ini`), or temporary/log files to GitHub.

## Overview

`Initialize-GitIgnore.ps1` creates a security-oriented `.gitignore` template inside a specified local repository (`-RepoPath`), optionally scaffolds `.env` and `.local` directories (`-CreateLocalEnv`, enabled by default), protects existing `.gitignore` files unless `-Force` is provided, blocks critical Windows system directories, and supports PowerShell `-WhatIf` / `-Confirm` simulation.

## Environment & Prerequisites

- **OS:** Windows 10, Windows 11, or Windows Server
- **PowerShell:** Windows PowerShell 5.1 or PowerShell 7+
- **Dependencies:** None (uses built-in PowerShell cmdlets only)

## Permissions Required

**User** — Operates on the user-specified `-RepoPath` directory and explicitly blocks critical system directories (`C:\`, `C:\Windows`, `C:\Windows\System32`, `$env:SystemRoot`). No Administrator privileges are required.

## Safety & Impact

- **Risk Level:** `Modifies local repository files` — Creates `.gitignore` (refusing to overwrite an existing `.gitignore` unless `-Force` is specified) and, when `-CreateLocalEnv` is `$true` (default), creates `.env` and `.local` directories in `-RepoPath`.
- **WhatIf / Confirm & Backup:** **Supports `-WhatIf` and `-Confirm`** via `[CmdletBinding(SupportsShouldProcess=$true)]` for dry-run simulation without modifying disk files. Creates no backups before overwriting an existing `.gitignore` when `-Force` is passed, and writes no disk log files. Running without `-RepoPath` or with `-Help` / `-h` displays help safely.

## Usage Examples

```powershell
# Display built-in help (empty run or -Help / -h)
.\Initialize-GitIgnore.ps1
.\Initialize-GitIgnore.ps1 -Help

# Display PowerShell Comment-Based Help
Get-Help .\Initialize-GitIgnore.ps1 -Full

# Basic initialization (creates .gitignore, .env/, and .local/)
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit"

# Force overwrite an existing .gitignore
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -Force

# Generate only .gitignore without creating .env and .local directories
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -CreateLocalEnv:$false

# Simulate changes without touching disk (-WhatIf)
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -WhatIf
```

### Parameters

| Parameter | Alias | Type | Required | Default | Description |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `-RepoPath` | *(Positional 0)* | `[string]` | Yes (to apply) | *None* | Path to the Git repository root directory. |
| `-Force` | *(none)* | `[switch]` | No | `$false` | Overwrites an existing `.gitignore` file if present. |
| `-CreateLocalEnv` | *(none)* | `[bool]` | No | `$true` | Creates `.env` and `.local` directories if they do not exist. |
| `-Help` | `-h` | `[switch]` | No | `$false` | Displays detailed help and usage examples. |

## Author

- **Roman Pindela**
- **Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
- **GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)
- **Version:** `1.7.0`
- **License:** MIT
