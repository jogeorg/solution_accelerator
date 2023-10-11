data "azurerm_subnet" "this" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.core_rg_name
}

data "azurerm_private_dns_zone" "example" {
  name                = "privatelink.blob.core.usgovcloudapi.net"
  resource_group_name = var.core_rg_name
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_accountname
  resource_group_name      = var.resource_name
  location                 = var.resource_location
  account_tier             = var.storage_accounttier
  account_replication_type = var.storage_accountreplication
  account_kind             = var.storage_accountkind
  access_tier              = var.storage_accesstier
  enable_https_traffic_only = true
  public_network_access_enabled = true
  tags = var.tags
}

resource "azurerm_private_endpoint" "example" {
  name                = "storage-endpoint"
  location            = var.resource_location
  resource_group_name = var.resource_name
  subnet_id           = data.azurerm_subnet.this.id

  private_service_connection {
    name                           = "storage-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.example.id]
  }
  tags = var.tags
}