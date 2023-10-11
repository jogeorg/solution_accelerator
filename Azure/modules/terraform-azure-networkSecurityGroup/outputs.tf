output "nsg_name" {
  value = azurerm_network_security_group.nsg.name
}

output "nsg_id" {
  value = azurerm_network_security_group.nsg.id
}

output "nsg_location" {
  value = azurerm_network_security_group.nsg.location
}

output "nsg_security_rules" {
  value = azurerm_network_security_group.nsg.security_rule
}