<#
.SYNOPSIS
    Automates the initial deployment, verification, and authentication pipeline for GitHub CLI.
.DESCRIPTION
    This enterprise-grade automation utility verifies system prerequisites (Git and GitHub CLI),
    provisions missing components using the Windows Package Manager (winget) if necessary,
    and initializes the web-browser authentication handshake using native SSH communication protocols.
.PARAMETER Help
    Displays the technical manual, operational examples, and developer metadata.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\Connect-GitHubCLI.ps1
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\Connect-GitHubCLI.ps1 -Help
.NOTES
    Author: Roman Pindela
    Email: roman.pindela@gmail.com
    GitHub: https://github.com/romanpindela
    Version: 1.0.0
#>

param (
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

function Show-ScriptHelp {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "          GITHUB CLI AUTOMATED WORKSPACE CONNECTION ENGINE" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "Version : 1.0.0" -ForegroundColor Yellow
    Write-Host "Author  : Roman Pindela (roman.pindela@gmail.com)" -ForegroundColor Yellow
    Write-Host "GitHub  : https://github.com/romanpindela" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------------------------"
    Write-Host "DESCRIPTION:"
    Write-Host "  Verifies environment state variables, updates application dependencies,"
    Write-Host "  and boots up the visual web-token authentication prompt for GitHub CLI."
    Write-Host ""
    Write-Host "USAGE OPTIONS:"
    Write-Host "  Execute standard automated pipeline wrapper:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\Connect-GitHubCLI.ps1"
    Write-Host ""
    Write-Host "  Display this operational help manual:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\Connect-GitHubCLI.ps1 -Help"
    Write-Host "=====================================================================" -ForegroundColor Cyan
}

# Enforcement of empty-run logic is decoupled here; running without parameters executes the tool natively
if ($Help) {
    Show-ScriptHelp
    Exit 0
}

Write-Host "[*] Auditing host automation dependencies..." -ForegroundColor Green

# Step 1: Verify Git Engine
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Fatal System State: Git engine binaries not found in local system PATH. Install Git before proceeding."
    Exit 1
}

# Step 2: Verify or Install GitHub CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[!] GitHub CLI component missing. Triggering deployment via Windows Package Manager (winget)..." -ForegroundColor Yellow
    try {
        # Deploy GitHub CLI natively
        winget install --id GitHub.cli --silent --accept-source-agreements --accept-package-agreements | Out-Null
        Write-Host "[SUCCESS] GitHub CLI binary deployed. Dynamic environment refresh required." -ForegroundColor Green
        Write-Host "[CRITICAL] Please open a FRESH PowerShell terminal and execute this script again to bind the new environment paths." -ForegroundColor Core
        Exit 0
    }
    catch {
        Write-Error "Deployment Fault: Automation engine was unable to trigger winget packages programmatically. Install GitHub CLI manually."
        Exit 1
    }
}

# Step 3: Trigger Interactive Web Handshake Authentication
Write-Host "`n=====================================================================" -ForegroundColor Cyan
Write-Host "               INITIATING GITHUB AUTHORIZATION PIPELINE" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "  1. When prompted below, ensure your cursor points to 'Login with a web browser'."
Write-Host "  2. Choose 'SSH' as your default git operations protocol."
Write-Host "  3. Copy the 8-digit token generated on your screen."
Write-Host "  4. Complete the handshake loop inside your secure browser panel."
Write-Host "---------------------------------------------------------------------\n" -ForegroundColor Gray

# Force active interactive login via standard parameters (GitHub.com, SSH protocol, Browser handshake)
gh auth login --hostname github.com --git-protocol ssh --web

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] PowerShell interface safely linked with the upstream GitHub account environment!" -ForegroundColor Green
    Write-Host "[*] Displaying current connection status parameters:`n" -ForegroundColor Gray
    gh auth status
} else {
    Write-Error "Authentication Failure: The cryptographic handshake loop returned an exit validation anomaly."
    Exit 1
}
Write-Host "=====================================================================" -ForegroundColor Cyan