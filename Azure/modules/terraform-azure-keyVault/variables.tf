variable "key_vault_name" {
  type = string
  default = "corekv"
  description = "The name of the Key Vault to be deployed"
}

variable "rg_name" {
  type        = string
  default = "TFVARS"
  description = "Default Resource Group"
}

variable "resourcelocations" {
  type        = list(string)
  default     = ["usgovvirginia", "usgovtexas", "usgovarizona", "usdodeast", "usdodcentral"]
  description = "Locations in Azure for resource definition."
}