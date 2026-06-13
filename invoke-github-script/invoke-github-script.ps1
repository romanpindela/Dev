<#
.SYNOPSIS
    Downloads and executes a PowerShell script from a remote URL securely.
.DESCRIPTION
    This script automates the process of downloading a remote script (e.g., from GitHub),
    unblocking it, and executing it with temporary execution policy bypass.
    It includes automatic UAC elevation using language-independent SIDs and input validation.
.PARAMETER ScriptUrl
    The direct raw URL of the PowerShell script to download.
.PARAMETER OutputPath
    The local path where the downloaded script should be saved. Defaults to the user's Downloads folder.
.PARAMETER HelpMe
    Displays the custom help menu and usage examples.
.EXAMPLE
    .\invoke-github-script.ps1 -ScriptUrl "https://raw.githubusercontent.com/romanpindela/Windows-Desktop/main/enable-remote-management/enable-remote-management.ps1"
.EXAMPLE
    .\invoke-github-script.ps1 -HelpMe
.NOTES
    Author: Roman Pindela
    Email: roman.pindela@gmail.com
    GitHub: https://github.com/romanpindela
    Version: 1.2.0
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, Position = 0)]
    [ValidatePattern('^https?://')]
    [string]$ScriptUrl,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "$env:USERPROFILE\Downloads\enable-remote-management.ps1",

    [Parameter(Mandatory = $false)]
    [Alias('h', 'Help')]
    [switch]$HelpMe
)

# Custom function to display help/about info
function Show-ExtendedHelp {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host " PowerShell Script Downloader & Runner v1.2.0" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "Author:  Roman Pindela"
    Write-Host "Email:   roman.pindela@gmail.com"
    Write-Host "GitHub:  https://github.com/romanpindela"
    Write-Host "---------------------------------------------------------------------"
    Write-Host "Description:"
    Write-Host "  Downloads a remote script, automatically unblocks it using Unblock-File,"
    Write-Host "  and runs it securely using a temporary process-level Execution Policy."
    Write-Host "  Supports language-independent (PL/EN) Administrator verification."
    Write-Host "---------------------------------------------------------------------"
    Write-Host "Usage Examples:"
    Write-Host "  1) Run with default target (Downloads folder):" -ForegroundColor Yellow
    Write-Host "     .\invoke-github-script.ps1 -ScriptUrl 'https://raw.githubusercontent.com/...'"
    Write-Size ""
    Write-Host "  2) Run and save to a custom location:" -ForegroundColor Yellow
    Write-Host "     .\invoke-github-script.ps1 -ScriptUrl 'URL' -OutputPath 'C:\Tools\script.ps1'"
    Write-Host "=====================================================================" -ForegroundColor Cyan
}

# 1. Check if help was explicitly requested or no arguments were passed
if ($HelpMe -or [string]::IsNullOrEmpty($ScriptUrl)) {
    Show-ExtendedHelp
    Exit
}

# 2. Automatic UAC elevation and language-independent admin validation
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
$adminSid = New-Object Security.Principal.SecurityIdentifier([Security.Principal.WellKnownSidType]::BuiltInAdministratorsSid, $null)

$isAdmin = $principal.IsInRole($adminSid)

if (-not $isAdmin) {
    Write-Host "Missing Administrator privileges. Requesting elevation..." -ForegroundColor Yellow
    try {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ScriptUrl `"$ScriptUrl`" -OutputPath `"$OutputPath`"" -Verb RunAs
    }
    catch {
        Write-Error "Failed to elevate privileges. Please run PowerShell as Administrator manually."
    }
    Exit
}

# 3. Main Logic (CleanCode execution block)
try {
    # Secure validation of Output Path directory
    $targetDir = Split-Path -Path $OutputPath -Parent
    if (-not (Test-Path -Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    Write-Host "Downloading script from: $ScriptUrl..." -ForegroundColor Green
    Invoke-WebRequest -Uri $ScriptUrl -OutFile $OutputPath -UseBasicParsing

    if (Test-Path -Path $OutputPath) {
        Write-Host "Unblocking file at: $OutputPath..." -ForegroundColor Green
        Unblock-File -Path $OutputPath

        Write-Host "Executing script with process-scoped Execution Policy..." -ForegroundColor Cyan
        # Run in a separate process to avoid modifying the user's permanent Execution Policy
        powershell -NoProfile -ExecutionPolicy Bypass -File $OutputPath
        
        Write-Host "Execution completed successfully." -ForegroundColor Green
    } else {
        throw "File download failed. Target path does not exist."
    }
}
catch {
    Write-Error "An error occurred: $_"
}