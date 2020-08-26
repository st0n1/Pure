<# 
   .SYNOPSIS
   Creating a snapshot on a Pure FlashBlade for use with Veeam Backup & Replication NAS backup althernative path option.

   .DESCRIPTION
   This script creates a snapshot on a Pure FlashBlade for the defined Filesystem. Based on the Pure Flashblade PowerShell module PureFBModule.
    
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
   
   .INPUTS
   None.

   .Example
   c:\scripts\latest\Invoke-FlashbladeNASBackup.ps1 -Name fb01.example.com -FilesystemName share01 -ApiToken T-bf48b96d-c425-4e5c-blaf-70b0ea364eaf 

   .Notes 
   Version:        0.2
   Author:         Christian Stein (cstein@purestorage.com)
   Creation Date:  04.09.2020
   Purpose/Change: Initial script development
   Based on:       https://github.com/marcohorstmann/psscripts/tree/master/NASBackup by Marco Horstmann (marco.horstmann@veeam.com)
 #> 

 #requires -PSEdition Core

 [CmdletBinding(DefaultParameterSetName="__AllParameterSets")]
 Param(
 
    [Parameter(Mandatory=$True)]
    [alias("Name")]
    [string]$Script:FBName,
 
    [Parameter(Mandatory=$True)]
    [alias("ApiToken")]
    [string]$Script:ApiToken,   
 
    [Parameter(Mandatory=$True)]
    [alias("FilesystemName")]
    [string]$Script:FilesystemName,
 
    [Parameter(Mandatory=$True)]
    [alias("SnapshotSuffix")]
    [string]$Script:SnapshotSuffix,
 
    [Parameter(Mandatory=$True)]
    [alias("LogFile")]
    [string]$Script:LogFile
 
 )
 
 PROCESS {
 
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
     
     function Load-FBModule {
        Write-Log -Info "Trying to load Flashblade Powershell module" -Status Info
        # If module is imported say that and do nothing
        if (Get-Module | Where-Object {$_.Name -eq "PureFBModule"}) {
            Write-Log -Info "Module PureFBModule is already imported." -Status Info
        }
        else {
    
            # If module is not imported, but available on disk then import
            if (Get-Module -ListAvailable | Where-Object {$_.Name -eq "PureFBModule"}) {
                Write-Log -Info "Required Flashblade Powershell module is installed. Importing." -Status Info
                Import-Module PureFBModule
            }
            else {
    
                # If module is not imported, not available on disk, but is in online gallery then install and import
                if (Find-Module -Name PureFBModule | Where-Object {$_.Name -eq "PureFBModule"}) {
                    Write-Log -Info "Required Flashblade Powershell module is not installed. Installing." -Status Info
                    Install-Module -Name PureFBModule -Force -Scope CurrentUser
                    Write-Log -Info "Required Flashblade Powershell module is now installed. Importing." -Status Info
                    Import-Module PureFBModule
                }
                else {
    
                    # If module is not imported, not available and not in online gallery then abort
                    Write-Log -Info "Module PureFBModule not imported, not available and not in online gallery, exiting." -Status Error
                    EXIT 1
                }
            }
        }
    }
 
     function Test-FBConnection{
        Write-Log -Info "Trying to connect to the Flashblade $FBName" -Status Info
        $FBConnection = Get-PfbArray -Flashblade $FBName -ApiToken $ApiToken
        $FBConnectionID = $FBConnection.id
        if ( $FBConnectionID ) {
            Write-Log -Info "Connection to Flashblade $FBName with ID $FBConnectionID established successfully" -Status Info
        }
        else {
            Write-Log -Info "$_" -Status Error
            Write-Log -Info "Connection to Flashblade $FBName" -Status Error
            exit 1
        }
     }

     function Create-NewSnapShot{
         Write-Log -Info "Trying to create a new snapshot for $FBName : $FilesystemName" -Status Info
         #check if there is a snapshot with the same name
         $ExistingSnap = Get-PfbFilesystemSnapshot -Flashblade $FBName -ApiToken $ApiToken -Name $FilesystemName
         $ExistingSnapName = $ExistingSnap.name
             if ( $ExistingSnapName -eq "$FilesystemName.$SnapshotSuffix" ) {
                Write-Log -Info "Snapshot $ExistingSnapName found" -Status Info
                 #We need to execute Get-PfbFilesystemSnapshot twice, because Get-PfbFilesystemSnapshot throws an error if -Name doenst exist.
                 $ExistingSnap = Get-PfbFilesystemSnapshot -Flashblade $FBName -ApiToken $ApiToken -Name "$FilesystemName.$SnapshotSuffix"
                 $ExistingSnapName = $ExistingSnap.name
                 $ExistingSnapID = $ExistingSnap.id
                 #Convert UnixTime to DateTime for readable Output
                 $SnapCreationUnixTime = [datetimeoffset]::FromUnixTimeMilliseconds($ExistingSnap.created)
                 $SnapCreationTime = $SnapCreationUnixTime.LocalDateTime
                 try {
                     #remove the existing snapshot
                     Write-Log -Info "Trying to remove snapshot $ExistingSnapName with ID $ExistingSnapID and date $SnapCreationTime." -Status Info
                     Update-PfbFilesystemSnapshot -Flashblade $FBName -ApiToken $ApiToken -Name "$FilesystemName.$SnapshotSuffix" -Attributes '{"destroyed":"true" } ' | Out-Null 
                     Write-Log -Info "Snapshot $ExistingSnapName with ID $ExistingSnapID destroyed" -Status Info
                     Remove-PfbFilesystemSnapshot -Flashblade $FBName -ApiToken $ApiToken -Name "$FilesystemName.$SnapshotSuffix"
                     Write-Log -Info "Snapshot $ExistingSnapName with ID $ExistingSnapID eradicated" -Status Info
                 }
                 catch {
                     Write-Log -Info "$_" -Status Error
                     Write-Log -Info "Removing the old snapshot failed" -Status Error
                     exit 1
                 }
             }
             else {
             Write-Log -Info "No existing snapshot found" -Status Info
             }
         #create a new snapshot for the share
         try {
             $Snapshot = Add-PfbFilesystemSnapshot -Flashblade $FBName -ApiToken $ApiToken -Sources "$FilesystemName" -Suffix "$SnapshotSuffix"
             $SnapShotID = $Snapshot.ID
             Write-Log -Info "New snapshot named $FilesystemName.$SnapshotSuffix created, ID: $SnapShotID" -Status Info
         }
         catch {
             Write-Log -Info "$_" -Status Error
             Write-Log -Info "Snapshot creation failed" -Status Error
             exit 1
         }
     }
 
 
     Write-Log -Info "Executing Invoke-FlashbladeNASBackup.ps1" -Status Info

     #Load the required PS modules
     Load-FBModule
     
     #Test Connection
     Test-FBConnection

     #Create the new snapshot
     Create-NewSnapShot
   
 } # END Process
 
 