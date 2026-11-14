# Invoke-GitHubScript

## Problem Statement

Running a standalone PowerShell script hosted on GitHub (such as a workstation setup or remote management helper) manually requires copying raw URLs, downloading the file, stripping the Windows `Zone.Identifier` (`Unblock-File`), handling UAC elevation, and temporarily bypassing PowerShell's Execution Policy without weakening system-wide security settings.

## Overview

`Invoke-GitHubScript.ps1` downloads a remote PowerShell script from a GitHub URL (automatically converting `/blob/` web URLs to `raw.githubusercontent.com`), requests UAC elevation via language-independent SID (`BuiltInAdministratorsSid`) while preserving `-ScriptUrl` and `-OutputPath`, unblocks the downloaded script with `Unblock-File`, and executes it in a child PowerShell process with `-ExecutionPolicy Bypass`.

## Environment & Prerequisites

- **OS:** Windows 10, Windows 11, or Windows Server
- **PowerShell:** Windows PowerShell 5.1 or PowerShell 7+
- **Dependencies:** Outbound HTTPS access (`github.com` / `raw.githubusercontent.com`) and built-in `Invoke-WebRequest` and `Unblock-File`

## Permissions Required

**Admin** — Evaluates local Administrator privileges using language-independent SID (`BuiltInAdministratorsSid`) and automatically triggers UAC elevation (`Start-Process -Verb RunAs`, forwarding `-ScriptUrl` and `-OutputPath`) if launched from a non-elevated console.

## Safety & Impact

- **Risk Level:** `Modifies system state (downloads & executes remote code)` — Creates the target parent directory if missing, writes the downloaded `.ps1` file to `-OutputPath` (default: `$env:USERPROFILE\Downloads\<filename>`), removes its `Zone.Identifier` stream, and immediately executes the downloaded script in a child process with `-ExecutionPolicy Bypass`. Only run against trusted, audited URLs.
- **WhatIf / Confirm & Backup:** Does not support `-WhatIf` / `-Confirm` and creates no backups before overwriting an existing file at `-OutputPath` or writing disk log files. Running without `-ScriptUrl` or with `-HelpMe` / `-h` / `-Help` displays help safely without downloading or executing code.

## Usage Examples

```powershell
# Unblock the script after downloading from GitHub
Unblock-File -Path .\Invoke-GitHubScript.ps1

# Display built-in help (empty run or -HelpMe / -h / -Help)
.\Invoke-GitHubScript.ps1
.\Invoke-GitHubScript.ps1 -HelpMe

# Display PowerShell Comment-Based Help
Get-Help .\Invoke-GitHubScript.ps1 -Full

# Download to Downloads folder, unblock, and run a remote script
.\Invoke-GitHubScript.ps1 -ScriptUrl "https://raw.githubusercontent.com/romanpindela/Windows-Desktop/main/Enable-RemoteManagement/Enable-RemoteManagement.ps1"

# Download to a custom path and execute
.\Invoke-GitHubScript.ps1 -ScriptUrl "https://raw.githubusercontent.com/romanpindela/Windows-Desktop/main/Enable-RemoteManagement/Enable-RemoteManagement.ps1" -OutputPath "C:\Scripts\Enable-RemoteManagement.ps1"
```

### Parameters

| Parameter | Alias | Type | Required | Default | Description |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `-ScriptUrl` | *(Positional 0)* | `[string]` | Yes (to run) | *None* | Direct raw or GitHub `/blob/` URL (`http://` or `https://`) of the script to download. |
| `-OutputPath` | *(none)* | `[string]` | No | `$env:USERPROFILE\Downloads\<filename>` | Local file path where the downloaded script is saved. |
| `-HelpMe` | `-h`, `-Help` | `[switch]` | No | `$false` | Displays extended help manual and usage examples. |

### Alternative One-Liner (`alternative_script.ps1`)

This folder also retains [`alternative_script.ps1`](./alternative_script.ps1) as a minimal manual console snippet achieving the same download-unblock-run flow:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/romanpindela/Windows-Desktop/main/Enable-RemoteManagement/Enable-RemoteManagement.ps1" -OutFile "$env:USERPROFILE\Downloads\Enable-RemoteManagement.ps1"
Unblock-File -Path "$env:USERPROFILE\Downloads\Enable-RemoteManagement.ps1"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
& "$env:USERPROFILE\Downloads\Enable-RemoteManagement.ps1"
```

## Author

- **Roman Pindela**
- **Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
- **GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)
- **Version:** `1.2.0`
- **License:** MIT
