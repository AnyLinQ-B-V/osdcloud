Install-Module AzureAD -Force
Install-Module WindowsAutopilotIntune -Force
Install-Module Microsoft.Graph.Intune -Force
Install-Module Microsoft.Graph.Identity.DirectoryManagement -Force

Connect-MSGraph

Install-Script Get-Windowsautopilotinfo
Get-WindowsAutoppilotinfo -online
