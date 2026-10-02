# Clone-GitHubRepositories – Dokumentacja i Instrukcja

**Autor:** Roman Pindela
**GitHub:** [https://github.com/romanpindela](https://github.com/romanpindela)
**E-mail:** romanpindela@gmail.com
**Wersja:** 1.1.0
## 1. Przeznaczenie narzędzia
Skrypt `Clone-GitHubRepositories.ps1` służy do zautomatyzowanego pobierania oraz aktualizowania zestawu repozytoriów z platformy GitHub na lokalny dysk roboczy. Dedykowany jest do środowisk deweloperskich i administracyjnych wykorzystujących **Visual Studio Code**.
Kluczowe właściwości:
- **Brak na sztywno wpisanych repozytoriów** – lista projektów wczytywana jest dynamicznie z zewnętrznego pliku tekstowego.
- **Idempotentność** – jeżeli repozytorium nie istnieje lokalnie, skrypt wykonuje `git clone`; jeśli już istnieje, synchronizuje gałąź za pomocą bezpiecznego `git pull --ff-only`.
- **Wbudowana pomoc** – uruchomienie bez argumentów lub z flagą `-Help` / `-h` wyświetla pełną składnię, parametry i dane kontaktowe.
- **Elastyczność protokołów** – wsparcie dla protokołów **HTTPS** oraz **SSH**.
## 2. Wymagania systemowe
1. System operacyjny Windows 10 / Windows 11 lub Windows Server.
2. PowerShell 5.1 lub PowerShell 7+.
3. Zainstalowany [Git for Windows](https://git-scm.com/) z dostępem w zmiennej środowiskowej PATH.
4. Visual Studio Code do późniejszej pracy z kodem.
## 3. Struktura plików

katalog_roboczy/
│
├── Clone-GitHubRepositories.ps1    # Główny skrypt PowerShell
└── repositoriesToClone.txt         # Lista nazw repozytoriów (po jednym w linii)
## 4. Konfiguracja listy (`repositoriesToClone.txt`)
W pliku umieszczamy same nazwy repozytoriów użytkownika. Linie puste oraz zaczynające się od `#` są automatycznie pomijane.

Automation
Microsoft-365
Active-Directory
Windows-Desktop
Windows-Server
Dev
Forensic
## 5. Parametry skryptu
| Parametr | Typ / Wartość | Opis |
| --- | --- | --- |
| `-RepositoriesFile` | Ścieżka (String) | Ścieżka do pliku z listą repozytoriów (np. `.\repositoriesToClone.txt`). |
| `-TargetDir` | Ścieżka (String) | Katalog docelowy, w którym zostaną sklonowane repozytoria (np. `C:\dane\rpindela\GitHub`). |
| `-Username` | String | Nazwa konta GitHub (wartość domyślna: `romanpindela`). |
| `-AuthProtocol` | `HTTPS` \| `SSH` | Wybór protokołu klonowania (wartość domyślna: `HTTPS`). |
| `-Help` / `-h` | Switch | Wyświetla wbudowany ekran pomocy oraz informacje autorskie i kończy działanie. |
## 6. Przykłady wywołania
### Wyświetlenie pomocy:

powershell .\Clone-GitHubRepositories.ps1 -Help
### Klonowanie standardowe przez HTTPS:

powershell .\Clone-GitHubRepositories.ps1 -RepositoriesFile ".\repositoriesToClone.txt" -TargetDir "C:\dane\rpindela\GitHub"
### Klonowanie przez SSH:

powershell .\Clone-GitHubRepositories.ps1 -RepositoriesFile ".\repositoriesToClone.txt" -TargetDir "C:\dane\rpindela\GitHub" -AuthProtocol SSH
## 7. Praca w Visual Studio Code
Po pobraniu repozytoriów do katalogu docelowego można natychmiast otworzyć całe środowisko robocze za pomocą wiersza poleceń:

code C:\dane\rpindela\GitHub
Lub otworzyć pojedyncze wybrane repozytorium:

code C:\dane\rpindela\GitHub\Windows-Desktop

