<#
================================================================================
  Script Name : git-AllReposUpdate.ps1
  Author      : Roman Pindela
  Contact     : roman.pindela@gmail.com
  Version     : 1.0.0
  Release Date: 2026-10-08
  License     : MIT
  Repository  : https://github.com/romanpindela/Dev

  DESCRIPTION:
    Automates the process of updating all local Git repositories located
    in the specified working directory (default: C:\GitHub).

    For each detected repository, the script verifies the active branch,
    checks for uncommitted local changes (dirty worktree), fetches the latest
    references from the remote server (git fetch), and safely updates the local
    state (git pull --ff-only).

    During execution, it displays a responsive, dynamic progress bar
    (Write-Progress), reports the real-time status of each project to the
    console (including the exact number of pulled commits), and concludes
    with a comprehensive execution summary.

    Running the script without any parameters displays detailed help,
    version and author information, and practical usage examples.

================================================================================
.SYNOPSIS
    Automated synchronization and update of all local Git repositories.
.DESCRIPTION
    Scans the specified path for directories containing a .git subdirectory,
    verifies branches and upstream tracking, executes fetch/pull, and reports changes.
.PARAMETER Update
    Switch initiating the repository update procedure.
.PARAMETER Path
    Parent directory containing Git repositories. Default: C:\GitHub.
.PARAMETER Prune
    Enables pruning of deleted remote branches (git fetch -p / --prune).
.PARAMETER LogPath
    Optional path to a text file for detailed operation logging.
.PARAMETER Help
    Displays detailed help menu, version, contact information, and examples.
.EXAMPLE
    .\git-AllReposUpdate.ps1
    # Run without parameters - displays help, examples, and author info
.EXAMPLE
    .\git-AllReposUpdate.ps1 -Update
    # Updates all repositories in default directory C:\GitHub
.EXAMPLE
    .\git-AllReposUpdate.ps1 -Path "C:\GitHub"
    # Updates repositories in the specified directory
.EXAMPLE
    .\git-AllReposUpdate.ps1 -Update -Prune
    # Updates repositories and prunes deleted remote references
.EXAMPLE
    .\git-AllReposUpdate.ps1 -Update -LogPath "C:\Logs\git-update-report.txt"
    # Updates repositories and writes report to the specified log file
.NOTES
    Author: Roman Pindela
    Email: roman.pindela@gmail.com
    GitHub: https://github.com/romanpindela
    Version: 1.0.0
#>

[CmdletBinding(DefaultParameterSetName = "Default")]
param (
    [Parameter(ParameterSetName = "Update")]
    [Alias("u", "Run", "All")]
    [switch]$Update,

    [Parameter(ParameterSetName = "Update")]
    [Parameter(ParameterSetName = "CustomPath")]
    [Alias("p")]
    [string]$Path = "C:\GitHub",

    [Parameter(ParameterSetName = "Update")]
    [Parameter(ParameterSetName = "CustomPath")]
    [switch]$Prune,

    [Parameter(ParameterSetName = "Update")]
    [Parameter(ParameterSetName = "CustomPath")]
    [Alias("l", "Log")]
    [string]$LogPath,

    [Parameter(ParameterSetName = "Help")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("h")]
    [switch]$Help
)

Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

# --- SCRIPT INFORMATION AND METADATA ---
$SCRIPT_INFO = @{
    Name        = "git-AllReposUpdate";
    Version     = "1.0.0";
    Author      = "Roman Pindela";
    Contact     = "roman.pindela@gmail.com";
    GitHub      = "https://github.com/romanpindela";
    ReleaseDate = "2026-10-08";
    License     = "MIT";
};

# Global handle for active log file
$script:ActiveLogFile = $null;

# --- HELPER FUNCTIONS ---

function Write-Log {
    param (
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    try { [Console]::CursorLeft = 0; } catch {}
    Write-Host "$Message" -ForegroundColor $Color;

    if (-not [string]::IsNullOrWhiteSpace($script:ActiveLogFile)) {
        try {
            $timePrefix = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss");
            $cleanLine = "[$timePrefix] $Message`r`n";
            [System.IO.File]::AppendAllText($script:ActiveLogFile, $cleanLine, [System.Text.Encoding]::UTF8);
        }
        catch {}
    }
}

function Show-HelpGuide {
    try { [Console]::CursorLeft = 0; } catch {}
    Write-Host @"
================================================================================
  $($SCRIPT_INFO.Name) - v$($SCRIPT_INFO.Version)
  Author: $($SCRIPT_INFO.Author) | Contact: $($SCRIPT_INFO.Contact)
  GitHub: $($SCRIPT_INFO.GitHub) | License: $($SCRIPT_INFO.License)
================================================================================
DESCRIPTION:
  Automated manager for synchronizing and updating local Git repositories.
  Iterates through all subdirectories in the specified path (default: C:\GitHub),
  verifies branch status, fetches latest commits from remote (git fetch),
  and safely synchronizes local changes (git pull --ff-only).

  Displays a dynamic progress bar, real-time status updates (with commit counts),
  and a comprehensive post-execution summary.

USAGE:
  .\git-AllReposUpdate.ps1 -Update [-Path <directory>] [-Prune] [-LogPath <file.txt>]
  .\git-AllReposUpdate.ps1 -Path <directory> [-Prune] [-LogPath <file.txt>]
  .\git-AllReposUpdate.ps1 -h | -Help

PARAMETERS:
  -Update, -u, -Run, -All : Initiates automated repository update.
  -Path, -p               : Path to root folder containing Git repositories.
                            Default: C:\GitHub
  -Prune                  : Prunes stale remote-tracking branches (git fetch --prune).
  -LogPath, -l, -Log      : [Optional] Saves full report and log to a file.
  -Help, -h               : Displays this help menu and author info.

EXAMPLES:
  1) Display help menu:
     .\git-AllReposUpdate.ps1
     .\git-AllReposUpdate.ps1 -Help

  2) Update all repositories in default C:\GitHub:
     .\git-AllReposUpdate.ps1 -Update

  3) Update with custom path:
     .\git-AllReposUpdate.ps1 -Path "C:\Projects\GitHub"

  4) Update with branch pruning:
     .\git-AllReposUpdate.ps1 -Update -Prune

  5) Update and save log to a dedicated file:
     .\git-AllReposUpdate.ps1 -Update -LogPath "C:\Logs\git_sync.txt"
================================================================================
"@ -ForegroundColor Cyan;
}

function Invoke-GitCmd {
    param (
        [string]$RepoPath,
        [string]$Arguments
    )
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo;
    $pinfo.FileName = "git.exe";
    $pinfo.WorkingDirectory = $RepoPath;
    $pinfo.Arguments = $Arguments;
    $pinfo.RedirectStandardOutput = $true;
    $pinfo.RedirectStandardError = $true;
    $pinfo.UseShellExecute = $false;
    $pinfo.CreateNoWindow = $true;
    $pinfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8;
    $pinfo.StandardErrorEncoding = [System.Text.Encoding]::UTF8;

    $proc = [System.Diagnostics.Process]::Start($pinfo);
    $stdOut = $proc.StandardOutput.ReadToEnd();
    $stdErr = $proc.StandardError.ReadToEnd();
    $proc.WaitForExit();

    return [PSCustomObject]@{
        ExitCode = $proc.ExitCode
        StdOut   = if ($stdOut) { $stdOut.Trim() } else { "" }
        StdErr   = if ($stdErr) { $stdErr.Trim() } else { "" }
    };
}

# --- INPUT VALIDATION AND NO-ARGUMENT EXECUTION ---

# If invoked with help switch or completely without arguments:
if ($Help -or ($PSBoundParameters.Count -eq 0)) {
    Show-HelpGuide;
    exit 0;
}

# --- SYSTEM PREREQUISITES CHECK ---

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    [Console]::ForegroundColor = [ConsoleColor]::Red;
    [Console]::WriteLine("[-] Critical error: 'git' command not found in system PATH.");
    [Console]::WriteLine("    Ensure Git for Windows is installed and accessible in the environment.");
    [Console]::ResetColor();
    exit 1;
}

# Resolve full parent directory path
$resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);

if (-not (Test-Path -Path $resolvedPath -PathType Container)) {
    [Console]::ForegroundColor = [ConsoleColor]::Red;
    [Console]::WriteLine("[-] Error: Specified directory path does not exist or is not a folder: $resolvedPath");
    [Console]::ResetColor();
    exit 1;
}

# Initialize log file if -LogPath was specified
if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
    $resolvedLogPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LogPath);
    $logDirectory = [System.IO.Path]::GetDirectoryName($resolvedLogPath);
    if (-not [string]::IsNullOrWhiteSpace($logDirectory) -and -not [System.IO.Directory]::Exists($logDirectory)) {
        [System.IO.Directory]::CreateDirectory($logDirectory) | Out-Null;
    }
    $script:ActiveLogFile = $resolvedLogPath;
}

# --- MAIN PROCESS EXECUTION ---

try { Clear-Host; } catch {}
Write-Log "================================================================================" Cyan;
Write-Log "  $($SCRIPT_INFO.Name) v$($SCRIPT_INFO.Version) - Git Repositories Synchronization" Cyan;
Write-Log "  Author: $($SCRIPT_INFO.Author) | Contact: $($SCRIPT_INFO.Contact)" Gray;
Write-Log "  Source Directory : $resolvedPath" Yellow;
if (-not [string]::IsNullOrWhiteSpace($script:ActiveLogFile)) {
    Write-Log "  Log File         : $script:ActiveLogFile" DarkCyan;
}
Write-Log "================================================================================" Cyan;
Write-Log "" White;

Write-Log "[*] Scanning directory for Git projects..." DarkGray;

$repoDirs = Get-ChildItem -Path $resolvedPath -Directory -ErrorAction SilentlyContinue |
    Where-Object { Test-Path -Path (Join-Path -Path $_.FullName -ChildPath ".git") }

if ($null -eq $repoDirs -or $repoDirs.Count -eq 0) {
    Write-Log "[!] No Git repositories found in specified path: $resolvedPath" Yellow;
    exit 0;
}

$totalRepos = $repoDirs.Count;
Write-Log "[+] Found $totalRepos repository(ies) to verify.`n" Green;

# Results tracking
$results = [System.Collections.Generic.List[PSCustomObject]]::new();
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew();

for ($i = 0; $i -lt $totalRepos; $i++) {
    $repoDir      = $repoDirs[$i];
    $repoName     = $repoDir.Name;
    $repoFullName = $repoDir.FullName;
    $repoIndex    = $i + 1;
    $percent      = [math]::Round(($repoIndex / $totalRepos) * 100);

    # Progress bar Write-Progress
    Write-Progress -Activity "Updating Git Repositories ($resolvedPath)" `
                   -Status "[$repoIndex/$totalRepos] Processing: $repoName" `
                   -PercentComplete $percent;

    # Report item initialization
    $reportItem = [PSCustomObject]@{
        Name           = $repoName
        Path           = $repoFullName
        Branch         = "Unknown"
        Status         = "Unprocessed"
        CommitsPulled  = 0
        CommitSubjects = @()
        Details        = ""
    };

    try {
        # 1. Read active branch
        $branchResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "branch --show-current";
        $branch = $branchResult.StdOut;
        if ([string]::IsNullOrWhiteSpace($branch)) {
            $abbrevResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "rev-parse --abbrev-ref HEAD";
            $branch = $abbrevResult.StdOut;
        }
        if ([string]::IsNullOrWhiteSpace($branch)) {
            $branch = "HEAD (detached)";
        }
        $reportItem.Branch = $branch;

        # 2. Verify commit presence (unborn branch check)
        $headResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "rev-parse --verify --quiet HEAD";
        if ($headResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($headResult.StdOut)) {
            $reportItem.Status = "Empty Repository";
            $reportItem.Details = "No commits in repository (empty or new branch)";
            Write-Log "  [-] [EMPTY REPO]       $repoName ($branch) -> No commits in repository" Yellow;
            $results.Add($reportItem);
            continue;
        }
        $oldHead = $headResult.StdOut;

        # 3. Check for uncommitted local changes
        $dirtyResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "status --porcelain";
        $isDirty = (-not [string]::IsNullOrWhiteSpace($dirtyResult.StdOut));

        # 4. Check configured remotes
        $remoteResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "remote";
        if ([string]::IsNullOrWhiteSpace($remoteResult.StdOut)) {
            $reportItem.Status = "No Remote";
            $reportItem.Details = "No remote configured (origin)";
            Write-Log "  [-] [NO REMOTE]        $repoName ($branch) -> No remote defined" Yellow;
            $results.Add($reportItem);
            continue;
        }

        # 5. Fetch latest references from remote (git fetch)
        $fetchArgs = if ($Prune) { "fetch --prune" } else { "fetch" };
        $fetchResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments $fetchArgs;
        if ($fetchResult.ExitCode -ne 0) {
            $reportItem.Status = "Fetch Error";
            $reportItem.Details = "Fetch operation failed: $($fetchResult.StdErr)";
            Write-Log "  [-] [FETCH ERROR]      $repoName ($branch) -> $($reportItem.Details)" Red;
            $results.Add($reportItem);
            continue;
        }

        # 6. Check upstream / tracking branch
        $upstreamResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "rev-parse --abbrev-ref @{u}";
        $upstream = $upstreamResult.StdOut;
        if ($upstreamResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($upstream)) {
            $reportItem.Status = "No Upstream";
            $reportItem.Details = "Branch '$branch' does not track any remote branch";
            Write-Log "  [-] [NO UPSTREAM]      $repoName ($branch) -> No associated remote branch" DarkYellow;
            $results.Add($reportItem);
            continue;
        }

        # 7. Calculate commits behind and ahead
        $behindResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "rev-list HEAD..$upstream --count";
        $behindCount = 0;
        if ($behindResult.StdOut -match '^\d+$') {
            $behindCount = [int]$behindResult.StdOut;
        }

        $aheadResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "rev-list $upstream..HEAD --count";
        $aheadCount = 0;
        if ($aheadResult.StdOut -match '^\d+$') {
            $aheadCount = [int]$aheadResult.StdOut;
        }

        # 8. Safe update (git pull --ff-only)
        if ($behindCount -eq 0) {
            if ($aheadCount -gt 0) {
                $reportItem.Status = "Up to Date (Local Ahead)";
                $reportItem.Details = "Local branch is ahead of remote by $aheadCount commit(s)";
                Write-Log "  [=] [UP TO DATE]       $repoName ($branch) -> Up to date (locally: +$aheadCount commit(s) to push)" DarkGray;
            } else {
                $reportItem.Status = "Up to Date";
                $reportItem.Details = "Repository is completely up to date";
                Write-Log "  [=] [UP TO DATE]       $repoName ($branch) -> Up to date" DarkGray;
            }
        }
        else {
            # New commits to pull!
            if ($isDirty) {
                $reportItem.Details = "Uncommitted local changes before pull. ";
            }

            $pullResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "pull --ff-only";
            if ($pullResult.ExitCode -eq 0) {
                $newHeadResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "rev-parse HEAD";
                $newHead = $newHeadResult.StdOut;

                $pulledSubjects = @();
                if (-not [string]::IsNullOrWhiteSpace($oldHead) -and -not [string]::IsNullOrWhiteSpace($newHead)) {
                    $logResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "log $oldHead..$newHead --oneline";
                    if (-not [string]::IsNullOrWhiteSpace($logResult.StdOut)) {
                        $pulledSubjects = $logResult.StdOut -split "`r?`n";
                    }
                }

                $reportItem.Status         = "Updated";
                $reportItem.CommitsPulled  = $behindCount;
                $reportItem.CommitSubjects = $pulledSubjects;
                $reportItem.Details       += "Pulled $behindCount commit(s) successfully.";

                Write-Log "  [+] [UPDATED]          $repoName ($branch) -> +$behindCount commit(s)" Green;
                if ($pulledSubjects.Count -gt 0) {
                    foreach ($subj in $pulledSubjects | Select-Object -First 3) {
                        Write-Log "      * $subj" DarkGreen;
                    }
                    if ($pulledSubjects.Count -gt 3) {
                        $remaining = $pulledSubjects.Count - 3;
                        Write-Log "      * ... and $remaining more commit(s)" DarkGreen;
                    }
                }
            }
            else {
                $reportItem.Status  = "Pull Error";
                $reportItem.Details = "git pull failed: $($pullResult.StdErr)";
                Write-Log "  [!] [PULL ERROR]       $repoName ($branch) -> $($reportItem.Details)" Red;
            }
        }
    }
    catch {
        $reportItem.Status  = "Exception";
        $reportItem.Details = "Unexpected error: $($_.Exception.Message)";
        Write-Log "  [!] [EXCEPTION]        $repoName -> $($reportItem.Details)" Red;
    }

    $results.Add($reportItem);
}

# Close progress bar
Write-Progress -Activity "Updating Git Repositories" -Completed;
$stopwatch.Stop();

# --- RESULTS ANALYSIS AND SUMMARY ---

$updatedRepos  = @($results | Where-Object { $_.Status -eq "Updated" });
$upToDateRepos = @($results | Where-Object { $_.Status -like "Up to Date*" });
$issueRepos    = @($results | Where-Object { $_.Status -notmatch "^(Updated|Up to Date)" });

Write-Log "" White;
Write-Log "================================================================================" Cyan;
Write-Log "                       GIT SYNCHRONIZATION SUMMARY                              " Cyan;
Write-Log "================================================================================" Cyan;
Write-Log "Working directory         : $resolvedPath" White;
Write-Log "Total repositories        : $totalRepos" White;
Write-Log "Updated                   : $($updatedRepos.Count)" Green;
Write-Log "Up to date                : $($upToDateRepos.Count)" Gray;
Write-Log "Requires attention/other  : $($issueRepos.Count)" $(if ($issueRepos.Count -gt 0) { [ConsoleColor]::Yellow } else { [ConsoleColor]::Gray });
Write-Log "Total execution time      : $($stopwatch.Elapsed.ToString("mm\:ss\.ff"))" DarkCyan;
Write-Log "--------------------------------------------------------------------------------" DarkGray;

if ($updatedRepos.Count -gt 0) {
    Write-Log "`n[+] UPDATED REPOSITORIES:" Green;
    foreach ($r in $updatedRepos) {
        Write-Log "  * $($r.Name) [$($r.Branch)] : pulled $($r.CommitsPulled) commit(s)" Green;
        foreach ($sub in $r.CommitSubjects | Select-Object -First 2) {
            Write-Log "      - $sub" DarkGreen;
        }
    }
}

if ($upToDateRepos.Count -gt 0) {
    Write-Log "`n[=] UP TO DATE REPOSITORIES:" Gray;
    $upToDateNames = ($upToDateRepos | ForEach-Object { "$($_.Name) [$($_.Branch)]" }) -join ", ";
    Write-Log "  $upToDateNames" DarkGray;
}

if ($issueRepos.Count -gt 0) {
    Write-Log "`n[!] REPOSITORIES REQUIRING ATTENTION / EMPTY / ERRORS:" Yellow;
    foreach ($r in $issueRepos) {
        Write-Log "  * $($r.Name) [$($r.Branch)] : Status: $($r.Status) | Details: $($r.Details)" Yellow;
    }
}

Write-Log "`n================================================================================" Cyan;
if (-not [string]::IsNullOrWhiteSpace($script:ActiveLogFile)) {
    Write-Log "Synchronization report saved to: $script:ActiveLogFile" Green;
    Write-Log "================================================================================" Cyan;
}
Write-Log "Author contact: $($SCRIPT_INFO.Contact)`n" Gray;
