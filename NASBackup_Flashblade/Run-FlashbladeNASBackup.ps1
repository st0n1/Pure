<#
   .SYNOPSIS
   Wrapper to run Invoke-FlashbladeNASBackup.ps1 with pwsh and prefill required arguments.
   Wrapper calls static Powershell path as a Veeam requirement. Change it as needed
   .Notes 
   Version:        1.0
   Author:         Christian Stein
   Creation Date:  08.08.2020

#>

$PWSHEXE = "C:\Program Files\PowerShell\7\pwsh.exe"

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

& "$PWSHEXE" -f ./Invoke-FlashbladeNASBackup.ps1 @arguments