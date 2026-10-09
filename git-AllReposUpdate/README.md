# git-AllReposUpdate 🔄

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status: Production](https://img.shields.io/badge/Status-Production-brightgreen.svg)]()
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011%20%7C%20Server-blue.svg)]()
[![PowerShell: 5.1+|7+](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207%2B-blue.svg)]()

An advanced, production-grade PowerShell automation script that streamlines bulk verification, synchronization, and updates across all local Git repositories in a designated working directory (default: `C:\GitHub`).

---

## 📌 Metadata & Author Information

* **Author:** Roman Pindela
* **Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
* **GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)
* **Version:** `1.0.0`
* **Release Date:** October 2026
* **License:** MIT

---

## 📋 Table of Contents

1. [Tool Purpose](#1-tool-purpose)
2. [Key Features](#2-key-features)
3. [System Requirements](#3-system-requirements)
4. [Directory Structure](#4-directory-structure)
5. [Parameter Reference](#5-parameter-reference)
6. [Usage Examples](#6-usage-examples)
7. [Status Reporting & Interpretation](#7-status-reporting--interpretation)
8. [Safety Architecture (Fast-Forward Only)](#8-safety-architecture-fast-forward-only)
9. [Event Logging](#9-event-logging)
10. [Screenshots](#10-screenshots)

---

## 1. Tool Purpose

During everyday engineering and software development workflows on a local workstation, developers frequently maintain dozens of cloned repositories inside a single parent directory (e.g., `C:\GitHub`). Navigating manually into each directory to run `git fetch` and `git pull` is tedious, slow, and prone to human error.

The `git-AllReposUpdate.ps1` script performs fully automated, idempotent, and safe updates:
1. Scans the target directory for subfolders containing `.git` metadata.
2. Checks the active branch status and upstream tracking branch.
3. Fetches the latest remote references (`git fetch`).
4. Safely synchronizes the local branch (`git pull --ff-only`), guaranteeing that no unexpected merge commits are introduced.
5. Displays a clear dynamic progress bar (`Write-Progress`) and a detailed execution summary.

---

## 2. Key Features

- 🛡️ **Empty-Run Safeguard:** Running the script without parameters performs no destructive operations; instead, it displays a formatted help menu, version info, author metadata, and usage examples.
- 📊 **Dynamic Progress Bar:** Leverages PowerShell native `Write-Progress` to show the currently processed repository and percentage of completion.
- 🔍 **Precise Commit Counter:** When updating a repository, the script reports the exact number of pulled commits (`+N commit(s)`) and displays one-line commit log summaries (`git log --oneline`).
- ⚡ **Remote Branch Pruning (`-Prune`):** Optional removal of obsolete remote-tracking branch references (`git fetch --prune`).
- 📝 **Structured Event Logging (`-LogPath`):** Simultaneously logs console output to a designated text file with precise timestamps.
- 🎨 **Console Color Coding:** Intuitive terminal colors (Green = success/update, Gray = up-to-date, Yellow = warning/ahead, Red = error).

---

## 3. System Requirements

| Component | Requirement |
| :--- | :--- |
| **Operating System** | Windows 10, Windows 11, or Windows Server 2016+ (x64) |
| **Shell Environment** | Windows PowerShell 5.1 or PowerShell 7+ |
| **Git Engine** | [Git for Windows](https://git-scm.com/) installed and available in `$env:PATH` |
| **Git Credentials** | Configured Git Credential Manager (GCM) or SSH keys for GitHub access |

---

## 4. Directory Structure

```text
C:\GitHub\Dev\git-AllReposUpdate\
│
├── assets/
│   ├── Standard_run.jpg        # Default run view / help menu
│   └── Updating_repos.jpg      # Update process and summary view
├── git-AllReposUpdate.ps1      # Main PowerShell automation script
└── README.md                  # Technical documentation
```

---

## 5. Parameter Reference

| Parameter | Aliases | Type | Default Value | Description |
| :--- | :--- | :--- | :--- | :--- |
| `-Update` | `-u`, `-Run`, `-All` | Switch | `$false` | Initiates repository verification and update procedure. |
| `-Path` | `-p` | String | `C:\GitHub` | Parent directory containing Git project folders. |
| `-Prune` | *(none)* | Switch | `$false` | Enables pruning of deleted remote branches (`git fetch --prune`). |
| `-LogPath` | `-l`, `-Log` | String | `$null` | Optional file path for detailed text execution log. |
| `-Help` | `-h` | Switch | `$false` | Displays help menu and author information. |

---

## 6. Usage Examples

### 1) Default Run (Display Help Menu)
Running the script without arguments or with the `-Help` switch displays complete console documentation:
```powershell
.\git-AllReposUpdate.ps1
# or
.\git-AllReposUpdate.ps1 -Help
```

### 2) Standard Update of All Repositories
Scans the default directory `C:\GitHub` and synchronizes all projects:
```powershell
.\git-AllReposUpdate.ps1 -Update
```

### 3) Update Repositories in Custom Path
Specifies an alternative parent directory:
```powershell
.\git-AllReposUpdate.ps1 -Path "D:\Workspace\Projects"
```

### 4) Update with Remote Branch Pruning (Prune)
Removes local references to branches deleted from the remote GitHub server:
```powershell
.\git-AllReposUpdate.ps1 -Update -Prune
```

### 5) Full Synchronization with Log File Output
Generates a detailed execution report in a designated text file:
```powershell
.\git-AllReposUpdate.ps1 -Update -Prune -LogPath "C:\Logs\git-update-$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
```

---

## 7. Status Reporting & Interpretation

During execution, each repository is categorized into a clear state:

| Console Tag | Meaning |
| :--- | :--- |
| `[UPDATED]` *(Green)* | New commits detected on remote and successfully fast-forwarded (`+N commit(s)`). |
| `[UP TO DATE]` *(Gray)* | Local branch is completely synchronized with remote tracking branch. |
| `[UP TO DATE] (Local Ahead)` *(Gray)* | No remote commits to pull, but local branch has commits waiting to be pushed (`git push`). |
| `[NO UPSTREAM]` *(Yellow)* | Current branch does not track any remote branch (`@{u}`). |
| `[NO REMOTE]` *(Yellow)* | No remote origin is configured in the repository. |
| `[PULL ERROR]` *(Red)* | Fast-forward pull failed (`git pull --ff-only`), e.g., diverged history, merge conflicts, or local uncommitted changes. |
| `[FETCH ERROR]` *(Red)* | Network issue, authentication failure, or inaccessible remote server. |

### Sample Execution Summary Output:
```text
================================================================================
                       GIT SYNCHRONIZATION SUMMARY                              
================================================================================
Working directory         : C:\GitHub
Total repositories        : 12
Updated                   : 1
Up to date                : 11
Requires attention/other  : 0
Total execution time      : 00:08.45
--------------------------------------------------------------------------------

[+] UPDATED REPOSITORIES:
  * Dev [main] : pulled 2 commit(s)
      - a1b2c3d feat(core): implement new telemetry collector
      - d4e5f6g fix(parser): resolve json escaping edge case

[=] UP TO DATE REPOSITORIES:
  Active-Directory [main], Automation [main], brand-generator [main], Elektrimont-Sp.-z-o.-o [main],
  flashcards-translator [main], Forensic [main], gabinet-farmacja-kliniczna [main], Microsoft-365 [main],
  Pulse [main], Windows-Desktop [main], Windows-Server [main]

================================================================================
Author contact: roman.pindela@gmail.com
```

---

## 8. Safety Architecture (Fast-Forward Only)

The script strictly enforces:
```bash
git pull --ff-only
```
This architectural decision protects the integrity of your codebases:
1. **No Accidental Merge Commits:** If a clean fast-forward is not possible, Git will never auto-generate merge commits (`Merge branch '...'`).
2. **Local Experiment Protection:** If you have divergent local commits or experimental branches, the script never forces a merge or rebase; it simply flags the status in the summary report for administrator review.
3. **Idempotence:** Running the script multiple times is 100% safe across all repositories.

---

## 9. Event Logging

When the `-LogPath` parameter is provided:
- Automatically creates any missing parent directories for the log file.
- Writes every message in `UTF-8` encoding with `[yyyy-MM-dd HH:mm:ss]` timestamps.
- Non-blocking design: logging issues never interrupt console execution.

---

## 10. Screenshots

### Standard Run (Help Menu / No Parameters)
![Standard Run](assets/Standard_run.jpg)

### Repository Update Process (-Update)
![Updating Repos](assets/Updating_repos.jpg)
