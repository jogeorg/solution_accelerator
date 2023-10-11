data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "example" {
  name                            = var.key_vault_name
  location                        = var.resourcelocations[0]
  resource_group_name             = var.rg_name
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
}