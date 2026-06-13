# Initialize-GitIgnore

## Description
`Initialize-GitIgnore.ps1` is an advanced PowerShell script that automates the process of creating and configuring a `.gitignore` file in local Git repositories. 
It implements professional security and organizational standards, preventing accidental pushes to a remote repository (e.g., GitHub) of:
- Local utility scripts.
- Environment configurations and credentials (tokens, passwords, API keys - including `.env` files).
- Temporary system files.
- Log files, backups, and application locks.

## Features
- **Safe Deployment:** The script protects existing `.gitignore` files from being overwritten (this can be bypassed using the `-Force` parameter).
- **Critical Path Protection:** Includes safeguard mechanisms preventing execution in key system paths (e.g., `C:\Windows`).
- **Simulation Mode (WhatIf):** Built-in support for the `-WhatIf` parameter, allowing for safe testing of operations without modifying the disk.
- **Environment Structure Generation:** A default-enabled parameter initializes a `.env` directory and a `.local` directory in the repository, accelerating project configuration.

## Parameters

| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `RepoPath` | `string` | No (Positional) | None | The path to the Git repository root directory. |
| `Force` | `switch` | No | `$false` | Forces overwriting the `.gitignore` file if it already exists. |
| `CreateLocalEnv` | `bool` | No | `$true` | Enabled by default; automatically creates a `.env` directory and a `.local` directory if they do not already exist. |
| `Help` | `switch` | No | `$false` | Displays detailed documentation (Help) for the script. |

## Usage Examples

### Basic Initialization (Recommended)
```powershell
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit"
Creates a .gitignore file in the specified directory and generates the base structure (the .env file and .local directory).

###Force Overwrite Configuration
```PowerShell
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -Force
Overwrites an already existing .gitignore file.

###Disable Environment File and Directory Generation
```PowerShell
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -CreateLocalEnv:$false
Generates only the .gitignore file, completely skipping the step of creating .env and .local.

###Simulate Changes
```PowerShell
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -WhatIf