output "dc_password" {
    value       = flatten([for s in data.azurerm_key_vault_secret.winAdmin : s.value])
    sensitive   = true
}