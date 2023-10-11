resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.resourcelocations[0]
  tags     = var.tags
}
