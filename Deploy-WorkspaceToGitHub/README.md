# Deploy-WorkspaceToGitHub

## Problem Statement

Publishing a new local project directory to GitHub manually involves checking GitHub CLI authentication, running `git init`, making an initial commit (handling empty folders), creating the remote repository with the right visibility, adding `origin`, and pushing the primary branch. Doing these steps repeatedly increases friction and risks publishing sensitive folders as public by mistake.

## Overview

`Deploy-WorkspaceToGitHub.ps1` verifies `git` and `gh` availability (refreshing `$env:Path` from the registry if needed), ensures `gh auth` is active (falling back to SSH browser login), initializes a `.git` repository with an initial commit in `-Path` if missing, creates a `public` or `private` GitHub repository via `gh repo create`, and pushes `-MainBranch` to `origin`.

## Environment & Prerequisites

- **OS:** Windows 10, Windows 11, or Windows Server
- **PowerShell:** Windows PowerShell 5.1 or PowerShell 7+
- **Dependencies:**
  - [Git for Windows](https://git-scm.com/) (`git.exe` in `$env:PATH`)
  - [GitHub CLI](https://cli.github.com/) (`gh.exe` in `$env:PATH`)
  - GitHub account with SSH authentication configured (or interactive browser access for `gh auth login`)

## Permissions Required

**User** — Operates within the user-specified `-Path` directory and the authenticated user's GitHub account; no Administrator privileges are required.

## Safety & Impact

- **Risk Level:** `Modifies local files & creates remote GitHub repository` — Initializes `.git` in `-Path` (creating a placeholder `README.md` if the folder is empty and committing all contents), creates a new `public` (default) or `private` repository on GitHub named after the folder, sets remote `origin`, and pushes `-MainBranch`. Skips initialization/creation idempotently if `.git` or `origin` already exist.
- **WhatIf / Confirm & Backup:** Does not support `-WhatIf` / `-Confirm` and creates no backups or disk log files. Running without parameters or with `-Help` displays help safely without changes.

## Usage Examples

```powershell
# Unblock script if downloaded from GitHub
Unblock-File -Path .\Deploy-WorkspaceToGitHub.ps1

# Display built-in help (empty run or -Help)
powershell -ExecutionPolicy Bypass -File .\Deploy-WorkspaceToGitHub.ps1
powershell -ExecutionPolicy Bypass -File .\Deploy-WorkspaceToGitHub.ps1 -Help

# Display PowerShell Comment-Based Help
Get-Help .\Deploy-WorkspaceToGitHub.ps1 -Full

# Initialize and publish a public GitHub repository
powershell -ExecutionPolicy Bypass -File .\Deploy-WorkspaceToGitHub.ps1 -Path "C:\GitHub\Dev\MyScripts"

# Initialize and publish a private GitHub repository on a custom main branch
powershell -ExecutionPolicy Bypass -File .\Deploy-WorkspaceToGitHub.ps1 -Path "C:\GitHub\Dev\SecretScripts" -Visibility "private" -MainBranch "main"
```

### Parameters

| Parameter | Target Scope | Required | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `-Path` | Local Directory | Yes (to deploy) | *None* | Absolute or relative path to the target repository or workspace directory. |
| `-Visibility` | Remote Visibility | No | `public` | GitHub repository visibility (`public` or `private`). |
| `-MainBranch` | Git Primary Branch | No | `main` | Default primary branch name for `git init` and `git push`. |
| `-Help` | Control Switch | No | `$false` | Displays help manual, metadata, and usage examples, then exits. |

## Author

- **Roman Pindela**
- **Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
- **GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)
- **Version:** `1.2.1`
- **License:** MIT
