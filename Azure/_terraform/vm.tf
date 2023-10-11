module "windows_dc" {
  source = "../modules/terraform-azure-virtualMachineDC"

  rg_name                    = azurerm_resource_group.rg.name
  windows_dc                = var.windows_dc
  windows_dc_nics           = var.windows_dc_nics
  dc_domain_prefix          = var.dc_domain_prefix
  storage_accountname       = module.storageact1.storage_accountname
  subnet_name               = var.subnet_name
  administrator_user_name   = var.administrator_user_name
  key_vault_name            = var.key_vault_name
  kv_resource_group         = var.kv_resource_group
  vnet_name                 = var.vnet_name
  dc_domain_name            = var.dc_domain_name

  tags       = var.tags
  depends_on = [azurerm_resource_group.rg, module.storageact1]
}

module "windows_dsc" {
  source = "../modules/terraform-azure-virtualMachineDSC"

  rg_name                   = azurerm_resource_group.rg.name
  core_rg_name              = var.core_rg_name
  windows_dsc               = var.windows_dsc
  windows_dsc_nics          = var.windows_dsc_nics
  storage_accountname       = module.storageact1.storage_accountname
  core_storage_accountname  = var.core_storage_accountname
  subnet_name               = var.subnet_name
  administrator_user_name   = var.administrator_user_name
  key_vault_name            = var.key_vault_name
  kv_resource_group         = var.kv_resource_group
  vnet_name                 = var.vnet_name

  tags       = var.tags
  depends_on = [azurerm_resource_group.rg, module.storageact1]
}

module "windows_vm" {
  source = "../modules/terraform-azure-virtualMachine"

  rg_name                 = azurerm_resource_group.rg.name
  windows_vm              = var.windows_vm
  windows_vm_nics         = var.windows_vm_nics
  storage_accountname     = module.storageact1.storage_accountname
  subnet_name             = var.subnet_name
  administrator_user_name = var.administrator_user_name
  key_vault_name          = var.key_vault_name
  kv_resource_group       = var.kv_resource_group
  vnet_name               = var.vnet_name

  tags       = var.tags  
  depends_on = [azurerm_resource_group.rg, module.storageact1]
}