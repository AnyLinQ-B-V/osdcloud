Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
Install-PackageProvider -Name NuGet -Force
Write-Host 'Installing Get-WindowsAutopilotInfo:'`n
Install-Script -Name Get-WindowsAutoPilotInfo -Force
  
Write-Host 'Installing dependencies (Module: WindowsAutopilotIntune).'`n
Write-Host 'Opening Login Window after the installation was successfull:'`n
 
Get-WindowsAutopilotInfo.ps1 -online
         
Write-Host 'Everything completed. Rebooting now ...'`n
Start-Sleep -s 2
Restart-Computer
