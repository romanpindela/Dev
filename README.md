# Dev 🚀

A collection of production-grade automation scripts and utilities designed to streamline developer workflows via GitHub integration, automate environment provisioning, manage repository lifecycles, and configure secure cryptographic commit signing.

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
- [Key Features](#-key-features)
- [Repository Structure](#-repository-structure)
- [Available Scripts & Automation](#-available-scripts--automation)
  - [Enable-GitCommitSigning](#1-enable-gitcommitsigning-)
  - [git-AllReposUpdate](#2-git-allreposupdate-)
  - [Clone-GitHubRepositories](#3-clone-githubrepositories-)
  - [configure-git-environment](#4-configure-git-environment-)
  - [deploy-workspace-to-github](#5-deploy-workspace-to-github-)
  - [connect-github-cli](#6-connect-github-cli-)
  - [initialize-gitignore](#7-initialize-gitignore-)
  - [configure-powershell](#8-configure-powershell-)
  - [convert-ps2exe](#9-convert-ps2exe-)
  - [invoke-github-script](#10-invoke-github-script-)
- [Getting Started](#-getting-started)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🔍 About the Project

The **Dev** repository serves as a centralized hub for modern software development configurations, utility scripts, and environment scaffolding. Whether setting up a fresh workstation, configuring cryptographic commit verification, batch-synchronizing dozens of repositories, or deploying local codebases to GitHub, this repository bundles the essential automation modules needed to reduce "time-to-code" while maintaining clean, robust standards.

> **Note:** This repository is structured to be modular. Each tool resides in its own self-contained directory complete with an executable PowerShell script, assets, and comprehensive documentation.

---

## ✨ Key Features

- 🔏 **Cryptographic Commit Signing:** Native OpenSSH key-based commit & tag signing for Git and GitHub verified badges.
- 🔄 **Bulk Repository Management:** Automated discovery, synchronization, fetching, and fast-forward updating across multiple Git repositories.
- 🛠️ **Automated Environment Provisioning:** Quick setup scripts for Git configurations, line endings, SSH keys, and PowerShell profiles.
- 📦 **Zero-Friction GitHub Integration:** GitHub CLI authentication, automated repository creation, and secure push pipelines.
- 📊 **Dynamic Visual Feedback:** Native `Write-Progress` status bars and colorized console diagnostics.
- 📝 **Audited Event Logging:** Structured multi-level file logging for enterprise traceability.

---

## 📂 Repository Structure

```text
C:\Dane\rpindela\GitHub\Dev\
├── Clone-GitHubRepositories/        # Bulk clone utility for multiple GitHub repositories
├── configure-git-environment/       # Automated Git global profile & SSH initial configuration
├── configure-powershell/            # Modern PowerShell profile & environment optimizer
├── connect-github-cli/              # GitHub CLI authentication & connectivity validator
├── convert-ps2exe/                  # PowerShell to standalone executable compilation helper
├── deploy-workspace-to-github/      # Workspace initializer and remote GitHub repo publisher
├── Enable-GitCommitSigning/         # Cryptographic SSH commit signing engine & GitHub onboarding
├── git-AllReposUpdate/              # Bulk synchronization engine with progress bars for all local repos
├── initialize-gitignore/            # Comprehensive .gitignore template generator
├── invoke-github-script/            # Secure remote script execution utility
├── add-run-screenshots-to-readme/   # Automated documentation screenshot integration helper
├── .gitignore                       # Global git ignore definitions
└── README.md                        # Master repository documentation (this file)
```

---

## 🚀 Available Scripts & Automation

### 1. Enable-GitCommitSigning 🔏
* **Location:** [`Enable-GitCommitSigning/`](./Enable-GitCommitSigning/)
* **Script:** [`Enable-GitCommitSigning.ps1`](./Enable-GitCommitSigning/Enable-GitCommitSigning.ps1)
* **Description:** Provisions cryptographic SSH commit and tag signing in Git, manages Ed25519/RSA keys, configures `allowed_signers` for local signature verification, manages the Windows OpenSSH agent service, handles automated/semi-automated key registration on GitHub, and provides a file shipping pipeline with real-time `Write-Progress` bars.
* **Usage:**
  ```powershell
  # Interactive help & examples (empty-run safeguard)
  .\Enable-GitCommitSigning\Enable-GitCommitSigning.ps1

  # Full automatic onboarding & GitHub registration
  .\Enable-GitCommitSigning\Enable-GitCommitSigning.ps1 -Enable

  # Use existing SSH key (~/.ssh/id_ed25519)
  .\Enable-GitCommitSigning\Enable-GitCommitSigning.ps1 -Enable -UseExistingKey

  # Ship signed commit to remote with real-time progress bar
  .\Enable-GitCommitSigning\Enable-GitCommitSigning.ps1 -Push -RepoPath "C:\MyRepo" -CommitMessage "feat: signed commit"
  ```

### 2. git-AllReposUpdate 🔄
* **Location:** [`git-AllReposUpdate/`](./git-AllReposUpdate/)
* **Script:** [`git-AllReposUpdate.ps1`](./git-AllReposUpdate/git-AllReposUpdate.ps1)
* **Description:** Scans a parent directory (default: `C:\GitHub`), detects all local repositories, checks branch states, fetches remote commits, performs safe fast-forward updates (`git pull --ff-only`), and displays real-time progress bars with commit counts.
* **Usage:**
  ```powershell
  .\git-AllReposUpdate\git-AllReposUpdate.ps1 -Update -Prune
  ```

### 3. Clone-GitHubRepositories 📥
* **Location:** [`Clone-GitHubRepositories/`](./Clone-GitHubRepositories/)
* **Script:** [`Clone-GitHubRepositories.ps1`](./Clone-GitHubRepositories/Clone-GitHubRepositories.ps1)
* **Description:** Automates batch cloning of GitHub repositories specified in a configuration list (`repositoriesToClone.txt`).

### 4. configure-git-environment ⚙️
* **Location:** [`configure-git-environment/`](./configure-git-environment/)
* **Script:** [`configure-git-environment.ps1`](./configure-git-environment/configure-git-environment.ps1)
* **Description:** Sets up standard global Git parameters (identity, autocrlf, default branch, code editor) and initial basic SSH authentication connectivity.

### 5. deploy-workspace-to-github 🚢
* **Location:** [`deploy-workspace-to-github/`](./deploy-workspace-to-github/)
* **Script:** [`deploy-workspace-to-github.ps1`](./deploy-workspace-to-github/deploy-workspace-to-github.ps1)
* **Description:** Automatically initializes a local directory as a Git repository, creates a public or private GitHub repository via GitHub CLI, maps upstream remotes, and executes the initial push.

### 6. connect-github-cli 🔗
* **Location:** [`connect-github-cli/`](./connect-github-cli/)
* **Script:** [`connect-github-cli.ps1`](./connect-github-cli/connect-github-cli.ps1)
* **Description:** Checks GitHub CLI binary availability, validates active authentication tokens, and initiates interactive login loops.

### 7. initialize-gitignore 📄
* **Location:** [`initialize-gitignore/`](./initialize-gitignore/)
* **Script:** [`initialize-gitignore.ps1`](./initialize-gitignore/initialize-gitignore.ps1)
* **Description:** Dynamically generates standardized `.gitignore` templates tailored for PowerShell, Python, Node.js, and Windows environments.

### 8. configure-powershell 💻
* **Location:** [`configure-powershell/`](./configure-powershell/)
* **Script:** [`configure-powershell.ps1`](./configure-powershell/configure-powershell.ps1)
* **Description:** Configures PowerShell profiles, installs productivity modules (PSReadLine, Terminal-Icons), and aligns console formatting.

### 9. convert-ps2exe 📦
* **Location:** [`convert-ps2exe/`](./convert-ps2exe/)
* **Script:** [`convert-ps2exe.ps1`](./convert-ps2exe/convert-ps2exe.ps1)
* **Description:** Automates compiling PowerShell scripts into standalone Windows executables (`.exe`).

### 10. invoke-github-script 🌐
* **Location:** [`invoke-github-script/`](./invoke-github-script/)
* **Script:** [`invoke-github-script.ps1`](./invoke-github-script/invoke-github-script.ps1)
* **Description:** Downloads and securely executes scripts directly from GitHub repositories.

---

## 🏁 Getting Started

### Prerequisites
1. Windows 10/11 or Windows Server 2016+
2. PowerShell 5.1 or PowerShell 7+
3. [Git for Windows](https://git-scm.com/) installed and available in `$env:PATH`
4. [GitHub CLI](https://cli.github.com/) (recommended)

### Unblocking Scripts
PowerShell marks downloaded files from the web as untrusted. Unblock the scripts before running:
```powershell
Get-ChildItem -Path "C:\Dane\rpindela\GitHub\Dev" -Recurse -Filter "*.ps1" | Unblock-File
```

---

## 🤝 Contributing

Contributions, feedback, and pull requests are warmly welcomed! Please ensure all scripts adhere to the project standards (`PowerShell Script Standards.txt`), include clean-code practices, proper parameter help blocks, and comprehensive README documentation.

---

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](./LICENSE) for details.
