Param (
 [Parameter(Mandatory = $True, HelpMessage = "What is the path to the folder containing the customization files?")]
 [Alias("Content")]
 [String]$strContentDirectory = "",
 [Parameter(Mandatory = $True, HelpMessage = "Specify the password for the <run as> user.")]
 [Alias("Password")]
 [String]$strPass = ""
)

echo "Executing 05-configure-dc.ps1"

# Import Active Directory Powershell Module
Import-Module ActiveDirectory | Out-Null
Sleep -Seconds 30

Import-Module GroupPolicy | Out-Null
Sleep -Seconds 30

$strNetwork = "NIPRNET"

# Schema GUID Values for Active Directory
$objADGUIDComputers = [System.GUID]"bf967a86-0de6-11d0-a285-00aa003049e2"
$objADGUIDiNetOrgPerson = [System.GUID]"4828cc14-1437-45bc-9b07-ad6f015e5f28"
$objADGUIDUsers = [System.GUID]"bf967aba-0de6-11d0-a285-00aa003049e2"
$objADGUIDGroups = [System.GUID]"bf967a9c-0de6-11d0-a285-00aa003049e2"
$objADGUIDContacts = [System.GUID]"5cb41ed0-0e4c-11d0-a286-00aa003049e2"
$objADGUIDOUs = [System.GUID]"bf967aa5-0de6-11d0-a285-00aa003049e2"

# System.Security.AccessControl AccessControlType Enumeration
$objACTAllow = [System.Security.AccessControl.AccessControlType]::Allow
$objACTDeny = [System.Security.AccessControl.AccessControlType]::Deny

# System.Security.AccessControl AuditFlags Enumeration
$objAFNone = [System.Security.AccessControl.AuditFlags]::None
$objAFSuccess = [System.Security.AccessControl.AuditFlags]::Success
$objAFFailure = [System.Security.AccessControl.AuditFlags]::Failure

# System.DirectorySecurityServices ActiveDirectorySecurityInheritance Enumeration
$objADSINone = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None
$objADSIAll = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All
$objADSIDecendents = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::Decendents
$objADSISelfAndChildren = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::SelfAndChildren
$objADSIChildren = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::Children

# System.DirectorySecurityServices ActiveDirectoryRights Enumeration
$objADRDelete = [System.DirectoryServices.ActiveDirectoryRights]::Delete
$objADRReadControl = [System.DirectoryServices.ActiveDirectoryRights]::ReadControl
$objADRWriteDacl = [System.DirectoryServices.ActiveDirectoryRights]::WriteDacl
$objADRWriteOwner = [System.DirectoryServices.ActiveDirectoryRights]::WriteOwner
$objADRSynchronize = [System.DirectoryServices.ActiveDirectoryRights]::Synchronize
$objADRAccessSystemSecurity = [System.DirectoryServices.ActiveDirectoryRights]::AccessSystemSecurity
$objADRGenericRead = [System.DirectoryServices.ActiveDirectoryRights]::GenericRead
$objADRGenericWrite = [System.DirectoryServices.ActiveDirectoryRights]::GenericWrite
$objADRGenericExecute = [System.DirectoryServices.ActiveDirectoryRights]::GenericExecute
$objADRGenericAll = [System.DirectoryServices.ActiveDirectoryRights]::GenericAll
$objADRCreateChild = [System.DirectoryServices.ActiveDirectoryRights]::CreateChild
$objADRDeleteChild = [System.DirectoryServices.ActiveDirectoryRights]::DeleteChild
$objADRListChildren = [System.DirectoryServices.ActiveDirectoryRights]::ListChildren
$objADRSelf = [System.DirectoryServices.ActiveDirectoryRights]::Self
$objADRReadProperty = [System.DirectoryServices.ActiveDirectoryRights]::ReadProperty
$objADRWriteProperty = [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty
$objADRDeleteTree = [System.DirectoryServices.ActiveDirectoryRights]::DeleteTree
$objADRListObject = [System.DirectoryServices.ActiveDirectoryRights]::ListObject
$objADRExtendedRight = [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight

# Connect Computer's Management Interface and Create Reference Object
$strComputerName = Get-Content env:ComputerName
$objComputer = [ADSI]"WinNT://$strComputerName"

# Get information about the current domain
$objRootDSE = [ADSI]"LDAP://RootDSE"
$strDomainDN = $objRootDSE.DefaultNamingContext
$strDomainFQDN = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
$strDomainShort = $strDomainFQDN.Split(".")[0].ToUpper()
$strDomainNETBIOS = $(Get-ADDomain -Identity $strDomainFQDN).NetBIOSName

### CONFIGURE/HARDEN DNS #######################################################

# Remove Root Hints Again (Required for Domain Controllers)
dnscmd /RecordDelete /RootHints "@" NS a.root-servers.net. /f
dnscmd /RecordDelete /RootHints "@" NS b.root-servers.net. /f 
dnscmd /RecordDelete /RootHints "@" NS c.root-servers.net. /f 
dnscmd /RecordDelete /RootHints "@" NS d.root-servers.net. /f 
dnscmd /RecordDelete /RootHints "@" NS e.root-servers.net. /f 
dnscmd /RecordDelete /RootHints "@" NS f.root-servers.net. /f 
dnscmd /RecordDelete /RootHints "@" NS g.root-servers.net. /f 
dnscmd /RecordDelete /RootHints "@" NS h.root-servers.net. /f 
dnscmd /RecordDelete /RootHints "@" NS i.root-servers.net. /f 
dnscmd /RecordDelete /RootHints "@" NS j.root-servers.net. /f 
dnscmd /RecordDelete /RootHints "@" NS k.root-servers.net. /f 
dnscmd /RecordDelete /RootHints "@" NS l.root-servers.net. /f 
dnscmd /RecordDelete /RootHints "@" NS m.root-servers.net. /f 
dnscmd /RecordDelete /RootHints a.root-servers.net. A 198.41.0.4 /f 
dnscmd /RecordDelete /RootHints b.root-servers.net. A 192.228.79.201 /f
dnscmd /RecordDelete /RootHints c.root-servers.net. A 192.33.4.12 /f
dnscmd /RecordDelete /RootHints d.root-servers.net. A 128.8.10.90 /f
dnscmd /RecordDelete /RootHints e.root-servers.net. A 192.203.230.10 /f
dnscmd /RecordDelete /RootHints f.root-servers.net. A 192.5.5.241 /f
dnscmd /RecordDelete /RootHints g.root-servers.net. A 192.112.36.4 /f
dnscmd /RecordDelete /RootHints h.root-servers.net. A 128.63.2.53 /f
dnscmd /RecordDelete /RootHints i.root-servers.net. A 192.36.148.17 /f
dnscmd /RecordDelete /RootHints j.root-servers.net. A 192.58.128.30 /f
dnscmd /RecordDelete /RootHints k.root-servers.net. A 193.0.14.129 /f
dnscmd /RecordDelete /RootHints l.root-servers.net. A 198.32.64.12 /f
dnscmd /RecordDelete /RootHints m.root-servers.net. A 202.12.27.33 /f

# Let the DNS server have time to process things
Sleep -Seconds 10

# Add DNS forwarders
# This value is needed to resolve Private DNS Zones in the JCF Environment
Add-DnsServerForwarder -IPAddress 168.63.129.16 -Passthru

# Let the DNS server have time to process things
Sleep -Seconds 10


### CREATE ACTIVE DIRECTORY ORGANIZATIONAL UNITS ###############################

# Create Top-Level Organizational Units
New-ADOrganizationalUnit -Name "Enterprise Services" -Path ([String]$strDomainDN) -ProtectedFromAccidentalDeletion $True

# Create the Enterprise Services Organizational Unit Structure
New-ADOrganizationalUnit -Name "Administration" -Path ([String]"OU=Enterprise Services," + $strDomainDN) -ProtectedFromAccidentalDeletion $True

# Create the Enterprise Services / Administration Organizational Unit Structure
New-ADOrganizationalUnit -Name "Contacts" -Path ([String]"OU=Administration,OU=Enterprise Services," + $strDomainDN) -ProtectedFromAccidentalDeletion $True
New-ADOrganizationalUnit -Name "Distribution Lists" -Path ([String]"OU=Administration,OU=Enterprise Services," + $strDomainDN) -ProtectedFromAccidentalDeletion $True
New-ADOrganizationalUnit -Name "Groups" -Path ([String]"OU=Administration,OU=Enterprise Services," + $strDomainDN) -ProtectedFromAccidentalDeletion $True
New-ADOrganizationalUnit -Name "Maintenance" -Path ([String]"OU=Administration,OU=Enterprise Services," + $strDomainDN) -ProtectedFromAccidentalDeletion $True
New-ADOrganizationalUnit -Name "Users" -Path ([String]"OU=Administration,OU=Enterprise Services," + $strDomainDN) -ProtectedFromAccidentalDeletion $True

# Create the Enterprise Services / Administration / Users Organizational Unit Structure
New-ADOrganizationalUnit -Name "Disabled" -Path ([String]"OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN) -ProtectedFromAccidentalDeletion $True
New-ADOrganizationalUnit -Name "Domain Administrators" -Path ([String]"OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN) -ProtectedFromAccidentalDeletion $True
New-ADOrganizationalUnit -Name "Enterprise Administrators" -Path ([String]"OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN) -ProtectedFromAccidentalDeletion $True
New-ADOrganizationalUnit -Name "Organization Administrators" -Path ([String]"OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN) -ProtectedFromAccidentalDeletion $True
New-ADOrganizationalUnit -Name "Shared Accounts" -Path ([String]"OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN) -ProtectedFromAccidentalDeletion $True

### UPDATE OU GROUP POLICY INHERITANCE #########################################

Set-GPInheritance -Target ([String]"OU=Maintenance,OU=Administration,OU=Enterprise Services,$strDomainDN") -IsBlocked Yes | Out-Null

### MOVE/RENAME DEFAULT/BUILT-IN OBJECTS ########################################

Move-ADObject ("CN=Administrator,CN=Users," + $strDomainDN) -TargetPath ("OU=Enterprise Administrators,OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Allowed RODC Password Replication Group,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Cert Publishers,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Denied RODC Password Replication Group,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=DnsAdmins,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=DnsUpdateProxy,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Domain Admins,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Domain Auditors,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Domain Computers,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Domain Controllers,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Domain Guests,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Domain Users,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Enterprise Admins,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Enterprise Read-only Domain Controllers,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Group Policy Creator Owners,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Guest,CN=Users," + $strDomainDN) -TargetPath ("OU=Disabled,OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=krbtgt,CN=Users," + $strDomainDN) -TargetPath ("OU=Disabled,OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Power Users,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=RAS and IAS Servers,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Read-only Domain Controllers,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=$strBackupAdminUsername,CN=Users," + $strDomainDN) -TargetPath ("OU=Enterprise Administrators,OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN)
Move-ADObject ("CN=Schema Admins,CN=Users," + $strDomainDN) -TargetPath ("OU=Groups,OU=Administration,OU=Enterprise Services," + $strDomainDN)

# Update AD Objects
Rename-ADObject ("CN=Administrator,OU=Enterprise Administrators,OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN) -NewName "(EA) Enterprise Administrator"
Rename-ADObject ("CN=$strBackupAdminUsername,OU=Enterprise Administrators,OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN) -NewName "(EA) Backup Enterprise Administrator"
Rename-ADObject ("CN=Guest,OU=Disabled,OU=Users,OU=Administration,OU=Enterprise Services," + $strDomainDN) -NewName "(DG) Enterprise Guest"

### CREATE UPN SUFFIX ##########################################################

If ($strNetwork -eq "NIPRNET") {
  Set-ADForest -UPNSuffixes @{Add = "mil" } -Identity ""
}
ElseIf ($strNetwork -eq "SIPRNET") {
  Set-ADForest -UPNSuffixes @{Add = "smil.mil" } -Identity ""
}

### ENABLE/DISABLE OPTIONAL FEATURES ###########################################

# Enable the Recycle Bin
Enable-ADOptionalFeature -Identity ("CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration," + $strDomainDN) -Scope ForestOrConfigurationSet -Target $strDomainFQDN -Server $strComputerName -Confirm:$False

### CREATE WMI FILTERS #########################################################

# Get the current date/time and format it for WMI Filter Strings
$objTime = (Get-Date).ToUniversalTime()
$strWMIDate = ($objTime.Year).ToString("0000") + ($objTime.Month).ToString("00") + ($objTime.Day).ToString("00") + ($objTime.Hour).ToString("00") + ($objTime.Minute).ToString("00") + ($objTime.Second).ToString("00") + "." + ($objTime.MilliSecond * 1000).ToString("000000") + "-000"
$strWMIAuthor = $("forward.ea@" + $strDomainFQDN)

# Define WMI Filters
$colWMIFilters = @(
  ('All Client Operating Systems', 'All Non-Server Operating Systems WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE ProductType="1"'),
  ('All Server Operating Systems', 'All Server Operating Systems WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE ProductType="2" OR ProductType="3"'),
  ('Microsoft Windows 2000', 'Microsoft Windows 2000 WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "5.0%" AND ProductType="1"'),
  ('Microsoft Windows XP', 'Microsoft Windows XP WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "5.1%" AND ProductType="1"'),
  ('Microsoft Windows Vista', 'Microsoft Windows Vista WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.0%" AND ProductType="1"'),
  ('Microsoft Windows 7', 'Microsoft Windows 7 WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.1%" AND ProductType="1"'),
  ('Microsoft Windows 8', 'Microsoft Windows 8 WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.2%" AND ProductType="1"'),
  ('Microsoft Windows 8.1', 'Microsoft Windows 8.1 WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.3%" AND ProductType="1"'),
  ('Microsoft Windows 8 and 8.1', 'Microsoft Windows 8 and 8.1 WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.3%" AND ProductType="1"'),
  ('Microsoft Windows 10', 'Microsoft Windows 10 WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.%" AND ProductType="1"'),
  ('Microsoft Windows Server 2000 (Domain Controller)', 'Microsoft Windows Server 2000 Domain Controller WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "5.0%" AND ProductType="2"'), 
  ('Microsoft Windows Server 2000 (Member Server)', 'Microsoft Windows Server 2000 Member Server WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "5.0%" AND ProductType="3"'), 
  ('Microsoft Windows Server 2003 (Domain Controller)', 'Microsoft Windows Server 2003 Domain Controller WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "5.2%" AND ProductType="2"'), 
  ('Microsoft Windows Server 2003 (Member Server)', 'Microsoft Windows Server 2003 Member Server WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "5.2%" AND ProductType="3"'), 
  ('Microsoft Windows Server 2008 (Domain Controller)', 'Microsoft Windows Server 2008 Domain Controller WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.0%" AND ProductType="2"'), 
  ('Microsoft Windows Server 2008 (Member Server)', 'Microsoft Windows Server 2008 Member Server WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.0%" AND ProductType="3"'), 
  ('Microsoft Windows Server 2008 R2 (Domain Controller)', 'Microsoft Windows Server 2008 R2 Domain Controller WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.1%" AND ProductType="2"'), 
  ('Microsoft Windows Server 2008 R2 (Member Server)', 'Microsoft Windows Server 2008 R2 Member Server WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.1%" AND ProductType="3"'), 
  ('Microsoft Windows Server 2012 (Domain Controller)', 'Microsoft Windows Server 2012 Domain Controller WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.2%" AND ProductType="2"'), 
  ('Microsoft Windows Server 2012 (Member Server)', 'Microsoft Windows Server 2012 Member Server WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.2%" AND ProductType="3"'), 
  ('Microsoft Windows Server 2012 R2 (Domain Controller)', 'Microsoft Windows Server 2012 R2 Domain Controller WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.3%" AND ProductType="2"'), 
  ('Microsoft Windows Server 2012 R2 (Member Server)', 'Microsoft Windows Server 2012 R2 Member Server WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.3%" AND ProductType="3"'),
  ('Microsoft Windows Server 2016 (Domain Controller)', 'Microsoft Windows Server 2016 Domain Controller WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.0.14393" AND ProductType="2"'), 
  ('Microsoft Windows Server 2016 (Member Server)', 'Microsoft Windows Server 2016 Member Server WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.0.14393" AND ProductType="3"'), 
  ('Microsoft Windows Server 2019 (Domain Controller)', 'Microsoft Windows Server 2019 Domain Controller WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.0.17763" AND ProductType="2"'), 
  ('Microsoft Windows Server 2019 (Member Server)', 'Microsoft Windows Server 2019 Member Server WMI Filter', 'SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.0.17763" AND ProductType="3"') 
  
)

# Create the blank LDIFDE string
$strLDIFDE = ""

for ($i = 0; $i -lt $colWMIFilters.Count; $i++) {
  $strWMIGUID = [String]"{" + ([System.Guid]::NewGuid()) + "}"
  $strWMIDN = "CN=" + $strWMIGUID + ",CN=SOM,CN=WMIPolicy,CN=System," + $strDomainDN
  $strWMIName = [String]$colWMIFilters[$i][0]
  $strWMIDesc = [String]$colWMIFilters[$i][1]
  $strWMICode = [String]$colWMIFilters[$i][2]
  $strWMILen = $strWMICode.Length.ToString()

  # Create the WMI Filter LDIFDE string
  $strLDIFDE = $strLDIFDE + @"

dn: $strWMIDN
changetype: add
objectClass: top
objectClass: msWMI-Som
cn: $strWMIGUID
distinguishedName: $strWMIDN
instanceType: 4
showInAdvancedViewOnly: TRUE
name: $strWMIGUID
objectCategory: CN=ms-WMI-Som,CN=Schema,CN=Configuration,$strDomainDN
msWMI-Author: $strWMIAuthor
msWMI-ID: $strWMIGUID
msWMI-Name: $strWMIName
msWMI-Parm1: $strWMIDesc
msWMI-Parm2: 1;3;10;$strWMILen;WQL;root\CIMv2;$strWMICode;

"@
}

# Output LDIFDE to a text file and execute the import
$strLDIFDE | Out-File "C:\DENT-BUILD\GPOBackups\DENTLDIFDE.txt"
ldifde -i -f "C:\DENT-BUILD\GPOBackups\DENTLDIFDE.txt" | Out-Null

### IMPORT GPOs ################################################################

# Update the GPO XML files with information on users and groups from the new
# domain. This is done because the GPMC migration table cannot handle Microsoft
# Active Directory Group Policy Extensions

# Update the GPReport.XML portion of the GPO backup
$colGPOReports = Get-ChildItem "$strContentDirectory\GPOBackups\*" -Recurse -Include "gpreport.xml"

ForEach ($objGPOReportXML In $ColGPOReports) {
  $objGPOXML = New-Object System.Xml.XmlDocument
  $objGPOXML.Load($objGPOReportXML.FullName)

  # Establish the Namespace for GPOReports.XML
  $xmlNSManager = New-Object System.Xml.XmlNamespaceManager $objGPOXML.CreateNavigator().NameTable
  $xmlNSManager.AddNamespace("E", "http://www.microsoft.com/GroupPolicy/Settings")
  $xmlNSManager.AddNamespace("U", "http://www.microsoft.com/GroupPolicy/Settings/Lugs")

  $colGroups = $objGPOXML.SelectNodes("//U:LocalUsersAndGroups/U:Group", $xmlNSManager)
  ForEach ($objGroup In $colGroups) {
    $colMembers = $objGroup.SelectNodes("U:Properties/U:Members/U:Member", $xmlNSManager)
    ForEach ($objMember In $colMembers) {
      Switch ($objMember.GetAttribute("name")) {
        # Update Groups Exported from the DEMO/DEV Datacenter(s) (Alpha/Beta Testing)

        "DEMO\Domain Auditors" {
          $strADOBJName = "Domain Auditors"
          $objADOBJ = New-Object System.Security.Principal.NTAccount($strADOBJName)
          $objADOBJSID = $objADOBJ.Translate([System.Security.Principal.SecurityIdentifier])
          $objMember.SetAttribute("name", ([String]$strDomainNETBIOS + "\" + $strADOBJName))
          $objMember.SetAttribute("sid", ([String]$objADOBJSID))
        }

        "MIEDEV\Domain Auditors" {
          $strADOBJName = "Domain Auditors"
          $objADOBJ = New-Object System.Security.Principal.NTAccount($strADOBJName)
          $objADOBJSID = $objADOBJ.Translate([System.Security.Principal.SecurityIdentifier])
          $objMember.SetAttribute("name", ([String]$strDomainNETBIOS + "\" + $strADOBJName))
          $objMember.SetAttribute("sid", ([String]$objADOBJSID))
        }
      }
    }
  }
  
  $objGPOXML.Save($objGPOReportXML.FullName)
}

# Update the Groups.XML portion of the GPO backup
$colGPOReports = Get-ChildItem "$strContentDirectory\GPOBackups\*" -Recurse -Include "groups.xml"
ForEach ($objGPOReportXML In $ColGPOReports) {
  $objGPOXML = New-Object System.Xml.XmlDocument
  $objGPOXML.Load($objGPOReportXML.FullName)

  $colGroups = $objGPOXML.SelectNodes("/Groups/Group")
  ForEach ($objGroup In $colGroups) {
    $colMembers = $objGroup.SelectNodes("Properties/Members/Member")
    ForEach ($objMember In $colMembers) {
      Switch ($objMember.GetAttribute("name")) {
        # Update Groups Exported from the DEMO/DEV Datacenter(s) (Alpha/Beta Testing)

        "DEMO\Domain Auditors" {
          $strADOBJName = "Domain Auditors"
          $objADOBJ = New-Object System.Security.Principal.NTAccount($strADOBJName)
          $objADOBJSID = $objADOBJ.Translate([System.Security.Principal.SecurityIdentifier])
          $objMember.SetAttribute("name", ([String]$strDomainNETBIOS + "\" + $strADOBJName))
          $objMember.SetAttribute("sid", ([String]$objADOBJSID))
        }
		
        "MIEDEV\Domain Auditors" {
          $strADOBJName = "Domain Auditors"
          $objADOBJ = New-Object System.Security.Principal.NTAccount($strADOBJName)
          $objADOBJSID = $objADOBJ.Translate([System.Security.Principal.SecurityIdentifier])
          $objMember.SetAttribute("name", ([String]$strDomainNETBIOS + "\" + $strADOBJName))
          $objMember.SetAttribute("sid", ([String]$objADOBJSID))
        }    
      }
    }
  }

  # Save the file
  $objGPOXML.Save($objGPOReportXML.FullName)
}

# Construct the GPMC Management Objects
$objGPM = New-Object -Com gpmgmt.gpm
$objGPMConstants = $objGPM.GetConstants()
$objGPMDomain = $objGPM.GetDomain($strDomainFQDN, $Null, $objGPMConstants.UseAnyDC)
$objGPMBackups = $objGPM.GetBackupDir("$strContentDirectory\GPOBackups")
$objGPMSOM = $objGPMDomain.GetSOM($strDomainDN)

# Construct the GPO Migration Table

# Update Groups Exported from the DEMO/DEV Datacenter(s) (Alpha/Beta Testing)
$objGPMMigration = $objGPM.CreateMigrationTable()
$objGPMMigration.AddEntry("DEMO\Domain Auditors", $objGPMConstants.EntryTypeLocalGroup, $($strDomainNETBIOS + "\Domain Auditors"))
$objGPMMigration.AddEntry("MIEDEV\Domain Auditors", $objGPMConstants.EntryTypeLocalGroup, $($strDomainNETBIOS + "\Domain Auditors"))

# Disable Default GPO Links
#$colGPOLinks = $($objGPMDomain.GetSOM($strDomainDN)).GetGPOLinks()
#ForEach ($objGPOLink In $colGPOLinks) {
#  $objGPOLink.Delete()
#}

#$colGPOLinks = $($objGPMDomain.GetSOM(("OU=Domain Controllers," + $strDomainDN))).GetGPOLinks()
#ForEach ($objGPOLink In $colGPOLinks) {
#  $objGPOLink.Delete()
#}

# Disable Default GPO Settings
#$objDOMGPOSearch = $objGPM.CreateSearchCriteria()
#$objDOMGPOSearch.Add($objGPMConstants.SearchPropertyGPODisplayName,$objGPMConstants.SearchOpContains,"Default")
#$colGPOs = $objGPMDomain.SearchGPOs($objDOMGPOSearch)
#ForEach ($objGPO in $colGPOs) {
#  $objGPO.SetComputerEnabled($False)
#  $objGPO.SetUserEnabled($False)
#}

# Search the GPO backups and build a list of names
$objBUPGPOSearch = $objGPM.CreateSearchCriteria()
$objBUPGPOSearch.Add($objGPMConstants.SearchPropertyGPODisplayName, $objGPMConstants.SearchOpContains, "")
$colGPOs = $objGPMBackups.SearchBackups($objBUPGPOSearch)

# Create a blank GPO object and import the settings from the backup
ForEach ($objGPOBUP in $colGPOs) {
  $objNewGPO = $objGPMDomain.CreateGPO()
  $objNewGPO.DisplayName = $objGPOBUP.GPODisplayName
  $objResult = $objNewGPO.Import(0, $objGPOBUP, $objGPMMigration)
  
  # Set the WMI Filter associated with the GPO
  Switch ($objNewGPO.DisplayName) {

    "DoD Windows Server 2012 R2 Member Server STIG User v2r18" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2012 R2 (Member Server)") {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows Server 2012 R2 Member Server STIG Computer v2r18" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2012 R2 (Member Server)") {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows Server 2012 R2 Domain Controller STIG User v2r20" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2012 R2 (Domain Controller)") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows Server 2012 R2 Domain Controller STIG Computer v2r20" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2012 R2 (Domain Controller)") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows Server 2016 Member Server STIG User v1r11" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2016 (Member Server)") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows Server 2016 Member Server STIG Computer v1r11" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2016 (Member Server)") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows Server 2016 Domain Controller STIG User v1r11" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2016 (Domain Controller)") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }
  
    "DoD Windows Server 2016 Domain Controller STIG Computer v1r11" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2016 (Domain Controller)") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows Server 2019 Member Server STIG User v1r4" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2019 (Member Server)") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows Server 2019 Member Server STIG Computer v1r4" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2019 (Member Server)") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows Server 2019 Domain Controller STIG User v1r4" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2019 (Domain Controller)") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows Server 2019 Domain Controller STIG Computer v1r4" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows Server 2019 (Domain Controller)") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows 8 and 8.1 STIG User v1r22" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows 8 and 8.1") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows 8 and 8.1 STIG Computer v1r22" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows 8 and 8.1") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows 10 STIG User v1r22" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows 10") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

    "DoD Windows 10 STIG Computer v1r22" {
      # Associate the correct WMI filter to the GPO
      $objWMIFilterSearch = $objGPM.CreateSearchCriteria()
      $colWMIFilters = $objGPMDomain.SearchWMIFilters($objWMIFilterSearch)
      ForEach ($objWMIFilter in $colWMIFilters) {
        If ($objWMIFilter.Name -eq "Microsoft Windows 10") 
        {
          $objNewGPO.SetWMIFilter($objWMIFilter)
          Break
        }
      }
    }

  }
}

# $Attributes = @{
#    Enabled = $true
#    ChangePasswordAtLogon = $true
#    UserPrincipalName = "test"
#    Name = "Test.Person"
#    GivenName = "Test"
#    Surname = "Person"
#    DisplayName = "Test"
#    Description = "This is the account for test"
#    Office = "No office for test person."

#    Company = $Domain_Name
#    Department = "IT"
#    Title = "Some Person"
#    City = "Salt Lake City"
#    State = "Utah"

#    AccountPassword = $strPass | ConvertTo-SecureString -AsPlainText -Force

# }

# New-ADUser @Attributes

Sleep -Seconds 30

# START Uncomment the following lines to link the GPOs this was left commented out during development to allow for RDP connections
# # Reset the GPO link Order 
# $intGPOLinkOrder = 1

# # Link the GPOs and put them in the correct stacking order

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Internet Explorer 11 STIG User v1r19" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Internet Explorer 11 STIG Computer v1r19" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Google Chrome STIG Computer v1r19" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Defender Antivirus STIG Computer v1r9" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Firewall STIG v1r7" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows 8 and 8.1 STIG User v1r22" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows 8 and 8.1 STIG Computer v1r22" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows 10 STIG User v1r22" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows 10 STIG Computer v1r22" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2012 R2 Member Server STIG User v2r18" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2012 R2 Member Server STIG Computer v2r18" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2012 R2 Domain Controller STIG User v2r20" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2012 R2 Domain Controller STIG Computer v2r20" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2016 Member Server STIG User v1r11" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2016 Member Server STIG Computer v1r11" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2016 Domain Controller STIG User v1r11" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2016 Domain Controller STIG Computer v1r11" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2019 Member Server STIG User v1r4" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2019 Member Server STIG Computer v1r4" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2019 Domain Controller STIG User v1r4" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }

# If (New-GPLink -Order $intGPOLinkOrder -Name "DoD Windows Server 2019 Domain Controller STIG Computer v1r4" -Target "$strDomainDN" -LinkEnabled Yes) {
#   $intGPOLinkOrder = $intGPOLinkOrder + 1
# }
# END Uncomment the following lines to link the GPOs this was left commented out during development to allow for RDP connections

# Remove Autologon Information
Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultUserName' -Force
Remove-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultPassword' -Force

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Rebooting from 05-configure-dc.ps1"

Restart-Computer -Force