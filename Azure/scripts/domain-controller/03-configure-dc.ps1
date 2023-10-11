Param (
 [Parameter(Mandatory = $True, HelpMessage = "Provide the domain prefix used for domain user accounts (i.e domain-prefix\username).")]
 [Alias("DomainPrefix")]
 [String]$Domain_Prefix = "", 
 [Parameter(Mandatory = $True, HelpMessage = "Specify the name of the <run as> user account to use when you run the task, must be a Domain Admin.")]
 [Alias("User")]
 [String]$strUser = "",
 [Parameter(Mandatory = $True, HelpMessage = "Specify the password for the <run as> user.")]
 [Alias("Password")]
 [String]$strPass = ""
)

echo "Executing 03-configure-dc.ps1"

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Setting up task to run $($PSScriptRoot)\04-configure-dc.ps1"
$A = New-ScheduledTaskAction -Execute "cmd" -Argument "/c powershell.exe -ExecutionPolicy Unrestricted -File $PSScriptRoot\04-configure-dc.ps1 -User $strUser -Password $strPass -DomainPrefix $Domain_Prefix -Content $PSScriptRoot\Content >> c:\dc-config-log.txt"
$T = New-ScheduledTaskTrigger -Once -At (get-date).AddSeconds(180); $t.EndBoundary = (get-date).AddSeconds(420).ToString('s')
$S = New-ScheduledTaskSettingsSet -StartWhenAvailable #-DeleteExpiredTaskAfter 00:00:30
Register-ScheduledTask -Force -User "$Domain_Prefix\$strUser" -Password "$strPass" -RunLevel "Highest" -TaskName "DC Script 4" -Action $A -Trigger $T -Settings $S
Sleep -Seconds 10

Get-ScheduledTask -TaskName "DC Script 4"