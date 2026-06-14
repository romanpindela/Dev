# Add Run Screenshots to README

A professional utility script written in Python to automatically execute a given PowerShell, `.exe`, or `.py` script, capture its output window as screenshots, and embed those screenshots directly into a `readme.md` file. 

This is particularly useful for quickly generating execution showcases for your CLI applications, scripts, and utilities on GitHub or in documentation.

## Features

- **Auto-Environment Setup:** Automatically installs missing dependencies (`pygetwindow`, `pillow`) without breaking the run flow.
- **Smart Window Tracking:** Safely launches a target `.ps1`, `.exe`, or `.py` process, anchors the window from closing too early, and intelligently waits until the window actually appears on the screen.
- **Dual Run Snapshots:** Captures both:
  1. The "Standard Run" output (using standard supplied arguments).
  2. The "-Help" flag output.
- **Automated README Modification:** Appends the generated screenshot links in standard Markdown notation to an existing `readme.md` (or creates a new one). It prevents duplicate inserts by checking if the section already exists.

## Requirements

- Windows operating system (relies on `cmd.exe` and `powershell.exe`)
- Python 3.6 or later

*Note: Dependencies like `pygetwindow` and `Pillow` are automatically resolved and installed during runtime if they are not already present.*

## Usage

To capture screenshots and append them to a script's documentation, simply invoke the Python utility and pass the target script via `-s`:

```powershell
python add-run-screenshots-to-readme.py -s "C:\path\to\your\script.ps1"
```

### Arguments

| Argument | Short | Description | Required | Default |
| :--- | :--- | :--- | :--- | :--- |
| `--script` | `-s` | Absolute or relative path to the `.ps1`, `.exe`, or `.py` target script. | **Yes** | *None* |
| `--arguments` | `-args` | Optional arguments to pass down to the standard run. | No | `""` (Empty string) |

### Example

If your script takes an argument like `-Verbose`, you can run it as follows:

```powershell
python add-run-screenshots-to-readme.py -s "my-tool.ps1" -args "-Verbose"
```

This will:
1. Create an `assets/` directory in `my-tool.ps1`'s directory.
2. Save `screenshot-standard-run.jpg` and `screenshot-help.jpg`.
3. Create or update `readme.md` in the target script's directory with a visual section.