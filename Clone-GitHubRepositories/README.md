# Clone-GitHubRepositories

## Problem Statement

Manually cloning and keeping a curated set of GitHub repositories synchronized across a new or existing development workstation one by one is repetitive and error-prone. Developers need a repeatable, configuration-driven script that reads repository names from a text file and ensures every project is present and fast-forwarded locally.

## Overview

`Clone-GitHubRepositories.ps1` reads repository names from an external text file (`repositoriesToClone.txt`, ignoring blank lines and `#` comments) and clones missing repositories into `-TargetDir` via HTTPS or SSH. For repositories that already exist locally with a `.git` folder, it safely pulls upstream changes using `git pull --ff-only`.

## Environment & Prerequisites

- **OS:** Windows 10, Windows 11, or Windows Server
- **PowerShell:** Windows PowerShell 5.1 or PowerShell 7+
- **Dependencies:** [Git for Windows](https://git-scm.com/) (`git` available in `$env:PATH`); configured Git credentials or SSH keys for private/SSH repositories
- **Optional:** Visual Studio Code (`code`) for opening the cloned workspace

## Permissions Required

**User** — Operates purely within the user-specified `-TargetDir` using standard `git` commands; no Administrator privileges are required.

## Safety & Impact

- **Risk Level:** `Modifies local files & Git repositories` — Creates `-TargetDir` if it does not exist, clones new repositories into subdirectories, and runs `git pull --ff-only` on existing local repositories (preventing accidental merge commits).
- **WhatIf / Confirm & Backup:** Does not support `-WhatIf` / `-Confirm` and creates no backups or disk log files.

## Usage Examples

```powershell
# Display built-in help (empty run or -h / -help)
.\Clone-GitHubRepositories.ps1
.\Clone-GitHubRepositories.ps1 -help

# Display PowerShell Comment-Based Help
Get-Help .\Clone-GitHubRepositories.ps1 -Full

# Clone or update repositories using HTTPS (default)
.\Clone-GitHubRepositories.ps1 -RepositoriesFile ".\repositoriesToClone.txt" -TargetDir "C:\GitHub"

# Clone or update repositories using SSH
.\Clone-GitHubRepositories.ps1 -RepositoriesFile ".\repositoriesToClone.txt" -TargetDir "C:\GitHub" -AuthProtocol SSH

# Positional arguments
.\Clone-GitHubRepositories.ps1 ".\repositoriesToClone.txt" "C:\GitHub"
```

### Script Parameters

| Parameter | Type / Value | Required | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `-RepositoriesFile` | `[string]` | Yes | *None* | Path to the text file containing repository names (e.g., `.\repositoriesToClone.txt`). |
| `-TargetDir` | `[string]` | Yes | *None* | Target folder where repositories will be cloned (e.g., `C:\GitHub`). |
| `-Username` | `[string]` | No | `romanpindela` | GitHub username or organization owning the repositories. |
| `-AuthProtocol` | `HTTPS` \| `SSH` | No | `HTTPS` | Transport protocol used for cloning. |

### Directory Structure & Configuration (`repositoriesToClone.txt`)

```text
Clone-GitHubRepositories/
├── Clone-GitHubRepositories.ps1    # Main PowerShell script
├── repositoriesToClone.txt         # Repository name list (one per line)
└── README.md                       # Documentation
```

Place one repository name per line in `repositoriesToClone.txt`; blank lines and `#` comments are ignored:

```text
Automation
Microsoft-365
Active-Directory
Windows-Desktop
Windows-Server
Dev
Forensic
```

### Working with Visual Studio Code

```powershell
code C:\GitHub
# Or open a single repository:
code C:\GitHub\Windows-Desktop
```

## Author

- **Roman Pindela**
- **Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
- **GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)
- **Version:** `1.1.0`
- **License:** MIT
