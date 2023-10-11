locals {
  vm_ids_map = {
    for vm in azurerm_windows_virtual_machine.windows_dsc :
    vm.name => vm.id
  }

  msi_enabled_windows_dsc = [
    for vm_k, vm_v in var.windows_dsc :
    vm_v if coalesce(lookup(vm_v, "assign_identity"), false) == true
  ]

  vm_principal_ids = flatten([
    for x in azurerm_windows_virtual_machine.windows_dsc :
    [
      for y in x.identity :
      y.principal_id if y.principal_id != ""
    ] if length(keys(azurerm_windows_virtual_machine.windows_dsc)) > 0
  ])


}

data "azurerm_key_vault" "core_kv" {
  name = var.key_vault_name
  resource_group_name = var.kv_resource_group
}

data "azurerm_subnet" "this" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.kv_resource_group
}

data "azurerm_key_vault_secret" "winAdmin" {
  for_each     = var.windows_dsc
  name         = each.key
  key_vault_id = data.azurerm_key_vault.core_kv.id
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_storage_account" "team_storage" {
  name = var.storage_accountname
  resource_group_name = var.rg_name
}

data "azurerm_storage_blob" "Get-Dsc" {
  name                   = "Get-Dsc.ps1"
  storage_account_name   = var.core_storage_accountname
  storage_container_name = "dsc"
}

data "azurerm_storage_account" "core" {
  name                = var.core_storage_accountname
  resource_group_name = var.core_rg_name
}

resource "azurerm_windows_virtual_machine" "windows_dsc" {
  for_each            = var.windows_dsc
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
    for_each = lookup(var.windows_dsc, each.value["name"], null) == null ? (lookup(each.value, "source_image_reference_publisher", null) == null ? [] : [lookup(each.value, "source_image_reference_publisher", null)]) : []
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
#  source_image_id          = lookup(var.windows_dsc, each.value["name"], null)

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
  for_each                      = var.windows_dsc_nics
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

##########################################################
# CUSTOM SCRIPT EXTENSION FOR DSC TO BE ADDED TO TEST VM #
##########################################################

resource "azurerm_virtual_machine_extension" "extension" {
  for_each             = {
    for vm_name, vm in var.windows_dsc :
    coalesce(strcontains(vm.source_image_reference_sku, "2022"), false) == false ? "" : vm_name => vm
  if strcontains(vm.source_image_reference_sku, "2022")
}
#for_each = coalesce(lookup(each.value, "assign_identity"), false) == false ? [] : tolist([coalesce(lookup(each.value, "assign_identity"), false)])
  name                 = each.value["name"]
  depends_on           = []
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_dsc["${each.key}"].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
  {
    "fileUris": [
      "${data.azurerm_storage_blob.Get-Dsc.url}"],
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ${data.azurerm_storage_blob.Get-Dsc.name}"
  }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "storageAccountName": "${data.azurerm_storage_account.core.name}",
    "storageAccountKey": "${data.azurerm_storage_account.core.primary_access_key}"
  }
  PROTECTED_SETTINGS 
}