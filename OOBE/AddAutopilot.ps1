Set-Executionpolicy RemoteSigned
Install-Script Get-WindowsAutopilotImportGUI -Force -SkipPublisherCheck
Get-WindowsAutopilotImportGUI

#Restart-Computer
