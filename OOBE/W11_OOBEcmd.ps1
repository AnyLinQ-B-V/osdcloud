Set-ExecutionPolicy RemoteSigned -Force

#================================================
#   [PreOS] Update Module
#================================================
Write-Host  -ForegroundColor Cyan "AnyLinQ Interne IT - Reset van Windows"
Start-Sleep -Seconds 5

Import-Module OSD -Force

#=======================================================================
#   [OS] Params and Start-OSDCloud
#=======================================================================
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
#  [PostOS] AutopilotOOBE Configuration Staging
#================================================
Install-Module AutopilotOOBE -Force
Import-Module AutopilotOOBE -Force

$Serial = Get-WmiObject Win32_bios | Select-Object -ExpandProperty SerialNumber
$TargetComputername = $Serial
$AssignedComputerName = "AQ-LT-$TargetComputername"

$AutopilotOOBEJson = @"
{
    "Assign":  {
        "IsPresent": true
    },
    "AssignedComputerName": "$AssignedComputerName",
    "AddToGroup": "AnyLinQ Laptop",
    "Disabled": [
        "AddToGroup",
        "Assign"
    ]
    "Hidden": [
        "AssignedUser",
        "PostAction",
        "Run",
        "Docs"
    ],
    "PostAction": "Quit",
    "Title": "AnyLinQ Autopilot Registratie"
}
"@

If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$AutopilotOOBEJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json" -Encoding ascii -Force

#================================================
#  [PostOS] OOBEDeploy Configuration
#================================================
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
        "Microsoft.Microsoft3DViewer",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MixedReality.Portal",
        "Microsoft.MSPaint",
        "Microsoft.People",
        "Microsoft.SkypeApp",
        "Microsoft.StorePurchaseApp",
        "Microsoft.Todos",
        "Microsoft.Wallet",
        "microsoft.windowscommunicationsapps",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp",
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
#  [PostOS] AutopilotOOBE CMD Command Line
#================================================
$OOBECMD = @'
@echo off

:: Set the PowerShell Execution Policy
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force

:: Add PowerShell Scripts to the Path
set path=%path%;C:\Program Files\WindowsPowerShell\Scripts

Start /Wait PowerShell -NoL -C Install-Module AutopilotOOBE -Force -Verbose
Start /Wait PowerShell -NoL -C Install-Module OSD -Force -Verbose
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/OOBE/AP-Prereq.ps1
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/OOBE/Start-AutopilotOOBE.ps1
Start /Wait PowerShell -NoL -C Start-AutopilotOOBE
Start /Wait PowerShell -NoL -C Start-OOBEDeploy
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/OOBE/TPM.ps1
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/OOBE/CleanUp.ps1
Start /Wait PowerShell -NoL -C Restart-Computer -Force
'@
$OOBECMD | Out-File -FilePath 'C:\Windows\System32\OOBE.cmd' -Encoding ascii -Force

#================================================
#  [PostOS] SetupComplete CMD Command Line
#================================================
$SetupCompleteCMD = @'
@echo off

:: Set the PowerShell Execution Policy
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force

:: Add PowerShell Scripts to the Path
set path=%path%;C:\Program Files\WindowsPowerShell\Scripts

:: Open and Minimize a PowerShell instance just in case
start PowerShell -NoL -W Mi

:: Install the latest AutopilotOOBE Module
start "Install-Module AutopilotOOBE" /wait PowerShell -NoL -C Install-Module AutopilotOOBE -Force -Verbose

:: Start-AutopilotOOBE
powershell.exe -Command "& {IEX (IRM https://raw.githubusercontent.com/AnyLinQ-B-V/osdcloud/main/OOBE/oobetasks.ps1)}"

exit
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
Write-Host  -ForegroundColor Cyan "Herstart in 20 seconden!"
Start-Sleep -Seconds 20
wpeutil reboot