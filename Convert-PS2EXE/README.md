# Convert-PS2EXE

## Problem Statement

Distributing PowerShell automation scripts to end users or restricted environments often runs into execution policy prompts, `.ps1` file-association defaults (opening in Notepad instead of running), or missing prerequisite modules. Wrapping a `.ps1` script into a standalone `.exe` manually requires installing `ps2exe` and remembering its CLI parameters.

## Overview

`Convert-PS2EXE.ps1` validates the target `.ps1` script path, checks for Administrator privileges (auto-elevating via UAC if needed), installs the `ps2exe` module if absent, and compiles the script into a standalone `.exe` file in the same directory as the source `.ps1`.

## Environment & Prerequisites

- **OS:** Windows 10, Windows 11, or Windows Server
- **PowerShell:** Windows PowerShell 5.1 or PowerShell 7+
- **Dependencies:** `ps2exe` PowerShell module (automatically installed from PowerShell Gallery via `Install-Module` if missing; requires internet access on first run)

## Permissions Required

**Admin** — Verifies local Administrator privileges using language-independent SID (`BuiltInAdministratorsSid`) and automatically prompts for UAC elevation (`Start-Process -Verb RunAs`) when invoked from a non-elevated shell. (When passing `-ScriptPath` from a non-elevated session, note that auto-elevation relaunches without forwarding CLI arguments, so run from an elevated shell when passing `-ScriptPath`.)

## Safety & Impact

- **Risk Level:** `Modifies system state & local files` — Sets `[Net.ServicePointManager]::SecurityProtocol` to TLS 1.2 for the session, installs the `ps2exe` module (`CurrentUser` scope) if not already available, and writes `<ScriptName>.exe` in the source script's directory.
- **WhatIf / Confirm & Backup:** Does not support `-WhatIf` / `-Confirm` and creates no backups or log files before overwriting an existing `.exe` with the same name.

## Usage Examples

```powershell
# Unblock the script after downloading from GitHub
Unblock-File -Path .\Convert-PS2EXE.ps1

# Display built-in help (empty run or -Help / -h)
.\Convert-PS2EXE.ps1
.\Convert-PS2EXE.ps1 -Help

# Display PowerShell Comment-Based Help
Get-Help .\Convert-PS2EXE.ps1 -Full

# Compile a PowerShell script into an executable (from an elevated PowerShell session)
.\Convert-PS2EXE.ps1 -ScriptPath "C:\Scripts\MyScript.ps1"
```

### Parameters

| Parameter | Alias | Type | Required | Default | Description |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `-ScriptPath` | *(none)* | `[string]` | Yes (to compile) | *None* | Absolute or relative path to the source `.ps1` script to compile. |
| `-Help` | `-h` | `[switch]` | No | `$false` | Displays usage manual, requirements, and author details. |

## Author

- **Roman Pindela**
- **Email:** [roman.pindela@gmail.com](mailto:roman.pindela@gmail.com)
- **GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)
- **Version:** `1.2.0`
- **License:** MIT
