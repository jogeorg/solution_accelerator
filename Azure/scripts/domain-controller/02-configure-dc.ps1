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

echo "Executing 02-configure-dc.ps1"

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Adding AD Role to Server"
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Sleep -Seconds 10

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Adding Remote Server Administration Tools"
Install-WindowsFeature RSAT
Sleep -Seconds 10

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Adding Active Directory Certificate Services (AD CS) Certification Authority (CA) role"
$params = @{
    CAType             = EnterpriseRootCa
    CryptoProviderName = "ECDSA_P256#Microsoft Software Key Storage Provider"
    KeyLength          = 256
    HashAlgorithmName  = SHA256
}
Install-AdcsCertificationAuthority @params
Install-AdcsOnlineResponder
Sleep -Seconds 10

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Adding Key Management Services"
Install-WindowsFeature -Name VolumeActivation -IncludeManagementTools
Set-NetFirewallRule -Name SPPSVC-In-TCP -Profile Domain,Private -Enabled True
Sleep -Seconds 10

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Creating simple AD Forest"
$Safe_Mode_Pwd_Secure = ConvertTo-SecureString $Safe_Mode_Pwd -AsPlainText -Force
Install-ADDSForest -DomainName $Domain_Name -InstallDNS -Force -NoRebootOnCompletion -SafeModeAdministratorPassword $Safe_Mode_Pwd_Secure

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Setting up task to run $($PSScriptRoot)\03-configure-dc.ps1"
$A = New-ScheduledTaskAction -Execute "cmd" -Argument "/c powershell.exe -ExecutionPolicy Unrestricted -File $PSScriptRoot\03-configure-dc.ps1 -User $strUser -Password $strPass -DomainPrefix $Domain_Prefix >> c:\dc-config-log.txt"
$T = New-ScheduledTaskTrigger -Once -At (get-date).AddSeconds(180); $t.EndBoundary = (get-date).AddSeconds(420).ToString('s')
$S = New-ScheduledTaskSettingsSet -StartWhenAvailable #-DeleteExpiredTaskAfter 00:00:30
Register-ScheduledTask -Force -User "SYSTEM" -RunLevel "Highest" -TaskName "DC Script 3" -Action $A -Trigger $T -Settings $S
Sleep -Seconds 10

Get-ScheduledTask -TaskName "DC Script 3"

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Rebooting from 02-configure-dc.ps1"
Restart-Computer -Force