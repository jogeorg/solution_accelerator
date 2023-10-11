module "storageact1" {
  source = "../modules/terraform-azure-storage"

  storage_accountname        = var.storage_accountname
  resource_name              = azurerm_resource_group.rg.name
  resource_location          = azurerm_resource_group.rg.location
  storage_accounttier        = var.storage_accounttier
  storage_accountreplication = var.storage_accountreplication
  storage_accountkind        = var.storage_accountkind
  storage_accesstier         = var.storage_accesstier
  subnet_name                = var.subnet_name
  vnet_name                  = var.vnet_name
  core_rg_name               = var.core_rg_name

  tags = var.tags
}