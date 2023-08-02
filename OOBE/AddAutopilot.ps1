Set-ExecutionPolicy RemoteSigned -Force
Install-Module AzureAD -SkipPublisherCheck -Force -Verbose
Install-Module WindowsAutopilotIntune -SkipPublisherCheck -Force -Verbose
Install-Module Microsoft.Graph.Intune -SkipPublisherCheck -Force -Verbose
Install-Module Microsoft.Graph.Identity.DirectoryManagement -SkipPublisherCheck -Force -Verbose

Connect-MSGraph

Install-Script Get-Windowsautopilotinfo
Get-WindowsAutoppilotinfo -online
