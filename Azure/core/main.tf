terraform {
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  subscription_id = var.subscription
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant
  environment     = var.environment
  skip_provider_registration = true
  # metadata_host   = var.metadata_host
  features {}
}

data "azurerm_resource_group" "core" {
  name = var.rg_name
}

data "azurerm_storage_account" "core" {
  name                = var.storage_accountname
  resource_group_name = data.azurerm_resource_group.core.name
}

resource "azurerm_storage_container" "dsc" {
  name                  = "dsc"
  storage_account_name  = data.azurerm_storage_account.core.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "Get-Dsc" {
  name                   = "Get-Dsc.ps1"
  storage_account_name   = data.azurerm_storage_account.core.name
  storage_container_name = azurerm_storage_container.dsc.name
  type                   = "Block"
  access_tier            = "Hot"
  source                 = "../scripts/Get-Dsc.ps1"
}

data "azurerm_key_vault" "core" {
  name                = "corekv"
  resource_group_name = data.azurerm_resource_group.core.name
}

module "vnet" {
  source = "../modules/terraform-azure-network"

  vnet_name   = var.vnet_name
  vnet_cidr   = var.vnet_cidr
  rg_name     = data.azurerm_resource_group.core.name
  rg_location = data.azurerm_resource_group.core.location
  tags = var.tags

  subnets = var.subnets
}
# Perm hardcoded

# resource "azurerm_role_assignment" "avd-sp" {
#   scope                = "/subscriptions/${var.subscription}"
#   role_definition_name = "Desktop Virtualization Power On Off Contributor"
#   principal_id         = "71523f7d-5996-420c-9fb4-c503f82428ed"
# }