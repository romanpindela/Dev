# Configure-GitEnvironment

## Problem Statement

Setting up a fresh Windows development workstation requires manually configuring global Git identity, line-ending handling (`core.autocrlf`), default branch naming, editor integration, and an Ed25519 SSH keypair for GitHub authentication. Performing these steps manually often leads to inconsistent `.gitconfig` defaults or forgotten SSH verification checks.

## Overview

`Configure-GitEnvironment.ps1` automates global Git configuration (`user.name`, `user.email`, `core.autocrlf`, `core.editor`, `init.defaultBranch`), generates an Ed25519 SSH keypair in `$HOME\.ssh\id_ed25519`, prints the public key for GitHub registration, tests SSH connectivity against `git@github.com`, and displays a colorized summary of all active Git configuration settings.

## Environment & Prerequisites

- **OS:** Windows 10, Windows 11, or Windows Server
- **PowerShell:** Windows PowerShell 5.1 or PowerShell 7+ (with `RemoteSigned` or `-ExecutionPolicy Bypass`)
- **Dependencies:**
  - [Git for Windows](https://git-scm.com/) (`git` available in `$env:PATH`)
  - OpenSSH Client (`ssh-keygen` and `ssh`, built into Windows 10/11)

## Permissions Required

**User** — Modifies only user-level global Git configuration (`~/.gitconfig`) and user SSH files (`$HOME\.ssh\id_ed25519`, `$HOME\.ssh\known_hosts`). No Administrator privileges are required.

## Safety & Impact

- **Risk Level:** `Modifies user configuration & SSH keys` — Overwrites global Git settings (`user.name`, `user.email`, `core.autocrlf`, `core.editor`, `init.defaultBranch`), creates `$HOME\.ssh\id_ed25519` (prompting for confirmation before overwriting an existing key), and appends GitHub's host key to `~/.ssh/known_hosts` via `StrictHostKeyChecking=AcceptNew`.
- **WhatIf / Confirm & Backup:** Does not support `-WhatIf` / `-Confirm` and creates no automatic backups or disk log files. Running without parameters or with `-Help` displays the help screen safely without modifying anything.

## Usage Examples

```powershell
# Display built-in help (empty run or -Help)
.\Configure-GitEnvironment.ps1
.\Configure-GitEnvironment.ps1 -Help

# Display PowerShell Comment-Based Help
Get-Help .\Configure-GitEnvironment.ps1 -Full

# Configure Git identity and generate an Ed25519 SSH keypair
.\Configure-GitEnvironment.ps1 -Name "Roman Pindela" -Email "roman.pindela@gmail.com"

# Customize default branch and editor
.\Configure-GitEnvironment.ps1 -Name "Roman Pindela" -Email "roman.pindela@gmail.com" -DefaultBranch "main" -Editor "code --wait"
```

### Script Parameters

| Parameter | Target Mapping | Required | Default Value | Description |
| :--- | :--- | :---: | :--- | :--- |
| `-Name` | `user.name` | Yes (to apply) | *None* | Full name registered globally in Git. |
| `-Email` | `user.email` | Yes (to apply) | *None* | Structurally validated email address mapped to Git commits and SSH key comment. |
| `-DefaultBranch` | `init.defaultBranch` | No | `main` | Default branch name for newly initialized repositories. |
| `-Editor` | `core.editor` | No | `code --wait` | Default text/code editor command line string. |
| `-Help` | *Control Switch* | No | `$false` | Displays help manual, author info, and usage examples, then exits. |

### Key Features

- **Empty-Run Safeguard & Input Validation:** Running without arguments displays help; `-Email` is validated against an email regex before making changes.
- **Cross-Platform Line Endings:** Sets `core.autocrlf true` for Windows/cross-platform consistency.
- **Modern Cryptography:** Uses Ed25519 (`ssh-keygen -t ed25519`) and prompts before overwriting an existing key.
- **Diagnostics:** Prints the public key with a link to `https://github.com/settings/keys`, runs `ssh -T git@github.com`, and renders all `git config --list` entries color-coded by section.

## Author

- **Roman Pindela**
- **Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
- **GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)
- **Version:** `1.0.0`
- **License:** MIT
