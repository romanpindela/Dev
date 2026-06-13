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
- **Environment Structure Generation:** A default-enabled parameter initializes an empty `.env` file and a `.local` directory in the repository, accelerating project configuration.

## Parameters

| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `RepoPath` | `string` | No (Positional) | None | The path to the Git repository root directory. |
| `Force` | `switch` | No | `$false` | Forces overwriting the `.gitignore` file if it already exists. |
| `CreateLocalEnv` | `bool` | No | `$true` | Enabled by default; automatically creates an `.env` file and a `.local` directory if they do not already exist. |
| `Help` | `switch` | No | `$false` | Displays detailed documentation (Help) for the script. |

## Usage Examples

### Basic Initialization (Recommended)
```powershell
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit"
```
*Tworzy plik `.gitignore` w zadanym katalogu oraz generuje podstawową strukturę (plik `.env` i katalog `.local`).*

### Wymuszenie nadpisania konfiguracji
```powershell
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -Force
```
*Nadpisuje istniejący już plik `.gitignore`.*

### Wyłączenie generowania plików i katalogów środowiskowych
```powershell
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -CreateLocalEnv:$false
```
*Generuje wyłącznie plik `.gitignore`, całkowicie ignorując krok tworzenia `.env` oraz `.local`.*

### Symulacja zmian
```powershell
.\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -WhatIf
```
*Wyświetla logi informujące o tym, co zostanie utworzone bez faktycznego wprowadzania zmian na dysku.*