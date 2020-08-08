<#
   .SYNOPSIS
   Wrapper to run Invoke-FlashbladeNASBackup.ps1 with pwsh and prefill required arguments
   .Notes 
   Version:        1.0
   Author:         Christian Stein
   Creation Date:  08.08.2020

#>

$arguments = @{
    #
    # Name or ip adress.
    #
    Name = ""
    #
    # API-Token
    #
    APIToken = ""
    #
    # Filesystem Names
    #
    FilesystemName = ""
    #
    # SnapshotSuffix
    #
    SnapshotSuffix="VeeamNASBackup"
    #
    # Logfile
    #
    LogFile="C:\ProgramData\Veeam\Backup\FlashbladeNASBackup.log"
 }
 # 

$PSVersionTable.PSVersion | Out-Null

if ($PSVersionTable.PSVersion -lt "8.0")
{
   & C:\"Program Files"\PowerShell\7\pwsh.exe -f ./Invoke-FlashbladeNASBackup.ps1 @arguments
   return
   # & pwsh -f ./Invoke-FlashbladeNASBackup.ps1 @arguments
}