# Add-RunScreenshotsToReadme

## Problem Statement

Documenting CLI scripts and automation utilities with up-to-date execution screenshots requires manually launching each tool with standard arguments and `-Help`, resizing and capturing console windows, saving image files into `assets/`, and embedding Markdown image links into `README.md`. This manual workflow is repetitive and easy to fall out of sync when script outputs change.

## Overview

`Add-RunScreenshotsToReadme.py` automates capturing console execution screenshots for `.ps1`, `.exe`, or `.py` scripts on Windows. It launches the target script in a maximized PowerShell window for both a standard run and a `-Help` run, captures the window with `pygetwindow` and `Pillow`, saves `assets/screenshot-standard-run.jpg` and `assets/screenshot-help.jpg`, and appends an `Execution View` section to `readme.md` in the target script's directory if not already present.

## Environment & Prerequisites

- **OS:** Windows 10, Windows 11, or Windows Server (relies on `cmd.exe` and `powershell.exe`)
- **Python:** Python 3.6 or later
- **Python Packages:** `pygetwindow` and `pillow` (automatically installed via `pip` on startup if missing)

## Permissions Required

**User** — Runs in a standard user session. Missing Python packages (`pygetwindow`, `pillow`) are installed via `pip` into the active Python environment (elevated privileges are only needed if Python is installed system-wide without user-site write access, or if the target script itself requires elevation).

## Safety & Impact

- **Risk Level:** `Modifies local files & Python environment` — Installs missing `pygetwindow` and `pillow` packages via `pip`, executes the target script twice (with `-args` and with `-Help`), creates an `assets/` folder in the target script's directory, overwrites `screenshot-standard-run.jpg` and `screenshot-help.jpg`, and creates or appends to `readme.md` in that directory.
- **Dry-Run / Backup:** Does not support `--dry-run` and does not create backups before overwriting existing screenshot `.jpg` files.

## Usage Examples

```powershell
# Capture standard run (no arguments) and -Help screenshots for a PowerShell script
python .\Add-RunScreenshotsToReadme.py -s "C:\path\to\Your-Script.ps1"

# Pass custom arguments for the standard run snapshot
python .\Add-RunScreenshotsToReadme.py -s "C:\path\to\Your-Script.ps1" -args "-Verbose"

# Display CLI help
python .\Add-RunScreenshotsToReadme.py --help
```

### Arguments

| Argument | Short | Description | Required | Default |
| :--- | :--- | :--- | :--- | :--- |
| `--script` | `-s` | Absolute or relative path to the `.ps1`, `.exe`, or `.py` target script. | **Yes** | *None* |
| `--arguments` | `-args` | Optional arguments to pass down to the standard run. | No | `""` (Empty string) |

### Generated Output

Running the tool against `Your-Script.ps1`:
1. Creates an `assets/` directory in `Your-Script.ps1`'s directory.
2. Saves `assets/screenshot-standard-run.jpg` and `assets/screenshot-help.jpg`.
3. Creates or updates `readme.md` in the target script's directory with an `## Execution View` section (without duplicating it if already present).

## Author

- **Roman Pindela**
