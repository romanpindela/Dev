# Dev 🚀

A collection of production-grade automation scripts and utilities designed to streamline developer workflows via GitHub integration, automate workstation and PowerShell provisioning, manage repository lifecycles, package scripts, and configure secure cryptographic commit signing.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen.svg)]()
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011%20%7C%20Server-blue.svg)]()

---

## 📌 Metadata & Author Information

* **Author:** Roman Pindela
* **Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
* **GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)
* **Repository:** [https://github.com/romanpindela/Dev](https://github.com/romanpindela/Dev)
* **License:** MIT

---

## 📋 Table of Contents
- [About the Project](#-about-the-project)
- [Script Catalog (Alphabetical)](#-script-catalog-alphabetical)
- [Key Features](#-key-features)
- [Repository Structure](#-repository-structure)
- [Available Scripts & Automation](#-available-scripts--automation)
  - [1. Add-RunScreenshotsToReadme](#1-add-runscreenshotstoreadme-)
  - [2. Clone-GitHubRepositories](#2-clone-githubrepositories-)
  - [3. Configure-GitEnvironment](#3-configure-gitenvironment-)
  - [4. Configure-PowerShell](#4-configure-powershell-)
  - [5. Connect-GitHubCLI](#5-connect-githubcli-)
  - [6. Convert-PS2EXE](#6-convert-ps2exe-)
  - [7. Deploy-WorkspaceToGitHub](#7-deploy-workspacetogithub-)
  - [8. Enable-GitCommitSigning](#8-enable-gitcommitsigning-)
  - [9. Initialize-GitIgnore](#9-initialize-gitignore-)
  - [10. Invoke-GitHubScript](#10-invoke-githubscript-)
  - [11. Sync-GitHubUserRepos](#11-sync-githubuserrepos-)
  - [12. Update-AllGitRepos](#12-update-allgitrepos-)
- [Getting Started](#-getting-started)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🔍 About the Project

The **Dev** repository serves as a centralized hub for modern software development configurations, utility scripts, and environment scaffolding. Whether setting up a fresh workstation, configuring cryptographic commit verification, batch-synchronizing dozens of repositories, packaging scripts into executables, automating README screenshots, or deploying local codebases to GitHub, this repository bundles the essential automation modules needed to reduce "time-to-code" while maintaining clean, consistent standards.

> **Note:** This repository is structured to be modular. Each tool resides in its own self-contained `Verb-Noun` directory complete with an executable PowerShell (`.ps1`) or Python (`.py`) script, optional assets/supporting files, and standardized documentation.

---

## 📊 Script Catalog (Alphabetical)

| Script Name | Description | Problem Solved | Category Tag | Permissions |
| :--- | :--- | :--- | :--- | :--- |
| [Add-RunScreenshotsToReadme](./Add-RunScreenshotsToReadme/README.md) | Executes a target script for standard and `-Help` runs, captures console screenshots, and embeds them into `readme.md`. | Eliminates manual capturing, saving, and Markdown embedding of CLI execution screenshots. | `Documentation Automation` | `User` |
| [Clone-GitHubRepositories](./Clone-GitHubRepositories/README.md) | Clones or fast-forward updates a list of GitHub repositories read from an external text file (`repositoriesToClone.txt`). | Replaces manual one-by-one cloning and updating of curated multi-repo workspaces. | `Git & GitHub` | `User` |
| [Configure-GitEnvironment](./Configure-GitEnvironment/README.md) | Configures global Git identity/line endings/editor settings, generates an Ed25519 SSH keypair, and tests GitHub SSH connectivity. | Standardizes initial workstation `.gitconfig` and SSH setup without missing key settings. | `Environment Setup` | `User` |
| [Configure-PowerShell](./Configure-PowerShell/README.md) | Provisions PowerShell 5.1 and 7+ profiles with a default workspace directory, `RemoteSigned` policy, and `PSReadLine` history options. | Automates consistent shell profile setup across PS 5.1/7+ and OneDrive-redirected folders. | `Environment Setup` | `User` |
| [Connect-GitHubCLI](./Connect-GitHubCLI/README.md) | Verifies `git`, installs GitHub CLI via `winget` if absent, and initiates SSH browser authentication (`gh auth login`). | Streamlines installing and authenticating `gh` CLI with SSH on fresh Windows hosts. | `Git & GitHub` | `User (Admin optional)` |
| [Convert-PS2EXE](./Convert-PS2EXE/README.md) | Auto-elevates, ensures the `ps2exe` module is installed, and compiles a `.ps1` script into a standalone `.exe` binary. | Simplifies distributing PowerShell scripts to environments restricted by `.ps1` policies. | `Build & Packaging` | `Admin` |
| [Deploy-WorkspaceToGitHub](./Deploy-WorkspaceToGitHub/README.md) | Initializes a local Git repository if needed, creates a public or private GitHub repository via `gh`, and pushes `main`. | Removes multi-step manual `git init`, `gh repo create`, and upstream push friction. | `Git & GitHub` | `User` |
| [Enable-GitCommitSigning](./Enable-GitCommitSigning/README.md) | Provisions Ed25519/RSA SSH commit signing, `allowed_signers`, optional `ssh-agent`, GitHub key registration, and signed `-Push`. | Replaces complex GPG/PGP suites with automated native OpenSSH commit signing. | `Security & Signing` | `User (Admin optional)` |
| [Initialize-GitIgnore](./Initialize-GitIgnore/README.md) | Generates a security-focused `.gitignore` template (with `-WhatIf` support) and optionally scaffolds `.env` and `.local` folders. | Prevents accidental commits of secrets, `.env` files, local scripts, and OS temp artifacts. | `Security & Signing` | `User` |
| [Invoke-GitHubScript](./Invoke-GitHubScript/README.md) | Auto-elevates, downloads a remote GitHub `.ps1` script (converting `/blob/` URLs to raw), unblocks it, and executes it securely. | Removes manual raw-URL conversion, `Unblock-File`, and execution-policy friction for remote scripts. | `Remote Execution` | `Admin` |
| [Sync-GitHubUserRepos](./Sync-GitHubUserRepos/README.md) | Queries the GitHub REST API for a user's repositories, applies date/fork filters, clones missing repos, and optionally updates outdated ones. | Automates mass backup, date-filtered auditing, and synchronization of all user GitHub repos. | `Git & GitHub` | `User` |
| [Update-AllGitRepos](./Update-AllGitRepos/README.md) | Scans a root directory for local `.git` repositories, fetches remotes (with optional `--prune`), and fast-forwards with `git pull --ff-only`. | Eliminates manual `git fetch` and fast-forward pulling across dozens of local repositories. | `Git & GitHub` | `User` |

---

## ✨ Key Features

- 🔏 **Cryptographic Commit Signing:** Native OpenSSH key-based commit & tag signing for Git and GitHub verified badges.
- 🔄 **Bulk Repository Management:** Automated discovery, date-filtered mirroring, fetching, and safe fast-forward updating across multiple Git repositories.
- 🛠️ **Automated Environment Provisioning:** Quick setup scripts for Git configurations, `.gitignore` security templates, SSH keys, and PowerShell profiles.
- 📦 **Zero-Friction GitHub Integration & Packaging:** GitHub CLI authentication, automated repository creation, secure remote script execution, and `.ps1` to `.exe` compilation.
- 📸 **Documentation Automation:** Automated console screenshot capture and Markdown `README.md` embedding for CLI scripts.
- 📊 **Dynamic Visual Feedback & Audited Logging:** Native `Write-Progress` status bars, colorized console diagnostics, and UTF-8 execution logs.

---

## 📂 Repository Structure

```text
C:\Dane\rpindela\GitHub\Dev\
├── Add-RunScreenshotsToReadme/    # Automated README execution screenshot generator (Python)
├── Clone-GitHubRepositories/      # Bulk clone/update utility from repositoriesToClone.txt
├── Configure-GitEnvironment/      # Automated Git global profile & Ed25519 SSH configuration
├── Configure-PowerShell/          # Multi-version PowerShell profile & PSReadLine configurator
├── Connect-GitHubCLI/             # GitHub CLI installation & SSH web-auth wrapper
├── Convert-PS2EXE/                # PowerShell (.ps1) to standalone Windows executable (.exe) compiler
├── Deploy-WorkspaceToGitHub/      # Local Git initializer and remote GitHub repository publisher
├── Enable-GitCommitSigning/       # Cryptographic SSH commit signing engine & GitHub onboarding
├── Initialize-GitIgnore/          # Security-focused .gitignore & local environment scaffold generator
├── Invoke-GitHubScript/           # Remote GitHub PowerShell script downloader, unblocker, and runner
├── Sync-GitHubUserRepos/          # GitHub REST API user repo mass cloner, date filter, and updater
├── Update-AllGitRepos/            # Bulk fast-forward synchronization engine for all local repos
└── README.md                      # Master repository documentation (this file)
```

---

## 🚀 Available Scripts & Automation

### 1. Add-RunScreenshotsToReadme 📸
* **Location:** [`Add-RunScreenshotsToReadme/`](./Add-RunScreenshotsToReadme/)
* **Script:** [`Add-RunScreenshotsToReadme.py`](./Add-RunScreenshotsToReadme/Add-RunScreenshotsToReadme.py)
* **Description:** Launches a target `.ps1`, `.exe`, or `.py` script in a maximized PowerShell window for both a standard run and a `-Help` run, saves `assets/screenshot-standard-run.jpg` and `assets/screenshot-help.jpg`, and embeds an `Execution View` section into the target script's `readme.md`.
* **Usage:**
  ```powershell
  python .\Add-RunScreenshotsToReadme\Add-RunScreenshotsToReadme.py -s "C:\path\to\Your-Script.ps1" -args "-Verbose"
  ```

### 2. Clone-GitHubRepositories 📥
* **Location:** [`Clone-GitHubRepositories/`](./Clone-GitHubRepositories/)
* **Script:** [`Clone-GitHubRepositories.ps1`](./Clone-GitHubRepositories/Clone-GitHubRepositories.ps1)
* **Description:** Automates batch cloning and safe fast-forward updating (`git pull --ff-only`) of GitHub repositories listed in [`repositoriesToClone.txt`](./Clone-GitHubRepositories/repositoriesToClone.txt).
* **Usage:**
  ```powershell
  .\Clone-GitHubRepositories\Clone-GitHubRepositories.ps1 -RepositoriesFile ".\Clone-GitHubRepositories\repositoriesToClone.txt" -TargetDir "C:\GitHub"
  ```

### 3. Configure-GitEnvironment ⚙️
* **Location:** [`Configure-GitEnvironment/`](./Configure-GitEnvironment/)
* **Script:** [`Configure-GitEnvironment.ps1`](./Configure-GitEnvironment/Configure-GitEnvironment.ps1)
* **Description:** Configures global Git settings (`user.name`, `user.email`, `core.autocrlf`, `core.editor`, `init.defaultBranch`), generates an Ed25519 SSH keypair, and verifies GitHub SSH connectivity.
* **Usage:**
  ```powershell
  .\Configure-GitEnvironment\Configure-GitEnvironment.ps1 -Name "Roman Pindela" -Email "roman.pindela@gmail.com"
  ```

### 4. Configure-PowerShell 💻
* **Location:** [`Configure-PowerShell/`](./Configure-PowerShell/)
* **Script:** [`Configure-PowerShell.ps1`](./Configure-PowerShell/Configure-PowerShell.ps1)
* **Description:** Provisions PowerShell 5.1 and 7+ profiles with a default startup directory, `RemoteSigned` execution policy, `PSReadLine` history prediction, and live profile reload.
* **Usage:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\Configure-PowerShell\Configure-PowerShell.ps1 -DefaultFolder "C:\GitHub\"
  ```

### 5. Connect-GitHubCLI 🔗
* **Location:** [`Connect-GitHubCLI/`](./Connect-GitHubCLI/)
* **Script:** [`Connect-GitHubCLI.ps1`](./Connect-GitHubCLI/Connect-GitHubCLI.ps1)
* **Description:** Verifies `git` availability, installs GitHub CLI (`gh`) via `winget` if missing, and launches browser-based SSH authentication (`gh auth login`).
* **Usage:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\Connect-GitHubCLI\Connect-GitHubCLI.ps1
  ```

### 6. Convert-PS2EXE 📦
* **Location:** [`Convert-PS2EXE/`](./Convert-PS2EXE/)
* **Script:** [`Convert-PS2EXE.ps1`](./Convert-PS2EXE/Convert-PS2EXE.ps1)
* **Description:** Auto-elevates via UAC, installs the `ps2exe` module if absent, and compiles any `.ps1` script into a standalone Windows executable (`.exe`).
* **Usage:**
  ```powershell
  .\Convert-PS2EXE\Convert-PS2EXE.ps1 -ScriptPath "C:\Scripts\MyScript.ps1"
  ```

### 7. Deploy-WorkspaceToGitHub 🚢
* **Location:** [`Deploy-WorkspaceToGitHub/`](./Deploy-WorkspaceToGitHub/)
* **Script:** [`Deploy-WorkspaceToGitHub.ps1`](./Deploy-WorkspaceToGitHub/Deploy-WorkspaceToGitHub.ps1)
* **Description:** Initializes a local directory as a Git repository, creates a public or private GitHub repository via GitHub CLI, configures `origin`, and pushes the primary branch.
* **Usage:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\Deploy-WorkspaceToGitHub\Deploy-WorkspaceToGitHub.ps1 -Path "C:\GitHub\MyProject" -Visibility "private"
  ```

### 8. Enable-GitCommitSigning 🔏
* **Location:** [`Enable-GitCommitSigning/`](./Enable-GitCommitSigning/)
* **Script:** [`Enable-GitCommitSigning.ps1`](./Enable-GitCommitSigning/Enable-GitCommitSigning.ps1)
* **Description:** Provisions cryptographic SSH commit and tag signing in Git, manages Ed25519/RSA keys, configures `allowed_signers` for local signature verification, manages the Windows OpenSSH agent service, registers signing keys on GitHub, and provides a signed `-Push` pipeline with `Write-Progress` bars.
* **Usage:**
  ```powershell
  .\Enable-GitCommitSigning\Enable-GitCommitSigning.ps1 -Enable
  .\Enable-GitCommitSigning\Enable-GitCommitSigning.ps1 -Push -RepoPath "C:\Dane\rpindela\GitHub\Dev" -CommitMessage "feat: signed commit"
  ```

### 9. Initialize-GitIgnore 📄
* **Location:** [`Initialize-GitIgnore/`](./Initialize-GitIgnore/)
* **Script:** [`Initialize-GitIgnore.ps1`](./Initialize-GitIgnore/Initialize-GitIgnore.ps1)
* **Description:** Generates a standardized `.gitignore` template blocking credentials, `.env`, local sandboxes, and OS temporary files (with `-WhatIf` support), and optionally creates `.env` and `.local` folders.
* **Usage:**
  ```powershell
  .\Initialize-GitIgnore\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -WhatIf
  ```

### 10. Invoke-GitHubScript 🌐
* **Location:** [`Invoke-GitHubScript/`](./Invoke-GitHubScript/)
* **Script:** [`Invoke-GitHubScript.ps1`](./Invoke-GitHubScript/Invoke-GitHubScript.ps1)
* **Description:** Downloads a remote PowerShell script from GitHub (converting `/blob/` URLs to raw), unblocks it with `Unblock-File`, and executes it in an elevated process with temporary execution policy bypass. Also includes [`alternative_script.ps1`](./Invoke-GitHubScript/alternative_script.ps1).
* **Usage:**
  ```powershell
  .\Invoke-GitHubScript\Invoke-GitHubScript.ps1 -ScriptUrl "https://raw.githubusercontent.com/romanpindela/Windows-Desktop/main/Enable-RemoteManagement/Enable-RemoteManagement.ps1"
  ```

### 11. Sync-GitHubUserRepos 🗂️
* **Location:** [`Sync-GitHubUserRepos/`](./Sync-GitHubUserRepos/)
* **Script:** [`Sync-GitHubUserRepos.ps1`](./Sync-GitHubUserRepos/Sync-GitHubUserRepos.ps1)
* **Description:** Automates mass cloning, status verification, flexible date filtering, and synchronization (`git pull`) of all GitHub repositories owned by a user account or email address, supporting PAT authentication, REST API pagination, and UTF-8 logging.
* **Usage:**
  ```powershell
  .\Sync-GitHubUserRepos\Sync-GitHubUserRepos.ps1 -UserName "roman.pindela@gmail.com" -CreatedBefore "2024-05" -Update
  ```

### 12. Update-AllGitRepos 🔄
* **Location:** [`Update-AllGitRepos/`](./Update-AllGitRepos/)
* **Script:** [`Update-AllGitRepos.ps1`](./Update-AllGitRepos/Update-AllGitRepos.ps1)
* **Description:** Scans a parent directory (default: `C:\GitHub`), detects all local Git repositories, checks branch states, fetches remote commits, performs safe fast-forward updates (`git pull --ff-only`), and displays real-time progress bars with commit counts.
* **Usage:**
  ```powershell
  .\Update-AllGitRepos\Update-AllGitRepos.ps1 -Update -Prune
  ```

---

## 🏁 Getting Started

### Prerequisites
1. Windows 10/11 or Windows Server 2016+
2. Windows PowerShell 5.1 or PowerShell 7+
3. [Git for Windows](https://git-scm.com/) installed and available in `$env:PATH`
4. [GitHub CLI](https://cli.github.com/) (required by `Connect-GitHubCLI` and `Deploy-WorkspaceToGitHub`; optional for `Enable-GitCommitSigning`)
5. Python 3.6+ (required only for `Add-RunScreenshotsToReadme.py`)

### Unblocking Scripts
PowerShell marks downloaded files from the web as untrusted. Unblock the scripts before running:
```powershell
Get-ChildItem -Path "C:\Dane\rpindela\GitHub\Dev" -Recurse -Filter "*.ps1" | Unblock-File
```

---

## 🤝 Contributing

Contributions, feedback, and pull requests are warmly welcomed! Please ensure all scripts follow `Verb-Noun` PascalCase naming, include clean-code practices, complete Comment-Based Help blocks, and standardized `README.md` documentation.

---

## 📄 License

Distributed under the **MIT License**.
