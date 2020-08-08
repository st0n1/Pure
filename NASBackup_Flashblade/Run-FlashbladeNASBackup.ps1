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
    # Filesystem Name
    #
    FilesystemName = ""
 }
 # 

$PSVersionTable.PSVersion

if ($PSVersionTable.PSVersion -lt "6.0")
{
	pwsh -f $PSScriptRoot\Invoke-FlashbladeNASBackup.ps1 @arguments
	return
}


