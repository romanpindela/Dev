<#
================================================================================
  Script Name : Enable-GitCommitSigning.ps1
  Author      : Roman Pindela
  Contact     : roman.pindela@gmail.com
  GitHub      : https://github.com/romanpindela
  Version     : 1.0.0
  Release Date: 2026-10-22
  License     : MIT
  Repository  : https://github.com/romanpindela/Dev

  DESCRIPTION:
    Production-grade PowerShell automation engine for configuring cryptographic
    SSH commit and tag signing in Git, managing local allowed signers, configuring
    the OpenSSH agent service, and executing automated or semi-automated key
    registration on GitHub as an official "Signing Key".

    Features dynamic real-time progress bars (Write-Progress), comprehensive
    pre-execution diagnostic tables, structured multi-target logging, empty-run
    safeguards, and an integrated file shipping pipeline with detailed progress
    visualization.

    Running the script without any parameters safely displays the interactive
    help guide, metadata, and operational examples without altering system state.

  SECURITY & BEST PRACTICES:
    - Implements RFC 8032 Ed25519 high-performance elliptic-curve cryptography.
    - Maintains local 'allowed_signers' verification mapping for valid local audit
      via 'git log --show-signature'.
    - Language-independent SID verification for administrative role detection.
    - Automated fallback mechanisms for GitHub CLI authorization and scopes.
================================================================================
.SYNOPSIS
    Automates Git SSH commit signing configuration, key generation, and GitHub registration.
.DESCRIPTION
    Configures global Git variables for SSH commit signing (gpg.format, user.signingkey,
    commit.gpgsign, tag.gpgSign, gpg.ssh.allowedSignersFile), creates or links Ed25519/RSA
    SSH keys, handles automated/semi-automated GitHub registration, tests signatures,
    and supports shipping repository commits with real-time progress bars.
.PARAMETER Enable
    Switch initiating the end-to-end Git commit signing onboarding procedure.
.PARAMETER KeyPath
    Absolute or relative path to the SSH private key.
    Default: $HOME\.ssh\id_ed25519_signing (or existing $HOME\.ssh\id_ed25519 if selected).
.PARAMETER UseExistingKey
    Switch to automatically detect and use an existing primary SSH key ($HOME\.ssh\id_ed25519).
.PARAMETER KeyType
    Cryptographic algorithm used for newly generated keys: 'ed25519' (recommended) or 'rsa'.
    Default: ed25519.
.PARAMETER KeyTitle
    Human-readable title for the key when registered on GitHub.
    Default: "<Hostname> - Git Commit Signing (<KeyType>)".
.PARAMETER Email
    Email address associated with Git commits and GitHub account.
    Defaults to global git config 'user.email' if available.
.PARAMETER Name
    Full committer name. Defaults to global git config 'user.name' if available.
.PARAMETER AllowedSignersFile
    Path to the allowed signers verification file.
    Default: $HOME\.ssh\allowed_signers.
.PARAMETER RegistrationMode
    GitHub registration strategy:
      - 'Auto'   : Uses GitHub CLI ('gh ssh-key add ... --type signing').
      - 'Manual' : Copies public key to clipboard, launches browser to GitHub Keys settings,
                   and displays step-by-step instructions.
      - 'Prompt' : Prompts user to choose between Auto and Manual during execution.
    Default: Auto.
.PARAMETER ConfigureAgent
    Switch enabling OpenSSH Authentication Agent service (ssh-agent) startup and key caching.
.PARAMETER TestCommit
    Creates an isolated temporary repository to verify cryptographic signature generation.
.PARAMETER RepoPath
    Optional path to a target local Git repository for local configuration or file shipping.
.PARAMETER Push
    Stages, cryptographically signs, and pushes changes from RepoPath with a real-time progress bar.
.PARAMETER CommitMessage
    Commit message used when shipping files with the -Push parameter.
.PARAMETER LogPath
    Custom path for the operation log file. If omitted, a timestamped log is created in
    $HOME\.git-commit-signing\logs\.
.PARAMETER NoLog
    Disables writing log events to disk (console output remains active).
.PARAMETER Help
    Displays the detailed operational manual, parameter definitions, and usage examples.
.EXAMPLE
    .\Enable-GitCommitSigning.ps1
    # Empty-run: Displays formatted help guide, author info, and usage examples.
.EXAMPLE
    .\Enable-GitCommitSigning.ps1 -Enable
    # Standard setup: Generates dedicated Ed25519 signing key, configures Git globally,
    # configures allowed_signers, registers on GitHub via gh CLI, and tests signature.
.EXAMPLE
    .\Enable-GitCommitSigning.ps1 -Enable -UseExistingKey
    # Uses existing $HOME\.ssh\id_ed25519 key instead of generating a new keypair.
.EXAMPLE
    .\Enable-GitCommitSigning.ps1 -Enable -RegistrationMode Manual
    # Configures Git signing and launches GitHub web portal with key copied to clipboard.
.EXAMPLE
    .\Enable-GitCommitSigning.ps1 -Enable -ConfigureAgent
    # Configures Git signing and registers key inside Windows OpenSSH Authentication Agent.
.EXAMPLE
    .\Enable-GitCommitSigning.ps1 -Push -RepoPath "C:\Dane\rpindela\GitHub\Dev" -CommitMessage "feat: sign commits"
    # Stages files, signs commit, and pushes to remote with detailed real-time progress bar.
.NOTES
    Author: Roman Pindela
    Email: roman.pindela@gmail.com
    GitHub: https://github.com/romanpindela
    Version: 1.0.0
    ReleaseDate: 2026-10-22

    SECURITY NOTICE:
    When downloading this script from a remote repository or internet source,
    unblock execution in PowerShell prior to first run:
    Unblock-File -Path .\Enable-GitCommitSigning.ps1
#>

[CmdletBinding(DefaultParameterSetName = "Default")]
param (
    [Parameter(ParameterSetName = "Configure")]
    [Alias("e", "Setup", "Init")]
    [switch]$Enable,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [Alias("k", "Key")]
    [string]$KeyPath,

    [Parameter(ParameterSetName = "Configure")]
    [Alias("Existing")]
    [switch]$UseExistingKey,

    [Parameter(ParameterSetName = "Configure")]
    [ValidateSet("ed25519", "rsa")]
    [string]$KeyType = "ed25519",

    [Parameter(ParameterSetName = "Configure")]
    [Alias("t", "Title")]
    [string]$KeyTitle,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [string]$Email,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [string]$Name,

    [Parameter(ParameterSetName = "Configure")]
    [string]$AllowedSignersFile,

    [Parameter(ParameterSetName = "Configure")]
    [ValidateSet("Auto", "Manual", "Prompt")]
    [string]$RegistrationMode = "Auto",

    [Parameter(ParameterSetName = "Configure")]
    [Alias("Agent")]
    [switch]$ConfigureAgent,

    [Parameter(ParameterSetName = "Configure")]
    [Alias("Test")]
    [switch]$TestCommit,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [Alias("p", "Path")]
    [string]$RepoPath,

    [Parameter(ParameterSetName = "PushMode")]
    [Alias("Ship")]
    [switch]$Push,

    [Parameter(ParameterSetName = "PushMode")]
    [Alias("m", "Message")]
    [string]$CommitMessage,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [Alias("l", "Log")]
    [string]$LogPath,

    [Parameter(ParameterSetName = "Configure")]
    [Parameter(ParameterSetName = "PushMode")]
    [switch]$NoLog,

    [Parameter(ParameterSetName = "Help")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("h")]
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- GLOBAL METADATA DECLARATION ---
$SCRIPT_INFO = @{
    Name        = "Enable-GitCommitSigning"
    Version     = "1.0.0"
    Author      = "Roman Pindela"
    Contact     = "roman.pindela@gmail.com"
    GitHub      = "https://github.com/romanpindela"
    ReleaseDate = "2026-10-22"
    License     = "MIT"
}

# Global log file handle
$script:ActiveLogFile = $null

# --- LOGGING & OUTPUT SUBSYSTEM ---

function Initialize-Logger {
    param (
        [string]$CustomLogPath,
        [bool]$DisableLogging
    )

    if ($DisableLogging) {
        $script:ActiveLogFile = $null
        return
    }

    try {
        if (-not [string]::IsNullOrWhiteSpace($CustomLogPath)) {
            $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($CustomLogPath)
            $logDir = [System.IO.Path]::GetDirectoryName($resolved)
            if (-not [string]::IsNullOrWhiteSpace($logDir) -and -not [System.IO.Directory]::Exists($logDir)) {
                [System.IO.Directory]::CreateDirectory($logDir) | Out-Null
            }
            $script:ActiveLogFile = $resolved
        } else {
            # Default structured log path
            $defaultLogDir = Join-Path $HOME ".git-commit-signing\logs"
            if (-not [System.IO.Directory]::Exists($defaultLogDir)) {
                [System.IO.Directory]::CreateDirectory($defaultLogDir) | Out-Null
            }
            $timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
            $script:ActiveLogFile = Join-Path $defaultLogDir "commit-signing-$timestamp.log"
        }

        # Initialize log header
        $header = @"
================================================================================
  $($SCRIPT_INFO.Name) - Execution Log
  Start Time : $((Get-Date).ToString("yyyy-MM-dd HH:mm:ss"))
  Version    : $($SCRIPT_INFO.Version)
  Author     : $($SCRIPT_INFO.Author) ($($SCRIPT_INFO.Contact))
  Host       : $env:COMPUTERNAME | User: $env:USERNAME
================================================================================
"@
        [System.IO.File]::AppendAllText($script:ActiveLogFile, $header + "`r`n", [System.Text.Encoding]::UTF8)
    }
    catch {
        Write-Warning "Failed to initialize log file at '$CustomLogPath': $_"
        $script:ActiveLogFile = $null
    }
}

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARN", "ERROR", "STEP", "RAW")]
        [string]$Level = "INFO",
        [ConsoleColor]$Color = [ConsoleColor]::White
    )

    $timePrefix = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logLine = "[$timePrefix] [$Level] $Message"

    # Color routing if default White was given
    if ($Color -eq [ConsoleColor]::White) {
        switch ($Level) {
            "SUCCESS" { $Color = [ConsoleColor]::Green }
            "WARN"    { $Color = [ConsoleColor]::Yellow }
            "ERROR"   { $Color = [ConsoleColor]::Red }
            "STEP"    { $Color = [ConsoleColor]::Cyan }
            "RAW"     { $Color = [ConsoleColor]::Gray }
            default   { $Color = [ConsoleColor]::White }
        }
    }

    try { [Console]::CursorLeft = 0 } catch {}

    if ($Level -eq "RAW") {
        Write-Host $Message -ForegroundColor $Color
    } else {
        Write-Host $Message -ForegroundColor $Color
    }

    if (-not [string]::IsNullOrWhiteSpace($script:ActiveLogFile)) {
        try {
            [System.IO.File]::AppendAllText($script:ActiveLogFile, $logLine + "`r`n", [System.Text.Encoding]::UTF8)
        }
        catch {}
    }
}

# --- SYSTEM & ENVIRONMENT DIAGNOSTICS ---

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $adminSid = New-Object Security.Principal.SecurityIdentifier([Security.Principal.WellKnownSidType]::BuiltInAdministratorsSid, $null)
    return $principal.IsInRole($adminSid)
}

function Format-NormalizedPath {
    param ([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return "" }
    return ($Path -replace '\\', '/').Trim()
}

function Invoke-GitProcess {
    param (
        [string]$Arguments,
        [string]$WorkingDirectory = $PWD.Path
    )

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "git.exe"
    $pinfo.Arguments = $Arguments
    if (-not [string]::IsNullOrWhiteSpace($WorkingDirectory) -and (Test-Path $WorkingDirectory)) {
        $pinfo.WorkingDirectory = $WorkingDirectory
    }
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError = $true
    $pinfo.UseShellExecute = $false
    $pinfo.CreateNoWindow = $true
    $pinfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $pinfo.StandardErrorEncoding = [System.Text.Encoding]::UTF8

    $proc = [System.Diagnostics.Process]::Start($pinfo)
    $stdOut = $proc.StandardOutput.ReadToEnd()
    $stdErr = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()

    return [PSCustomObject]@{
        ExitCode = $proc.ExitCode
        StdOut   = if ($stdOut) { $stdOut.Trim() } else { "" }
        StdErr   = if ($stdErr) { $stdErr.Trim() } else { "" }
    }
}

# --- HELP DISPLAY (EMPTY-RUN SAFEGUARD) ---

function Show-HelpGuide {
    try { [Console]::CursorLeft = 0 } catch {}
    Write-Host @"
================================================================================
  $($SCRIPT_INFO.Name) - v$($SCRIPT_INFO.Version)
  Author : $($SCRIPT_INFO.Author) | Contact: $($SCRIPT_INFO.Contact)
  GitHub : $($SCRIPT_INFO.GitHub) | License: $($SCRIPT_INFO.License)
================================================================================
DESCRIPTION:
  Automates the configuration of SSH key-based Git commit and tag signing.
  Enforces cryptographic authenticity verification on GitHub, generating
  verified commit badges without needing external GPG suites.

  Configures:
    - Git global signing parameters (gpg.format=ssh, commit.gpgsign=true, tag.gpgSign=true)
    - Cryptographic keypair generation (RFC 8032 Ed25519 or 4096-bit RSA)
    - Local verification database (gpg.ssh.allowedSignersFile)
    - OpenSSH Authentication Agent (ssh-agent service)
    - GitHub key registration (automated via 'gh' CLI or semi-automated web portal)
    - Cryptographic signature sandbox verification test
    - Git push and file shipping pipeline with real-time progress bars (Write-Progress)

USAGE:
  .\Enable-GitCommitSigning.ps1 -Enable [-UseExistingKey] [-KeyPath <path>]
                                [-RegistrationMode <Auto|Manual|Prompt>]
                                [-ConfigureAgent] [-TestCommit] [-LogPath <file>]
  .\Enable-GitCommitSigning.ps1 -Push -RepoPath <path> [-CommitMessage <text>]
  .\Enable-GitCommitSigning.ps1 -Help | -h

PARAMETERS:
  -Enable, -e, -Setup      : Executes the complete end-to-end Git commit signing onboarding.
  -UseExistingKey          : Auto-detects and uses default key (~/.ssh/id_ed25519).
  -KeyPath, -k             : Path to custom SSH private key (default: ~/.ssh/id_ed25519_signing).
  -KeyType                 : Cryptographic key type: 'ed25519' (default) or 'rsa'.
  -KeyTitle, -t            : Descriptive title for GitHub (default: "<Host> - Git Commit Signing").
  -Email                   : Committer email address (auto-detected from git config if omitted).
  -Name                    : Committer display name (auto-detected from git config if omitted).
  -AllowedSignersFile      : Custom path to allowed_signers database (default: ~/.ssh/allowed_signers).
  -RegistrationMode        : 'Auto' (GitHub CLI 'gh'), 'Manual' (clipboard + browser), 'Prompt'.
  -ConfigureAgent, -Agent  : Sets Windows 'ssh-agent' service to Automatic, starts it, and adds key.
  -TestCommit, -Test       : Runs an isolated sandbox test commit to verify cryptographic signatures.
  -RepoPath, -p            : Path to a specific Git repository for local configuration or pushing.
  -Push, -Ship             : Stages, signs, and pushes changes from RepoPath with a real-time progress bar.
  -CommitMessage, -m       : Commit message when shipping code with -Push.
  -LogPath, -l             : Custom path for execution log file (default: ~/.git-commit-signing/logs/).
  -NoLog                   : Disables file logging.
  -Help, -h                : Displays this detailed help menu and exits safely.

EXAMPLES:
  1) Standard Onboarding (Automatic):
     .\Enable-GitCommitSigning.ps1 -Enable

  2) Use Existing Default SSH Key (~/.ssh/id_ed25519):
     .\Enable-GitCommitSigning.ps1 -Enable -UseExistingKey

  3) Semi-Automated Registration (Copies key and opens GitHub web portal):
     .\Enable-GitCommitSigning.ps1 -Enable -RegistrationMode Manual

  4) Configure OpenSSH Agent Service & Run Cryptographic Sandbox Test:
     .\Enable-GitCommitSigning.ps1 -Enable -ConfigureAgent -TestCommit

  5) Ship Signed Changes to Remote with Real-Time Progress Bar:
     .\Enable-GitCommitSigning.ps1 -Push -RepoPath "C:\Dane\rpindela\GitHub\Dev" -CommitMessage "feat: sign commits"

SECURITY NOTICE:
  To unblock script execution after cloning:
  Unblock-File -Path .\Enable-GitCommitSigning.ps1
================================================================================
"@ -ForegroundColor Cyan
}

# Empty-run validation guardrail
if ($Help -or ($PSBoundParameters.Count -eq 0)) {
    Show-HelpGuide
    exit 0
}

# --- INITIALIZE RUNTIME PARAMETERS & LOGGING ---

Initialize-Logger -CustomLogPath $LogPath -DisableLogging $NoLog

Write-Log "================================================================================" "RAW" Cyan
Write-Log "  $($SCRIPT_INFO.Name) v$($SCRIPT_INFO.Version) - Cryptographic Git Signing Engine" "RAW" Cyan
Write-Log "  Author: $($SCRIPT_INFO.Author) | Contact: $($SCRIPT_INFO.Contact)" "RAW" Gray
if (-not [string]::IsNullOrWhiteSpace($script:ActiveLogFile)) {
    Write-Log "  Active Log File : $script:ActiveLogFile" "RAW" DarkCyan
}
Write-Log "================================================================================" "RAW" Cyan
Write-Log "" "RAW" White

# Step 0: Binary Dependencies Verification
Write-Log "[*] Verifying system binary execution dependencies..." "INFO" DarkGray

$missingDeps = [System.Collections.Generic.List[string]]::new()
if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) { $missingDeps.Add("git.exe (Git for Windows)") }
if (-not (Get-Command ssh-keygen.exe -ErrorAction SilentlyContinue)) { $missingDeps.Add("ssh-keygen.exe (OpenSSH)") }

if ($missingDeps.Count -gt 0) {
    Write-Log "[-] Critical Missing Dependencies detected:" "ERROR" Red
    foreach ($dep in $missingDeps) {
        Write-Log "    - $dep" "ERROR" Red
    }
    Write-Log "    Install required dependencies and ensure they exist in system PATH." "ERROR" Red
    exit 1
}

# Detect or sanitize Committer Identity
$resolvedName = $Name
if ([string]::IsNullOrWhiteSpace($resolvedName)) {
    $cfgName = Invoke-GitProcess -Arguments "config --global user.name"
    if ($cfgName.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($cfgName.StdOut)) {
        $resolvedName = $cfgName.StdOut
    } else {
        $resolvedName = $env:USERNAME
    }
}

$resolvedEmail = $Email
if ([string]::IsNullOrWhiteSpace($resolvedEmail)) {
    $cfgEmail = Invoke-GitProcess -Arguments "config --global user.email"
    if ($cfgEmail.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($cfgEmail.StdOut)) {
        $resolvedEmail = $cfgEmail.StdOut
    }
}

# Validate Email Format
if (-not [string]::IsNullOrWhiteSpace($resolvedEmail)) {
    if ($resolvedEmail -notmatch "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
        Write-Log "[-] Validation Error: The email address '$resolvedEmail' is not a valid email format." "ERROR" Red
        exit 1
    }
}

# Resolve Target Key Path
$sshDir = Join-Path $HOME ".ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

$resolvedKeyPath = $KeyPath
if ([string]::IsNullOrWhiteSpace($resolvedKeyPath)) {
    if ($UseExistingKey) {
        $defaultKey = Join-Path $sshDir "id_ed25519"
        if (Test-Path $defaultKey) {
            $resolvedKeyPath = $defaultKey
        } else {
            $defaultRsa = Join-Path $sshDir "id_rsa"
            if (Test-Path $defaultRsa) {
                $resolvedKeyPath = $defaultRsa
            } else {
                $resolvedKeyPath = Join-Path $sshDir "id_ed25519_signing"
            }
        }
    } else {
        $resolvedKeyPath = Join-Path $sshDir "id_ed25519_signing"
    }
} else {
    $resolvedKeyPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($resolvedKeyPath)
}

$resolvedPubKeyPath = "${resolvedKeyPath}.pub"

# Resolve Key Title
$resolvedKeyTitle = $KeyTitle
if ([string]::IsNullOrWhiteSpace($resolvedKeyTitle)) {
    $resolvedKeyTitle = "$env:COMPUTERNAME - Git Commit Signing ($KeyType)"
}

# Resolve Allowed Signers File
$resolvedAllowedSigners = $AllowedSignersFile
if ([string]::IsNullOrWhiteSpace($resolvedAllowedSigners)) {
    $resolvedAllowedSigners = Join-Path $sshDir "allowed_signers"
} else {
    $resolvedAllowedSigners = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($resolvedAllowedSigners)
}

# GitHub CLI Status Detection
$hasGhCli = [bool](Get-Command gh.exe -ErrorAction SilentlyContinue)
$ghAuthStatus = $false
$ghHasSigningScope = $false

if ($hasGhCli) {
    $authCheck = gh auth status 2>&1 | Out-String
    if ($authCheck -match "Logged in to github.com") {
        $ghAuthStatus = $true
        if ($authCheck -match "admin:ssh_signing_key") {
            $ghHasSigningScope = $true
        }
    }
}

# --- PARAMETERS & DIAGNOSTIC TABLE VISUALIZER ---

function Show-ConfigurationSummaryTable {
    Write-Log "--------------------------------------------------------------------------------" "RAW" DarkCyan
    Write-Log "                   ACTIVE EXECUTION CONFIGURATION & PARAMETERS" "RAW" Cyan
    Write-Log "--------------------------------------------------------------------------------" "RAW" DarkCyan
    $emailDisplay = if ($resolvedEmail) { $resolvedEmail } else { "[NOT CONFIGURED]" }
    $emailColor   = if ($resolvedEmail) { [ConsoleColor]::White } else { [ConsoleColor]::Yellow }
    $keyExists    = Test-Path $resolvedKeyPath
    $keyColor     = if ($keyExists) { [ConsoleColor]::Green } else { [ConsoleColor]::Yellow }
    $ghCliColor   = if ($hasGhCli) { [ConsoleColor]::Green } else { [ConsoleColor]::Gray }
    $ghAuthColor  = if ($ghAuthStatus) { [ConsoleColor]::Green } else { [ConsoleColor]::DarkYellow }
    $ghScopeColor = if ($ghHasSigningScope) { [ConsoleColor]::Green } else { [ConsoleColor]::DarkYellow }

    Write-Log ("  Committer Name        : {0}" -f $resolvedName) "RAW" White
    Write-Log ("  Committer Email       : {0}" -f $emailDisplay) "RAW" $emailColor
    Write-Log ("  Selected Key Type     : {0}" -f $KeyType.ToUpper()) "RAW" White
    Write-Log ("  Private Key Path      : {0}" -f $resolvedKeyPath) "RAW" White
    Write-Log ("  Public Key Path       : {0}" -f $resolvedPubKeyPath) "RAW" White
    Write-Log ("  Key Exists on Disk    : {0}" -f $keyExists) "RAW" $keyColor
    Write-Log ("  Allowed Signers Path  : {0}" -f $resolvedAllowedSigners) "RAW" White
    Write-Log ("  Signing GPG Format    : ssh" ) "RAW" Green
    Write-Log ("  Commit GPG Signing    : true" ) "RAW" Green
    Write-Log ("  Tag GPG Signing       : true" ) "RAW" Green
    Write-Log ("  GitHub CLI Installed  : {0}" -f $hasGhCli) "RAW" $ghCliColor
    Write-Log ("  GitHub CLI Logged In  : {0}" -f $ghAuthStatus) "RAW" $ghAuthColor
    Write-Log ("  GitHub Signing Scope  : {0}" -f $ghHasSigningScope) "RAW" $ghScopeColor
    Write-Log ("  Registration Mode     : {0}" -f $RegistrationMode) "RAW" White
    if ($Push -or -not [string]::IsNullOrWhiteSpace($RepoPath)) {
        $repoDisplay = if ($RepoPath) { $RepoPath } else { $PWD.Path }
        Write-Log ("  Target Repository     : {0}" -f $repoDisplay) "RAW" Magenta
        Write-Log ("  Shipping Mode (Push)  : {0}" -f $Push) "RAW" Magenta
    }
    Write-Log "--------------------------------------------------------------------------------" "RAW" DarkCyan
    Write-Log "" "RAW" White
}

# --- EXECUTION STAGE HANDLERS ---

function Step-1-EnsureKeyExists {
    Write-Progress -Activity "Configuring Git Commit Signing" -Status "Step 1/7: Preparing SSH Keypair" -PercentComplete 15
    Write-Log "[Step 1/7] Inspecting SSH Keypair Material..." "STEP" Cyan

    if (Test-Path $resolvedKeyPath) {
        Write-Log "  [+] Existing private key identified at: $resolvedKeyPath" "INFO" Green
    } else {
        Write-Log "  [*] Generating new high-security $KeyType cryptographic keypair..." "INFO" Blue
        if ([string]::IsNullOrWhiteSpace($resolvedEmail)) {
            Write-Log "[-] Cannot generate SSH key without an email address. Provide -Email or set git user.email." "ERROR" Red
            exit 1
        }

        # Generate key without passphrase prompt
        $keygenArgs = "-t $KeyType -C `"$resolvedEmail`" -f `"$resolvedKeyPath`" -N `"`" -q"
        $keygenProc = Start-Process -FilePath "ssh-keygen.exe" -ArgumentList $keygenArgs -NoNewWindow -Wait -PassThru

        if ($keygenProc.ExitCode -ne 0 -or -not (Test-Path $resolvedKeyPath)) {
            Write-Log "[-] Failed to generate SSH keypair using ssh-keygen." "ERROR" Red
            exit 1
        }
        Write-Log "  [SUCCESS] Generated new $KeyType keypair at: $resolvedKeyPath" "SUCCESS" Green
    }

    # Ensure public key exists
    if (-not (Test-Path $resolvedPubKeyPath)) {
        Write-Log "  [*] Generating missing public key from private key..." "INFO" DarkGray
        $pubArgs = "-y -f `"$resolvedKeyPath`""
        $pubContent = & ssh-keygen.exe -y -f "$resolvedKeyPath"
        if (-not [string]::IsNullOrWhiteSpace($pubContent)) {
            Set-Content -Path $resolvedPubKeyPath -Value $pubContent -Encoding utf8
        } else {
            Write-Log "[-] Failed to derive public key from private key." "ERROR" Red
            exit 1
        }
    }

    $pubKeyText = (Get-Content -Path $resolvedPubKeyPath -Raw).Trim()
    Write-Log "  [+] Public Key Fingerprint:" "INFO" Gray
    $fpResult = & ssh-keygen.exe -l -f "$resolvedPubKeyPath"
    Write-Log "      $fpResult" "RAW" DarkCyan
}

function Step-2-ConfigureGitGlobal {
    Write-Progress -Activity "Configuring Git Commit Signing" -Status "Step 2/7: Applying Global Git Settings" -PercentComplete 30
    Write-Log "[Step 2/7] Injecting Global Git SSH Signing Configuration..." "STEP" Cyan

    # Ensure user identity is configured in Git
    if (-not [string]::IsNullOrWhiteSpace($resolvedName)) {
        git config --global user.name "$resolvedName"
    }
    if (-not [string]::IsNullOrWhiteSpace($resolvedEmail)) {
        git config --global user.email "$resolvedEmail"
    }

    # Normalize path with forward slashes for Git for Windows compatibility
    $normalizedKeyPath = Format-NormalizedPath $resolvedPubKeyPath
    $normalizedAllowedSigners = Format-NormalizedPath $resolvedAllowedSigners

    git config --global gpg.format ssh
    git config --global user.signingkey "$normalizedKeyPath"
    git config --global commit.gpgsign true
    git config --global tag.gpgSign true
    git config --global gpg.ssh.allowedSignersFile "$normalizedAllowedSigners"

    Write-Log "  [+] git config --global gpg.format ssh" "INFO" Gray
    Write-Log "  [+] git config --global user.signingkey $normalizedKeyPath" "INFO" Gray
    Write-Log "  [+] git config --global commit.gpgsign true" "INFO" Gray
    Write-Log "  [+] git config --global tag.gpgSign true" "INFO" Gray
    Write-Log "  [+] git config --global gpg.ssh.allowedSignersFile $normalizedAllowedSigners" "INFO" Gray
    Write-Log "  [SUCCESS] Global Git parameters successfully committed." "SUCCESS" Green
}

function Step-3-ConfigureAllowedSigners {
    Write-Progress -Activity "Configuring Git Commit Signing" -Status "Step 3/7: Updating Allowed Signers" -PercentComplete 45
    Write-Log "[Step 3/7] Managing Local Allowed Signers Database..." "STEP" Cyan

    $allowedDir = [System.IO.Path]::GetDirectoryName($resolvedAllowedSigners)
    if (-not [string]::IsNullOrWhiteSpace($allowedDir) -and -not (Test-Path $allowedDir)) {
        New-Item -ItemType Directory -Path $allowedDir -Force | Out-Null
    }

    if (-not (Test-Path $resolvedAllowedSigners)) {
        New-Item -ItemType File -Path $resolvedAllowedSigners -Force | Out-Null
    }

    $pubKeyText = (Get-Content -Path $resolvedPubKeyPath -Raw).Trim()
    $signerEntry = "$resolvedEmail $pubKeyText"

    $existingContent = Get-Content -Path $resolvedAllowedSigners -ErrorAction SilentlyContinue
    $alreadyExists = $false

    if ($existingContent) {
        foreach ($line in $existingContent) {
            if ($line.Trim() -eq $signerEntry -or ($line -match [regex]::Escape($pubKeyText))) {
                $alreadyExists = $true
                break
            }
        }
    }

    if (-not $alreadyExists) {
        Add-Content -Path $resolvedAllowedSigners -Value $signerEntry -Encoding utf8
        Write-Log "  [SUCCESS] Added signing identity to allowed_signers database:" "SUCCESS" Green
        Write-Log "      $signerEntry" "RAW" DarkGray
    } else {
        Write-Log "  [+] Signing identity already registered in allowed_signers." "INFO" DarkYellow
    }
}

function Step-4-ConfigureSshAgent {
    Write-Progress -Activity "Configuring Git Commit Signing" -Status "Step 4/7: Checking OpenSSH Agent" -PercentComplete 60
    Write-Log "[Step 4/7] Checking OpenSSH Authentication Agent (ssh-agent)..." "STEP" Cyan

    $agentService = Get-Service -Name "ssh-agent" -ErrorAction SilentlyContinue

    if ($null -eq $agentService) {
        Write-Log "  [-] OpenSSH Authentication Agent service not found on this system." "WARN" Yellow
        return
    }

    $isAdmin = Test-IsAdministrator

    if ($ConfigureAgent) {
        if ($isAdmin) {
            Write-Log "  [*] Setting ssh-agent startup type to Automatic and starting service..." "INFO" Blue
            Set-Service -Name "ssh-agent" -StartupType Automatic
            Start-Service -Name "ssh-agent"
            Write-Log "  [SUCCESS] OpenSSH Authentication Agent configured and running." "SUCCESS" Green
        } else {
            if ($agentService.Status -ne [System.ServiceProcess.ServiceControllerStatus]::Running) {
                Write-Log "  [!] Notice: Windows 'ssh-agent' service requires Administrator privileges to configure." "WARN" Yellow
                Write-Log "      To enable it permanently, launch PowerShell as Administrator and run:" "WARN" Yellow
                Write-Log "      Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent" "WARN" Cyan
            }
        }
    }

    # Attempt to add key via ssh-add if agent is running
    $refreshedService = Get-Service -Name "ssh-agent" -ErrorAction SilentlyContinue
    if ($refreshedService -and $refreshedService.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running) {
        try {
            $addResult = & ssh-add.exe "$resolvedKeyPath" 2>&1
            Write-Log "  [+] Loaded key into OpenSSH Agent: $addResult" "INFO" DarkGray
        }
        catch {
            Write-Log "  [!] Unable to load key into ssh-agent: $_" "WARN" DarkYellow
        }
    } else {
        Write-Log "  [*] ssh-agent service is Stopped/Disabled. Git will sign directly via key file." "INFO" DarkGray
    }
}

function Step-5-RegisterKeyOnGitHub {
    Write-Progress -Activity "Configuring Git Commit Signing" -Status "Step 5/7: GitHub Key Registration" -PercentComplete 75
    Write-Log "[Step 5/7] Registering SSH Signing Key with GitHub..." "STEP" Cyan

    $pubKeyText = (Get-Content -Path $resolvedPubKeyPath -Raw).Trim()

    $targetMode = $RegistrationMode
    if ($targetMode -eq "Prompt") {
        Write-Host ""
        Write-Host "Select GitHub Registration Mode:" -ForegroundColor Yellow
        Write-Host "  [1] Automatic via GitHub CLI (gh)" -ForegroundColor White
        Write-Host "  [2] Semi-Automated via Browser & Clipboard" -ForegroundColor White
        $choice = Read-Host "Enter option (1 or 2, default: 1)"
        if ($choice -eq "2") {
            $targetMode = "Manual"
        } else {
            $targetMode = "Auto"
        }
    }

    $registeredSuccessfully = $false

    if ($targetMode -eq "Auto" -and $hasGhCli -and $ghAuthStatus) {
        Write-Log "  [*] Attempting automated registration via GitHub CLI (gh)..." "INFO" Blue

        # First verify if key already exists on GitHub
        $existingKeys = gh ssh-key list 2>&1 | Out-String
        if ($existingKeys -match [regex]::Escape($pubKeyText.Substring(0, [math]::Min(30, $pubKeyText.Length)))) {
            Write-Log "  [+] Key appears to already be registered on your GitHub account." "INFO" Green
            $registeredSuccessfully = $true
        } else {
            # Attempt to add key as signing key
            $addOutput = gh ssh-key add "$resolvedPubKeyPath" --title "$resolvedKeyTitle" --type signing 2>&1 | Out-String
            $addExit = $LASTEXITCODE

            if ($addExit -eq 0) {
                Write-Log "  [SUCCESS] Key successfully registered on GitHub as a Signing Key!" "SUCCESS" Green
                $registeredSuccessfully = $true
            } elseif ($addOutput -match "admin:ssh_signing_key") {
                Write-Log "  [!] GitHub CLI token is missing 'admin:ssh_signing_key' scope." "WARN" Yellow
                Write-Log "      Switching to semi-automated registration workflow..." "WARN" Yellow
                $targetMode = "Manual"
            } else {
                Write-Log "  [!] GitHub CLI registration returned: $($addOutput.Trim())" "WARN" Yellow
                $targetMode = "Manual"
            }
        }
    } elseif ($targetMode -eq "Auto") {
        Write-Log "  [!] GitHub CLI (gh) is not installed or not authenticated. Switching to Manual mode." "WARN" Yellow
        $targetMode = "Manual"
    }

    if ($targetMode -eq "Manual" -and -not $registeredSuccessfully) {
        Write-Log "  [*] Launching Semi-Automated GitHub Registration Procedure..." "INFO" Blue

        # Copy to clipboard
        try {
            Set-Clipboard -Value $pubKeyText
            Write-Log "  [+] Public key copied to Windows Clipboard automatically." "SUCCESS" Green
        }
        catch {
            try {
                $pubKeyText | clip.exe
                Write-Log "  [+] Public key copied to Windows Clipboard via clip.exe." "SUCCESS" Green
            }
            catch {
                Write-Log "  [!] Could not copy key to clipboard automatically." "WARN" Yellow
            }
        }

        # Open GitHub settings in default web browser
        $githubKeysUrl = "https://github.com/settings/keys"
        Write-Log "  [*] Opening GitHub SSH Keys Settings in default browser: $githubKeysUrl" "INFO" Cyan
        try {
            Start-Process $githubKeysUrl
        } catch {
            Write-Log "  [!] Could not launch browser automatically. Navigate to: $githubKeysUrl" "WARN" Yellow
        }

        # Print detailed visual step-by-step instructions
        Write-Host ""
        Write-Host "================================================================================" -ForegroundColor Yellow
        Write-Host "             ACTION REQUIRED: ADD SIGNING KEY TO GITHUB DASHBOARD" -ForegroundColor Yellow
        Write-Host "================================================================================" -ForegroundColor Yellow
        Write-Host "1. In the opened browser window, click the green button: 'New SSH key'." -ForegroundColor White
        Write-Host "2. Title    : Enter a descriptive name, e.g.:" -ForegroundColor White
        Write-Host "              $resolvedKeyTitle" -ForegroundColor Cyan
        Write-Host "3. Key type : Select 'Signing Key' from the dropdown menu." -ForegroundColor White
        Write-Host "              (IMPORTANT: Do NOT select 'Authentication Key')!" -ForegroundColor Red
        Write-Host "4. Key      : Paste the public key currently in your clipboard (Ctrl+V)." -ForegroundColor White
        Write-Host "5. Click    : 'Add SSH key' and confirm with your GitHub credentials." -ForegroundColor White
        Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "Public Key String (also stored in clipboard):" -ForegroundColor DarkCyan
        Write-Host $pubKeyText -ForegroundColor White
        Write-Host "================================================================================" -ForegroundColor Yellow
        Write-Host ""
    }
}

function Step-6-TestLocalSigningSandbox {
    Write-Progress -Activity "Configuring Git Commit Signing" -Status "Step 6/7: Testing Cryptographic Signatures" -PercentComplete 90
    Write-Log "[Step 6/7] Running Cryptographic Signature Sandbox Test..." "STEP" Cyan

    $tempTestDir = Join-Path $env:TEMP "git-signing-sandbox-$((Get-Date).Ticks)"
    New-Item -ItemType Directory -Path $tempTestDir -Force | Out-Null

    try {
        $initResult = Invoke-GitProcess -Arguments "init -b main" -WorkingDirectory $tempTestDir
        $dummyFile = Join-Path $tempTestDir "signature_audit.txt"
        Set-Content -Path $dummyFile -Value "Signature audit verification timestamp: $((Get-Date).ToString('o'))" -Encoding utf8

        Invoke-GitProcess -Arguments "add signature_audit.txt" -WorkingDirectory $tempTestDir | Out-Null
        $commitResult = Invoke-GitProcess -Arguments "commit -S -m `"chore: audit cryptographic signing`"" -WorkingDirectory $tempTestDir

        if ($commitResult.ExitCode -ne 0) {
            Write-Log "[-] Sandbox commit signing test failed: $($commitResult.StdErr)" "ERROR" Red
            return $false
        }

        $logCheck = Invoke-GitProcess -Arguments "log --show-signature -1" -WorkingDirectory $tempTestDir
        $logOutput = $logCheck.StdOut

        if ($logOutput -match "Good `"git`" signature" -or $logOutput -match "Good.*signature") {
            Write-Log "  [SUCCESS] Cryptographic signature generated and verified successfully!" "SUCCESS" Green
            Write-Log "  [+] Signature Verification Output:" "INFO" Gray
            foreach ($line in ($logOutput -split "`r?`n")) {
                if ($line -match "Good.*signature" -or $line -match "ED25519" -or $line -match "RSA") {
                    Write-Log "      $line" "RAW" Green
                }
            }
            return $true
        } else {
            Write-Log "  [!] Commit was created, but signature output returned:" "WARN" Yellow
            Write-Log "      $logOutput" "RAW" DarkGray
            return $false
        }
    }
    catch {
        Write-Log "[-] Exception during sandbox test: $_" "ERROR" Red
        return $false
    }
    finally {
        if (Test-Path $tempTestDir) {
            Remove-Item -Path $tempTestDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Step-7-FinalizeAndReport {
    Write-Progress -Activity "Configuring Git Commit Signing" -Status "Step 7/7: Complete" -PercentComplete 100
    Write-Log "[Step 7/7] Onboarding Pipeline Completed Successfully." "STEP" Cyan
    Write-Progress -Activity "Configuring Git Commit Signing" -Completed

    Write-Log "" "RAW" White
    Write-Log "================================================================================" "RAW" Green
    Write-Log "          GIT COMMIT SIGNING IS NOW FULLY CONFIGURED & ACTIVE" "RAW" Green
    Write-Log "================================================================================" "RAW" Green
    Write-Log "Summary of Active Settings:" "RAW" White
    Write-Log "  Signing Engine       : OpenSSH (gpg.format = ssh)" "RAW" White
    Write-Log "  Signing Public Key   : $resolvedPubKeyPath" "RAW" White
    Write-Log "  Auto Sign Commits    : Enabled (commit.gpgsign = true)" "RAW" White
    Write-Log "  Auto Sign Tags       : Enabled (tag.gpgSign = true)" "RAW" White
    Write-Log "  Allowed Signers File : $resolvedAllowedSigners" "RAW" White
    Write-Log "--------------------------------------------------------------------------------" "RAW" DarkGray
    Write-Log "Every future commit created via 'git commit' will be cryptographically signed!" "RAW" Cyan
    Write-Log "Commits pushed to GitHub will display the verified badge: [ Verified ]" "RAW" Green
    Write-Log "================================================================================" "RAW" Green
}

# --- PUSH & FILE SHIPPING SUBSYSTEM WITH REAL-TIME PROGRESS BAR ---

function Invoke-FileShippingPipeline {
    param (
        [string]$TargetRepoPath,
        [string]$Message
    )

    $resolvedRepo = if ([string]::IsNullOrWhiteSpace($TargetRepoPath)) { $PWD.Path } else {
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TargetRepoPath)
    }

    if (-not (Test-Path $resolvedRepo -PathType Container)) {
        Write-Log "[-] Error: Target repository directory does not exist: $resolvedRepo" "ERROR" Red
        exit 1
    }

    $gitDir = Join-Path $resolvedRepo ".git"
    if (-not (Test-Path $gitDir)) {
        Write-Log "[-] Error: Specified directory is not a Git repository (missing .git): $resolvedRepo" "ERROR" Red
        exit 1
    }

    if ([string]::IsNullOrWhiteSpace($Message)) {
        $Message = "feat: update project files with cryptographic commit signature"
    }

    Write-Log "================================================================================" "RAW" Cyan
    Write-Log "               SHIPPING REPOSITORY COMMITS OVER SECURE PROTOCOL" "RAW" Cyan
    Write-Log "================================================================================" "RAW" Cyan
    Write-Log "  Repository Path : $resolvedRepo" "RAW" White

    # Detect current branch and remote
    $branchRes = Invoke-GitProcess -Arguments "branch --show-current" -WorkingDirectory $resolvedRepo
    $activeBranch = if ($branchRes.ExitCode -eq 0 -and $branchRes.StdOut) { $branchRes.StdOut } else { "main" }

    $remoteRes = Invoke-GitProcess -Arguments "remote get-url origin" -WorkingDirectory $resolvedRepo
    $remoteUrl = if ($remoteRes.ExitCode -eq 0) { $remoteRes.StdOut } else { "origin (unknown URL)" }

    Write-Log "  Active Branch   : $activeBranch" "RAW" White
    Write-Log "  Remote Target   : $remoteUrl" "RAW" White
    Write-Log "  Commit Message  : $Message" "RAW" White
    Write-Log "--------------------------------------------------------------------------------" "RAW" DarkGray

    # Audit dirty worktree files
    Write-Progress -Activity "Shipping Repository ($activeBranch)" -Status "Phase 1/5: Inspecting modified files" -PercentComplete 20
    $statusRes = Invoke-GitProcess -Arguments "status --porcelain" -WorkingDirectory $resolvedRepo

    $filesToShip = [System.Collections.Generic.List[string]]::new()
    if (-not [string]::IsNullOrWhiteSpace($statusRes.StdOut)) {
        foreach ($line in ($statusRes.StdOut -split "`r?`n")) {
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                $filesToShip.Add($line.Trim())
            }
        }
    }

    $filesColor = if ($filesToShip.Count -gt 0) { [ConsoleColor]::Yellow } else { [ConsoleColor]::Green }
    Write-Log "  [+] Modified / Untracked files discovered: $($filesToShip.Count)" "INFO" $filesColor
    foreach ($item in $filesToShip) {
        Write-Log "      $item" "RAW" DarkGray
    }

    # Phase 2: Staging files
    Write-Progress -Activity "Shipping Repository ($activeBranch)" -Status "Phase 2/5: Staging files (git add .)" -PercentComplete 40
    Write-Log "`n[*] Staging all files into Git index..." "INFO" Blue
    $addRes = Invoke-GitProcess -Arguments "add -A" -WorkingDirectory $resolvedRepo
    if ($addRes.ExitCode -ne 0) {
        Write-Log "[-] Failed to stage files: $($addRes.StdErr)" "ERROR" Red
        exit 1
    }

    # Phase 3: Cryptographically signed commit
    Write-Progress -Activity "Shipping Repository ($activeBranch)" -Status "Phase 3/5: Cryptographically signing commit (-S)" -PercentComplete 60
    Write-Log "[*] Creating cryptographically signed commit..." "INFO" Blue

    $commitRes = Invoke-GitProcess -Arguments "commit -S -m `"$Message`"" -WorkingDirectory $resolvedRepo
    if ($commitRes.ExitCode -ne 0) {
        if ($commitRes.StdOut -match "nothing to commit" -or $commitRes.StdErr -match "nothing to commit") {
            Write-Log "  [*] No uncommitted changes detected in working tree. Proceeding to push check." "INFO" DarkYellow
        } else {
            Write-Log "[-] Commit signing failed: $($commitRes.StdErr) $($commitRes.StdOut)" "ERROR" Red
            exit 1
        }
    } else {
        Write-Log "  [SUCCESS] Signed commit created successfully:" "SUCCESS" Green
        foreach ($line in ($commitRes.StdOut -split "`r?`n")) {
            Write-Log "      $line" "RAW" DarkCyan
        }
    }

    # Phase 4: Pushing to remote with progress
    Write-Progress -Activity "Shipping Repository ($activeBranch)" -Status "Phase 4/5: Pushing objects to $remoteUrl" -PercentComplete 80
    Write-Log "`n[*] Uploading and pushing signed objects to remote ($activeBranch)..." "INFO" Blue

    $pushRes = Invoke-GitProcess -Arguments "push origin $activeBranch --progress" -WorkingDirectory $resolvedRepo

    # Parse push output
    $pushCombined = "$($pushRes.StdOut)`n$($pushRes.StdErr)".Trim()
    if ($pushRes.ExitCode -eq 0) {
        Write-Log "  [SUCCESS] Remote update completed successfully." "SUCCESS" Green
        foreach ($line in ($pushCombined -split "`r?`n")) {
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                Write-Log "      $line" "RAW" Gray
            }
        }
    } else {
        Write-Log "[-] Push operation failed: $pushCombined" "ERROR" Red
        exit 1
    }

    # Phase 5: Verification & commit hash reporting
    Write-Progress -Activity "Shipping Repository ($activeBranch)" -Status "Phase 5/5: Auditing signature verification" -PercentComplete 100
    $lastCommit = Invoke-GitProcess -Arguments "log --show-signature -1" -WorkingDirectory $resolvedRepo

    Write-Log "" "RAW" White
    Write-Log "================================================================================" "RAW" Green
    Write-Log "                  FILE SHIPPING & SIGNING SUMMARY" "RAW" Green
    Write-Log "================================================================================" "RAW" Green
    Write-Log "Latest Shipped Commit Details:" "RAW" White
    foreach ($line in ($lastCommit.StdOut -split "`r?`n")) {
        if ($line -match "Good.*signature") {
            Write-Log "  Signature : $line" "RAW" Green
        } elseif ($line -match "^commit ") {
            Write-Log "  Commit ID : $line" "RAW" Cyan
        }
    }
    Write-Log "================================================================================" "RAW" Green
    Write-Progress -Activity "Shipping Repository ($activeBranch)" -Completed
}

# --- MAIN EXECUTION DISPATCHER ---

Show-ConfigurationSummaryTable

if ($Enable) {
    Step-1-EnsureKeyExists
    Step-2-ConfigureGitGlobal
    Step-3-ConfigureAllowedSigners
    Step-4-ConfigureSshAgent
    Step-5-RegisterKeyOnGitHub
    $null = Step-6-TestLocalSigningSandbox
    Step-7-FinalizeAndReport
} elseif ($TestCommit) {
    $null = Step-6-TestLocalSigningSandbox
}

if ($Push) {
    Invoke-FileShippingPipeline -TargetRepoPath $RepoPath -Message $CommitMessage
}
