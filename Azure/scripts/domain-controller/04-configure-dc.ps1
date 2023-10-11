Param (
 [Parameter(Mandatory = $True, HelpMessage = "What is the path to the folder containing the customization files?")]
 [Alias("Content")]
 [String]$strContentDirectory = "",
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

echo "Executing 04-configure-dc.ps1"

# Import Active Directory Powershell Module
Import-Module ActiveDirectory | Out-Null
Sleep -Seconds 30

Import-Module GroupPolicy | Out-Null
Sleep -Seconds 30

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

### DISA STIG V-3487 (Unnecessary Services) ####################################

# Set the Active Directory Domain Services Services to Automatic
Try {
  Set-Service "NTDS" -StartupType "Automatic"
} Catch {
  Write-Host "Service is not installed"
}

# Set the Active Directory Web Services to Automatic
Try {
  Set-Service "ADWS" -StartupType "Automatic"
} Catch {
  Write-Host "Service is not installed"
}

# Set the DFS Namespace Services to Automatic
Try {
  Set-Service "Dfs" -StartupType "Automatic"
} Catch {
  Write-Host "Service is not installed"
}

# Set the DFS Replication Services to Automatic
Try {
  Set-Service "DFSR" -StartupType "Automatic"
} Catch {
  Write-Host "Service is not installed"
}

# Set the DNS Server Services to Automatic
Try {
  Set-Service "DNS" -StartupType "Automatic"
} Catch {
  Write-Host "Service is not installed"
}

# Set the Intersite Messaging Services to Automatic
Try {
  Set-Service "IsmServ" -StartupType "Automatic"
} Catch {
  Write-Host "Service is not installed"
}

# Set the Kerberos Key Distribution Center Services to Automatic
Try {
  Set-Service "KDC" -StartupType "Automatic"
} Catch {
  Write-Host "Service is not installed"
}

# Set the Net.Tcp Port Sharing Service to Disabled
Try {
  Set-Service "NetTcpPortSharing" -StartupType "Disabled"
} Catch {
  Write-Host "Service is not installed"
}

# Set the Windows CardSpace Services to Manual
Try {
  Set-Service "idsvc" -StartupType "Manual"
} Catch {
  Write-Host "Service is not installed"
}

# Set the Windows Presentation Foundation Font Cache 3.0.0.0 Services to Manual
Try {
  Set-Service "FontCache3.0.0.0" -StartupType "Manual"
} Catch {
  Write-Host "Service is not installed"
}

### DISA STIG V-8316 (Directory Data File Access Permissions) ##################
$objACL = New-Object System.Security.AccessControl.DirectorySecurity
$objACL.SetAccessRuleProtection($True,$False)
$objACL.SetAuditRuleProtection($True,$False)

# Construct the Access Control Rules
$objUser = New-Object System.Security.Principal.NTAccount("Administrators")
$objACLRule = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser,"FullControl","ContainerInherit,ObjectInherit","None","Allow")
$objACL.AddAccessRule($objACLRule)

$objUser = New-Object System.Security.Principal.NTAccount("SYSTEM")
$objACLRule = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser,"FullControl","ContainerInherit,ObjectInherit","None","Allow")
$objACL.AddAccessRule($objACLRule)

# Audit Failures 
$objACLRule = New-Object System.Security.AccessControl.FileSystemAuditRule("Everyone","FullControl","ContainerInherit,ObjectInherit","None","Failure")
$objACL.AddAuditRule($objACLRule)

# Audit Non-Routine Behavior on Active Directory Files
$objACLRule = New-Object System.Security.AccessControl.FileSystemAuditRule("Everyone","ChangePermissions,Delete,DeleteSubdirectoriesAndFiles,TakeOwnership,WriteExtendedAttributes","ContainerInherit,ObjectInherit","None","Success")
$objACL.AddAuditRule($objACLRule)

# Set the ACL for Active Directory Folders and Files
Get-ChildItem "C:\Windows\NTDS" -Recurse -Force | Set-Acl -AclObject $objACL
Get-ChildItem "C:\Windows\NTDS" -Recurse -Include *.log -Force | Set-Acl -AclObject $objACL

### DISA STIG V-14831 (Inactive Server Connections) ############################
ntdsutil "ldap policies" "connections" ("connect to server " + $env:COMPUTERNAME) "q" "set MaxConnIdleTime to 300" "commit changes" "q" "q"

### DISA STIG V-4243 (Directory Data Object Auditing) ##########################

# +--------------------------------------------------------------------------+ #
# | Domain Object Audit Settings                                             | #
# +--------------------------------------------------------------------------+ #

Try {
  $objADOBJ = [ADSI]("LDAP://$strDomainDN")
  
  $objADOBJACL = $objADOBJ.psbase.ObjectSecurity
  $objADACL = New-Object System.DirectoryServices.ActiveDirectorySecurity
  $objADACL.SetSecurityDescriptorSddlForm(($objADOBJACL.GetSecurityDescriptorSddlForm([System.Security.AccessControl.AccessControlSections]::ALL)))
  $objADACL.SetAuditRuleProtection($True,$False)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRGenericAll,$objAFFailure,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteProperty,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteDacl,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteOwner,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Administrators")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRExtendedRight,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Domain Users")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRExtendedRight,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objADOBJ.ObjectSecurity = $objADACL
  $objADOBJ.psbase.CommitChanges()
} Catch {
  Write-Host "Could not update the ACL for the Domain object"
} 

# +--------------------------------------------------------------------------+ #
# | Infrastructure Object Audit Settings                                     | #
# +--------------------------------------------------------------------------+ #

Try {
  $objADOBJ = [ADSI]("LDAP://CN=Infrastructure,$strDomainDN")
  
  $objADOBJACL = $objADOBJ.psbase.ObjectSecurity
  $objADACL = New-Object System.DirectoryServices.ActiveDirectorySecurity
  $objADACL.SetSecurityDescriptorSddlForm(($objADOBJACL.GetSecurityDescriptorSddlForm([System.Security.AccessControl.AccessControlSections]::ALL)))
  $objADACL.SetAuditRuleProtection($True,$False)
 
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRGenericAll,$objAFFailure,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRExtendedRight,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteProperty,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objADOBJ.ObjectSecurity = $objADACL
  $objADOBJ.psbase.CommitChanges()
} Catch {
  Write-Host "Could not update the ACL for the Infrastructure object"
} 

# +--------------------------------------------------------------------------+ #
# | AdminSDHolder Object Audit Settings                                      | #
# +--------------------------------------------------------------------------+ #

Try {
  $objADOBJ = [ADSI]("LDAP://CN=AdminSDHolder,CN=System,$strDomainDN")
  
  $objADOBJACL = $objADOBJ.psbase.ObjectSecurity
  $objADACL = New-Object System.DirectoryServices.ActiveDirectorySecurity
  $objADACL.SetSecurityDescriptorSddlForm(($objADOBJACL.GetSecurityDescriptorSddlForm([System.Security.AccessControl.AccessControlSections]::ALL)))
  $objADACL.SetAuditRuleProtection($True,$False)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRGenericAll,$objAFFailure,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteDacl,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteOwner,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteProperty,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objADOBJ.ObjectSecurity = $objADACL
  $objADOBJ.psbase.CommitChanges()
} Catch {
  Write-Host "Could not update the ACL for the AdminSDHelper object"
} 

# +--------------------------------------------------------------------------+ #
# | RID Manager$ Object Audit Settings                                       | #
# +--------------------------------------------------------------------------+ #

Try {
  $objADOBJ = [ADSI]("LDAP://CN=RID Manager$,CN=System,$strDomainDN")
  
  $objADOBJACL = $objADOBJ.psbase.ObjectSecurity
  $objADACL = New-Object System.DirectoryServices.ActiveDirectorySecurity
  $objADACL.SetSecurityDescriptorSddlForm(($objADOBJACL.GetSecurityDescriptorSddlForm([System.Security.AccessControl.AccessControlSections]::ALL)))
  $objADACL.SetAuditRuleProtection($True,$False)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRGenericAll,$objAFFailure,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRExtendedRight,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteProperty,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objADOBJ.ObjectSecurity = $objADACL
  $objADOBJ.psbase.CommitChanges()
} Catch {
  Write-Host "Could not update the ACL for the RID Manager$ Objects object"
} 

# +--------------------------------------------------------------------------+ #
# | Domain Controllers Object Audit Settings                                 | #
# +--------------------------------------------------------------------------+ #

Try {
  $objADOBJ = [ADSI]("LDAP://OU=Domain Controllers,$strDomainDN")
  
  $objADOBJACL = $objADOBJ.psbase.ObjectSecurity
  $objADACL = New-Object System.DirectoryServices.ActiveDirectorySecurity
  $objADACL.SetSecurityDescriptorSddlForm(($objADOBJACL.GetSecurityDescriptorSddlForm([System.Security.AccessControl.AccessControlSections]::ALL)))
  $objADACL.SetAuditRuleProtection($True,$False)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRGenericAll,$objAFFailure,$objADSIAll)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteProperty,$objAFSuccess,$objADSIAll)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteDacl,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteOwner,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRCreateChild,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRDelete,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRDeleteChild,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRDeleteTree,$objAFSuccess,$objADSINone)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objADOBJ.ObjectSecurity = $objADACL
  $objADOBJ.psbase.CommitChanges()
} Catch {
  Write-Host "Could not update the ACL for the Domain Controllers object"
} 

# +--------------------------------------------------------------------------+ #
# | Group Policy Object Audit Settings                                       | #
# +--------------------------------------------------------------------------+ #

Try {
  $objADOBJ = [ADSI]("LDAP://CN=Policies,CN=System,$strDomainDN")
  
  $objADOBJACL = $objADOBJ.psbase.ObjectSecurity
  $objADACL = New-Object System.DirectoryServices.ActiveDirectorySecurity
  $objADACL.SetSecurityDescriptorSddlForm(($objADOBJACL.GetSecurityDescriptorSddlForm([System.Security.AccessControl.AccessControlSections]::ALL)))
  $objADACL.SetAuditRuleProtection($True,$False)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRGenericAll,$objAFFailure,$objADSIAll)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteProperty,$objAFSuccess,$objADSIChildren)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objUser = New-Object System.Security.Principal.NTAccount("Everyone")
  $objADOBJAuditRule = New-Object System.DirectoryServices.ActiveDirectoryAuditRule($objUser,$objADRWriteDacl,$objAFSuccess,$objADSIChildren)
  $objADACL.AddAuditRule($objADOBJAuditRule)
  
  $objADOBJ.ObjectSecurity = $objADACL
  $objADOBJ.psbase.CommitChanges()
} Catch {
  Write-Host "Could not update the ACL for the Group Policy Objects object"
} 

### CREATE CENTRAL POLICY STORE ################################################

# Copy the Customization Files From the Network to the Local Computer
Try {
  New-Item "C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions" -Type Directory
  Copy-Item -Path "$strContentDirectory\*" -Recurse -Destination "C:\Windows\SYSVOL\domain\Policies\PolicyDefinitions" -Force
} Catch {
  Write-Host "Failed: Could not create/populate Central Policy Definition Store"
  If ($strIsDebug -eq "Y") {
    Write-EventLog -LogName "Setup" -Source "Deployable Enterprise Toolkit" -EventID 1001 -EntryType "Error" -Message "Failed: Could not create/populate Central Policy Definition Store"
  }
}

# Allow WMI Filter Changes using LDIFDE (Import is part of Phase 04)
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\NTDS\Parameters" -Name "Allow System Only Change" -Value 1 -propertyType dword

### CONFIGURE/HARDEN DNS #######################################################
dnscmd /ResetForwarders
dnscmd /config /bootmethod 3
dnscmd /config /defaultagingstate 1
dnscmd /config /disableautoreversezones 0
dnscmd /config /disablensrecordsautocreation 0
dnscmd /config /enablednssec 1
dnscmd /config /eventloglevel 4
dnscmd /config /isslave 0
dnscmd /config /localnetpriority 1
dnscmd /config /logfilemaxsize 0x320000 
dnscmd /config /logfilepath "C:\Windows\System32\Winevt\Logs\MSDNS.txt" 
dnscmd /config /loglevel 0xFFFF
dnscmd /config /norecursion 0
dnscmd /config /scavenginginterval 0xC
dnscmd /config /sendport 0x35

# Let the DNS server have time to process things
Sleep -Seconds 10

# Remove Root Hints
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

# Stop DNS Server
net stop dns

# Remove the Root Hints from AD
$objRootHint = [ADSI]$("LDAP://DC=a.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=b.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=c.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=d.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=e.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=f.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=g.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=h.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=i.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=j.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=k.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=l.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)

$objRootHint = [ADSI]$("LDAP://DC=m.root-servers.net,DC=RootDNSServers,CN=MicrosoftDNS,CN=System," + $strDomainDN)
$objRootHint.DeleteObject(0)


# Remove the DNS Cache File
Remove-Item C:\Windows\System32\dns\cache.dns -Force

# Remove the Backup DNS Cache File
Try {
    Remove-Item C:\Windows\System32\dns\backup\cache.dns -Force    
} Catch {
    Write-Host "Backup DNS Cache File not found."
}

# Rebuild the DNS Cache File (without the root hints)
$strDNSCache = ";`r`n; End of File"
$strDNSCache | Out-File -Encoding "ASCII" -Force "C:\Windows\System32\dns\cache.dns"

# Rebuild the Backup DNS Cache File (without the root hints)
$strDNSCache = ";`r`n; End of File"
$strDNSCache | Out-File -Encoding "ASCII" -Force "C:\Windows\System32\dns\backup\cache.dns"

# Set the ACL on DNS System Folder
$objACL = New-Object System.Security.AccessControl.DirectorySecurity

$objACL.SetAccessRuleProtection($True,$False)
$objACL.SetAuditRuleProtection($True,$False)

$objUser = New-Object System.Security.Principal.NTAccount("Administrators")
$objACLRule = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser,"FullControl","ContainerInherit,ObjectInherit","None","Allow")
$objACL.AddAccessRule($objACLRule)

$objUser = New-Object System.Security.Principal.NTAccount("SYSTEM")
$objACLRule = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser,"FullControl","ContainerInherit,ObjectInherit","None","Allow")
$objACL.AddAccessRule($objACLRule)

$objACLRule = New-Object System.Security.AccessControl.FileSystemAuditRule("Everyone","FullControl","ContainerInherit,ObjectInherit","None","Failure")
$objACL.AddAuditRule($objACLRule)

$objACLRule = New-Object System.Security.AccessControl.FileSystemAuditRule("Everyone","ChangePermissions,Delete,DeleteSubdirectoriesAndFiles,TakeOwnership,WriteExtendedAttributes","ContainerInherit,ObjectInherit","None","Success")
$objACL.AddAuditRule($objACLRule)

$objUser = New-Object System.Security.Principal.NTAccount("Administrators")
$objACL.SetOwner($objUser)

$objACL | Set-Acl "C:\Windows\System32\dns"

# Let the DNS server have time to process things
Sleep -Seconds 30

# Restart DNS
net start dns
Sleep -Seconds 10

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Setting up task to run $($PSScriptRoot)\05-configure-dc.ps1"
$A = New-ScheduledTaskAction -Execute "cmd" -Argument "/c powershell.exe -ExecutionPolicy Unrestricted -File $PSScriptRoot\05-configure-dc.ps1 -Password $strPass -Content $PSScriptRoot\Content >> c:\dc-config-log.txt"
$T = New-ScheduledTaskTrigger -Once -At (get-date).AddSeconds(180); $t.EndBoundary = (get-date).AddSeconds(420).ToString('s')
$S = New-ScheduledTaskSettingsSet -StartWhenAvailable #-DeleteExpiredTaskAfter 00:00:30
Register-ScheduledTask -Force -User "$Domain_Prefix\$strUser" -Password "$strPass" -RunLevel "Highest" -TaskName "DC Script 5" -Action $A -Trigger $T -Settings $S
Sleep -Seconds 10

Get-ScheduledTask -TaskName "DC Script 5"

echo "$(Get-Date -Format "MM/dd/yyyy HH:mm K") Rebooting from 04-configure-dc.ps1"
Restart-Computer -Force