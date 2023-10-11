Param (
  [Parameter(Mandatory = $True, HelpMessage = "Password for the administrator account when the computer is started in Safe Mode.")]
  [Alias("SafeModeAdministratorPassword")]
  [String]$Safe_Mode_Pwd = "",
  [Parameter(Mandatory = $True, HelpMessage = "Fully qualified domain name (FQDN) for the root domain in the forest.")]
  [Alias("DomainName")]
  [String]$Domain_Name = "",
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

Add-Content c:\dc-config-log.txt "Executing 01-configure-dc.ps1"
Add-Content c:\dc-config-log.txt "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Expanding Zipped Content File"
Expand-Archive .\dc-configuration-content.zip -DestinationPath ".\Content" -Force
$currentDir = Get-Location | select -ExpandProperty Path
Add-Content c:\dc-config-log.txt "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Setting up task to run $($PSScriptRoot)\02-configure-dc.ps1"
$A = New-ScheduledTaskAction -Execute "cmd" -Argument "/c powershell.exe -ExecutionPolicy Unrestricted -File $PSScriptRoot\02-configure-dc.ps1 -SafeModeAdministratorPassword $Safe_Mode_Pwd -DomainName $Domain_Name -User $strUser -Password $strPass -DomainPrefix $Domain_Prefix >> c:\dc-config-log.txt"
$T = New-ScheduledTaskTrigger -Once -At (get-date).AddSeconds(180); $t.EndBoundary = (get-date).AddSeconds(240).ToString('s')
$S = New-ScheduledTaskSettingsSet -StartWhenAvailable #-DeleteExpiredTaskAfter 00:00:30
Register-ScheduledTask -Force -User "SYSTEM" -RunLevel "Highest" -TaskName "DC Script 2" -Action $A -Trigger $T -Settings $S
Sleep -Seconds 10

Get-ScheduledTask -TaskName "DC Script 2"