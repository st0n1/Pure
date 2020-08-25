#NASBackup_Flashblade

NASBACKUP_Flashblade consists of 2 .ps1 Powershell Scripts and takes care of backing up a Flashblade FileShare via an alternative path (Snapshot) within Veeam.
1. Invoke-FlashbladeNASBackup.ps1 and
2. RUN-FlashbladeNASBackup.ps1 makes sure that Invoke-FlashbladeNASBackup.ps1 will be executed by pwsh (powershell 6/7) instead of powershell 5. Furthermore you can use it for parameterization. 

Both scripts need to be in the same path on the Veeam Server.

Requirements: Powershell 6/7 on the Veeam Server (can be installed via powershell cli with the following command: 
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI")

Furthermore you need an API-Token. Generate it by logging into the Flashblade via SSH and execute:
pureadmin create --api-token 
Write down he API Token and insert it as an parameter into the RUN-FlashbladeNASBackup.ps1 script.

All required and optional parameters are documented within the script itself.

To use the script insert it as an PreCommand within the Veeam Backupjob: Select your File Backup Job -> Right Click Edit -> Storage -> Advanced -> Scripts -> "Run the following script before the job" -> Browse for the RUN-FlashbladeNASBackup.ps1 -> OK -> Finish

After that add the Snapshot in the Share Configuration. Inventory -> File Shares -> Right Click the File Share -> Properties -> Advanced -> "Backup from a storage snapshot at the following path" and insert the Snapshot path, e.g. \\1.2.3.4\TESTSHARE\.snapshot\TESTSHARE.VeeamNASBackup -> OK -> Finish

Have fun!