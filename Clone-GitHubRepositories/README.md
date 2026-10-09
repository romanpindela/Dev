# Clone-GitHubRepositories – Documentation & Usage Guide

**Author:** Roman Pindela  
**GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)  
**Email:** romanpindela@gmail.com  
**Version:** 1.1.0  

---

## 1. Tool Purpose
The `Clone-GitHubRepositories.ps1` script automates downloading and updating a designated set of GitHub repositories to a local working directory. It is designed for development and administrative environments leveraging **Visual Studio Code**.

Key Features:
- **No Hardcoded Repositories** – The list of projects is dynamically loaded from an external text file.
- **Idempotence** – If a repository does not exist locally, the script executes `git clone`; if it already exists, it synchronizes the branch using a safe `git pull --ff-only`.
- **Built-in Help** – Running without arguments or with `-Help` / `-h` displays complete syntax, parameters, and author information.
- **Protocol Flexibility** – Supports both **HTTPS** and **SSH** cloning protocols.

---

## 2. System Requirements
1. Windows 10 / Windows 11 or Windows Server.
2. PowerShell 5.1 or PowerShell 7+.
3. [Git for Windows](https://git-scm.com/) installed and accessible in the system PATH.
4. Visual Studio Code for subsequent codebase work.

---

## 3. Directory Structure

```text
working_directory/
│
├── Clone-GitHubRepositories.ps1    # Main PowerShell script
└── repositoriesToClone.txt         # Repository name list (one per line)
```

---

## 4. Repository List Configuration (`repositoriesToClone.txt`)
Place raw repository names in the file. Blank lines and lines starting with `#` are automatically ignored.

```text
Automation
Microsoft-365
Active-Directory
Windows-Desktop
Windows-Server
Dev
Forensic
```

---

## 5. Script Parameters

| Parameter | Type / Value | Description |
| :--- | :--- | :--- |
| `-RepositoriesFile` | String (Path) | Path to the text file containing repository names (e.g., `.\repositoriesToClone.txt`). |
| `-TargetDir` | String (Path) | Target folder where repositories will be cloned (e.g., `C:\GitHub`). |
| `-Username` | String | GitHub username (default: `romanpindela`). |
| `-AuthProtocol` | `HTTPS` \| `SSH` | Cloning protocol selection (default: `HTTPS`). |
| `-Help` / `-h` | Switch | Displays built-in help and author information, then exits. |

---

## 6. Usage Examples

### Display Help:
```powershell
powershell .\Clone-GitHubRepositories.ps1 -Help
```

### Standard Cloning via HTTPS:
```powershell
powershell .\Clone-GitHubRepositories.ps1 -RepositoriesFile ".\repositoriesToClone.txt" -TargetDir "C:\GitHub"
```

### Cloning via SSH:
```powershell
powershell .\Clone-GitHubRepositories.ps1 -RepositoriesFile ".\repositoriesToClone.txt" -TargetDir "C:\GitHub" -AuthProtocol SSH
```

---

## 7. Working with Visual Studio Code
After cloning repositories into the destination directory, open the entire workspace directly from the command line:

```powershell
code C:\GitHub
```

Or open a single target repository:

```powershell
code C:\GitHub\Windows-Desktop
```
