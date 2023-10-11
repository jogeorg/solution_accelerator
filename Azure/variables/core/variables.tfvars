subnets={
    AVD_SUBNET = {
      subnet_name           = "AVD_SUBNET"
      subnet_address_prefix = ["10.150.0.128/26"]
      service_endpoints     = ["Microsoft.Storage"]
    }
    sample_SUBNET = {
        subnet_name           = "SAMPLE_SUBNET"
        subnet_address_prefix = ["10.150.0.192/26"]
        service_endpoints     = ["Microsoft.Storage"]
    }
  }

rg_name = "CORE_RG"
vnet_name = "CORE_VNET"
tags = {}

storage_accountname = "coregenstorageact"

# AVD
workspace_name        = "core-avd"
workspace_description = "Workspace for Azure Users"
host_pool_name           = "core-avd-host"
validate_environment     = true
start_vm_on_connect      = true
custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
host_pool_type           = "Pooled"
maximum_sessions_allowed = 50
load_balancer_type       = "DepthFirst"
# agent_updates_enabled = true
# scheduled_agent_updates = {
#   day_of_week = "Saturday"
#   hour_of_day = 2
# }
host_pool_description = "Host pool for AVD"
app_group_name        = "core-avd-app"
app_group_type        = "RemoteApp"
app_group_description = "value"
scaling_plan_name        = "core-avd-plan"
scaling_plan_time_zone   = "GMT Standard Time"
scaling_plan_description = "value"
scaling_plan_schedule = {
  schedule = {
    name                                 = "Weekdays"
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                   = "05:00"
    ramp_up_load_balancing_algorithm     = "BreadthFirst"
    ramp_up_minimum_hosts_percent        = 20
    ramp_up_capacity_threshold_percent   = 10
    peak_start_time                      = "09:00"
    peak_load_balancing_algorithm        = "BreadthFirst"
    ramp_down_start_time                 = "19:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 10
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 45
    ramp_down_notification_message       = "Please log off in the next 45 minutes..."
    ramp_down_capacity_threshold_percent = 5
    ramp_down_stop_hosts_when            = "ZeroSessions"
    off_peak_start_time                  = "22:00"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }
}
host_pool_scaling_plan_enabled = true
rdsh_count = 2
prefix               = "avdtf"
vm_size              = "Standard_D2s_v3"
local_admin_username = "localadm"
subnet_name           = "AVD_SUBNET"
dc_domain_name       = "customer.mil"
dc_domain_prefix     = "CUSTOMER"
administrator_user_name = "DoD_Admin"
kv_resource_group = "CORE_RG"

windows_dc = {
 coredccakms = {
  name = "CORE-DC-CA-KMS"
  computer_name = "dccakms"
  vm_size = "Standard_B2s"
  zone = "2"
  assign_identity = true
  availability_set_key                 = null
  vm_nic_keys                          = ["coredcnic"]
  source_image_reference_publisher     = "MicrosoftWindowsServer"
  source_image_reference_offer         = "WindowsServer"
  source_image_reference_sku           = "2019-datacenter-gensecond"
  source_image_reference_version       = "latest"
  os_disk_name                         = "CORE-DC-CA-KMS"
  storage_os_disk_caching              = "ReadWrite"
  managed_disk_type                    = "Standard_LRS"
  disk_size_gb                         = 1024
  write_accelerator_enabled            = false
  recovery_services_vault_name         = null
  vm_backup_policy_name                = null
  use_existing_disk_encryption_set     = false
  existing_disk_encryption_set_name    = null
  existing_disk_encryption_set_rg_name = null
  enable_cmk_disk_encryption           = false
  customer_managed_key_name            = null
  disk_encryption_set_name             = null
  enable_automatic_updates             = true
  custom_data_path                     = null
  custom_data_args                     = null
}
}

windows_dc_nics = {
  coredcnic = {
    name                           = "core-dc-nic-001"
    subnet_name                    = "AVD_SUBNET"
    vnet_name                      = "CORE_VNET"
    networking_resource_group      = "CORE_RG"
    lb_backend_pool_names          = null
    lb_nat_rule_names              = null
    app_security_group_names       = null
    app_gateway_backend_pool_names = null
    internal_dns_name_label        = ""
    enable_ip_forwarding           = false
    enable_accelerated_networking  = false
    dns_servers                    = null
    nic_ip_configurations = [
      {
          name      = "core-dc-ip-config-001"
          static_ip = null
      }
    ]
  }
}
