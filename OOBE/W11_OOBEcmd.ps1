Set-ExecutionPolicy RemoteSigned -Force

#================================================
#   [PreOS] Update Module
#================================================
Write-Host  -ForegroundColor Cyan "AnyLinQ Interne IT - Reset van Windows"
Start-Sleep -Seconds 5

# if ((Get-MyComputerModel) -match 'Virtual') {
# 	Write-Host -ForegroundColor Green "Setting Display Resolution to 1600x"
# 	Set-DisRes 1600
# }

Install-Module OSD -Force
Import-Module OSD -Force

#=======================================================================
#   [OS] Params and Start-OSDCloud
#=======================================================================
Write-Host  -ForegroundColor Cyan "Start OSDCloud met AnyLinQ Interne IT Parameters"
$Params = @{
    OSVersion = "Windows 11"
    OSBuild = "22H2"
    OSEdition = "Pro"
    OSLanguage = "en-us"
    OSLicense = "Volume"
    ZTI = $true
    Firmware = $false
}
Start-OSDCloud @Params

#================================================
#  [PostOS] OOBEDeploy Configuration
#================================================
Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json"
$OOBEDeployJson = @'
{
    "AddNetFX3":  {
                      "IsPresent":  true
                  },
    "Autopilot":  {
                      "IsPresent":  true
                  },
    "RemoveAppx":  [
                    "MicrosoftTeams",
                    "Microsoft.BingWeather",
                    "Microsoft.BingNews",
                    "Microsoft.GamingApp",
                    "Microsoft.GetHelp",
                    "Microsoft.Getstarted",
                    "Microsoft.Messaging",
                    "Microsoft.MicrosoftOfficeHub",
                    "Microsoft.MicrosoftSolitaireCollection",
                    "Microsoft.MSPaint",
                    "Microsoft.People",
                    "Microsoft.StorePurchaseApp",
                    "Microsoft.Todos",
                    "microsoft.windowscommunicationsapps",
                    "Microsoft.WindowsFeedbackHub",
                    "Microsoft.WindowsMaps",
                    "Microsoft.WindowsSoundRecorder",
                    "Microsoft.Xbox.TCUI",
                    "Microsoft.XboxGameOverlay",
                    "Microsoft.XboxGamingOverlay",
                    "Microsoft.XboxIdentityProvider",
                    "Microsoft.XboxSpeechToTextOverlay",
                    "Microsoft.YourPhone",
                    "Microsoft.ZuneMusic",
                    "Microsoft.ZuneVideo"
                   ],
    "UpdateDrivers":  {
                          "IsPresent":  true
                      },
    "UpdateWindows":  {
                          "IsPresent":  true
                      }
}
'@
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$OOBEDeployJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json" -Encoding ascii -Force

#================================================
#  [PostOS] AutopilotOOBE Configuration Staging
#================================================
Write-Host -ForegroundColor Green "Define Computername:"
$Serial = Get-WmiObject Win32_bios | Select-Object -ExpandProperty SerialNumber

$AssignedComputerName = "AQ-LT-$Serial"
Write-Host -ForegroundColor Red $AssignedComputerName
Write-Host ""

Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json"
$AutopilotOOBEJson = @"
{
    "CloudAssignedTenantDomain": "AnylinQ.com",
    "CloudAssignedTenantId": "c94d8e55-b7eb-455c-8cf7-ecaadd84ae70",
    "CloudAssignedAutopilotUpdateTimeout":  1800000,
    "CloudAssignedAutopilotUpdateDisabled":  1,
    "CloudAssignedForcedEnrollment":  1,
    "Version": 2049,
    "Comment_File": "Profile AQ Laptop Open",
    "CloudAssignedAadServerData": "{\"ZeroTouchConfig\":{\"CloudAssignedTenantUpn\":\"\",\"CloudAssignedTenantDomain\":\"AnylinQ.com\",\"ForcedEnrollment\":1}}",
    "CloudAssignedDomainJoinMethod": 0,
    "CloudAssignedOobeConfig": 1308,
    "ZtdCorrelationId": "6f6b5bc5-e4f7-415e-9090-6c5ef70f82db",
    "CloudAssignedLanguage": "os-default",
    "CloudAssignedDeviceName": "AQ-LT-%SERIAL%"
}
"@

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$AutopilotOOBEJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json" -Encoding ascii -Force

#================================================
#  [PostOS] AutopilotOOBE CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Create C:\Windows\System32\OOBE.cmd"
$OOBECMD = @'
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force
Set Path = %PATH%;C:\Program Files\WindowsPowerShell\Scripts
Start /Wait PowerShell -NoL -C Install-Module AutopilotOOBE -Force -Verbose
Start /Wait PowerShell -NoL -C Install-Module OSD -Force -Verbose
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/OOBE/AP-Prereq.ps1
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/OOBE/Start-AutopilotOOBE.ps1
Start /Wait PowerShell -NoL -C Start-OOBEDeploy
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/OOBE/TPM.ps1
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/OOBE/CleanUp.ps1
Start /Wait PowerShell -NoL -C Restart-Computer -Force
'@
$OOBECMD | Out-File -FilePath 'C:\Windows\System32\OOBE.cmd' -Encoding ascii -Force

#================================================
#  [PostOS] SetupComplete CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Create C:\Windows\Setup\Scripts\SetupComplete.cmd"
$SetupCompleteCMD = @'
powershell.exe -Command Set-ExecutionPolicy RemoteSigned -Force
powershell.exe -Command "& {IEX (IRM https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/OOBE/main/oobetasks.ps1)}"
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
Write-Host  -ForegroundColor Cyan "Herstart in 20 seconden!"
Start-Sleep -Seconds 20
wpeutil reboot