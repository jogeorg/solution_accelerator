locals {
  vm_ids_map = {
    for vm in azurerm_windows_virtual_machine.windows_dc :
    vm.name => vm.id
  }

  msi_enabled_windows_dc = [
    for vm_k, vm_v in var.windows_dc :
    vm_v if coalesce(lookup(vm_v, "assign_identity"), false) == true
  ]

  vm_principal_ids = flatten([
    for x in azurerm_windows_virtual_machine.windows_dc :
    [
      for y in x.identity :
      y.principal_id if y.principal_id != ""
    ] if length(keys(azurerm_windows_virtual_machine.windows_dc)) > 0
  ])

  # dc_IPs = flatten([
  #   for nic_k, nic_v in azurerm_network_interface.windows_nics : 
  #   nic_v.private_ip_address if(contains(each.value["vm_nic_keys"], nic_k) == true)])
}

# data "external" "set-azure-dns" {
#   program = ["/bin/sh", "../scripts/azure-dns.sh"]
#   query = {
#     client_id           = var.client_id
#     client_secret       = data.azurerm_key_vault_secret.secret.value
#     tenant_id           = var.tenant
#     environment         = var.environment
#     subscription_id     = var.subscription
#     resource_group_name = data.azurerm_resource_group.rg.name
#     vnet_name           = var.vnet_name
#   }
# }

data "azurerm_key_vault" "core_kv" {
  name = var.key_vault_name
  resource_group_name = var.kv_resource_group
}

data "azurerm_subnet" "this" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.kv_resource_group
}

data "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  resource_group_name = var.kv_resource_group
}

data "azurerm_key_vault_secret" "winAdmin" {
  for_each     = var.windows_dc
  name         = each.key
  key_vault_id = data.azurerm_key_vault.core_kv.id
}

data "azurerm_key_vault_secret" "secret" {
  name         = "ADO-SP"
  key_vault_id = data.azurerm_key_vault.core_kv.id
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_storage_account" "team_storage" {
  name = var.storage_accountname
  resource_group_name = var.rg_name
}

resource "azurerm_windows_virtual_machine" "windows_dc" {
  for_each            = var.windows_dc
  name                = each.value["name"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  network_interface_ids = [for nic_k, nic_v in azurerm_network_interface.windows_nics : nic_v.id if(contains(each.value["vm_nic_keys"], nic_k) == true)]
  size                  = coalesce(lookup(each.value, "vm_size"), "Standard_DS1_v2")
  zone                  = lookup(each.value, "availability_set_key", null) == null ? lookup(each.value, "zone", null) : null
  #availability_set_id   = lookup(each.value, "availability_set_key", null) == null ? null : lookup(azurerm_availability_set.this, each.value["availability_set_key"])["id"]
  admin_username        = var.administrator_user_name
  admin_password        = data.azurerm_key_vault_secret.winAdmin[each.key].value

  os_disk {
    name                      = each.value["os_disk_name"]
    caching                   = coalesce(lookup(each.value, "storage_os_disk_caching"), "ReadWrite")
    storage_account_type      = coalesce(lookup(each.value, "managed_disk_type"), "Standard_LRS")
    disk_size_gb              = lookup(each.value, "disk_size_gb", null)
    write_accelerator_enabled = lookup(each.value, "write_accelerator_enabled", null)
#    disk_encryption_set_id    = lookup(each.value, "use_existing_disk_encryption_set", false) == true ? lookup(data.azurerm_disk_encryption_set.this, each.key )["id"] : (coalesce(lookup(each.value, "enable_cmk_disk_encryption"), false) == true && ((local.keyvault_state_exists == true ? data.terraform_remote_state.keyvault.outputs.purge_protection : data.azurerm_key_vault.this.0.purge_protection_enabled) == true) ? lookup(azurerm_disk_encryption_set.this, each.key)["id"] : null)
  }

  dynamic "source_image_reference" {
    for_each = lookup(var.windows_dc, each.value["name"], null) == null ? (lookup(each.value, "source_image_reference_publisher", null) == null ? [] : [lookup(each.value, "source_image_reference_publisher", null)]) : []
    content {
      publisher = lookup(each.value, "source_image_reference_publisher", null)
      offer     = lookup(each.value, "source_image_reference_offer", null)
      sku       = lookup(each.value, "source_image_reference_sku", null)
      version   = lookup(each.value, "source_image_reference_version", null)
    }
  }

  enable_automatic_updates = lookup(each.value, "enable_automatic_updates", null)
  computer_name            = upper( each.value["computer_name"] )
  custom_data              = lookup(each.value, "custom_data_path", null) == null ? null : (base64encode(templatefile("${path.root}${each.value["custom_data_path"]}", each.value["custom_data_args"] != null ? each.value["custom_data_args"] : {})))
#  source_image_id          = lookup(var.windows_dc, each.value["name"], null)

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.team_storage.primary_blob_endpoint
  }

    dynamic "identity" {
    for_each = coalesce(lookup(each.value, "assign_identity"), false) == false ? [] : tolist([coalesce(lookup(each.value, "assign_identity"), false)])
    content {
      type = "SystemAssigned"
    }
  }

  lifecycle {
    ignore_changes = [
      admin_password,
      network_interface_ids,
      os_disk[0].disk_encryption_set_id
    ]
  }

  tags = var.tags

  depends_on = []
}

resource "azurerm_network_interface" "windows_nics" {
  for_each                      = var.windows_dc_nics
  name                          = each.value.name
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  enable_ip_forwarding          = lookup(each.value, "enable_ip_forwarding", null)
  enable_accelerated_networking = lookup(each.value, "enable_accelerated_networking", null)
  dns_servers                   = lookup(each.value, "dns_servers", null)
  
  ip_configuration {
    name = "internal"
    subnet_id = data.azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# resource "azurerm_private_dns_a_record" "example" {
#   for_each            = var.windows_dc
#   name                = each.value["computer_name"]
#   zone_name           = azurerm_private_dns_zone.example.name
#   resource_group_name = data.azurerm_resource_group.rg.name
#   ttl                 = 300
#   records             = [for nic_k, nic_v in azurerm_network_interface.windows_nics : nic_v.private_ip_address if(contains(each.value["vm_nic_keys"], nic_k) == true)]
# }

resource "azurerm_virtual_network_dns_servers" "example" {
  for_each           = var.windows_dc
  virtual_network_id = data.azurerm_virtual_network.vnet.id
  dns_servers        = concat(data.azurerm_virtual_network.vnet.dns_servers, flatten([
    for nic_k, nic_v in azurerm_network_interface.windows_nics : 
    nic_v.private_ip_address if(contains(each.value["vm_nic_keys"], nic_k) == true)]), ["168.63.129.16"])

  depends_on = [azurerm_virtual_machine_extension.dc_extension]
  
  lifecycle {
    ignore_changes = [
      dns_servers,
    ]
  }
}

################################################
# Windows DC Scripts section
###############################################

resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_name  = data.azurerm_storage_account.team_storage.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "dc-configuration-content" {
  name                    = "dc-configuration-content.zip"
  storage_account_name    = data.azurerm_storage_account.team_storage.name
  storage_container_name  = azurerm_storage_container.scripts.name
  type                    = "Block"
  access_tier             = "Hot"
  source                  = "../scripts/domain-controller/dc-configuration-content.zip"
}

resource "azurerm_storage_blob" "configure-dc-01" {
  name                    = "01-configure-dc.ps1"
  storage_account_name    = data.azurerm_storage_account.team_storage.name
  storage_container_name  = azurerm_storage_container.scripts.name
  type                    = "Block"
  access_tier             = "Hot"
  source                  = "../scripts/domain-controller/01-configure-dc.ps1"
}

resource "azurerm_storage_blob" "configure-dc-02" {
  name                    = "02-configure-dc.ps1"
  storage_account_name    = data.azurerm_storage_account.team_storage.name
  storage_container_name  = azurerm_storage_container.scripts.name
  type                    = "Block"
  access_tier             = "Hot"
  source                  = "../scripts/domain-controller/02-configure-dc.ps1"
}

resource "azurerm_storage_blob" "configure-dc-03" {
  name                    = "03-configure-dc.ps1"
  storage_account_name    = data.azurerm_storage_account.team_storage.name
  storage_container_name  = azurerm_storage_container.scripts.name
  type                    = "Block"
  access_tier             = "Hot"
  source                  = "../scripts/domain-controller/03-configure-dc.ps1"
}

resource "azurerm_storage_blob" "configure-dc-04" {
  name                    = "04-configure-dc.ps1"
  storage_account_name    = data.azurerm_storage_account.team_storage.name
  storage_container_name  = azurerm_storage_container.scripts.name
  type                    = "Block"
  access_tier             = "Hot"
  source                  = "../scripts/domain-controller/04-configure-dc.ps1"
}

resource "azurerm_storage_blob" "configure-dc-05" {
  name                    = "05-configure-dc.ps1"
  storage_account_name    = data.azurerm_storage_account.team_storage.name
  storage_container_name  = azurerm_storage_container.scripts.name
  type                    = "Block"
  access_tier             = "Hot"
  source                  = "../scripts/domain-controller/05-configure-dc.ps1"
}

#####################################
# Windows DC extension section
#####################################

resource "azurerm_virtual_machine_extension" "dc_extension" {
  for_each = {
    for vm_name, vm in var.windows_dc :
    coalesce(strcontains(vm.name, "DC"), false) == false ? "" : vm_name => vm
  if strcontains(vm.name, "DC")
  }
  name                 = each.value["name"]
  depends_on           = []
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_dc["${each.key}"].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
  {
    "fileUris": [
      "${azurerm_storage_blob.configure-dc-01.url}",
      "${azurerm_storage_blob.configure-dc-02.url}",
      "${azurerm_storage_blob.configure-dc-03.url}",
      "${azurerm_storage_blob.configure-dc-04.url}",
      "${azurerm_storage_blob.configure-dc-05.url}",
      "${azurerm_storage_blob.dc-configuration-content.url}"],
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ${azurerm_storage_blob.configure-dc-01.name} -DomainPrefix ${var.dc_domain_prefix} -DomainName ${var.dc_domain_name} -SafeModeAdministratorPassword ${data.azurerm_key_vault_secret.winAdmin[each.key].value} -User ${var.administrator_user_name} -Password ${data.azurerm_key_vault_secret.winAdmin[each.key].value}"
  }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "storageAccountName": "${azurerm_storage_container.scripts.storage_account_name}",
    "storageAccountKey": "${data.azurerm_storage_account.team_storage.primary_access_key}"
  }
  PROTECTED_SETTINGS
}