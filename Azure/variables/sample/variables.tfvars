rg_name = "sample_RG"
tags = {
  sample = "demo"
}

nsg_name = "sample_NSG"
security_rule = [{
    name                       = "allow-rdp"
    priority                   = "1001"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
}]

core_rg_name                = "CORE_RG"
core_storage_accountname    = "coregenstorageact"

storage_accountname         = "samplepremstorageact"
storage_accounttier         = "Standard"
storage_accountreplication  = "LRS"
storage_accountkind         = "StorageV2"
storage_accesstier          = "Hot"

key_vault_name = "corekv"
kv_resource_group = "CORE_RG"

vnet_name = "CORE_VNET"
subnet_name = "SAMPLE_SUBNET"

windows_vm = {
 samplemecm = {
    name = "sample-MECM"
    computer_name = "samplemecm"
    vm_size = "Standard_B4ms"
    zone = "2"
    assign_identity = true
    availability_set_key                 = null
    vm_nic_keys                          = ["samplemecmnic"]
    source_image_reference_publisher     = "MicrosoftWindowsServer"
    source_image_reference_offer         = "WindowsServer"
    source_image_reference_sku           = "2019-datacenter-gensecond"
    source_image_reference_version       = "latest"
    os_disk_name                         = "sample-MECM"
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
 samplescom = {
    name = "sample-SCOM"
    computer_name = "samplescom"
    vm_size = "Standard_B4ms"
    zone = "2"
    assign_identity = true
    availability_set_key                 = null
    vm_nic_keys                          = ["samplescomnic"]
    source_image_reference_publisher     = "MicrosoftWindowsServer"
    source_image_reference_offer         = "WindowsServer"
    source_image_reference_sku           = "2019-datacenter-gensecond"
    source_image_reference_version       = "latest"
    os_disk_name                         = "sample-SCOM"
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
 samplescorch = {
    name = "sample-SCORCH"
    computer_name = "samplescorch"
    vm_size = "Standard_B4ms"
    zone = "2"
    assign_identity = true
    availability_set_key                 = null
    vm_nic_keys                          = ["samplescorchnic"]
    source_image_reference_publisher     = "MicrosoftWindowsServer"
    source_image_reference_offer         = "WindowsServer"
    source_image_reference_sku           = "2019-datacenter-gensecond"
    source_image_reference_version       = "latest"
    os_disk_name                         = "sample-SCORCH"
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
 sampleca = {
    name = "sample-CA"
    computer_name = "sampleca"
    vm_size = "Standard_B4ms"
    zone = "2"
    assign_identity = true
    availability_set_key                 = null
    vm_nic_keys                          = ["samplecanic"]
    source_image_reference_publisher     = "MicrosoftWindowsServer"
    source_image_reference_offer         = "WindowsServer"
    source_image_reference_sku           = "2019-datacenter-gensecond"
    source_image_reference_version       = "latest"
    os_disk_name                         = "sample-CA"
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

windows_dc = {
 sampledc = {
    name = "sample-DC"
    computer_name = "sampledc"
    vm_size = "Standard_B4ms"
    zone = "2"
    assign_identity = true
    availability_set_key                 = null
    vm_nic_keys                          = ["sampledcnic"]
    source_image_reference_publisher     = "MicrosoftWindowsServer"
    source_image_reference_offer         = "WindowsServer"
    source_image_reference_sku           = "2019-datacenter-gensecond"
    source_image_reference_version       = "latest"
    os_disk_name                         = "sample-DC"
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

windows_vm_nics = {
  samplemecmnic = {
    name                           = "samplemecm-001"
    subnet_name                    = "sample_SUBNET"
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
          name      = "samplemecm-ip-config-001"
          static_ip = null
      }
    ]
  }
  samplescomnic = {
    name                           = "samplescom-001"
    subnet_name                    = "sample_SUBNET"
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
          name      = "samplescom-ip-config-001"
          static_ip = null
      }
    ]
  }
  samplescorchnic = {
    name                           = "samplescorch-001"
    subnet_name                    = "sample_SUBNET"
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
          name      = "samplescorch-ip-config-001"
          static_ip = null
      }
    ]
  }
  samplecanic = {
    name                           = "sampleca-001"
    subnet_name                    = "sample_SUBNET"
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
          name      = "sampleca-ip-config-001"
          static_ip = null
      }
    ]
  }
}

windows_dc_nics = {
  sampledcnic = {
    name                           = "sampledc-001"
    subnet_name                    = "sample_SUBNET"
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
          name      = "sampledc-ip-config-001"
          static_ip = null
      }
    ]
  }
}

administrator_user_name = "DoD_Admin"
dc_domain_name       = "sample.mil"
dc_domain_prefix     = "sample"