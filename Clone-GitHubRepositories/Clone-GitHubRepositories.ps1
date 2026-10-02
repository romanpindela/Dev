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

# Sprawdzenie czy wywolano z -h, -help, /?, ? lub bez argumentow
$showHelp =$false
if ($args -contains "-h" -or $args -contains "-help" -or $args -contains "/?" -or $args -contains "?") {
    $showHelp =$true
}
if (-not $RepositoriesFile -or -not$TargetDir) {
    $showHelp =$true
}

if ($showHelp) {
    [Console]::ForegroundColor = [ConsoleColor]::Cyan
    [Console]::WriteLine("================================================================================")
    [Console]::WriteLine("  Clone-GitHubRepositories v$SCRIPT_VERSION")
    [Console]::WriteLine("  Autor:   $AUTHOR_NAME")
    [Console]::WriteLine("  GitHub:  $AUTHOR_GITHUB")
    [Console]::WriteLine("  E-mail:  $AUTHOR_EMAIL")
    [Console]::WriteLine("================================================================================")
    [Console]::WriteLine("")
    [Console]::WriteLine("OPIS:")
    [Console]::WriteLine("  Skrypt pobiera liste repozytoriow z pliku tekstowego i klonuje je do wskazanego")
    [Console]::WriteLine("  katalogu roboczego. W przypadku istnienia repozytorium wykonuje: git pull --ff-only.")
    [Console]::WriteLine("")
    [Console]::WriteLine("PARAMETRY:")
    [Console]::WriteLine("  -RepositoriesFile  Sciezka do pliku z nazwami repozytoriow (np. repositoriesToClone.txt)")
    [Console]::WriteLine("  -TargetDir         Katalog docelowy (np. C:\dane\rpindela\GitHub)")
    [Console]::WriteLine("  -Username          Uzytkownik GitHub (domyslnie: romanpindela)")
    [Console]::WriteLine("  -AuthProtocol      Protokol: HTTPS (domyslny) lub SSH")
    [Console]::WriteLine("  -h, -help          Wyswietlenie tej pomocy")
    [Console]::WriteLine("")
    [Console]::WriteLine("PRZYKLADY UZYCIA:")
    [Console]::WriteLine("  1) Standardowe:")
    [Console]::WriteLine("     .\Clone-GitHubRepositories.ps1 -RepositoriesFile .\repositoriesToClone.txt -TargetDir C:\dane\rpindela\GitHub")
    [Console]::WriteLine("")
    [Console]::WriteLine("  2) Klonowanie przez SSH:")
    [Console]::WriteLine("     .\Clone-GitHubRepositories.ps1 -RepositoriesFile .\repositoriesToClone.txt -TargetDir C:\dane\rpindela\GitHub -AuthProtocol SSH")
    [Console]::WriteLine("")
    [Console]::WriteLine("  3) Z uzyciem skrotow pozycyjnych:")
    [Console]::WriteLine("     .\Clone-GitHubRepositories.ps1 .\repositoriesToClone.txt C:\dane\rpindela\GitHub")
    [Console]::WriteLine("================================================================================")
    [Console]::ResetColor()
    exit 0
}

# Weryfikacja obecnosci narzedzia git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    [Console]::ForegroundColor = [ConsoleColor]::Red
    [Console]::WriteLine("Blad: Polecenie 'git' nie zostalo odnalezione w sciezce PATH.")
    [Console]::ResetColor()
    exit 1
}

# Weryfikacja istnienia pliku
if (-not (Test-Path -Path $RepositoriesFile -PathType Leaf)) {
    [Console]::ForegroundColor = [ConsoleColor]::Red
    [Console]::WriteLine("Blad: Nie znaleziono pliku: $RepositoriesFile")
    [Console]::ResetColor()
    exit 1
}

# Odczytanie repozytoriow
$repoList = Get-Content -Path $RepositoriesFile | 
    ForEach-Object { $_.Trim() } | 
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not$_.StartsWith("#") }

if ($repoList.Count -eq 0) {
    [Console]::ForegroundColor = [ConsoleColor]::Yellow
    [Console]::WriteLine("Plik '$RepositoriesFile' jest pusty.")
    [Console]::ResetColor()
    exit 0
}

Write-Host "Znaleziono $($repoList.Count) repozytoriow do przetworzenia.`n" -ForegroundColor DarkGray

if (-not (Test-Path -Path $TargetDir)) {
    Write-Host "[+] Tworzenie folderu docelowego: $TargetDir" -ForegroundColor Cyan
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
    Write-Host " Przetwarzanie: $repo" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray

    if (Test-Path -Path (Join-Path -Path $repoPath -ChildPath ".git")) {
        Write-Host "-> Repozytorium istnieje lokalnie. Pobieranie zmian (git pull)..." -ForegroundColor Green
        Push-Location $repoPath
        try {
            git pull --ff-only
        }
        catch {
            Write-Warning "Blad git pull dla $repo : $_"
        }
        finally {
            Pop-Location
        }
    } else {
        Write-Host "-> Klonowanie nowego repozytorium ($cloneUrl)..." -ForegroundColor Cyan
        git clone $cloneUrl $repoPath
    }
}

Write-Host "`n[✓] Zakonczono pomyslnie. Wszystkie repozytoria znajduja sie w: $resolvedTargetDir" -ForegroundColor Green
