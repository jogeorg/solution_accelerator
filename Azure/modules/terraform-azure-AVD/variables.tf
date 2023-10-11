variable "rg_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

######################
## Workspaces
#####################
variable "workspace_name" {
  type        = string
  description = "Name of the AVD workspace"
}

variable "workspace_description" {
  type        = string
  description = "Workspace for AVD"
}

######################
## Host Pool
######################
variable "host_pool_name" {
  type        = string
  description = "value"
}

variable "validate_environment" {
  type        = bool
  default     = true
  description = "value"
}

variable "start_vm_on_connect" {
  type        = bool
  default     = true
  description = "value"
}

variable "custom_rdp_properties" {
  type        = string
  default     = "value"
  description = "value"
}

variable "host_pool_description" {
  type        = string
  description = "value"
}

variable "host_pool_type" {
  type        = string
  description = "Personal or Pooled"
}

variable "maximum_sessions_allowed" {
  type        = number
  description = "value"
}

variable "load_balancer_type" {
  type        = string
  description = "Values: BreadthFirst, DepthFirst, or Persistent."
}

# variable "agent_updates_enabled" {
#   type = bool
#   default = true
#   description = "value"
# }

# variable "scheduled_agent_updates" {
#   type = object({
#         day_of_week = string
#         hour_of_day = number
#       })
# }

######################
## Application Groups
######################
variable "app_group_name" {
  type        = string
  description = "value"
}

variable "app_group_type" {
  type        = string
  description = "value"
}

variable "app_group_description" {
  type        = string
  description = "value"
}

######################
## Scaling Plans
######################
variable "scaling_plan_name" {
  type        = string
  description = "value"
}

variable "scaling_plan_description" {
  type        = string
  description = "value"
}

variable "scaling_plan_time_zone" {
  type        = string
  description = "value"
}

variable "scaling_plan_schedule" {
  type = map(object({
      name                                 = string
      days_of_week                         = list(string)
      ramp_up_start_time                   = string
      ramp_up_load_balancing_algorithm     = string
      ramp_up_minimum_hosts_percent        = number
      ramp_up_capacity_threshold_percent = number
      peak_start_time                      = string
      peak_load_balancing_algorithm        = string
      ramp_down_start_time                 = string
      ramp_down_load_balancing_algorithm   = string
      ramp_down_minimum_hosts_percent      = number
      ramp_down_force_logoff_users         = bool
      ramp_down_wait_time_minutes          = number
      ramp_down_notification_message       = string
      ramp_down_capacity_threshold_percent = number
      ramp_down_stop_hosts_when            = string
      off_peak_start_time                  = string
      off_peak_load_balancing_algorithm    = string
  }))
}

variable "host_pool_scaling_plan_enabled" {
  type        = bool
  description = "value"
}

#############################
# azurerm_network_interface #
#############################

variable "rdsh_count" {
  description = "Number of AVD machines to deploy"
  default     = 2
}

variable "prefix" {
  type        = string
  default     = "avdtf"
  description = "Prefix of the name of the AVD machine(s)"
}

###################################
# azurerm_windows_virtual_machine #
###################################

variable "vm_size" {
  description = "Size of the machine to deploy"
  default     = "Standard_DS2_v2"
}

variable "vnet_name" {
  type        = string
  description = "Vnet Name"
}

variable "subnet_name" {
  type = string
  description = "Subnet name"
}

variable "local_admin_username" {
  type        = string
  default     = "localadm"
  description = "local admin username"
}

variable "ou_path" {
  default = ""
}

variable "dc_domain_name" {
  type = string
}

variable "administrator_user_name" {
  type = string
}

variable "tags" {
  type = object({
    name       = string
    project    = string
    workstream = string
    costcenter = string
  })
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