//SYSTAMN STORAGE ACCOUNT
output "storage_accountid" {
  value = azurerm_storage_account.storage_account.id
}

output "storage_accountname" {
  value = azurerm_storage_account.storage_account.name
}

output "primary_access_key" {
  value = azurerm_storage_account.storage_account.primary_access_key
  sensitive = true
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.storage_account.primary_blob_endpoint
}