Set-ExecutionPolicy RemoteSigned -Force

Install-Module -Name OSD -Scope AllUsers
Update-Module -name OSD -Force
import-module -name OSD -Force

New-OSDCloudTemplate -Language nl-nl -SetInputLocale nl-nl -Verbose
$WorkingDir="C:\OSDCloud"
New-OSDCloudWorkspace -WorkspacePath $WorkingDir -Verbose

$KeepTheseDirs = @('boot','efi','en-us','sources','fonts','resources')
Get-ChildItem "$(Get-OSDCloudWorkspace)\Media" | Where {$_.PSIsContainer} | Where {$_.Name -notin $KeepTheseDirs} | Remove-Item -Recurse -Force
Get-ChildItem "$(Get-OSDCloudWorkspace)\Media\Boot" | Where {$_.PSIsContainer} | Where {$_.Name -notin $KeepTheseDirs} | Remove-Item -Recurse -Force
Get-ChildItem "$(Get-OSDCloudWorkspace)\Media\EFI\Microsoft\Boot" | Where {$_.PSIsContainer} | Where {$_.Name -notin $KeepTheseDirs} | Remove-Item -Recurse -Force

Invoke-WebRequest https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/Media/wallpaper.jpg -OutFile $WorkingDir\Media\wallpaper.jpg

Edit-OSDCloudWinPE -WorkspacePath $WorkingDir
Edit-OSDCloudWinPE -CloudDriver Dell,HP,IntelNet,LenovoDock,USB,VMware,WiFi -StartURL https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/OOBE/W11_OOBEcmd.ps1 -wallpaper $WorkingDir\Media\wallpaper.jpg -Verbose

New-OSDCloudISO -WorkspacePath $WorkingDir
