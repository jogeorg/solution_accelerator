//Network Outputs
//VNET
output "vnetid" {
  value = azurerm_virtual_network.vnet.id
}

output "vnetname" {
  value = azurerm_virtual_network.vnet.name
}

output "vnetcidr" {
  value = azurerm_virtual_network.vnet.address_space
}

output "vnetlocation" {
  value = azurerm_virtual_network.vnet.location
}

output "subnet_ids" {
  description = "List of IDs of subnets"
  value       = flatten([for s in azurerm_subnet.snet : s.id])
  depends_on  = [azurerm_subnet.snet]
}

# output "subnet_address_prefixes" {
#   description = "List of address prefix for subnets"
#   value       = flatten([for s in azurerm_subnet.snet : s.subnet_address_prefix])
# }
