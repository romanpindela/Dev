# Enable-GitCommitSigning 🔏

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status: Production](https://img.shields.io/badge/Status-Production-brightgreen.svg)]()
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011%20%7C%20Server-blue.svg)]()
[![PowerShell: 5.1+|7+](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207%2B-blue.svg)]()
[![Git: 2.34+](https://img.shields.io/badge/Git-2.34%2B-orange.svg)]()

A production-grade, enterprise-ready PowerShell automation engine that provisions and configures cryptographic **SSH commit and tag signing** for Git and GitHub. Eliminates the complexity of traditional GPG/PGP key management while achieving verified commit authenticity badges on GitHub.

---

## 📌 Metadata & Author Information

* **Author:** Roman Pindela
* **Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
* **GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)
* **Repository:** [https://github.com/romanpindela/Dev](https://github.com/romanpindela/Dev)
* **Version:** `1.0.0`
* **Release Date:** October 2026
* **License:** MIT

---

## 📋 Table of Contents

1. [Tool Purpose & Architecture](#1-tool-purpose--architecture)
2. [Key Features](#2-key-features)
3. [System Requirements](#3-system-requirements)
4. [Directory Structure](#4-directory-structure)
5. [Parameter Reference](#5-parameter-reference)
6. [Usage Examples](#6-usage-examples)
7. [GitHub Key Registration Modes](#7-github-key-registration-modes)
   - [Automated Registration (GitHub CLI)](#automated-registration-github-cli)
   - [Semi-Automated Registration (Web Portal + Clipboard)](#semi-automated-registration-web-portal--clipboard)
8. [Local Signature Verification (allowed_signers)](#8-local-signature-verification-allowedsigners)
9. [File Shipping Pipeline with Progress Bar (-Push)](#9-file-shipping-pipeline-with-progress-bar--push)
10. [Event Logging](#10-event-logging)
11. [Troubleshooting & FAQ](#11-troubleshooting--faq)
12. [Security & Script Unblocking](#12-security--script-unblocking)

---

## 1. Tool Purpose & Architecture

Historically, cryptographically signing Git commits required installing external GPG toolchains (such as GnuPG / Gpg4win), generating complex keyring architectures, dealing with expired key expirations, and configuring custom pinentry dialogs.

Starting with **Git 2.34**, Git natively supports signing commits and tags directly with standard **SSH keys** (`gpg.format = ssh`). GitHub natively validates SSH signatures and awards the green **Verified** badge next to signed commits.

`Enable-GitCommitSigning.ps1` completely automates this setup on Windows:
1. **Generates or Detects SSH Keys:** Provisions high-security RFC 8032 Ed25519 (or 4096-bit RSA) keys dedicated for commit signing.
2. **Configures Global Git Variables:** Sets `gpg.format = ssh`, `user.signingkey`, `commit.gpgsign = true`, `tag.gpgSign = true`, and links `gpg.ssh.allowedSignersFile`.
3. **Builds Local Verification Database:** Maintains `~/.ssh/allowed_signers` so `git log --show-signature` verifies commits locally on your workstation.
4. **Manages OpenSSH Authentication Agent:** Detects, configures, and starts the Windows `ssh-agent` service, caching keys for friction-free signing.
5. **Registers Signing Key on GitHub:** Provides both fully automated registration via GitHub CLI (`gh ssh-key add ... --type signing`) and a guided semi-automated web portal workflow with automated clipboard copying.
6. **Validates Cryptographic Signatures:** Runs an isolated sandbox commit test verifying that signatures produce `Good "git" signature` output.
7. **Monitors Push Activity:** Features a built-in file shipping pipeline that stages, signs, and pushes code with real-time progress bars (`Write-Progress`).

---

## 2. Key Features

- 🛡️ **Empty-Run Safeguard:** Executing the script without arguments displays the complete interactive help manual, parameter definitions, version info, and usage examples without modifying system settings.
- 🔑 **Ed25519 Elliptic-Curve Cryptography:** Uses fast, modern, and compact Ed25519 keys by default, with optional support for 4096-bit RSA.
- 🤖 **Automated GitHub CLI Registration:** Uses `gh ssh-key add --type signing` to register the public key directly into the user's GitHub profile.
- 🌐 **Semi-Automated Browser Fallback:** Seamlessly copies the public key to the Windows Clipboard (`Set-Clipboard` / `clip.exe`), opens `https://github.com/settings/keys`, and provides terminal instructions if CLI permissions are unavailable.
- 📋 **Local Signature Verification (`allowed_signers`):** Automatically populates `~/.ssh/allowed_signers` to enable local cryptographic auditing via `git log --show-signature`.
- 📊 **Dynamic Real-Time Progress Bars:** Leverages PowerShell native `Write-Progress` for 7-stage configuration tracking and 5-phase file shipping.
- 📑 **Structured Multi-Target Event Logging:** Logs all execution steps with millisecond timestamps to both console and a persistent UTF-8 log file (`$HOME\.git-commit-signing\logs\`).
- 🔐 **Language-Independent SID Elevation:** Evaluates Administrator privileges using well-known Windows SIDs (`[Security.Principal.WellKnownSidType]::BuiltInAdministratorsSid`), ensuring 100% compatibility across English and Polish Windows editions.

---

## 3. System Requirements

| Component | Minimum Requirement | Notes |
| :--- | :--- | :--- |
| **Operating System** | Windows 10 (1809+), Windows 11, Windows Server 2016+ | x64 / ARM64 architectures supported |
| **PowerShell** | Windows PowerShell 5.1 or PowerShell 7+ | Execution policy `RemoteSigned` or `Bypass` |
| **Git Engine** | [Git for Windows](https://git-scm.com/) **2.34.0+** | Required for native SSH signing support |
| **OpenSSH** | OpenSSH for Windows (`ssh-keygen.exe`) | Included natively with Windows 10/11 |
| **GitHub CLI** | [GitHub CLI](https://cli.github.com/) (`gh.exe`) | *Optional* for fully automated key registration |

---

## 4. Directory Structure

```text
C:\Dane\rpindela\GitHub\Dev\
│
├── Enable-GitCommitSigning\
│   ├── Enable-GitCommitSigning.ps1    # Main production automation script
│   └── README.md                      # Comprehensive documentation (this file)
│
├── Enable-GitCommitSigning.ps1        # Root proxy launcher (convenience wrapper)
└── README.md                          # Dev repository index
```

---

## 5. Parameter Reference

| Parameter | Aliases | Type | Default Value | Description |
| :--- | :--- | :--- | :--- | :--- |
| `-Enable` | `-e`, `-Setup`, `-Init` | Switch | `$false` | Triggers the complete end-to-end Git commit signing onboarding pipeline. |
| `-UseExistingKey` | `-Existing` | Switch | `$false` | Detects and uses the primary existing SSH key (`~/.ssh/id_ed25519`). |
| `-KeyPath` | `-k`, `-Key` | String | `~/.ssh/id_ed25519_signing` | Custom path to the SSH private key. |
| `-KeyType` | *(none)* | String | `ed25519` | Key algorithm: `ed25519` or `rsa`. |
| `-KeyTitle` | `-t`, `-Title` | String | `<Host> - Git Commit Signing` | Descriptive title for the key in GitHub account settings. |
| `-Email` | *(none)* | String | *(from git config)* | Committer email address mapped to GitHub account. |
| `-Name` | *(none)* | String | *(from git config)* | Full committer display name. |
| `-AllowedSignersFile` | *(none)* | String | `~/.ssh/allowed_signers` | Local database file for cryptographic signature verification. |
| `-RegistrationMode` | *(none)* | String | `Auto` | GitHub key upload mode: `Auto`, `Manual`, or `Prompt`. |
| `-ConfigureAgent` | `-Agent` | Switch | `$false` | Configures and starts the Windows `ssh-agent` service and adds the key. |
| `-TestCommit` | `-Test` | Switch | `$false` | Runs an isolated sandbox commit test verifying cryptographic signing. |
| `-RepoPath` | `-p`, `-Path` | String | *(Current Directory)* | Path to a target Git repository for local configuration or file shipping. |
| `-Push` | `-Ship` | Switch | `$false` | Stages, cryptographically signs, and pushes changes with a progress bar. |
| `-CommitMessage` | `-m`, `-Message` | String | *(Default message)* | Custom commit message when `-Push` is invoked. |
| `-LogPath` | `-l`, `-Log` | String | `~/.git-commit-signing/logs/` | Custom file path for execution logging. |
| `-NoLog` | *(none)* | Switch | `$false` | Disables disk file logging (console output remains active). |
| `-Help` | `-h` | Switch | `$false` | Displays the help guide and author information. |

---

## 6. Usage Examples

### Example 1: Display Help & Usage Manual (Empty-Run)
```powershell
.\Enable-GitCommitSigning.ps1
# Or explicitly:
.\Enable-GitCommitSigning.ps1 -Help
```

### Example 2: Complete Automatic Setup (Recommended)
Generates a dedicated `id_ed25519_signing` key, configures global Git variables, creates `allowed_signers`, registers the key via GitHub CLI (`gh`), and tests the signature:
```powershell
.\Enable-GitCommitSigning.ps1 -Enable
```

### Example 3: Use Existing SSH Key (~/.ssh/id_ed25519)
If you already have a personal SSH key and want to use it for commit signing:
```powershell
.\Enable-GitCommitSigning.ps1 -Enable -UseExistingKey
```

### Example 4: Semi-Automated Web Portal Registration
Copies the public key to the clipboard and automatically opens `https://github.com/settings/keys` in your browser:
```powershell
.\Enable-GitCommitSigning.ps1 -Enable -RegistrationMode Manual
```

### Example 5: Enable OpenSSH Agent Service & Run Cryptographic Sandbox Test
```powershell
.\Enable-GitCommitSigning.ps1 -Enable -ConfigureAgent -TestCommit
```

### Example 6: Ship Signed Changes to Remote with Real-Time Progress Bar
Stages all modified files, creates a cryptographically signed commit (`git commit -S`), and pushes to GitHub with real-time progress indicators:
```powershell
.\Enable-GitCommitSigning.ps1 -Push -RepoPath "C:\Dane\rpindela\GitHub\Dev" -CommitMessage "feat: implement cryptographic commit signing"
```

---

## 7. GitHub Key Registration Modes

### Automated Registration (GitHub CLI)
When `-RegistrationMode Auto` is selected (default), the script inspects your active GitHub CLI session:
1. Verifies that `gh.exe` is authenticated (`gh auth status`).
2. Checks if your token has the `admin:ssh_signing_key` OAuth scope.
3. Automatically executes:
   ```powershell
   gh ssh-key add "$HOME\.ssh\id_ed25519_signing.pub" --title "PC - Git Commit Signing" --type signing
   ```
4. If the key is already registered, it detects the duplicate and confirms key validity.

### Semi-Automated Registration (Web Portal + Clipboard)
If GitHub CLI is not installed, lacks the signing scope, or `-RegistrationMode Manual` is chosen:
1. The public key is copied to the Windows Clipboard (`Set-Clipboard` / `clip.exe`).
2. Your default web browser opens directly to `https://github.com/settings/keys`.
3. The script displays color-coded step-by-step instructions:
   - Click the green button **New SSH key**.
   - Enter a title (e.g., `RPINDELA-PC - Git Commit Signing`).
   - Change **Key type** from *Authentication Key* to **Signing Key**.
   - Paste the public key from your clipboard (Ctrl + V).
   - Click **Add SSH key**.

---

## 8. Local Signature Verification (allowed_signers)

GitHub automatically validates SSH signatures on its web platform. However, to verify signatures locally in your terminal with `git log --show-signature`, Git requires a local `allowed_signers` database.

The script creates and updates:
```text
C:\Users\<Username>\.ssh\allowed_signers
```
Containing your committer email and public key:
```text
roman.pindela@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...
```

And maps it globally in Git:
```powershell
git config --global gpg.ssh.allowedSignersFile "C:/Users/<Username>/.ssh/allowed_signers"
```

When you inspect signed commits locally, Git outputs:
```text
commit fda7c94ec8b79f1501ad41d45253a93d2241e219
Good "git" signature for roman.pindela@gmail.com with ED25519 key SHA256:trVS...
Author: Roman Pindela <roman.pindela@gmail.com>
Date:   Thu Oct 22 13:04:16 2026 +0200
```

---

## 9. File Shipping Pipeline with Progress Bar (-Push)

When shipping code to GitHub, `Enable-GitCommitSigning.ps1` provides an automated shipping workflow:
- **Phase 1 (20%):** Scans for dirty worktree and untracked files, reporting file names and modification status.
- **Phase 2 (40%):** Stages changes into the Git tracking index (`git add -A`).
- **Phase 3 (60%):** Cryptographically signs the commit with your private SSH key (`git commit -S -m ...`).
- **Phase 4 (80%):** Performs remote handshake and transfers objects to upstream branch (`git push origin <branch> --progress`).
- **Phase 5 (100%):** Validates the latest pushed commit hash and verifies that the signature was cryptographically sealed.

---

## 10. Event Logging

Logging is enabled by default to provide an audit trail of configuration changes and repository operations.

- **Default Log Location:**
  ```text
  $HOME\.git-commit-signing\logs\commit-signing-YYYYMMDD-HHmmss.log
  ```
- **Custom Log Path:** Pass `-LogPath "C:\MyLogs\signing.log"` to direct logs to a specific file.
- **Log Format:**
  ```text
  [2026-10-22 13:07:20] [INFO] Inspecting SSH Keypair Material...
  [2026-10-22 13:07:21] [SUCCESS] Generated new ed25519 keypair at: C:\Users\rpindela\.ssh\id_ed25519_signing
  [2026-10-22 13:07:21] [STEP] Injecting Global Git SSH Signing Configuration...
  [2026-10-22 13:07:22] [SUCCESS] Cryptographic signature generated and verified successfully!
  ```

---

## 11. Troubleshooting & FAQ

### Q1: Why does GitHub show "Unverified" on my commit?
**Answer:** The commit was signed with an SSH key that has not yet been registered on GitHub as a **Signing Key**.
- Go to `https://github.com/settings/keys`.
- Verify that your public key is listed under **SSH Keys** with the badge **Signing Key** (NOT only *Authentication Key*).
- Ensure the committer email in your Git configuration (`git config user.email`) is verified on your GitHub account.

### Q2: Why does `ssh-agent` service fail to start?
**Answer:** The Windows `OpenSSH Authentication Agent` service is set to `Disabled` by default on fresh Windows installations. Configuring service startup types requires Administrator privileges. Run PowerShell as Administrator once:
```powershell
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service -Name ssh-agent
```
*Note: Git SSH commit signing works directly via the key file even if `ssh-agent` is stopped.*

### Q3: How do I verify that signing is active?
**Answer:** Run `git config --list --show-origin` and look for:
```text
gpg.format=ssh
user.signingkey=C:/Users/.../.ssh/id_ed25519_signing.pub
commit.gpgsign=true
tag.gpgsign=true
gpg.ssh.allowedsignersfile=C:/Users/.../.ssh/allowed_signers
```

---

## 12. Security & Script Unblocking

When PowerShell scripts are downloaded from GitHub or external sources, Windows marks them with the `Zone.Identifier` NTFS alternate data stream. Before executing the script, unblock it:

```powershell
Unblock-File -Path .\Enable-GitCommitSigning.ps1
```

Or for all scripts in the repository:
```powershell
Get-ChildItem -Path "C:\Dane\rpindela\GitHub\Dev" -Recurse -Filter "*.ps1" | Unblock-File
```
