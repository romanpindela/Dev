<#
.SYNOPSIS
    Automates the global configuration of Git, generates an SSH keypair, and tests connections.
.DESCRIPTION
    This script provides a clean-code, professional automation workflow to configure global Git variables
    (user name, email, line endings, default branch, and editor), generate a secure Ed25519 SSH keypair,
    and verify SSH connectivity to GitHub.
.PARAMETER Name
    The full name to be registered globally within the Git environment.
.PARAMETER Email
    The email address mapped to your GitHub account and Git commits.
.PARAMETER DefaultBranch
    The default branch name for newly initialized repositories (e.g., 'main').
.PARAMETER Editor
    The command line execution string to map your default text/code editor (e.g., 'code --wait').
.PARAMETER Help
    Displays detailed manual, usage examples, and metadata regarding the author and current version.
.EXAMPLE
    .\Configure-GitEnvironment.ps1 -Name "Roman Pindela" -Email "roman.pindela@gmail.com"
.EXAMPLE
    .\Configure-GitEnvironment.ps1 -Help
.NOTES
    Author: Roman Pindela
    Email: roman.pindela@gmail.com
    GitHub: https://github.com/romanpindela
    Version: 1.0.0
#>

param (
    [Parameter(Mandatory=$false, HelpMessage="Your full name for Git commits.")]
    [string]$Name,

    [Parameter(Mandatory=$false, HelpMessage="Your GitHub email address.")]
    [string]$Email,

    [Parameter(Mandatory=$false)]
    [string]$DefaultBranch = "main",

    [Parameter(Mandatory=$false)]
    [string]$Editor = "code --wait",

    [Parameter(Mandatory=$false)]
    [switch]$Help
)

function Show-ScriptHelp {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "          GIT CONFIGURATION & AUTO-INITIALIZATION ENGINE" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "Version : 1.0.0" -ForegroundColor Yellow
    Write-Host "Author  : Roman Pindela (roman.pindela@gmail.com)" -ForegroundColor Yellow
    Write-Host "GitHub  : https://github.com/romanpindela" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------------------------"
    Write-Host "DESCRIPTION:"
    Write-Host "  Automates global Git parameters, sets up line-ending logic for Windows,"
    Write-Host "  creates an Ed25519 SSH verification token, and audits connection states."
    Write-Host ""
    Write-Host "USAGE OPTIONS:"
    Write-Host "  Execute with direct arguments to systematically apply your profiles:"
    Write-Host "  .\Configure-GitEnvironment.ps1 -Name 'Roman Pindela' -Email 'roman.pindela@gmail.com'"
    Write-Host ""
    Write-Host "  Explicit parameters can be provided:"
    Write-Host "  .\Configure-GitEnvironment.ps1 -Name 'Roman Pindela' -Email 'roman.pindela@gmail.com' -DefaultBranch 'main' -Editor 'code --wait'"
    Write-Host ""
    Write-Host "  Display Help manual:"
    Write-Host "  .\Configure-GitEnvironment.ps1 -Help"
    Write-Host "=====================================================================" -ForegroundColor Cyan
}

# Enforcement of empty-run validation rule
if ($Help -or ($PSBoundParameters.Count -eq 0)) {
    Show-ScriptHelp
    Exit 0
}

# Input Sanitization and Explicit Guard Rails
if ([string]::IsNullOrWhiteSpace($Name) -or [string]::IsNullOrWhiteSpace($Email)) {
    Write-Error "Security Validation Failed: Both [-Name] and [-Email] values must be explicitly supplied for secure system alteration."
    Exit 1
}

if ($Email -notmatch "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
    Write-Error "Validation Aborted: The supplied input parameter '$Email' does not conform to standard structural email definitions."
    Exit 1
}

Write-Host "[*] Orchestrating Secure Environment Alignment Strategy..." -ForegroundColor Green

# Step 1: Binary Verification
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Missing Dependency: The 'git' execution binary was not discovered within the system Environment PATH variables."
    Exit 1
}

# Step 2: Applying Global Git Adjustments via config engine
try {
    Write-Host "[+] Injecting Global Configuration Settings..." -ForegroundColor Blue
    git config --global user.name $Name
    git config --global user.email $Email
    git config --global core.autocrlf true
    git config --global core.editor $Editor
    git config --global init.defaultBranch $DefaultBranch
    Write-Host "    -> Global identity and system behaviors updated successfully." -ForegroundColor Gray
}
catch {
    Write-Error "Execution Fault: Unable to commit configurations into the active .gitconfig data architecture."
    Exit 1
}

# Step 3: Secure Key Generation Engine (Ed25519 Protocol Implementation)
$sshDirectory = Join-Path $HOME ".ssh"
$keyPath = Join-Path $sshDirectory "id_ed25519"

if (-not (Test-Path $sshDirectory)) {
    New-Item -ItemType Directory -Path $sshDirectory -Force | Out-Null
}

if (Test-Path $keyPath) {
    Write-Host "[!] Pre-existing Ed25519 cryptographic array identified at target path." -ForegroundColor Yellow
    $choice = Read-Host "Overwriting keys can isolate active integrations. Re-generate? (y/N)"
    if ($choice -ne "y") {
        Write-Host "[*] Skipping cryptographic material override process." -ForegroundColor Gray
        $skipKeygen = $true
    }
}

if (-not $skipKeygen) {
    Write-Host "[+] Fabricating Secure Ed25519 Cryptographic Signatures..." -ForegroundColor Blue
    # Run keygen process natively forcing empty passphrase bypassing text UI delays
    ssh-keygen -t ed25519 -C $Email -f $keyPath -N '""' -q
    Write-Host "    -> Keys dropped cleanly into location: $sshDirectory" -ForegroundColor Gray
}

# Step 4: Verification Audits & Diagnostic Pipelines
Write-Host "`n=====================================================================" -ForegroundColor Cyan
Write-Host "                 CONFIGURATION VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan

$appliedName = git config --global user.name
$appliedEmail = git config --global user.email
$appliedCrlf = git config --global core.autocrlf

Write-Host "Configured User  : $appliedName"
Write-Host "Configured Email : $appliedEmail"
Write-Host "Line Endings     : $appliedCrlf (True = Recommended for cross-platform)"
Write-Host "---------------------------------------------------------------------"

if (Test-Path "${keyPath}.pub") {
    Write-Host "[CRITICAL ACTION REQUIRED] Copy this public fingerprint string to GitHub:" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------------------------" -ForegroundColor DarkCyan
    Get-Content "${keyPath}.pub" -Raw | Write-Host -ForegroundColor White
    Write-Host "---------------------------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "Navigation Link: https://github.com/settings/keys" -ForegroundColor Cyan
}

Write-Host "`n[*] Initiating Real-Time SSH Connectivity Audit to Remote Host..." -ForegroundColor Green
Write-Host "Note: Expecting an verification prompt or access message string..." -ForegroundColor Gray

# Attempt authentication diagnostics
$sshTest = ssh -T -o ConnectTimeout=5 -o StrictHostKeyChecking=AcceptNew git@github.com 2>&1

if ($sshTest -match "successfully authenticated") {
    Write-Host "[SUCCESS] Communication channels validated. GitHub successfully accepted credentials." -ForegroundColor Green
} else {
    Write-Host "[NOTICE] Remote server handshake returned unusual parameters. This is expected if the public key has not been mapped inside your dashboard yet." -ForegroundColor Yellow
}
Write-Host "=====================================================================" -ForegroundColor Cyan

# Step 4: Verification Audits & Comprehensive Colorized Configuration Visualizer
Write-Host "`n=====================================================================" -ForegroundColor Cyan
Write-Host "              ALL ACTIVE GIT CONFIGURATION PARAMETERS" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "Formatting: [Key Name] ".PadRight(35) + " = [Configuration Value]" -ForegroundColor Gray
Write-Host "---------------------------------------------------------------------"

# Extract all configuration keys natively, filter out blanks, and cleanly tokenize them
$configLines = git config --list

foreach ($line in $configLines) {
    if ($line -match "^([^=]+)=(.*)$") {
        $key = $Matches[1].Trim()
        $value = $Matches[2].Trim()
        
        # Color strategy based on domain context for immediate technical insight
        if ($key -like "user.*") {
            $keyColor = "Green"
            $valueColor = "White"
        } elseif ($key -like "core.*") {
            $keyColor = "Yellow"
            $valueColor = "Cyan"
        } elseif ($key -like "init.*" -or $key -like "branch.*") {
            $keyColor = "Magenta"
            $valueColor = "White"
        } elseif ($key -like "remote.*" -or $key -like "url.*") {
            $keyColor = "DarkCyan"
            $valueColor = "Green"
        } else {
            $keyColor = "Gray"
            $valueColor = "DarkGray"
        }
        
        Write-Host $key.PadRight(35) -NoNewline -ForegroundColor $keyColor
        Write-Host " = " -NoNewline -ForegroundColor Gray
        Write-Host $value -ForegroundColor $valueColor
    }
}
Write-Host "=====================================================================" -ForegroundColor Cyan