# Configure PowerShell Profile

An enterprise-grade automation script written in PowerShell to initialize and configure your local user profile. It applies standard quality-of-life enhancements and establishes a default workspace directory right at the shell's startup.

## Features

- **Automated Directory Provisioning:** Checks if your target startup directory (e.g., `C:\Developer`) exists, and dynamically creates it if it doesn't.
- **Intelligent Autocomplete & History:** Injects settings for `PSReadLine` to enable smart autocomplete from your command history (`PredictionSource History`).
- **Optimized Developer Settings:**
  - Adjusts history counts to keep long logs (`$MaximumHistoryCount = 50000`).
  - Disables the annoying system bell (`BellStyle None`).
  - Ensures cursor moves to the end of history searches.
  - Sets the execution policy for the current user to `RemoteSigned` for easier script execution.
- **Interactive Help System:** Built-in console manual using standard PowerShell practices.

## Usage

To configure your profile using the default `C:\Developer` directory, simply run:

```powershell
powershell -ExecutionPolicy Bypass -File .\configure-powershell.ps1
```

### Arguments

| Argument | Type | Description | Required | Default |
| :--- | :--- | :--- | :--- | :--- |
| `-DefaultFolder` | String | Defines the absolute path to your default development directory. | No | `C:\Developer` |
| `-Help` | Switch | Displays the script's operational manual. | No | `False` |

### Example - Custom Workspace

If you want to set your start folder to another path, pass it using `-DefaultFolder`:

```powershell
powershell -ExecutionPolicy Bypass -File .\configure-powershell.ps1 -DefaultFolder "C:\GitHub\Workspace"
```

*Note: Make sure to restart your PowerShell session after execution for the changes to take effect.*