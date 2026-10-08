<#
================================================================================
  Nazwa skryptu : git-AllReposUpdate.ps1
  Autor         : Roman Pindela
  Kontakt       : roman.pindela@gmail.com
  Wersja        : 1.0.0
  Data wydania  : 2026-10-08
  Licencja      : MIT
  Repozytorium  : https://github.com/romanpindela/Dev

  OPIS:
    Skrypt automatyzuje proces aktualizacji wszystkich lokalnych repozytoriow Git
    znajdujacych sie w zadanym katalogu roboczym (domyslnie C:\GitHub).
    
    Dla kazdego wykrytego repozytorium skrypt weryfikuje aktywna galaz, sprawdza
    obecnosc niezatwierdzonych zmian (dirty worktree), pobiera najnowsze referencje
    ze zdalnego serwera (git fetch) oraz bezpiecznie aktualizuje stan lokalny
    (git pull --ff-only).
    
    W trakcie dzialania wyswietla czytelny, dynamiczny pasek postepu
    (Write-Progress), na biezaco raportuje status kazdego projektu w konsoli
    (wraz z dokladna liczba pobranych commitow), a na zakonczenie generuje
    profesjonalne podsumowanie operacji.

    Uruchomienie skryptu bez jakichkolwiek parametrow wyswietla szczegolowa
    pomoc, informacje o wersji, autorze oraz przyklady uzycia.

================================================================================
.SYNOPSIS
    Automatyczna synchronizacja i aktualizacja wszystkich lokalnych repozytoriow Git.
.DESCRIPTION
    Skanuje podana sciezke w poszukiwaniu katalogow z podkatalogiem .git,
    weryfikuje galezie oraz upstream, wykonuje fetch/pull i raportuje zmiany.
.PARAMETER Update
    Flaga inicjujaca wykonanie procedury aktualizacji repozytoriow.
.PARAMETER Path
    Katalog nadrzedny zawierajacy repozytoria Git. Domyslnie: C:\GitHub.
.PARAMETER Prune
    Wlacza opcje czyszczenia nieistniejacych zdalnych galezi (git fetch -p / --prune).
.PARAMETER LogPath
    Opcjonalna sciezka do pliku tekstowego ze szczegolowym logiem dzialania.
.PARAMETER Help
    Wyswietla szczegolowe menu pomocy, wersje, dane kontaktowe i przyklady.
.EXAMPLE
    .\git-AllReposUpdate.ps1
    # Uruchomienie bez parametrow - wyswietla pomoc, przyklady i informacje o autorze
.EXAMPLE
    .\git-AllReposUpdate.ps1 -Update
    # Aktualizuje wszystkie repozytoria w katalogu domyslnym C:\GitHub
.EXAMPLE
    .\git-AllReposUpdate.ps1 -Path "C:\GitHub"
    # Aktualizuje repozytoria w wybranym folderze
.EXAMPLE
    .\git-AllReposUpdate.ps1 -Update -Prune
    # Aktualizuje repozytoria z czyszczeniem usunietych referencji (prune)
.EXAMPLE
    .\git-AllReposUpdate.ps1 -Update -LogPath "C:\Logs\git-update-report.txt"
    # Aktualizuje repozytoria i zapisuje raport do wskazanego pliku logu
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

# --- INFORMACJE O SKRYPCIE I METADANE ---
$SCRIPT_INFO = @{
    Name        = "git-AllReposUpdate";
    Version     = "1.0.0";
    Author      = "Roman Pindela";
    Contact     = "roman.pindela@gmail.com";
    GitHub      = "https://github.com/romanpindela";
    ReleaseDate = "2026-10-08";
    License     = "MIT";
};

# Globalny uchwyt do aktywnego pliku dziennika
$script:ActiveLogFile = $null;

# --- FUNKCJE POMOCNICZE ---

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
  Autor: $($SCRIPT_INFO.Author) | Kontakt: $($SCRIPT_INFO.Contact)
  GitHub: $($SCRIPT_INFO.GitHub) | Licencja: $($SCRIPT_INFO.License)
================================================================================
OPIS:
  Automatyczny menedzer aktualizacji lokalnych repozytoriow Git.
  Przechodzi przez wszystkie podkatalogi w wyznaczonej sciezce (domyslnie C:\GitHub),
  sprawdza stan galezi, pobiera najnowsze commity ze zdalnego serwera (git fetch)
  oraz bezpiecznie synchronizuje zmiany lokalne (git pull --ff-only).

  Wyswietla dynamiczny pasek postepu, czytelny status na biezaco (z informacja
  o ilosci commitow) oraz kompleksowe podsumowanie wykonanych operacji.

UZYCIE:
  .\git-AllReposUpdate.ps1 -Update [-Path <katalog>] [-Prune] [-LogPath <plik.txt>]
  .\git-AllReposUpdate.ps1 -Path <katalog> [-Prune] [-LogPath <plik.txt>]
  .\git-AllReposUpdate.ps1 -h | -Help

PARAMETRY:
  -Update, -u, -Run, -All : Inicjuje automatyczna aktualizacje repozytoriow.
  -Path, -p               : Sciezka do glownego folderu z repozytoriami Git.
                            Domyslnie: C:\GitHub
  -Prune                  : Czysci osierocone galezie zdalne (git fetch --prune).
  -LogPath, -l, -Log      : [Opcjonalny] Zapisuje pelny raport i dziennik do pliku.
  -Help, -h               : Wyswietla to menu pomocy oraz informacje o autorze.

PRZYKLADY:
  1) Wyswietlenie menu pomocy:
     .\git-AllReposUpdate.ps1
     .\git-AllReposUpdate.ps1 -Help

  2) Aktualizacja wszystkich repozytoriow w domyslnym C:\GitHub:
     .\git-AllReposUpdate.ps1 -Update

  3) Aktualizacja ze wskazaniem wlasnej sciezki:
     .\git-AllReposUpdate.ps1 -Path "C:\Projekty\GitHub"

  4) Aktualizacja z opcja czyszczenia galezi (prune):
     .\git-AllReposUpdate.ps1 -Update -Prune

  5) Aktualizacja z zapisem logu do dedykowanego pliku:
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

# --- WALIDACJA WEJSCIA I URUCHOMIENIE BEZ PARAMETROW ---

# Jesli wywolano z flaga pomocy badz uruchomiono calkowicie bez parametrow:
if ($Help -or ($PSBoundParameters.Count -eq 0)) {
    Show-HelpGuide;
    exit 0;
}

# --- SPRAWDZENIE WYMAGAN SYSTEMOWYCH ---

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    [Console]::ForegroundColor = [ConsoleColor]::Red;
    [Console]::WriteLine("[-] Blad krytyczny: Narzedzie 'git' nie zostalo odnalezione w sciezce systemowej PATH.");
    [Console]::WriteLine("    Upewnij sie, ze Git for Windows jest zainstalowany i dostepny w srodowisku.");
    [Console]::ResetColor();
    exit 1;
}

# Rozwiazywanie pelnej sciezki katalogu nadrzednego
$resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);

if (-not (Test-Path -Path $resolvedPath -PathType Container)) {
    [Console]::ForegroundColor = [ConsoleColor]::Red;
    [Console]::WriteLine("[-] Blad: Podana sciezka katalogu nie istnieje lub nie jest folderem: $resolvedPath");
    [Console]::ResetColor();
    exit 1;
}

# Inicjalizacja pliku dziennika jesli podano parametr -LogPath
if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
    $resolvedLogPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LogPath);
    $logDirectory = [System.IO.Path]::GetDirectoryName($resolvedLogPath);
    if (-not [string]::IsNullOrWhiteSpace($logDirectory) -and -not [System.IO.Directory]::Exists($logDirectory)) {
        [System.IO.Directory]::CreateDirectory($logDirectory) | Out-Null;
    }
    $script:ActiveLogFile = $resolvedLogPath;
}

# --- ROZPOCZECIE GLOWNEGO PROCESU ---

try { Clear-Host; } catch {}
Write-Log "================================================================================" Cyan;
Write-Log "  $($SCRIPT_INFO.Name) v$($SCRIPT_INFO.Version) - Synchronizacja repozytoriow Git" Cyan;
Write-Log "  Autor: $($SCRIPT_INFO.Author) | Kontakt: $($SCRIPT_INFO.Contact)" Gray;
Write-Log "  Katalog zrodlowy : $resolvedPath" Yellow;
if (-not [string]::IsNullOrWhiteSpace($script:ActiveLogFile)) {
    Write-Log "  Plik dziennika   : $script:ActiveLogFile" DarkCyan;
}
Write-Log "================================================================================" Cyan;
Write-Log "" White;

Write-Log "[*] Skanowanie katalogu w poszukiwaniu projektow Git..." DarkGray;

$repoDirs = Get-ChildItem -Path $resolvedPath -Directory -ErrorAction SilentlyContinue |
    Where-Object { Test-Path -Path (Join-Path -Path $_.FullName -ChildPath ".git") }

if ($null -eq $repoDirs -or $repoDirs.Count -eq 0) {
    Write-Log "[!] Nie odnaleziono zadnych repozytoriow Git w podanej sciezce: $resolvedPath" Yellow;
    exit 0;
}

$totalRepos = $repoDirs.Count;
Write-Log "[+] Znaleziono $totalRepos repozytorium(ow) do weryfikacji.`n" Green;

# Klasy/struktury wynikowe
$results = [System.Collections.Generic.List[PSCustomObject]]::new();
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew();

for ($i = 0; $i -lt $totalRepos; $i++) {
    $repoDir      = $repoDirs[$i];
    $repoName     = $repoDir.Name;
    $repoFullName = $repoDir.FullName;
    $repoIndex    = $i + 1;
    $percent      = [math]::Round(($repoIndex / $totalRepos) * 100);

    # Pasek postepu Write-Progress
    Write-Progress -Activity "Aktualizacja repozytoriow Git ($resolvedPath)" `
                   -Status "[$repoIndex/$totalRepos] Przetwarzanie: $repoName" `
                   -PercentComplete $percent;

    # Inicjalizacja obiektu raportu
    $reportItem = [PSCustomObject]@{
        Name           = $repoName
        Path           = $repoFullName
        Branch         = "Nieznana"
        Status         = "Nieprzetworzone"
        CommitsPulled  = 0
        CommitSubjects = @()
        Details        = ""
    };

    try {
        # 1. Odczyt aktywnej galezi
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

        # 2. Weryfikacja obecnosci commitow (unborn branch check)
        $headResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "rev-parse --verify --quiet HEAD";
        if ($headResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($headResult.StdOut)) {
            $reportItem.Status = "Puste repozytorium";
            $reportItem.Details = "Brak commitow w repozytorium (pusta lub nowa galaz)";
            Write-Log "  [-] [PUSTE REPO]       $repoName ($branch) -> Brak commitow w repozytorium" Yellow;
            $results.Add($reportItem);
            continue;
        }
        $oldHead = $headResult.StdOut;

        # 3. Weryfikacja czy w repozytorium sa niezatwierdzone lokalne modyfikacje
        $dirtyResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "status --porcelain";
        $isDirty = (-not [string]::IsNullOrWhiteSpace($dirtyResult.StdOut));

        # 4. Sprawdzenie skonfigurowanych serwerow zdalnych
        $remoteResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "remote";
        if ([string]::IsNullOrWhiteSpace($remoteResult.StdOut)) {
            $reportItem.Status = "Brak remote";
            $reportItem.Details = "Brak skonfigurowanego serwera zdalnego (origin)";
            Write-Log "  [-] [BRAK REMOTE]      $repoName ($branch) -> Brak zdefiniowanego remote" Yellow;
            $results.Add($reportItem);
            continue;
        }

        # 5. Pobranie najnowszych referencji ze zdalnego serwera (git fetch)
        $fetchArgs = if ($Prune) { "fetch --prune" } else { "fetch" };
        $fetchResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments $fetchArgs;
        if ($fetchResult.ExitCode -ne 0) {
            $reportItem.Status = "Blad fetch";
            $reportItem.Details = "Niepowodzenie operacji fetch: $($fetchResult.StdErr)";
            Write-Log "  [-] [BLAD FETCH]       $repoName ($branch) -> $($reportItem.Details)" Red;
            $results.Add($reportItem);
            continue;
        }

        # 6. Weryfikacja galezi nadrzednej (upstream / tracking branch)
        $upstreamResult = Invoke-GitCmd -RepoPath $repoFullName -Arguments "rev-parse --abbrev-ref @{u}";
        $upstream = $upstreamResult.StdOut;
        if ($upstreamResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($upstream)) {
            $reportItem.Status = "Brak upstream";
            $reportItem.Details = "Galaz '$branch' nie sledzi zadnej galezi zdalnej";
            Write-Log "  [-] [BRAK UPSTREAM]    $repoName ($branch) -> Brak powiazanej galezi zdalnej" DarkYellow;
            $results.Add($reportItem);
            continue;
        }

        # 7. Wyliczenie ilosci commitow do pobrania (behind) oraz do wyslania (ahead)
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

        # 8. Wykonanie bezpiecznej aktualizacji (git pull --ff-only)
        if ($behindCount -eq 0) {
            if ($aheadCount -gt 0) {
                $reportItem.Status = "Bez zmian (Lokalne)";
                $reportItem.Details = "Lokalna galaz wyprzedza zdalna o $aheadCount commit(ow)";
                Write-Log "  [=] [BEZ ZMIAN]        $repoName ($branch) -> Aktualne (lokalnie: +$aheadCount commitow do push)" DarkGray;
            } else {
                $reportItem.Status = "Bez zmian";
                $reportItem.Details = "Repozytorium jest w pelni aktualne";
                Write-Log "  [=] [BEZ ZMIAN]        $repoName ($branch) -> Aktualne" DarkGray;
            }
        }
        else {
            # Istnieja nowe commity do pobrania!
            if ($isDirty) {
                $reportItem.Details = "Niezatwierdzone lokalne modyfikacje przed pull. ";
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

                $reportItem.Status         = "Zaktualizowano";
                $reportItem.CommitsPulled  = $behindCount;
                $reportItem.CommitSubjects = $pulledSubjects;
                $reportItem.Details       += "Pobrano $behindCount commit(ow) pomyslnie.";

                Write-Log "  [+] [ZAKTUALIZOWANO]   $repoName ($branch) -> +$behindCount commit(ow)" Green;
                if ($pulledSubjects.Count -gt 0) {
                    foreach ($subj in $pulledSubjects | Select-Object -First 3) {
                        Write-Log "      * $subj" DarkGreen;
                    }
                    if ($pulledSubjects.Count -gt 3) {
                        $remaining = $pulledSubjects.Count - 3;
                        Write-Log "      * ... oraz $remaining kolejnych commitow" DarkGreen;
                    }
                }
            }
            else {
                $reportItem.Status  = "Blad pull";
                $reportItem.Details = "Niepowodzenie git pull: $($pullResult.StdErr)";
                Write-Log "  [!] [BLAD PULL]        $repoName ($branch) -> $($reportItem.Details)" Red;
            }
        }
    }
    catch {
        $reportItem.Status  = "Wyjatek";
        $reportItem.Details = "Nieoczekiwany blad: $($_.Exception.Message)";
        Write-Log "  [!] [WYJATEK]          $repoName -> $($reportItem.Details)" Red;
    }

    $results.Add($reportItem);
}

# Zamkniecie paska postepu
Write-Progress -Activity "Aktualizacja repozytoriow Git" -Completed;
$stopwatch.Stop();

# --- ANALIZA WYNIKOW I PODSUMOWANIE ---

$updatedRepos = @($results | Where-Object { $_.Status -eq "Zaktualizowano" });
$upToDateRepos = @($results | Where-Object { $_.Status -like "Bez zmian*" });
$issueRepos    = @($results | Where-Object { $_.Status -notmatch "^(Zaktualizowano|Bez zmian)" });

Write-Log "" White;
Write-Log "================================================================================" Cyan;
Write-Log "                       PODSUMOWANIE SYNCHRONIZACJI GIT                          " Cyan;
Write-Log "================================================================================" Cyan;
Write-Log "Katalog roboczy           : $resolvedPath" White;
Write-Log "Wszystkich repozytoriow   : $totalRepos" White;
Write-Log "Zaktualizowane            : $($updatedRepos.Count)" Green;
Write-Log "Bez zmian (aktualne)      : $($upToDateRepos.Count)" Gray;
Write-Log "Wymagajace uwagi / inne   : $($issueRepos.Count)" $(if ($issueRepos.Count -gt 0) { [ConsoleColor]::Yellow } else { [ConsoleColor]::Gray });
Write-Log "Calkowity czas wykonania  : $($stopwatch.Elapsed.ToString("mm\:ss\.ff"))" DarkCyan;
Write-Log "--------------------------------------------------------------------------------" DarkGray;

if ($updatedRepos.Count -gt 0) {
    Write-Log "`n[+] REPOZYTORIA ZAKTUALIZOWANE:" Green;
    foreach ($r in $updatedRepos) {
        Write-Log "  * $($r.Name) [$($r.Branch)] : pobrano $($r.CommitsPulled) commit(ow)" Green;
        foreach ($sub in $r.CommitSubjects | Select-Object -First 2) {
            Write-Log "      - $sub" DarkGreen;
        }
    }
}

if ($upToDateRepos.Count -gt 0) {
    Write-Log "`n[=] REPOZYTORIA BEZ ZMIAN (AKTUALNE):" Gray;
    $upToDateNames = ($upToDateRepos | ForEach-Object { "$($_.Name) [$($_.Branch)]" }) -join ", ";
    Write-Log "  $upToDateNames" DarkGray;
}

if ($issueRepos.Count -gt 0) {
    Write-Log "`n[!] REPOZYTORIA WYMAGAJACE UWAGI / PUSTE / BLEDY:" Yellow;
    foreach ($r in $issueRepos) {
        Write-Log "  * $($r.Name) [$($r.Branch)] : Status: $($r.Status) | Szczegoly: $($r.Details)" Yellow;
    }
}

Write-Log "`n================================================================================" Cyan;
if (-not [string]::IsNullOrWhiteSpace($script:ActiveLogFile)) {
    Write-Log "Raport z synchronizacji zostal zapisany w: $script:ActiveLogFile" Green;
    Write-Log "================================================================================" Cyan;
}
Write-Log "Kontakt z autorem: $($SCRIPT_INFO.Contact)`n" Gray;
