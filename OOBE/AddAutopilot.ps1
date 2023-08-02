Set-ExecutionPolicy RemoteSigned -Force
Install-Module AzureAD -Force -Verbose
Install-Module WindowsAutopilotIntune -Force -Verbose
Install-Module Microsoft.Graph.Intune -Force -Verbose
Install-Module Microsoft.Graph.Identity.DirectoryManagement -Force -Verbose

Connect-MSGraph

Install-Script Get-Windowsautopilotinfo
Get-WindowsAutoppilotinfo -online
