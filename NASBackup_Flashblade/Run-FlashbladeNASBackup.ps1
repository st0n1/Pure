<#
   .SYNOPSIS
   Wrapper to run Invoke-FlashbladeNASBackup.ps1 with pwsh and prefill required arguments.
   Wrapper requires static Powershell pwsh.exe path as a Veeam requirement. Change it as needed.
   
   .PARAMETER Name
   With this parameter you specify the Flashblade DNS name or IP

   .PARAMETER ApiToken
   An API Token is required to connect securely without a user and password to the FlashBlade.
   You have to generate an API Token on the FlashBlade via commandline first: pureadmin create --api-token USERNAME 

   .PARAMETER FilesystemName
   With this parameter you specify the Filesystem that you want to snapshot
  
   .PARAMETER SnapshotSuffix
   With this parameter you can change the default snapshotsuffix "VeeamNASBackup" to your own name
   
   .PARAMETER LogFile
   You can set your own path for log files from this script. Default path is the same as VBR uses by default "C:\ProgramData\Veeam\Backup\FlashbladeNASBackup.log"
   
   .Notes 
   Version:        1.1
   Author:         Christian Stein
   Creation Date:  08.08.2020

#>

#Set Parameters here:
#Example [string]$Name="1.2.3.4"
Param(
        [Parameter()]
        [string]$Name="",
        [Parameter()]
        [string]$APIToken="",
        [Parameter()]
        [string]$FilesystemName="",
        [Parameter()]
        [string]$SnapshotSuffix="VeeamNASBackup",
        [Parameter()]
        [string]$LogFile="C:\ProgramData\Veeam\Backup\FlashbladeNASBackup.log"
    )

# Set PWSHEXE location here>
$PWSHEXE = "C:\Program Files\PowerShell\7\pwsh.exe"

$arguments = @{
    # Name or ip adress.
    Name = "$Name"
    # API-Token
    APIToken = "$APIToken"
    # Filesystem Names
    FilesystemName = "$FilesystemName"
    # SnapshotSuffix
    SnapshotSuffix="$SnapshotSuffix"
    # Logfile
    LogFile="$LogFile"
 }

 function Write-Log($Info, $Status){
   $timestamp = get-date -Format "yyyy-mm-dd HH:mm:ss"
   switch($Status){
       Info    {Write-Host "$timestamp $Info" -ForegroundColor Green  ; "$timestamp $Info" | Out-File -FilePath $LogFile -Append -Encoding Ascii}
       Status  {Write-Host "$timestamp $Info" -ForegroundColor Yellow ; "$timestamp $Info" | Out-File -FilePath $LogFile -Append -Encoding Ascii}
       Warning {Write-Host "$timestamp $Info" -ForegroundColor Yellow ; "$timestamp $Info" | Out-File -FilePath $LogFile -Append -Encoding Ascii}
       Error   {Write-Host "$timestamp $Info" -ForegroundColor Red -BackgroundColor White; "$timestamp $Info" | Out-File -FilePath $LogFile -Append -Encoding Ascii}
       default {Write-Host "$timestamp $Info" -ForegroundColor white "$timestamp $Info" | Out-File -FilePath $LogFile -Append -Encoding Ascii}
   }
}

Write-Log -Info " " -Status Info
Write-Log -Info "-------------- NEW SESSION --------------" -Status Info
Write-Log -Info " " -Status Info

try {
   Write-Log -Info "Checking if $PWSHEXE exists" -Status Info
   Get-ChildItem $PWSHEXE | Out-Null 
   Write-Log -Info "Calling Invoke-FlashbladeNASBackup.ps1 @arguments" -Status Info
   & "$PWSHEXE" -f .\Invoke-FlashbladeNASBackup.ps1 @arguments
}
catch{
   Write-Log -Info "Error while calling $PWSHEXE -f .\Invoke-FlashbladeNASBackup.ps1" -Status Error
   exit 1
}