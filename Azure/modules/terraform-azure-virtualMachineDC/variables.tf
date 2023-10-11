variable "subscription" {
  type        = string
}

variable "tenant" {
  type        = string
}

variable "client_id" {
  type        = string
}

variable "environment" {
  type        = string
  default     = "usgovernment"
}

variable "rg_name" {
  type        = string
  description = "Default Resource Group"
}

variable "dc_domain_prefix" {
  type = string
}

variable "dc_domain_name" {
  type = string
}

# variable "dc_safe_mode_password" {
#   type = string
#   sensitive = true
# }

variable "dc_username" {
  type = string
  default = "DCAdmin"
}

# variable "dc_password" {
#   type = string
#   sensitive = true
# }

variable "storage_accountname" {
  type = string
}

variable "windows_dc" {
  type = map(object({
    name                                 = string
    computer_name                        = string
    vm_size                              = string
    zone                                 = string
    assign_identity                      = bool
    availability_set_key                 = string
    vm_nic_keys                          = list(string)
    source_image_reference_publisher     = string
    source_image_reference_offer         = string
    source_image_reference_sku           = string
    source_image_reference_version       = string
    os_disk_name                         = string
    storage_os_disk_caching              = string
    managed_disk_type                    = string
    disk_size_gb                         = number
    write_accelerator_enabled            = bool
    recovery_services_vault_name         = string
    vm_backup_policy_name                = string
    use_existing_disk_encryption_set     = bool
    existing_disk_encryption_set_name    = string
    existing_disk_encryption_set_rg_name = string
    enable_cmk_disk_encryption           = bool
    customer_managed_key_name            = string
    disk_encryption_set_name             = string
    enable_automatic_updates             = bool
    custom_data_path                     = string
    custom_data_args                     = map(string)
  }))
  description = "Map containing Windows VM objects"
  default = {  }
}

variable "windows_vm_nics" {
  type = map(object({
    name                           = string
    subnet_name                    = string
    vnet_name                      = string
    networking_resource_group      = string
    lb_backend_pool_names          = list(string)
    lb_nat_rule_names              = list(string)
    app_security_group_names       = list(string)
    app_gateway_backend_pool_names = list(string)
    internal_dns_name_label        = string
    enable_ip_forwarding           = bool
    enable_accelerated_networking  = bool
    dns_servers                    = list(string)
    nic_ip_configurations = list(object({
      name      = string
      static_ip = string
    }))
  }))
  description = "Map containing Windows VM NIC objects"
  default     = {}
}

variable "windows_sql" {
    type = map(object({
    name                                 = string
    computer_name                        = string
    vm_size                              = string
    zone                                 = string
    assign_identity                      = bool
    availability_set_key                 = string
    vm_nic_keys                          = list(string)
    source_image_reference_publisher     = string
    source_image_reference_offer         = string
    source_image_reference_sku           = string
    source_image_reference_version       = string
    os_disk_name                         = string
    storage_os_disk_caching              = string
    managed_disk_type                    = string
    disk_size_gb                         = number
    write_accelerator_enabled            = bool
    recovery_services_vault_name         = string
    vm_backup_policy_name                = string
    use_existing_disk_encryption_set     = bool
    existing_disk_encryption_set_name    = string
    existing_disk_encryption_set_rg_name = string
    enable_cmk_disk_encryption           = bool
    customer_managed_key_name            = string
    disk_encryption_set_name             = string
    enable_automatic_updates             = bool
    custom_data_path                     = string
    custom_data_args                     = map(string)
  }))
  description = "Map containing Windows VM objects"
  default = {  }
}

variable "windows_sql_nics" {
    type = map(object({
    name                           = string
    subnet_name                    = string
    vnet_name                      = string
    networking_resource_group      = string
    lb_backend_pool_names          = list(string)
    lb_nat_rule_names              = list(string)
    app_security_group_names       = list(string)
    app_gateway_backend_pool_names = list(string)
    internal_dns_name_label        = string
    enable_ip_forwarding           = bool
    enable_accelerated_networking  = bool
    dns_servers                    = list(string)
    nic_ip_configurations = list(object({
      name      = string
      static_ip = string
    }))
  }))
  description = "Map containing Windows VM NIC objects"
  default     = {}
}

variable "windows_dc_nics" {
    type = map(object({
    name                           = string
    subnet_name                    = string
    vnet_name                      = string
    networking_resource_group      = string
    lb_backend_pool_names          = list(string)
    lb_nat_rule_names              = list(string)
    app_security_group_names       = list(string)
    app_gateway_backend_pool_names = list(string)
    internal_dns_name_label        = string
    enable_ip_forwarding           = bool
    enable_accelerated_networking  = bool
    dns_servers                    = list(string)
    nic_ip_configurations = list(object({
      name      = string
      static_ip = string
    }))
  }))
  description = "Map containing Windows VM NIC objects"
  default     = {}
}

variable "key_vault_name" {
  type        = string
  description = "Specifies the existing Key Vault Name where you want to store VM SSH Private Key."
  default     = null
}

variable "kv_resource_group" {
  type = string
  default = null
}

variable "vnet_name" {
  type        = string
  description = "Vnet Name"
}

variable "subnet_name" {
  type = string
  description = "Subnet name"
}

variable "tags" {
  type = object({
    name       = string
    project    = string
    workstream = string
    costcenter = string
  })
}

variable "resourcelocations" {
  type        = list(string)
  default     = ["usgovvirginia", "usgovtexas", "usgovarizona", "usdodeast", "usdodcentral"]
  description = "Locations in Azure for resource definition."
}

variable "administrator_user_name" {
  type        = string
  description = "Default admin name"
}