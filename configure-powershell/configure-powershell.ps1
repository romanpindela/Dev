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
    Version: 1.1.0
#>

param (
    [Parameter(Mandatory=$false)]
    [string]$DefaultFolder = "C:\GitHub\",

    [Parameter(Mandatory=$false)]
    [switch]$Help,

    [Parameter(Mandatory=$false)]
    [switch]$ResetProfile
)

function Show-ScriptHelp {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "          POWERSHELL PROFILE AUTOMATED CONFIGURATION ENGINE" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "Version : 1.1.0" -ForegroundColor Yellow
    Write-Host "Author  : Roman Pindela (roman.pindela@gmail.com)" -ForegroundColor Yellow
    Write-Host "GitHub  : https://github.com/romanpindela" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------------------------"
    Write-Host "DESCRIPTION:"
    Write-Host "  Automates the provisioning of a personalized PowerShell profile,"
    Write-Host "  handling multi-environment setups (PS5.1 & PS7), bypassing OneDrive"
    Write-Host "  sync constraints, and injecting optimized developer settings."
    Write-Host ""
    Write-Host "USAGE OPTIONS:"
    Write-Host "  Execute standard automated configuration (defaults to C:\GitHub\):"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\configure-powershell.ps1"
    Write-Host ""
    Write-Host "  Execute configuration with a custom startup directory:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\configure-powershell.ps1 -DefaultFolder 'C:\Workspace'"
    Write-Host ""
    Write-Host "  Reset existing profile and apply fresh configuration:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\configure-powershell.ps1 -ResetProfile"
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

Write-Host "[*] Configuring system ExecutionPolicy to allow profile execution..." -ForegroundColor Gray
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

$ProfileConfig = @"

# --- AUTOMATED CONFIGURATION AND STARTUP DIRECTORY ---
Write-Host "[*] Loading customized PowerShell environment..." -ForegroundColor DarkGray
try {
    Set-Location -Path "$DefaultFolder" -ErrorAction Stop
} catch {
    Write-Host "[!] Could not change directory to $DefaultFolder" -ForegroundColor Red
}

# Safely apply PSReadLine Options (compatible with older Windows PowerShell 5.1)
if (Get-Command Set-PSReadLineOption -Syntax | Select-String "PredictionSource") {
    Set-PSReadLineOption -PredictionSource History
}
try { Set-PSReadLineOption -HistorySearchCursorMovesToEnd -ErrorAction SilentlyContinue } catch {}
try { Set-PSReadLineOption -BellStyle None -ErrorAction SilentlyContinue } catch {}

`$MaximumHistoryCount = 32767

# You can append your custom aliases here, e.g.:
# New-Alias -Name n -Value notepad.exe -Force
"@

Write-Host "[*] Evaluating PowerShell profile file state..." -ForegroundColor Gray

# Define target profiles to support BOTH Windows PowerShell (5.1) and PowerShell Core (7+)
$TargetProfiles = @($PROFILE.CurrentUserAllHosts, $PROFILE)

$PS7ProfileDir = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "PowerShell"
if (-not (Test-Path $PS7ProfileDir)) {
    New-Item -ItemType Directory -Path $PS7ProfileDir -Force | Out-Null
}
$TargetProfiles += Join-Path $PS7ProfileDir "profile.ps1"
$TargetProfiles += Join-Path $PS7ProfileDir "Microsoft.PowerShell_profile.ps1"

# Ensure uniqueness in the array just in case
$TargetProfiles = $TargetProfiles | Select-Object -Unique

foreach ($ProfilePath in $TargetProfiles) {
    # Ensure the parent directory physically exists (Fixes OneDrive/Clean-install sync issues)
    $ProfileDir = Split-Path $ProfilePath
    if (-not (Test-Path $ProfileDir)) {
        New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    }

    if (-not (Test-Path -Path $ProfilePath)) {
        New-Item -ItemType File -Path $ProfilePath -Force | Out-Null 
    }

    if ($ResetProfile) {
        Clear-Content -Path $ProfilePath -ErrorAction SilentlyContinue
    }

    # Check for existing configuration to prevent duplicates
    $CurrentProfile = Get-Content -Path $ProfilePath -Raw -ErrorAction SilentlyContinue
    if ($CurrentProfile -notmatch "AUTOMATED CONFIGURATION AND STARTUP DIRECTORY") {
        Add-Content -Path $ProfilePath -Value $ProfileConfig -Encoding utf8
        Write-Host "[SUCCESS] Configuration injected into: $ProfilePath" -ForegroundColor Green
    } else {
        Write-Host "[!] Configuration already exists in $ProfilePath." -ForegroundColor DarkYellow
    }
}

Write-Host "`n=====================================================================" -ForegroundColor Cyan
Write-Host "                 CONFIGURATION VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "Active Profiles  : $($TargetProfiles.Count) detected and updated" -ForegroundColor White
Write-Host "Startup Folder   : $DefaultFolder" -ForegroundColor White
Write-Host "Execution Policy : $(Get-ExecutionPolicy)" -ForegroundColor White
Write-Host "History Limit    : 32767" -ForegroundColor White
Write-Host "=====================================================================" -ForegroundColor Cyan

Write-Host "`n[SUCCESS] The startup directory ($DefaultFolder) and profile configuration were successfully applied!" -ForegroundColor Green
Write-Host "[*] Live Reload: Executing the profile now to apply changes immediately..." -ForegroundColor Yellow
. $PROFILE