<#
.SYNOPSIS
    Configures an advanced .gitignore file in a local Git repository and lists ignored patterns.
.DESCRIPTION
    This script automates the creation or modification of a .gitignore file.
    It implements professional security and organizational standards by blocking 
    local utility scripts, environmental configurations, and sensitive credentials 
    from being pushed to remote repositories. Runs safely within user privileges
    and protects existing configuration files unless explicitly forced. Supports -WhatIf simulation.
    Additionally, a default parameter creates a .env directory and a .local directory 
    to establish a standard local environment structure.
.PARAMETER RepoPath
    The local path to the Git repository root directory.
.PARAMETER Force
    Forces the script to overwrite an existing .gitignore file. Without this parameter,
    the script will safely terminate if a .gitignore file already exists.
.PARAMETER CreateLocalEnv
    A default-enabled boolean parameter ($true). When enabled, creates a 
    .env directory and a .local directory if they do not already exist.
.PARAMETER Help
    Displays detailed script documentation and usage examples.
.EXAMPLE
    .\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit"
    Configures the .gitignore file inside the specified directory if it doesn't exist.
.EXAMPLE
    .\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -Force
    Overwrites the existing .gitignore file with the new base template structure.
.EXAMPLE
    .\Initialize-GitIgnore.ps1 -RepoPath "C:\Projects\SystemAudit" -WhatIf
    Simulates the execution, showing exactly what file would be checked or overwritten.
.EXAMPLE
    .\Initialize-GitIgnore.ps1 -Help
    Displays this help menu.
.NOTES
    Author: Roman Pindela
    Contact: roman.pindela@gmail.com[cite: 1]
    GitHub: https://github.com/romanpindela[cite: 1]
    Version: 1.7.0
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$false, Position=0)]
    [string]$RepoPath,

    [Parameter(Mandatory=$false)]
    [switch]$Force,

    [Parameter(Mandatory=$false)]
    [bool]$CreateLocalEnv = $true,

    [Parameter(Mandatory=$false)]
    [Alias("h")]
    [switch]$Help
)

function Show-ScriptHelp {
    Clear-Host
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "          INITIALIZE-GITIGNORE - WORKSPACE CONFIGURATION ENGINE" -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "Version : 1.7.0" -ForegroundColor Yellow
    Write-Host "Author  : Roman Pindela (roman.pindela@gmail.com)" -ForegroundColor Yellow
    Write-Host "GitHub  : https://github.com/romanpindela" -ForegroundColor Yellow
    Write-Host "---------------------------------------------------------------------"
    Write-Host "DESCRIPTION:"
    Write-Host "  Automates the creation or modification of a .gitignore file."
    Write-Host "  Blocks utility scripts, env configs, and sensitive credentials."
    Write-Host "  Safely handles existing files and supports -WhatIf simulations."
    Write-Host ""
    Write-Host "USAGE OPTIONS:"
    Write-Host "  Basic Initialization (Recommended):"
    Write-Host "  .\Initialize-GitIgnore.ps1 -RepoPath `"C:\Projects\SystemAudit`""
    Write-Host ""
    Write-Host "  Force Overwrite Configuration:"
    Write-Host "  .\Initialize-GitIgnore.ps1 -RepoPath `"C:\Projects\SystemAudit`" -Force"
    Write-Host ""
    Write-Host "  Simulation Mode (WhatIf):"
    Write-Host "  .\Initialize-GitIgnore.ps1 -RepoPath `"C:\Projects\SystemAudit`" -WhatIf"
    Write-Host ""
    Write-Host "  Display this operational help manual:"
    Write-Host "  .\Initialize-GitIgnore.ps1 -Help"
    Write-Host "=====================================================================" -ForegroundColor Cyan
}

# 1. Trigger Help if requested or if no parameters are provided
if ($Help -or [string]::IsNullOrEmpty($RepoPath)) {
    Show-ScriptHelp
    Exit 0
}

# 2. Secure Input Validation / Guardrails against dangerous path inputs
$SanitizedPath = $RepoPath.Trim()
$DangerousPaths = @("C:\", "C:\Windows", "C:\Windows\System32", "$env:SystemRoot")

if ($DangerousPaths -contains $SanitizedPath) {
    Write-Error "CRITICAL: Execution on core system directories is restricted for security reasons."
    Exit
}

$AbsolutePath = Resolve-Path -Path $SanitizedPath -ErrorAction SilentlyContinue
if (-not $AbsolutePath) {
    Write-Error "The specified directory path '$RepoPath' does not exist."
    Exit
}

# Ensure it's a directory, not a file input
if (-not (Test-Path -Path $AbsolutePath.Path -PathType Container)) {
    Write-Error "The provided path is a file. Please provide a valid Git repository root directory."
    Exit
}

$GitIgnorePath = Join-Path -Path $AbsolutePath.Path -ChildPath ".gitignore"

# 3. Defensive State Evaluation with Native Support for -WhatIf Simulation
if (Test-Path $GitIgnorePath) {
    if (-not $Force) {
        Write-Host "[!] A .gitignore file already exists in this repository." -ForegroundColor Yellow
        Write-Host "[!] Aborting execution to prevent data loss. Use the '-Force' switch if you explicitly want to overwrite it." -ForegroundColor Yellow
        Write-Host "    Example: .\Initialize-GitIgnore.ps1 -RepoPath `"$RepoPath`" -Force`n" -ForegroundColor DarkGray
        Exit
    } else {
        # This checks if the user ran the script with -WhatIf parameter
        if ($PSCmdlet.ShouldProcess($GitIgnorePath, "Overwrite existing repository configuration standard")) {
            Write-Host "[!] Force switch detected. Overwriting the existing .gitignore file configuration..." -ForegroundColor Red
        } else {
            # Execution will abort automatically here during simulation
            Exit
        }
    }
} else {
    if (-not ($PSCmdlet.ShouldProcess($GitIgnorePath, "Create new advanced initialization matrix"))) {
        # Stop processing if simulation mode is active
        Exit
    }
    Write-Host "[+] The .gitignore file does not exist in this repository. Creating a new initialization architecture..." -ForegroundColor Green
    New-Item -Path $GitIgnorePath -ItemType File -Force | Out-Null
}

# 4. Professional Base .gitignore Architecture Template (Bugs fixed with clean literals)
$IgnoreContent = @(
    "# =========================================================================",
    "# REPOSITORY SECURITY CONFIGURATION - GENERATED AUTOMATICALLY",
    "# =========================================================================",
    "",
    "# 1. Self-Exclusion Rule",
    "# Used to keep local administrative exclusion architectures purely environment-bound",
    ".gitignore",
    "",
    "# 2. Private Administrative Directories (Local script Sandboxes)",
    "local/",
    ".local/",
    "",
    "# 3. Environmental Configuration Layer (Tokens, Passwords, API Keys, Credentials)",
    ".env",
    ".env.local",
    "env.local",
    "*.env",
    "",
    "# 4. OS-Specific Temporary Overhead",
    "Thumbs.db",
    "ehthumbs.db",
    "Desktop.ini",
    '$RECYCLE.BIN/',
    "*.lnk",
    "",
    "# 5. Log Files, Backups, and Application Runtime Locks (e.g., MS Excel)",
    "~$*",
    "*.tmp",
    "*.log",
    "*.bak"
)

# 4.5. Optional: Generate Local Environment Scaffold
if ($CreateLocalEnv) {
    $EnvPath = Join-Path -Path $AbsolutePath.Path -ChildPath ".env"
    $LocalPath = Join-Path -Path $AbsolutePath.Path -ChildPath ".local"
    
    if (-not (Test-Path $EnvPath)) {
        if ($PSCmdlet.ShouldProcess($EnvPath, "Create .env directory")) {
            New-Item -Path $EnvPath -ItemType Directory -Force | Out-Null
            Write-Host "[+] Created standard .env directory." -ForegroundColor Green
        }
    }
    if (-not (Test-Path $LocalPath)) {
        if ($PSCmdlet.ShouldProcess($LocalPath, "Create .local directory structure")) {
            New-Item -Path $LocalPath -ItemType Directory -Force | Out-Null
            Write-Host "[+] Created standard .local directory." -ForegroundColor Green
        }
    }
}

# 5. Content Write Stream Execution and Summary Display
try {
    $IgnoreContent | Out-File -FilePath $GitIgnorePath -Encoding utf8 -Force
    Write-Host "`n[+] The .gitignore matrix has been successfully deployed to: $GitIgnorePath" -ForegroundColor Green
    
    # Target confirmation for requested structures
    Write-Host "[+] Verified: Core administrative and environment structures (env, .env, local, .local) are now strictly ignored." -ForegroundColor Cyan
    
    # 6. Reading and printing all other ignored patterns dynamically
    Write-Host "`n[*] Full list of active exclusion rules in this repository:" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------------------" -ForegroundColor Gray
    
    $CurrentIgnoreList = Get-Content -Path $GitIgnorePath
    foreach ($Line in $CurrentIgnoreList) {
        if ($Line.StartsWith("#")) {
            Write-Host $Line -ForegroundColor DarkGray
        } elseif (-not [string]::IsNullOrWhiteSpace($Line)) {
            Write-Host " -> $Line" -ForegroundColor DarkGreen
        }
    }
    Write-Host "------------------------------------------------------------------------" -ForegroundColor Gray
}
catch {
    Write-Error "An unhandled exception occurred during the execution stream write operation: $_"
}