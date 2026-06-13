<#
.SYNOPSIS
    Compiles a PowerShell script (.ps1) into an executable file (.exe) using the ps2exe module.
.DESCRIPTION
    This script automates the process of converting PowerShell scripts into executables. 
    It checks for mandatory Administrator privileges, ensures the 'ps2exe' module is installed, 
    and outputs the .exe file in the same directory as the source script by default.
.PARAMETER ScriptPath
    The absolute or relative path to the source PowerShell script (.ps1) that you want to convert.
.EXAMPLE
    .\convert-ps2exe.ps1 -ScriptPath "C:\Scripts\MyScript.ps1"
.EXAMPLE
    .\convert-ps2exe.ps1 -h
.NOTES
    Author: Roman Pindela
    Email: roman.pindela@gmail.com
    GitHub: https://github.com/romanpindela
    Version: 1.2.0
#>

[CmdletBinding(DefaultParameterSetName = "Default")]
param (
    [Parameter(Mandatory = $false, ParameterSetName = "Default")]
    [ValidateScript({
        if ($_ -notlike "*.ps1") {
            throw "The source file must have a .ps1 extension."
        }
        if (-not (Test-Path $_)) {
            throw "The specified file does not exist."
        }
        $true
    })]
    [string]$ScriptPath,

    [Parameter(Mandatory = $false, ParameterSetName = "Help")]
    [Alias("h")]
    [switch]$Help
)

# --- 1. Help & Usage Trigger ---
if ($Help -or ([string]::IsNullOrWhiteSpace($ScriptPath) -and $PSCmdlet.ParameterSetName -eq "Default")) {
    Write-Host "=========================================================================" -ForegroundColor Cyan
    Write-Host " PowerShell Script to EXE Converter v1.2.0" -ForegroundColor Cyan
    Write-Host " Author: Roman Pindela (roman.pindela@gmail.com)" -ForegroundColor Cyan
    Write-Host " GitHub: https://github.com/romanpindela" -ForegroundColor Cyan
    Write-Host "=========================================================================" -ForegroundColor Cyan
    Write-Host "`nDescription:"
    Write-Host "  Converts any .ps1 script into an executable .exe file using the ps2exe module."
    Write-Host "`nUsage:" -ForegroundColor Yellow
    Write-Host "  .\convert-ps2exe.ps1 -ScriptPath 'C:\Path\To\YourScript.ps1'" -ForegroundColor White
    Write-Host "  .\convert-ps2exe.ps1 -Help" -ForegroundColor White
    Write-Host "`nRequirements:"
    Write-Host "  - Local Administrator privileges (the script will auto-elevate if needed)."
    Write-Host "  - Internet connection (for the initial 'ps2exe' module installation)."
    Write-Host "=========================================================================" -ForegroundColor Cyan
    Exit
}

# --- 2. UAC Auto-Elevation (Language-Independent SID Verification) ---
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
$adminSid = New-Object Security.Principal.SecurityIdentifier([Security.Principal.WellKnownSidType]::BuiltInAdministratorsSid, $null)

$isAdmin = $principal.IsInRole($adminSid)

if (-not $isAdmin) {
    Write-Host "Missing Administrator privileges. Requesting elevation..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait
    Exit
}

# --- 3. Input Validation & Security Shield ---
$ResolvedPath = Resolve-Path -Path $ScriptPath -ErrorAction SilentlyContinue
if (-not $ResolvedPath) {
    Write-Error "Error: The file path '$ScriptPath' is invalid, inaccessible, or untrusted."
    Exit 1
}

# --- 4. Dependency Check & Installation (ps2exe) ---
Write-Host "Checking for required 'ps2exe' module..." -ForegroundColor Cyan
if (-not (Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host "'ps2exe' module not found. Starting installation..." -ForegroundColor Yellow
    try {
        # Force TLS 1.2 for secure module downloading
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Install-Module -Name ps2exe -Force -SkipPublisherCheck -Scope CurrentUser -AllowClobber
        Write-Host "'ps2exe' module successfully installed!" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install ps2exe module. Reason: $_"
        Exit 1
    }
} else {
    Write-Host "'ps2exe' module is already installed." -ForegroundColor Green
}

# --- 5. Path Resolution & Compilation Logic ---
$FullScriptPath = $ResolvedPath.Path
$ScriptDirectory = Split-Path -Parent $FullScriptPath
$ScriptNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($FullScriptPath)
$OutputExePath = Join-Path -Path $ScriptDirectory -ChildPath "$ScriptNameWithoutExtension.exe"

Write-Host "`nPreparing compilation..." -ForegroundColor Cyan
Write-Host "Source Script: $FullScriptPath" -ForegroundColor White
Write-Host "Target Executable: $OutputExePath" -ForegroundColor White

try {
    Write-Host "Compiling script to EXE..." -ForegroundColor Yellow
    ps2exe -inputFile $FullScriptPath -outputFile $OutputExePath
    
    if (Test-Path $OutputExePath) {
        Write-Host "`nSuccess! Executable created successfully at:" -ForegroundColor Green
        Write-Host $OutputExePath -ForegroundColor Green
    } else {
        throw "Compilation completed, but output file could not be found."
    }
}
catch {
    Write-Error "An error occurred during compilation: $_"
    Exit 1
}