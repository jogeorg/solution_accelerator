variable "resource_name" {
  type        = string
  description = "Default Resource Group Name."
}

variable "resource_location" {
  type        = string
  description = "Locations in Azure for regional datacenters."
}

//Storage Account Variables
variable "storage_accountname" {
  type        = string
  description = "Storage account name ."
}

variable "storage_accounttier" {
  type        = string
  description = "Storage account tier."
}

variable "storage_accountreplication" {
  type        = string
  description = "Storage account replication option."
}

variable "storage_accountkind" {
  type        = string
  description = "Storage account kind."
}

variable "storage_accesstier" {
  type        = string
  description = "Storage access tier."
}

variable "subnet_name" {
  type        = string
  description = "Team subnet name"
}

variable "vnet_name" {
  type        = string
  description = "core vnet name"
}

variable "core_rg_name" {
  type        = string
  description = "core resource group name"
}

//Tag Variables
variable "tags" {
  type        = object({
    name = string
    project = string
    workstream = string
    costcenter = string
  })
  description = "Tags to set."
}