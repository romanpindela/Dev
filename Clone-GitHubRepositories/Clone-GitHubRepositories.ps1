param(
    [string]$RepositoriesFile,
    [string]$TargetDir,
    [string]$Username = "romanpindela",
    [string]$AuthProtocol = "HTTPS"
)

$SCRIPT_VERSION = "1.1.0"
$AUTHOR_NAME    = "Roman Pindela"
$AUTHOR_GITHUB  = "https://github.com/romanpindela"
$AUTHOR_EMAIL   = "romanpindela@gmail.com"

# Check if called with -h, -help, /?, ? or without required parameters
$showHelp = $false
if ($args -contains "-h" -or $args -contains "-help" -or $args -contains "/?" -or $args -contains "?") {
    $showHelp = $true
}
if (-not $RepositoriesFile -or -not $TargetDir) {
    $showHelp = $true
}

if ($showHelp) {
    [Console]::ForegroundColor = [ConsoleColor]::Cyan
    [Console]::WriteLine("================================================================================")
    [Console]::WriteLine("  Clone-GitHubRepositories v$SCRIPT_VERSION")
    [Console]::WriteLine("  Author:  $AUTHOR_NAME")
    [Console]::WriteLine("  GitHub:  $AUTHOR_GITHUB")
    [Console]::WriteLine("  Email:   $AUTHOR_EMAIL")
    [Console]::WriteLine("================================================================================")
    [Console]::WriteLine("")
    [Console]::WriteLine("DESCRIPTION:")
    [Console]::WriteLine("  Clones a list of repositories from a text file into the specified working")
    [Console]::WriteLine("  directory. If a repository already exists locally, runs: git pull --ff-only.")
    [Console]::WriteLine("")
    [Console]::WriteLine("PARAMETERS:")
    [Console]::WriteLine("  -RepositoriesFile  Path to the text file containing repository names (e.g. repositoriesToClone.txt)")
    [Console]::WriteLine("  -TargetDir         Destination directory (e.g. C:\dane\rpindela\GitHub)")
    [Console]::WriteLine("  -Username          GitHub username (default: romanpindela)")
    [Console]::WriteLine("  -AuthProtocol      Protocol: HTTPS (default) or SSH")
    [Console]::WriteLine("  -h, -help          Displays this help message")
    [Console]::WriteLine("")
    [Console]::WriteLine("USAGE EXAMPLES:")
    [Console]::WriteLine("  1) Standard:")
    [Console]::WriteLine("     .\Clone-GitHubRepositories.ps1 -RepositoriesFile .\repositoriesToClone.txt -TargetDir C:\dane\rpindela\GitHub")
    [Console]::WriteLine("")
    [Console]::WriteLine("  2) Clone via SSH:")
    [Console]::WriteLine("     .\Clone-GitHubRepositories.ps1 -RepositoriesFile .\repositoriesToClone.txt -TargetDir C:\dane\rpindela\GitHub -AuthProtocol SSH")
    [Console]::WriteLine("")
    [Console]::WriteLine("  3) Positional arguments:")
    [Console]::WriteLine("     .\Clone-GitHubRepositories.ps1 .\repositoriesToClone.txt C:\dane\rpindela\GitHub")
    [Console]::WriteLine("================================================================================")
    [Console]::ResetColor()
    exit 0
}

# Verify git presence
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    [Console]::ForegroundColor = [ConsoleColor]::Red
    [Console]::WriteLine("Error: 'git' command not found in system PATH.")
    [Console]::ResetColor()
    exit 1
}

# Verify file existence
if (-not (Test-Path -Path $RepositoriesFile -PathType Leaf)) {
    [Console]::ForegroundColor = [ConsoleColor]::Red
    [Console]::WriteLine("Error: File not found: $RepositoriesFile")
    [Console]::ResetColor()
    exit 1
}

# Read repository list
$repoList = Get-Content -Path $RepositoriesFile | 
    ForEach-Object { $_.Trim() } | 
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#") }

if ($repoList.Count -eq 0) {
    [Console]::ForegroundColor = [ConsoleColor]::Yellow
    [Console]::WriteLine("File '$RepositoriesFile' is empty.")
    [Console]::ResetColor()
    exit 0
}

Write-Host "Found $($repoList.Count) repositories to process.`n" -ForegroundColor DarkGray

if (-not (Test-Path -Path $TargetDir)) {
    Write-Host "[+] Creating target folder: $TargetDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

$resolvedTargetDir = (Resolve-Path -Path $TargetDir).Path

foreach ($repo in $repoList) {
    $repoPath = Join-Path -Path $resolvedTargetDir -ChildPath $repo

    $cloneUrl = if ($AuthProtocol -eq "HTTPS") {
        "https://github.com/$Username/$repo.git"
    } else {
        "git@github.com:$Username/$repo.git"
    }

    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " Processing: $repo" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray

    if (Test-Path -Path (Join-Path -Path $repoPath -ChildPath ".git")) {
        Write-Host "-> Repository exists locally. Pulling changes (git pull)..." -ForegroundColor Green
        Push-Location $repoPath
        try {
            git pull --ff-only
        }
        catch {
            Write-Warning "git pull error for $repo : $_"
        }
        finally {
            Pop-Location
        }
    } else {
        Write-Host "-> Cloning new repository ($cloneUrl)..." -ForegroundColor Cyan
        git clone $cloneUrl $repoPath
    }
}

Write-Host "`n[✓] Completed successfully. All repositories are located in: $resolvedTargetDir" -ForegroundColor Green
