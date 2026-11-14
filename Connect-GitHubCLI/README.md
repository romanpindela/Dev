# Connect-GitHubCLI

## Problem Statement

Setting up the GitHub CLI (`gh`) on a new Windows workstation requires checking that `git` is available, installing `gh` if missing, authenticating via an interactive browser OAuth flow, and configuring SSH as the default Git protocol. Performing these steps manually slows down workstation onboarding.

## Overview

`Connect-GitHubCLI.ps1` verifies that `git` is present in `$env:PATH`, installs GitHub CLI (`GitHub.cli`) silently via `winget` if `gh` is missing, and launches `gh auth login --hostname github.com --git-protocol ssh --web` followed by `gh auth status` to confirm connectivity.

## Environment & Prerequisites

- **OS:** Windows 10, Windows 11, or Windows Server
- **PowerShell:** Windows PowerShell 5.1 or PowerShell 7+
- **Dependencies:**
  - [Git for Windows](https://git-scm.com/) (`git` available in `$env:PATH`)
  - [GitHub CLI](https://cli.github.com/) (`gh`) — automatically installed via Windows Package Manager (`winget`) if missing
  - Web browser and internet access to `github.com` for OAuth device/browser handshake

## Permissions Required

**User (Admin optional)** — Standard user privileges are sufficient when `gh` is already installed or when `winget` installs `GitHub.cli` into user scope. Administrator privileges may be required if `winget` or local policy enforces machine-wide package installation.

## Safety & Impact

- **Risk Level:** `Modifies system state` — Conditionally installs `GitHub.cli` via `winget` (exiting afterward so you can open a fresh terminal with updated `PATH`) and runs `gh auth login`, persisting GitHub CLI credentials and protocol preferences (`ssh`) in the user's `gh` config.
- **WhatIf / Confirm & Backup:** Does not support `-WhatIf` / `-Confirm` and creates no backups or disk log files.

## Usage Examples

```powershell
# Display built-in help
powershell -ExecutionPolicy Bypass -File .\Connect-GitHubCLI.ps1 -Help

# Display PowerShell Comment-Based Help
Get-Help .\Connect-GitHubCLI.ps1 -Full

# Verify dependencies, install gh if missing, and start browser SSH login
powershell -ExecutionPolicy Bypass -File .\Connect-GitHubCLI.ps1
```

### Parameters

| Parameter | Type | Required | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `-Help` | `[switch]` | No | `$false` | Displays the technical manual, operational examples, and author metadata. |

## Author

- **Roman Pindela**
- **Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
- **GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)
- **Version:** `1.0.0`
- **License:** MIT
