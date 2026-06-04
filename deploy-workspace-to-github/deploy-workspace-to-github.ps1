<#
.SYNOPSIS
    Verifies GitHub CLI session connectivity and automates local repository initialization and deployment.
.DESCRIPTION
    This script encapsulates an automated DevOps workflow tailored for infrastructure administrators.
    It verifies system requirements, handles active GitHub environment authentication loops, initializes
    untracked project folders, creates public or private remote repositories, and deploys local codebases
    securely utilizing standard SSH profiles.
.PARAMETER Path
    The absolute or relative system path to the target script repository or workspace directory.
.PARAMETER Visibility
    Defines the structural visibility state on GitHub. Valid inputs are 'public' or 'private'. Defaults to 'public'.
.PARAMETER MainBranch
    The target default primary tracking branch name. Defaults to 'main'.
.PARAMETER Help
    Displays the technical manual, operational examples, code version, and owner profiles.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\deploy-workspace-to-github.ps1 -Path "C:\GitHub\Dev\MyScripts"
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\deploy-workspace-to-github.ps1 -Path "C:\GitHub\Dev\SecretScripts" -Visibility "private"
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\deploy-workspace-to-github.ps1 -Help
.NOTES
    Author: Roman Pindela
    Email: roman.pindela@gmail.com
    GitHub: https://github.com/romanpindela
    Version: 1.2.0
#>

param (
    [Parameter(Mandatory=$false, HelpMessage="Absolute or relative path to the local repository directory.")]
    [string]$Path,

    [Parameter(Mandatory=$false)]
    [ValidateSet("public", "private")]
    [string]$Visibility = "public",

    [Parameter(Mandatory=$false)]
    [string]$MainBranch = "main",

    [Parameter(Mandatory=$false)]
    [switch]$Help
)

function Show-ScriptHelp {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "          ENTERPRISE WORKSPACE INITIALIZATION & DEPLOYMENT ENGINE" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "Version : 1.2.0" -ForegroundColor Yellow
    Write-Host "Author  : Roman Pindela (roman.pindela@gmail.com)" -ForegroundColor Yellow
    Write-Host "GitHub  : https://github.com/romanpindela" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------------------------"
    Write-Host "DESCRIPTION:"
    Write-Host "  Establishes safe GitHub CLI authentication wrappers, dynamically builds"
    Write-Host "  local git tracking structures, creates remote targets, and runs push actions."
    Write-Host ""
    Write-Host "USAGE OPTIONS:"
    Write-Host "  Deploy local repository with default configuration (Public):"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\deploy-workspace-to-github.ps1 -Path 'C:\MyScripts'"
    Write-Host ""
    Write-Host "  Deploy local repository with explicit parameters (Private Override):"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\deploy-workspace-to-github.ps1 -Path 'C:\MyScripts' -Visibility 'private'"
    Write-Host ""
    Write-Host "  Display this operational manual:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\deploy-workspace-to-github.ps1 -Help"
    Write-Host "=====================================================================" -ForegroundColor Cyan
}

# Enforcement of empty-run validation rule & input sanitization guardrails
if ($Help -or ($PSBoundParameters.Count -eq 0) -or [string]::IsNullOrWhiteSpace($Path)) {
    Show-ScriptHelp
    Exit 0
}

# Explicit path verification guardrails
if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "System Validation Failure: Target path directory reference '$Path' does not exist or is invalid."
    Exit 1
}

$AbsoluteTargetBranchPath = (Get-Item -Path $Path).FullName
$RepositoryName = (Get-Item -Path $Path).Name

Write-Host "[*] Auditing automation environment state variables..." -ForegroundColor Green

# Step 1: Binary Dependency Check
if (-not (Get-Command git -ErrorAction SilentlyContinue) -or -not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "Missing Dependency: Ensure both 'git.exe' and 'gh.exe' (GitHub CLI) binaries reside within system execution environments."
    Exit 1
}

# Step 2: Session Connectivity Management Validation Loop
Write-Host "[*] Evaluating active authentication context state..." -ForegroundColor Gray
$AuthStatus = gh auth status 2>&1

if ($AuthStatus -match "Logged in to github.com") {
    Write-Host "[SUCCESS] Verified active execution session context for GitHub CLI connection." -ForegroundColor Green
} else {
    Write-Host "[!] Unauthorized context detected. Initializing web-browser token handshake..." -ForegroundColor Yellow
    gh auth login --hostname github.com --git-protocol ssh --web
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Authentication Failure: High-level cryptographic security token loop handshake abandoned."
        Exit 1
    }
}

# Step 3: Local Repository Orchestration Loop
Set-Location -Path $AbsoluteTargetBranchPath

if (-not (Test-Path (Join-Path $AbsoluteTargetBranchPath ".git"))) {
    Write-Host "[+] Local tracking files absent. Instantiating a new Git structure..." -ForegroundColor Blue
    git init -b $MainBranch
    git add .
    git commit -m "Initial commit: Production scripts ingestion layout"
} else {
    Write-Host "[!] Target infrastructure has a registered local tracking layer. Skipping initialization." -ForegroundColor DarkYellow
}

# Step 4: Remote Infrastructure Mapping & Code Shipping
$RemoteVerification = git remote | Where-Object { $_ -eq "origin" }

if (-not $RemoteVerification) {
    Write-Host "[+] Injecting remote structure tracking definitions on upstream host..." -ForegroundColor Blue
    
    # Translate structural profile arguments to literal command line string parameter parameters
    $VisibilityParameter = if ($Visibility -eq "private") { "--private" } else { "--public" }
    
    # Deploy target upstream project framework
    gh repo create $RepositoryName $VisibilityParameter --source=. --remote=origin
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCCESS] Target repository namespace safely committed to GitHub platform ($Visibility)." -ForegroundColor Green
        Write-Host "[+] Encrypting and pushing changes over secure SSH protocol..." -ForegroundColor Blue
        git push -u origin $MainBranch
    } else {
        Write-Error "Deployment Fault: Remote engine declined allocation. Verify if target repository name '$RepositoryName' conflicts with existing remote namespaces."
        Exit 1
    }
} else {
    Write-Host "[!] Remote infrastructure mapping 'origin' already defined. Secure pipeline delivery bypassed." -ForegroundColor DarkYellow
}

Write-Host "`n[+] Workspace processing completed successfully!" -ForegroundColor Green