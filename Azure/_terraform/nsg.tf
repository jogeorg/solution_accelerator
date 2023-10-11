//NSG
module "nsg" {
  source              = "../modules/terraform-azure-networkSecurityGroup"
  nsg_name            = var.nsg_name
  resource_group_name = azurerm_resource_group.rg.name
  resourcelocations   = azurerm_resource_group.rg.location

  security_rule = var.security_rule
  tags     = var.tags
}