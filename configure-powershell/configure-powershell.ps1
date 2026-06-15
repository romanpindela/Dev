<#
.SYNOPSIS
    Automates the configuration of the PowerShell user profile with sane defaults.
.DESCRIPTION
    This script initializes the user's PowerShell profile, creates a default
    development workspace directory, and injects quality-of-life improvements
    such as persistent history, autocomplete from history, and a default startup location.
.PARAMETER DefaultFolder
    The absolute path to the desired default startup directory. Defaults to 'C:\Developer'.
.PARAMETER Help
    Displays the technical manual and operational examples.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\configure-powershell.ps1
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\configure-powershell.ps1 -DefaultFolder "C:\MyWorkspace"
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\configure-powershell.ps1 -Help
.NOTES
    Author: Roman Pindela
    Email: roman.pindela@gmail.com
    GitHub: https://github.com/romanpindela
    Version: 1.0.0
#>

param (
    [Parameter(Mandatory=$false)]
    [string]$DefaultFolder = "C:\Developer",

    [Parameter(Mandatory=$false)]
    [switch]$Help
)

function Show-ScriptHelp {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "          POWERSHELL PROFILE AUTOMATED CONFIGURATION ENGINE" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "Version : 1.0.0" -ForegroundColor Yellow
    Write-Host "Author  : Roman Pindela (roman.pindela@gmail.com)" -ForegroundColor Yellow
    Write-Host "GitHub  : https://github.com/romanpindela" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------------------------"
    Write-Host "DESCRIPTION:"
    Write-Host "  Automates the provisioning of a personalized PowerShell profile,"
    Write-Host "  injecting history retention rules, autocompletion settings, and a"
    Write-Host "  customized default starting directory."
    Write-Host ""
    Write-Host "USAGE OPTIONS:"
    Write-Host "  Execute standard automated configuration (defaults to C:\Developer):"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\configure-powershell.ps1"
    Write-Host ""
    Write-Host "  Execute configuration with a custom startup directory:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\configure-powershell.ps1 -DefaultFolder 'C:\Workspace'"
    Write-Host ""
    Write-Host "  Display this operational help manual:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\configure-powershell.ps1 -Help"
    Write-Host "=====================================================================" -ForegroundColor Cyan
}

if ($Help) {
    Show-ScriptHelp
    Exit 0
}

Write-Host "[*] Auditing target default directory..." -ForegroundColor Green

# Ensure the default folder physically exists on the disk
if (-not (Test-Path -Path $DefaultFolder)) {
    Write-Host "[+] Target directory '$DefaultFolder' not found. Creating it now..." -ForegroundColor Blue
    New-Item -ItemType Directory -Path $DefaultFolder -Force | Out-Null
}

$ProfileConfig = @"

# --- AUTOMATED CONFIGURATION AND STARTUP DIRECTORY ---
Set-Location "$DefaultFolder"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -BellStyle None
`$MaximumHistoryCount = 50000

# You can append your custom aliases here, e.g.:
# New-Alias -Name n -Value notepad.exe -Force
"@

Write-Host "[*] Evaluating PowerShell profile file state..." -ForegroundColor Gray

# Create the profile if it does not exist
if (-not (Test-Path -Path $PROFILE)) {
    Write-Host "[+] User profile absent. Instantiating a new profile structure..." -ForegroundColor Blue
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null 
}

# Append the configuration to the profile file
Add-Content -Path $PROFILE -Value $ProfileConfig

Write-Host "`n[SUCCESS] The startup directory ($DefaultFolder) and profile configuration were successfully applied!" -ForegroundColor Green
Write-Host "[CRITICAL] Please restart your PowerShell terminal to apply the new profile settings." -ForegroundColor Yellow