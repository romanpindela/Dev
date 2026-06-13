# PowerShell Script Downloader & Runner

A professional, secure, and production-ready PowerShell script designed to download remote scripts (such as environment configurators from GitHub), automatically unblock them, and execute them safely without modifying the system's global Execution Policy.

## Features
* **Auto-Elevation (UAC):** Automatically requests Administrator privileges if not already elevated.
* **Multi-Language Support:** Uses language-independent SIDs to detect administrative privileges seamlessly across both English and Polish Windows editions (Desktop and Server).
* **Security Focused:** Uses process-level execution policy bypass (`-ExecutionPolicy Bypass`), keeping your `CurrentUser` or `LocalMachine` scopes safe and untouched.
* **Input Validation:** Built-in defenses against malicious or malformed URL inputs.

## Script Details
* **Author:** Roman Pindela
* **Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
* **GitHub Profile:** [github.com/romanpindela](https://github.com/romanpindela)
* **Current Version:** 1.2.0

---

## Installation & Security Notice

> [!IMPORTANT]
> When downloading scripts directly from GitHub via web browser or PowerShell, Windows alternative data streams will mark the file as "Zone.Identifier=Internet". **You must unblock the main script after downloading it** to ensure smooth execution:
> ```powershell
> Unblock-File -Path ".\invoke-github-script.ps1"
>

## Usage Examples

**1. Basic Execution (Default Download Path):**
Downloads the remote script to your user `Downloads` folder, unblocks it, and runs it immediately.
```powershell
.\invoke-github-script.ps1 -ScriptUrl "https://raw.githubusercontent.com/romanpindela/Windows-Desktop/main/enable-remote-management/enable-remote-management.ps1"
```

**2. Custom Output Path:**
Downloads the script to a specific directory of your choice, creating the folder if it does not exist, and executes it.
```powershell
.\invoke-github-script.ps1 -ScriptUrl "https://raw.githubusercontent.com/romanpindela/Windows-Desktop/main/enable-remote-management/enable-remote-management.ps1" -OutputPath "C:\Scripts\MyScript.ps1"
```

**3. Display Help Menu:**
Shows detailed built-in help and usage examples directly in the console.
```powershell
.\invoke-github-script.ps1 -HelpMe
```