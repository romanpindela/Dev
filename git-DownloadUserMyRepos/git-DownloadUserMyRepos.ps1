<#
================================================================================
  Script Name : git-DownloadUserMyRepos.ps1
  Author      : Roman Pindela
  Contact     : roman.pindela@gmail.com
  Version     : 1.2.0
  Release Date: 2026-11-09
  License     : MIT
  Repository  : https://github.com/romanpindela/Dev

  DESCRIPTION:
    Automates mass cloning, status verification, date filtering, and
    synchronization (git pull) of all GitHub repositories belonging to a
    specified user or organization account (supports GitHub username or
    email address, e.g. roman.pindela@gmail.com).

    Date Filtering Capabilities:
      - Filter repositories by creation date (-CreatedBefore / -CreatedAfter).
        Repositories not created before the specified date/month/year are skipped.
      - Filter repositories by last update date (-UpdatedBefore / -UpdatedAfter).
        Repositories not updated before the specified date/month/year are skipped.
      - Supports flexible date formats: Year (YYYY), Month & Year (YYYY-MM),
        or Full Date (YYYY-MM-DD / DD.MM.YYYY).

    Existing Repository Verification:
      - Automatically checks whether local repositories are up to date with remote.
      - If up to date, reports current status.
      - If outdated and -Update is specified, synchronizes with latest remote commits.
      - If outdated and -Update is omitted, notifies that the repository exists
        and needs to be updated.

    Dual-compatible with PowerShell 5.1 and PowerShell 7+.
================================================================================
.SYNOPSIS
    Automated mass cloning, date filtering, verification, and synchronization of GitHub repositories.
.DESCRIPTION
    Retrieves the complete list of repositories for a given GitHub account
    via REST API, applies optional date filters (created/updated dates), checks
    whether each repository already exists locally, tests if it is up to date,
    and either clones it, updates it (if -Update is provided), or displays notification
    that an update is needed.
.PARAMETER UserName
    GitHub username or email address associated with the account.
.PARAMETER DestinationPath
    Local destination root directory where repositories are saved.
    Default: c:\Dane\rpindela\GitHub\BackupRepos.
.PARAMETER GitHubToken
    Optional Personal Access Token (PAT) as SecureString for accessing
    private repositories and raising API rate limits.
.PARAMETER CloneProtocol
    Transport protocol for cloning: 'HTTPS' (default) or 'SSH'.
.PARAMETER Update
    Switch. If specified and an existing repository is outdated,
    executes synchronization (git pull) to update it.
    Aliases: -SyncExisting, -Sync, -u.
.PARAMETER CreatedBefore
    Filter repositories created before or in the specified date/month/year
    (e.g. '2023', '2023-05', or '2023-05-15'). Repositories not created before
    this date will not be downloaded. Aliases: -CreatedDate, -CreatedUntil, -Created.
.PARAMETER UpdatedBefore
    Filter repositories updated before or in the specified date/month/year
    (e.g. '2024', '2024-06', or '2024-06-30'). Repositories not updated before
    this date will not be downloaded. Aliases: -UpdatedDate, -UpdatedUntil, -Updated.
.PARAMETER CreatedAfter
    Optional filter for repositories created on or after the specified date.
    Alias: -CreatedSince.
.PARAMETER UpdatedAfter
    Optional filter for repositories updated on or after the specified date.
    Alias: -UpdatedSince.
.PARAMETER IncludeForks
    Switch. Specifies whether to include forked repositories. Default: $true.
    Use -IncludeForks:$false to exclude forks.
.PARAMETER LogDirectory
    Directory where timestamped execution logs are written. Default: C:\Logs.
.PARAMETER Help
    Displays detailed help menu, author info, and practical examples.
.EXAMPLE
    .\git-DownloadUserMyRepos.ps1
    # Run without parameters - displays help, examples, and author info
.EXAMPLE
    .\git-DownloadUserMyRepos.ps1 -UserName "roman.pindela@gmail.com" -CreatedBefore "2023"
    # Clones only repositories created in or before 2023
.EXAMPLE
    .\git-DownloadUserMyRepos.ps1 -UserName "roman.pindela@gmail.com" -CreatedBefore "2024-05" -UpdatedBefore "2024-05"
    # Filters by year and month for creation and update dates
.EXAMPLE
    .\git-DownloadUserMyRepos.ps1 -UserName "roman.pindela@gmail.com" -CreatedBefore "2023-12-31" -Update
    # Filters by exact date and updates existing outdated repositories
.NOTES
    Author : Roman Pindela
    Email  : roman.pindela@gmail.com
    GitHub : https://github.com/romanpindela
    Version: 1.2.0
#>

[CmdletBinding(DefaultParameterSetName = "Default")]
param (
    [Parameter(ParameterSetName = "Download", Position = 0)]
    [Parameter(ParameterSetName = "Default", Position = 0)]
    [Alias("User", "Email")]
    [string]$UserName,

    [Parameter(ParameterSetName = "Download", Position = 1)]
    [Parameter(ParameterSetName = "Default", Position = 1)]
    [Alias("p", "Path", "Destination")]
    [string]$DestinationPath = "c:\Dane\rpindela\GitHub\BackupRepos",

    [Parameter(ParameterSetName = "Download")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("t", "Token")]
    [SecureString]$GitHubToken = $null,

    [Parameter(ParameterSetName = "Download")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("proto", "Protocol")]
    [ValidateSet("HTTPS", "SSH")]
    [string]$CloneProtocol = "HTTPS",

    [Parameter(ParameterSetName = "Download")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("SyncExisting", "Sync", "u")]
    [switch]$Update = $false,

    [Parameter(ParameterSetName = "Download")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("CreatedDate", "CreatedUntil", "Created", "CreatedYear")]
    [string]$CreatedBefore,

    [Parameter(ParameterSetName = "Download")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("UpdatedDate", "UpdatedUntil", "Updated", "UpdatedYear")]
    [string]$UpdatedBefore,

    [Parameter(ParameterSetName = "Download")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("CreatedSince")]
    [string]$CreatedAfter,

    [Parameter(ParameterSetName = "Download")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("UpdatedSince")]
    [string]$UpdatedAfter,

    [Parameter(ParameterSetName = "Download")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("forks")]
    [switch]$IncludeForks = $true,

    [Parameter(ParameterSetName = "Download")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("l", "Log")]
    [string]$LogDirectory = "C:\Logs",

    [Parameter(ParameterSetName = "Help")]
    [Parameter(ParameterSetName = "Default")]
    [Alias("h")]
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- SCRIPT METADATA ---
$SCRIPT_INFO = @{
    Name        = "git-DownloadUserMyRepos"
    Version     = "1.2.0"
    Author      = "Roman Pindela"
    Contact     = "roman.pindela@gmail.com"
    GitHub      = "https://github.com/romanpindela"
    ReleaseDate = "2026-11-09"
    License     = "MIT"
}

# --- DATE PARSER HELPER ---
function Convert-ToFilterDate {
    param (
        [string]$DateInput,
        [string]$ParamName,
        [switch]$IsBefore = $true
    )

    if ([string]::IsNullOrWhiteSpace($DateInput)) {
        return $null
    }

    $trimmed = $DateInput.Trim()

    # 1. Year only: YYYY (e.g. 2024)
    if ($trimmed -match '^\d{4}$') {
        $year = [int]$trimmed
        if ($IsBefore) {
            return [datetime]::new($year, 12, 31, 23, 59, 59, [System.DateTimeKind]::Utc)
        } else {
            return [datetime]::new($year, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
        }
    }

    # 2. Month and Year: YYYY-MM, YYYY.MM, YYYY/MM
    if ($trimmed -match '^(\d{4})[-/.](0?[1-9]|1[0-2])$') {
        $year = [int]$Matches[1]
        $month = [int]$Matches[2]
        $daysInMonth = [datetime]::DaysInMonth($year, $month)
        if ($IsBefore) {
            return [datetime]::new($year, $month, $daysInMonth, 23, 59, 59, [System.DateTimeKind]::Utc)
        } else {
            return [datetime]::new($year, $month, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
        }
    }

    # 3. Month and Year: MM-YYYY, MM.YYYY, MM/YYYY
    if ($trimmed -match '^(0?[1-9]|1[0-2])[-/.](\d{4})$') {
        $month = [int]$Matches[1]
        $year = [int]$Matches[2]
        $daysInMonth = [datetime]::DaysInMonth($year, $month)
        if ($IsBefore) {
            return [datetime]::new($year, $month, $daysInMonth, 23, 59, 59, [System.DateTimeKind]::Utc)
        } else {
            return [datetime]::new($year, $month, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
        }
    }

    # 4. Standard Date: Day.Month.Year or Year-Month-Day
    $parsedDate = [datetime]::MinValue
    $formats = @(
        "yyyy-MM-dd", "yyyy/MM/dd", "yyyy.MM.dd",
        "dd-MM-yyyy", "dd/MM/yyyy", "dd.MM.yyyy",
        "d-M-yyyy", "d/M/yyyy", "d.M.yyyy",
        "yyyy-MM-ddTHH:mm:ss", "yyyy-MM-ddTHH:mm:ssZ"
    )

    if ([datetime]::TryParseExact($trimmed, $formats, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal, [ref]$parsedDate)) {
        if ($IsBefore -and $parsedDate.TimeOfDay.TotalSeconds -eq 0) {
            $parsedDate = $parsedDate.AddDays(1).AddTicks(-1)
        }
        return $parsedDate
    }

    if ([datetime]::TryParse($trimmed, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal, [ref]$parsedDate)) {
        if ($IsBefore -and $parsedDate.TimeOfDay.TotalSeconds -eq 0) {
            $parsedDate = $parsedDate.AddDays(1).AddTicks(-1)
        }
        return $parsedDate
    }

    throw "Invalid date format for parameter '$ParamName': '$DateInput'. Accepted formats: YYYY (e.g. 2024), YYYY-MM (e.g. 2024-05), or YYYY-MM-DD / DD.MM.YYYY (e.g. 2024-05-15)."
}

# --- HELP GUIDE DISPLAY ---
function Show-HelpGuide {
    try { [Console]::CursorLeft = 0 } catch {}
    Write-Host @"
================================================================================
  $($SCRIPT_INFO.Name) - v$($SCRIPT_INFO.Version)
  Author: $($SCRIPT_INFO.Author) | Contact: $($SCRIPT_INFO.Contact)
  GitHub: $($SCRIPT_INFO.GitHub) | License: $($SCRIPT_INFO.License)
================================================================================
DESCRIPTION:
  Automates the process of mass cloning, date filtering, status verification,
  and updating (git pull) of all repositories belonging to a specified GitHub user
  or account. Supports both GitHub usernames and email addresses (e.g. roman.pindela@gmail.com).

  Date Filtering:
  - Repositories not created before -CreatedBefore date/month/year are skipped.
  - Repositories not updated before -UpdatedBefore date/month/year are skipped.
  - Formats supported: 'YYYY' (e.g. 2023), 'YYYY-MM' (e.g. 2023-05), 'YYYY-MM-DD'.

  Existing Repository Verification:
  - If a repository exists locally, inspects its remote status via git fetch.
  - If it is up to date, reports current status.
  - If outdated and -Update is specified, synchronizes with git pull.
  - If outdated and -Update is omitted, notifies that an update is needed.

USAGE:
  .\git-DownloadUserMyRepos.ps1 -UserName <account|email> [-DestinationPath <dir>]
                                [-GitHubToken <secure-token>] [-CloneProtocol <HTTPS|SSH>]
                                [-Update] [-CreatedBefore <date>] [-UpdatedBefore <date>]
                                [-IncludeForks:<`$true|`$false>] [-LogDirectory <dir>]
  .\git-DownloadUserMyRepos.ps1 -h | -Help

PARAMETERS:
  -UserName, -User, -Email   : GitHub username or email address (e.g. roman.pindela@gmail.com).
                               (Required for execution)
  -DestinationPath, -p, -Path: Root destination directory for cloned repositories.
                               Default: c:\Dane\rpindela\GitHub\BackupRepos
  -GitHubToken, -t, -Token   : [Optional] Personal Access Token (PAT) as SecureString
                               for accessing private repositories and increasing API rate limits.
  -CloneProtocol, -proto     : Protocol used for git cloning: 'HTTPS' (default) or 'SSH'.
  -Update, -u, -SyncExisting : If specified, automatically updates outdated existing repositories.
                               If omitted, reports whether existing repositories need updating.
  -CreatedBefore, -Created   : Filter repositories created before or in the specified date
                               (Year: 2023, Month: 2023-05, Date: 2023-05-15).
  -UpdatedBefore, -Updated   : Filter repositories updated before or in the specified date
                               (Year: 2024, Month: 2024-06, Date: 2024-06-30).
  -CreatedAfter, -CreatedSince: Filter repositories created on or after the specified date.
  -UpdatedAfter, -UpdatedSince: Filter repositories updated on or after the specified date.
  -IncludeForks, -forks      : Whether to include forked repositories. Default: `$true.
                               Pass -IncludeForks:`$false to exclude forks.
  -LogDirectory, -l, -Log    : Directory for storing execution logs. Default: C:\Logs
  -Help, -h                  : Displays this help menu, author info, and practical examples.

EXAMPLES:
  1) Display help and usage examples:
     .\git-DownloadUserMyRepos.ps1
     .\git-DownloadUserMyRepos.ps1 -Help
     .\git-DownloadUserMyRepos.ps1 -h

  2) Verify and clone repositories by email address:
     .\git-DownloadUserMyRepos.ps1 -UserName "roman.pindela@gmail.com"

  3) Download only repositories created before or in year 2023:
     .\git-DownloadUserMyRepos.ps1 -UserName "roman.pindela@gmail.com" -CreatedBefore "2023"

  4) Filter by month and year (created before May 2023 and updated before June 2024):
     .\git-DownloadUserMyRepos.ps1 -UserName "roman.pindela@gmail.com" -CreatedBefore "2023-05" -UpdatedBefore "2024-06"

  5) Filter by full date and update existing outdated repositories:
     .\git-DownloadUserMyRepos.ps1 -UserName "roman.pindela@gmail.com" -CreatedBefore "2023-12-31" -Update

  6) Clone private and public repositories using a GitHub PAT:
     `$token = Read-Host "Enter GitHub PAT" -AsSecureString
     .\git-DownloadUserMyRepos.ps1 -UserName "roman.pindela@gmail.com" -GitHubToken `$token -Update
================================================================================
"@ -ForegroundColor Cyan
}

# Check if called with help switch or without required parameters
if ($Help.IsPresent -or [string]::IsNullOrWhiteSpace($UserName)) {
    Show-HelpGuide
    exit 0
}

# --- 1. LOGGING INITIALIZATION ---
if (-not (Test-Path -Path $LogDirectory)) {
    try {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
    }
    catch {
        Write-Error "Failed to create log directory '$LogDirectory': $($_.Exception.Message)"
        exit 1
    }
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$compName = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { "LOCALHOST" }
$usrName = if ($env:USERNAME) { $env:USERNAME } else { "USER" }
$logFileName = "$timestamp-git-DownloadUserMyRepos-$compName-$usrName.log"
$script:LogFilePath = Join-Path -Path $LogDirectory -ChildPath $logFileName

function Write-LogMessage {
    param (
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")]
        [string]$Level = "INFO",

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $timeStr = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    $formattedLine = "[$timeStr] [$Level] $Message"

    $consoleColor = switch ($Level) {
        "INFO"    { [ConsoleColor]::White }
        "WARN"    { [ConsoleColor]::Yellow }
        "ERROR"   { [ConsoleColor]::Red }
        "SUCCESS" { [ConsoleColor]::Green }
    }

    try { [Console]::CursorLeft = 0 } catch {}
    Write-Host $formattedLine -ForegroundColor $consoleColor

    try {
        Add-Content -Path $script:LogFilePath -Value $formattedLine -Encoding UTF8
    }
    catch {
        Write-Warning "Failed to write to log file: $($_.Exception.Message)"
    }
}

# Parse Date Filters
try {
    $targetCreatedBefore = Convert-ToFilterDate -DateInput $CreatedBefore -ParamName "CreatedBefore" -IsBefore:$true
    $targetUpdatedBefore = Convert-ToFilterDate -DateInput $UpdatedBefore -ParamName "UpdatedBefore" -IsBefore:$true
    $targetCreatedAfter  = Convert-ToFilterDate -DateInput $CreatedAfter  -ParamName "CreatedAfter"  -IsBefore:$false
    $targetUpdatedAfter  = Convert-ToFilterDate -DateInput $UpdatedAfter  -ParamName "UpdatedAfter"  -IsBefore:$false
}
catch {
    Write-LogMessage -Level "ERROR" "$($_.Exception.Message)"
    exit 1
}

$filterForks = if ($PSBoundParameters.ContainsKey('IncludeForks')) { [bool]$IncludeForks } else { $true }

Write-LogMessage -Level "INFO" "================================================================================"
Write-LogMessage -Level "INFO" "  $($SCRIPT_INFO.Name).ps1 - Session Started"
Write-LogMessage -Level "INFO" "  Target Account/Email : $UserName"
Write-LogMessage -Level "INFO" "  Destination Path     : $DestinationPath"
Write-LogMessage -Level "INFO" "  Clone Protocol       : $CloneProtocol"
Write-LogMessage -Level "INFO" "  Update Outdated      : $(if ($Update.IsPresent) { 'Enabled (-Update)' } else { 'Disabled (Notification only)' })"
if ($CreatedBefore) { Write-LogMessage -Level "INFO" "  Created Before Filter: $CreatedBefore (Cutoff: $($targetCreatedBefore.ToString('yyyy-MM-dd HH:mm:ss UTC')))" }
if ($UpdatedBefore) { Write-LogMessage -Level "INFO" "  Updated Before Filter: $UpdatedBefore (Cutoff: $($targetUpdatedBefore.ToString('yyyy-MM-dd HH:mm:ss UTC')))" }
if ($CreatedAfter)  { Write-LogMessage -Level "INFO" "  Created After Filter : $CreatedAfter (Cutoff: $($targetCreatedAfter.ToString('yyyy-MM-dd HH:mm:ss UTC')))" }
if ($UpdatedAfter)  { Write-LogMessage -Level "INFO" "  Updated After Filter : $UpdatedAfter (Cutoff: $($targetUpdatedAfter.ToString('yyyy-MM-dd HH:mm:ss UTC')))" }
Write-LogMessage -Level "INFO" "  Include Forks        : $filterForks"
Write-LogMessage -Level "INFO" "  Log File Path        : $script:LogFilePath"
Write-LogMessage -Level "INFO" "================================================================================"

# --- 2. ENVIRONMENT PRE-CHECK ---
try {
    $gitCommand = Get-Command git -ErrorAction Stop
    Write-LogMessage -Level "INFO" "Detected Git client binary: $($gitCommand.Source)"
}
catch {
    Write-LogMessage -Level "ERROR" "Git binary was not found in system PATH. Please ensure Git is installed."
    exit 1
}

if (-not (Test-Path -Path $DestinationPath)) {
    try {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        Write-LogMessage -Level "INFO" "Created destination directory: $DestinationPath"
    }
    catch {
        Write-LogMessage -Level "ERROR" "Failed to create destination directory '$DestinationPath': $($_.Exception.Message)"
        exit 1
    }
}
$resolvedDestination = (Resolve-Path -Path $DestinationPath).Path

# --- 3. GITHUB API HEADERS PREPARATION ---
$headers = @{
    "Accept"     = "application/vnd.github.v3+json"
    "User-Agent" = "PowerShell-git-DownloadUserMyRepos"
}

$tokenPlain = $null
if ($GitHubToken -ne $null) {
    try {
        $tokenPlain = [System.Net.NetworkCredential]::new('', $GitHubToken).Password
        $headers["Authorization"] = "Bearer $tokenPlain"
        Write-LogMessage -Level "INFO" "Applied Personal Access Token (PAT) authentication."
    }
    catch {
        Write-LogMessage -Level "ERROR" "Failed to decrypt GitHubToken SecureString: $($_.Exception.Message)"
        exit 1
    }
}

# Resolve username if email address was provided
$effectiveUser = $UserName
if ($UserName.Contains("@") -and $GitHubToken -eq $null) {
    Write-LogMessage -Level "INFO" "Detected email address '$UserName'. Resolving GitHub user account..."
    try {
        $encodedEmail = [System.Uri]::EscapeDataString($UserName)

        # 1. First attempt: search commits by author-email (returns exact GitHub user login)
        $commitHeaders = @{
            "Accept"     = "application/vnd.github.cloak-preview+json, application/vnd.github.v3+json"
            "User-Agent" = "PowerShell-git-DownloadUserMyRepos"
        }
        $commitSearchUri = "https://api.github.com/search/commits?q=author-email:$encodedEmail"
        $commitRes = Invoke-RestMethod -Uri $commitSearchUri -Headers $commitHeaders -Method Get -ErrorAction SilentlyContinue

        if ($commitRes -and $commitRes.total_count -gt 0 -and $commitRes.items[0].author -and $commitRes.items[0].author.login) {
            $effectiveUser = $commitRes.items[0].author.login
            Write-LogMessage -Level "INFO" "Successfully resolved email '$UserName' to GitHub username: $effectiveUser"
        }
        else {
            # 2. Second attempt: search user profiles by email
            $searchUri = "https://api.github.com/search/users?q=$encodedEmail+in:email"
            $searchRes = Invoke-RestMethod -Uri $searchUri -Headers $headers -Method Get -ErrorAction SilentlyContinue
            if ($searchRes -and $searchRes.total_count -gt 0) {
                $effectiveUser = $searchRes.items[0].login
                Write-LogMessage -Level "INFO" "Resolved email address to GitHub login: $effectiveUser"
            }
            else {
                # 3. Third attempt: search by name part of the email
                $nameCandidate = $UserName.Split('@')[0].Replace('.', ' ')
                $encodedCandidate = [System.Uri]::EscapeDataString($nameCandidate)
                $searchRes2 = Invoke-RestMethod -Uri "https://api.github.com/search/users?q=$encodedCandidate" -Headers $headers -Method Get -ErrorAction SilentlyContinue
                if ($searchRes2 -and $searchRes2.total_count -gt 0) {
                    $effectiveUser = $searchRes2.items[0].login
                    Write-LogMessage -Level "INFO" "Resolved account by name query: $effectiveUser"
                }
                else {
                    $effectiveUser = $UserName.Split('@')[0].Replace('.', '')
                    Write-LogMessage -Level "WARN" "Could not definitively resolve email to account. Using fallback identifier: $effectiveUser"
                }
            }
        }
    }
    catch {
        Write-LogMessage -Level "WARN" "Failed to search GitHub users API: $($_.Exception.Message). Continuing with: $effectiveUser"
    }
}

# --- 4. RETRIEVE REPOSITORY LIST (GITHUB REST API) ---
$allRepositories = [System.Collections.Generic.List[PSCustomObject]]::new()
$page = 1
$perPage = 100

$baseEndpoint = if ($GitHubToken -ne $null) {
    "https://api.github.com/user/repos"
} else {
    "https://api.github.com/users/$effectiveUser/repos"
}

Write-LogMessage -Level "INFO" "Querying repository list from GitHub API (endpoint: $baseEndpoint)..."

do {
    $connector = if ($baseEndpoint.Contains("?")) { "&" } else { "?" }
    $apiUrl = "$baseEndpoint${connector}per_page=$perPage&page=$page"
    if ($GitHubToken -ne $null) {
        $apiUrl += "&affiliation=owner&sort=updated"
    }

    try {
        $batch = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get -ErrorAction Stop
    }
    catch {
        $statusCode = $null
        if ($_.Exception -and $_.Exception.Response) {
            try { $statusCode = [int]$_.Exception.Response.StatusCode } catch {}
        }

        if ($statusCode -eq 401) {
            Write-LogMessage -Level "ERROR" "Error 401: Invalid GitHub Personal Access Token (Unauthorized)."
        }
        elseif ($statusCode -eq 403) {
            Write-LogMessage -Level "ERROR" "Error 403: GitHub API rate limit exceeded or access forbidden."
        }
        elseif ($statusCode -eq 404) {
            Write-LogMessage -Level "ERROR" "Error 404: GitHub user '$effectiveUser' was not found."
        }
        else {
            Write-LogMessage -Level "ERROR" "GitHub API connection failure: $($_.Exception.Message)"
        }
        exit 1
    }

    if ($null -eq $batch -or $batch.Count -eq 0) {
        break
    }

    foreach ($item in $batch) {
        $allRepositories.Add($item)
    }

    Write-LogMessage -Level "INFO" "Retrieved page $page ($($batch.Count) repositories)..."

    if ($batch.Count -lt $perPage) {
        break
    }

    $page++
} while ($true)

# Filter forks and dates
$filteredRepositories = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($repo in $allRepositories) {
    if (-not $filterForks -and $repo.fork -eq $true) {
        Write-LogMessage -Level "INFO" "Skipped forked repository: $($repo.name)"
        continue
    }

    $repoCreatedUtc = [DateTimeOffset]::Parse($repo.created_at).UtcDateTime
    $repoUpdatedUtc = [DateTimeOffset]::Parse($repo.updated_at).UtcDateTime

    # CreatedBefore filter: Repositories NOT created before cutoff are skipped
    if ($null -ne $targetCreatedBefore -and $repoCreatedUtc -gt $targetCreatedBefore) {
        Write-LogMessage -Level "INFO" "Skipped '$($repo.name)' - created at $($repo.created_at) (not created before $CreatedBefore)."
        continue
    }

    # CreatedAfter filter
    if ($null -ne $targetCreatedAfter -and $repoCreatedUtc -lt $targetCreatedAfter) {
        Write-LogMessage -Level "INFO" "Skipped '$($repo.name)' - created at $($repo.created_at) (created before $CreatedAfter)."
        continue
    }

    # UpdatedBefore filter: Repositories NOT updated before cutoff are skipped
    if ($null -ne $targetUpdatedBefore -and $repoUpdatedUtc -gt $targetUpdatedBefore) {
        Write-LogMessage -Level "INFO" "Skipped '$($repo.name)' - updated at $($repo.updated_at) (not updated before $UpdatedBefore)."
        continue
    }

    # UpdatedAfter filter
    if ($null -ne $targetUpdatedAfter -and $repoUpdatedUtc -lt $targetUpdatedAfter) {
        Write-LogMessage -Level "INFO" "Skipped '$($repo.name)' - updated at $($repo.updated_at) (updated before $UpdatedAfter)."
        continue
    }

    $filteredRepositories.Add($repo)
}

$totalRepos = $filteredRepositories.Count
Write-LogMessage -Level "INFO" "Total repositories qualified for processing: $totalRepos"

if ($totalRepos -eq 0) {
    Write-LogMessage -Level "WARN" "No repositories found matching criteria."
    Write-LogMessage -Level "INFO" "==================== EXECUTION SUMMARY ===================="
    Write-LogMessage -Level "INFO" "Cloned repositories       : 0"
    Write-LogMessage -Level "INFO" "Already up to date        : 0"
    Write-LogMessage -Level "INFO" "Updated repositories      : 0"
    Write-LogMessage -Level "INFO" "Needs update              : 0"
    Write-LogMessage -Level "INFO" "Failed operations         : 0"
    Write-LogMessage -Level "INFO" "Execution log saved to    : $script:LogFilePath"
    Write-LogMessage -Level "INFO" "==========================================================="
    exit 0
}

# --- 5. REPOSITORY PROCESSING LOOP (FOREACH) ---
$clonedCount      = 0
$upToDateCount    = 0
$updatedCount     = 0
$needsUpdateCount = 0
$skippedCount     = 0
$failedCount      = 0
$index            = 0

foreach ($repo in $filteredRepositories) {
    $index++
    $repoName = $repo.name
    $fullName = $repo.full_name
    $targetPath = Join-Path -Path $resolvedDestination -ChildPath $repoName

    $percent = [int](($index / $totalRepos) * 100)
    Write-Progress -Activity "Processing GitHub Repositories" `
                   -Status "[$index/$totalRepos] $repoName ($percent%)" `
                   -PercentComplete $percent

    # Protocol URL determination
    if ($CloneProtocol -eq "SSH") {
        $remoteUrl = $repo.ssh_url
        $safeUrl = $remoteUrl
    }
    else {
        if ($null -ne $tokenPlain -and $tokenPlain.Trim() -ne "") {
            $remoteUrl = "https://${tokenPlain}@github.com/${fullName}.git"
            $safeUrl = "https://***@github.com/${fullName}.git"
        }
        else {
            $remoteUrl = $repo.clone_url
            $safeUrl = $remoteUrl
        }
    }

    if (Test-Path -Path $targetPath) {
        # Directory exists: verify if it is a valid Git repository
        $gitDir = Join-Path -Path $targetPath -ChildPath ".git"
        if (-not (Test-Path -Path $gitDir)) {
            Write-LogMessage -Level "WARN" "[$index/$totalRepos] Directory '$targetPath' exists but is not a valid Git repository. Skipping."
            $skippedCount++
            continue
        }

        # Fetch latest references from remote to check if local is up to date
        try {
            $fetchOutput = & git -C "$targetPath" fetch "$remoteUrl" 2>&1
            $fetchFailed = ($LASTEXITCODE -ne 0)
        }
        catch {
            $fetchFailed = $true
        }

        if ($fetchFailed) {
            # Try plain git fetch origin as fallback
            $fetchOutput = & git -C "$targetPath" fetch origin 2>&1
        }

        # Determine active branch
        $activeBranch = (& git -C "$targetPath" rev-parse --abbrev-ref HEAD 2>&1).ToString().Trim()
        if ([string]::IsNullOrWhiteSpace($activeBranch) -or $activeBranch -eq "HEAD") {
            $activeBranch = if ($repo.default_branch) { $repo.default_branch } else { "main" }
        }

        # Check commit difference against FETCH_HEAD or tracking branch
        $behindCount = 0
        $revCountRaw = (& git -C "$targetPath" rev-list "HEAD..FETCH_HEAD" --count 2>&1).ToString().Trim()

        if ($revCountRaw -match '^\d+$') {
            $behindCount = [int]$revCountRaw
        }
        else {
            # Fallback to origin tracking branch comparison
            $revCountRaw2 = (& git -C "$targetPath" rev-list "HEAD..origin/$activeBranch" --count 2>&1).ToString().Trim()
            if ($revCountRaw2 -match '^\d+$') {
                $behindCount = [int]$revCountRaw2
            }
        }

        if ($behindCount -eq 0) {
            Write-LogMessage -Level "INFO" "[$index/$totalRepos] Repository '$repoName' ($activeBranch) is UP TO DATE with remote."
            $upToDateCount++
        }
        else {
            # Repository is outdated
            if ($Update.IsPresent) {
                Write-LogMessage -Level "INFO" "[$index/$totalRepos] Repository '$repoName' ($activeBranch) is OUTDATED (behind by $behindCount commit(s)). Updating (-Update)..."
                try {
                    $pullOutput = & git -C "$targetPath" pull 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-LogMessage -Level "SUCCESS" "[$index/$totalRepos] Successfully updated '$repoName' (+$behindCount commit(s) pulled)."
                        $updatedCount++
                    }
                    else {
                        $cleanErr = if ($tokenPlain) { "$pullOutput" -replace [regex]::Escape($tokenPlain), "***" } else { "$pullOutput" }
                        Write-LogMessage -Level "ERROR" "[$index/$totalRepos] Failed to update '$repoName': $cleanErr"
                        $failedCount++
                    }
                }
                catch {
                    Write-LogMessage -Level "ERROR" "[$index/$totalRepos] Exception during git pull on '$repoName': $($_.Exception.Message)"
                    $failedCount++
                }
            }
            else {
                # Update switch was not passed - notify the user that repository exists and needs to be updated
                Write-LogMessage -Level "WARN" "[$index/$totalRepos] Repository '$repoName' exists locally but IS OUTDATED (behind by $behindCount commit(s)). Run with -Update to synchronize."
                $needsUpdateCount++
            }
        }
    }
    else {
        # Directory does not exist: perform initial clone
        Write-LogMessage -Level "INFO" "[$index/$totalRepos] Cloning new repository '$repoName' ($safeUrl)..."
        try {
            $cloneOutput = & git clone "$remoteUrl" "$targetPath" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-LogMessage -Level "SUCCESS" "[$index/$totalRepos] Successfully cloned repository '$repoName'."
                $clonedCount++
            }
            else {
                $cleanErr = if ($tokenPlain) { "$cloneOutput" -replace [regex]::Escape($tokenPlain), "***" } else { "$cloneOutput" }
                Write-LogMessage -Level "ERROR" "[$index/$totalRepos] Failed to clone '$repoName': $cleanErr"
                $failedCount++
            }
        }
        catch {
            Write-LogMessage -Level "ERROR" "[$index/$totalRepos] Exception during git clone on '$repoName': $($_.Exception.Message)"
            $failedCount++
        }
    }
}

try {
    Write-Progress -Activity "Processing GitHub Repositories" -Completed
} catch {}

# --- 6. EXECUTION SUMMARY ---
Write-LogMessage -Level "INFO" "==================== EXECUTION SUMMARY ===================="
Write-LogMessage -Level "INFO" "Total repositories processed : $totalRepos"
Write-LogMessage -Level "SUCCESS" "Newly cloned repositories    : $clonedCount"
Write-LogMessage -Level "SUCCESS" "Already up to date           : $upToDateCount"
Write-LogMessage -Level "SUCCESS" "Updated repositories         : $updatedCount"
if ($needsUpdateCount -gt 0) {
    Write-LogMessage -Level "WARN" "Outdated (run with -Update)  : $needsUpdateCount"
}
if ($skippedCount -gt 0) {
    Write-LogMessage -Level "INFO" "Skipped / Non-Git folders    : $skippedCount"
}
if ($failedCount -gt 0) {
    Write-LogMessage -Level "WARN" "Failed operations            : $failedCount"
} else {
    Write-LogMessage -Level "SUCCESS" "Failed operations            : 0"
}
Write-LogMessage -Level "INFO" "Execution log saved to       : $script:LogFilePath"
Write-LogMessage -Level "INFO" "==========================================================="
