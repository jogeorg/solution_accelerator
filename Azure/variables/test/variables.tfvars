rg_name = "TEST_RG"
tags = {
  name       = "TEST"
  project    = "NETCOM"
  workstream = "TEST"
  costcenter = "1500"
}

nsg_name = "TEST_NSG"
security_rule = [{
    name                       = "allow-rdp"
    priority                   = "1001"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
}]

storage_accountname         = "teststorageact"
storage_accounttier         = "Standard"
storage_accountreplication  = "LRS"
storage_accountkind         = "StorageV2"
storage_accesstier          = "Hot"