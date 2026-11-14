Invoke-WebRequest -Uri "https://raw.githubusercontent.com/romanpindela/Windows-Desktop/main/Enable-RemoteManagement/Enable-RemoteManagement.ps1" -OutFile "$env:USERPROFILE\Downloads\Enable-RemoteManagement.ps1"
Unblock-File -Path "$env:USERPROFILE\Downloads\Enable-RemoteManagement.ps1"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
& "$env:USERPROFILE\Downloads\Enable-RemoteManagement.ps1"