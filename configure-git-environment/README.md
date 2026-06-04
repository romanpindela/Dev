# Automated Git & GitHub Workspace Initialization System

An advanced, enterprise-grade PowerShell script engineered to automate structural configuration of global Git variables, enforce line-ending normalization across heterogeneous infrastructures, generate cryptographic signatures, and launch secure authentication diagnostics against remote servers.

## Metadata & Ownership
* **Author:** Roman Pindela
* **Contact Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
* **GitHub Repository:** [https://github.com/romanpindela](https://github.com/romanpindela)
* **Current Version:** `1.0.0`
* **Development Date:** June 2026

---

## Architectural Features
- **Deterministic Validation:** Advanced structural and pattern-matching rules filter inputs against logical patterns, trapping syntax or validation failures prior to modification.
- **Cross-Platform Readiness:** Programmatically configures `core.autocrlf` parameters to neutralize cross-platform runtime execution risks (e.g., CRLF/LF issues).
- **Modern Security Alignments:** Abandons outdated RSA algorithms to automatically build secure, highly compact **Ed25519** public-private key signatures.
- **Embedded Diagnostic Loop:** Includes built-in active SSH handshake verification parameters to check authorization contexts against upstream hosts.

---

## Execution Prerequisites
1. **Administrative Shell Permissions:** A PowerShell execution environment with a permissive execution policy context (e.g., `RemoteSigned` or `Bypass`).
2. **Git Binaries Engine:** `git.exe` must reside in the target environment system variables path (`$env:PATH`).

---

## Complete Parameters Guide

| Parameter Name | Target Mapping | Default Value | Description / Scope |
| :--- | :--- | :--- | :--- |
| `-Name` | `user.name` | *Mandatory* | Direct mapping of project attribution tracking strings. |
| `-Email` | `user.email` | *Mandatory* | Structurally validated email corresponding to the platform login email. |
| `-DefaultBranch` | `init.defaultBranch` | `main` | Defines global master default sequence branching tracks. |
| `-Editor` | `core.editor` | `code --wait` | Binds preferred execution context for file mutations. |
| `-Help` | *Control Switch* | N/A | Forces manual, author profile, and example console render loop. |

---

## Comprehensive Usage Scenarios

### 1. Default Empty Run / Help Diagnostic Loop
Executing the script with missing parameters or passing the `-Help` switch safely forces structural instructions to render inside the active host window, isolating configurations from unintended alteration:
```powershell
powershell -ExecutionPolicy Bypass -File .\configure-git-environment.ps1 -help
# OR
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Unblock-File -Path .\configure-git-environment.ps1
.\configure-git-environment.ps1 -Name "Roman Pindela" -Email "roman.pindela@gmail.com"
.\configure-git-environment.ps1 -Help