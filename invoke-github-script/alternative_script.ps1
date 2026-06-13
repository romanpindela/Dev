Invoke-WebRequest -Uri "https://raw.githubusercontent.com/romanpindela/Windows-Desktop/main/enable-remote-management/enable-remote-management.ps1" -OutFile "$env:USERPROFILE\Downloads\enable-remote-management.ps1"
Unblock-File -Path "$env:USERPROFILE\Downloads\enable-remote-management.ps1"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
& "$env:USERPROFILE\Downloads\enable-remote-management.ps1"