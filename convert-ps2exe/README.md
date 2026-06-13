# PowerShell Script to EXE Converter

A professional, secure, and automated PowerShell utility designed to compile any standard `.ps1` script into a standalone Windows executable (`.exe`) file using the `ps2exe` module wrapper.

## Features
- **Auto-UAC Elevation**: Automatically detects privilege levels and prompts for elevation using language-independent SID checks (compatible with English and Polish Windows OS).
- **Dependency Management**: Automatically checks, verifies, and installs the required `ps2exe` module if missing.
- **Strict Guardrails**: Robust input validation to safeguard against invalid file paths or dangerous script injections.
- **Smart Defaulting**: Automatically outputs the generated `.exe` binary into the same directory as the source script, maintaining identical file naming.

## Metadata & Contact
- **Author:** Roman Pindela
- **Email:** roman.pindela@gmail.com
- **GitHub Profile:** [github.com/romanpindela](https://github.com/romanpindela)
- **Current Version:** 1.2.0

---

## Security Notice (First-Time Download)

When cloning or downloading scripts directly from GitHub, Windows security mechanisms (Zone.Identifier Alternate Data Streams) will mark the file as untrusted. You **must** unblock the script before execution.

Run the following command in an elevated PowerShell console:
```powershell
Unblock-File -Path "C:\Path\To\convert-ps2exe.ps1"