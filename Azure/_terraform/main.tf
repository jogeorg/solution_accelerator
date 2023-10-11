terraform {  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~>0.9"
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
  features {}
}