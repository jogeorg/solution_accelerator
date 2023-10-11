Param (
  [Parameter(Mandatory = $True, HelpMessage = "Domain administrator login for the domain (i.e domain-fqdn\domain-admin-username).")]
  [String]$Domain_Admin = "",
  [Parameter(Mandatory = $True, HelpMessage = "Fully qualified domain name (FQDN) for the root domain in the forest.")]
  [String]$Domain_Name = "",
  [Parameter(Mandatory = $True, HelpMessage = "The password for the domain adminstrator user.")]
  [String]$AD_Password = ""
)

echo "domain-join.ps1 Params: Domain_Admin: $($Domain_Admin) | Domain_Name: $($Domain_Name)"

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Adding Server to AD Domain"
$securePassword = $AD_Password | ConvertTo-SecureString -asPlainText -Force
$username = $Domain_Admin
$credential = New-Object System.Management.Automation.PSCredential($username,$securePassword)

Add-Computer -DomainName $Domain_Name -Credential $credential -force -Restart

Get-ScheduledTask -TaskName "Domain Join"

set-ExecutionPolicy -ExecutionPolicy restricted -Force