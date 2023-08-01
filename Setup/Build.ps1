Set-Location C:\osdcloud-scripts\
Set-ExecutionPolicy RemoteSigned -Force

Install-Module -Name OSD -Scope AllUsers
Update-Module -name OSD -Force
import-module -name OSD -Force

New-OSDCloudTemplate -Language nl-nl -SetInputLocale nl-nl -Verbose
$WorkingDir="C:\OSDCloud"
New-OSDCloudWorkspace -WorkspacePath $WorkingDir -Verbose

New-Item -ItemType Directory $WorkingDir\Media\OSDCloud\Automate
Copy-Item .\AutoPilotConfigurationFile.json $WorkingDir\Media\OSDCloud\Automate 

Invoke-WebRequest https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/Media/wallpaper.jpg -OutFile $WorkingDir\Media\wallpaper.jpg

Edit-OSDCloudWinPE -WorkspacePath $WorkingDir
Edit-OSDCloudWinPE -CloudDriver Dell,HP,IntelNet,LenovoDock,USB,VMware,WiFi -StartURL https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/OOBE/W11_OOBEcmd.ps1 -wallpaper $WorkingDir\Media\wallpaper.jpg -Verbose

New-OSDCloudISO -WorkspacePath $WorkingDir
