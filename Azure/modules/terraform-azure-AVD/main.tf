locals {
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
}

data "azurerm_key_vault" "core_kv" {
  name = var.key_vault_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "this" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_secret" "winAdmin" {
  name         = element(keys(var.windows_dc), 0)
  key_vault_id = data.azurerm_key_vault.core_kv.id
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = timeadd(timestamp(), "24h")
}

######################
## Workspaces
######################
resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = var.workspace_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  friendly_name = var.workspace_name
  description   = var.workspace_description
  
  tags     = var.tags
}
######################
## Host Pool
######################
resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  name                     = var.host_pool_name
  friendly_name            = var.host_pool_name
  validate_environment     = var.validate_environment
  start_vm_on_connect      = var.start_vm_on_connect
  custom_rdp_properties    = var.custom_rdp_properties
  description              = var.host_pool_description
  type                     = var.host_pool_type
  maximum_sessions_allowed = var.maximum_sessions_allowed
  load_balancer_type       = var.load_balancer_type
  # scheduled_agent_updates {
  #   enabled = var.agent_updates_enabled
  #   schedule {
  #     day_of_week = var.scheduled_agent_updates.day_of_week
  #     hour_of_day = var.scheduled_agent_updates.hour_of_day
  #   }
  # }

  tags     = var.tags
}
######################
## Application Groups
######################
resource "azurerm_virtual_desktop_application_group" "remoteapp" {
  name                = var.app_group_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  type          = var.app_group_type
  host_pool_id  = azurerm_virtual_desktop_host_pool.hostpool.id
  friendly_name = var.app_group_name
  description   = var.app_group_description
  
  tags     = var.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.remoteapp.id
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
}
######################
## Scaling Plans
######################
resource "azurerm_virtual_desktop_scaling_plan" "scaling_plan" {
  name                = var.scaling_plan_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  friendly_name       = var.scaling_plan_name
  description         = var.scaling_plan_description
  time_zone           = var.scaling_plan_time_zone
    dynamic "schedule" {
    for_each                             = var.scaling_plan_schedule
    content {
    name                                 = schedule.value["name"]
    days_of_week                         = schedule.value["days_of_week"]
    ramp_up_start_time                   = schedule.value["ramp_up_start_time"]
    ramp_up_load_balancing_algorithm     = schedule.value["ramp_up_load_balancing_algorithm"]
    ramp_up_minimum_hosts_percent        = schedule.value["ramp_up_minimum_hosts_percent"]
    ramp_up_capacity_threshold_percent   = schedule.value["ramp_up_capacity_threshold_percent"]
    peak_start_time                      = schedule.value["peak_start_time"]
    peak_load_balancing_algorithm        = schedule.value["peak_load_balancing_algorithm"]
    ramp_down_start_time                 = schedule.value["ramp_down_start_time"]
    ramp_down_load_balancing_algorithm   = schedule.value["ramp_down_load_balancing_algorithm"]
    ramp_down_minimum_hosts_percent      = schedule.value["ramp_down_minimum_hosts_percent"]
    ramp_down_force_logoff_users         = schedule.value["ramp_down_force_logoff_users"]
    ramp_down_wait_time_minutes          = schedule.value["ramp_down_wait_time_minutes"]
    ramp_down_notification_message       = schedule.value["ramp_down_notification_message"]
    ramp_down_capacity_threshold_percent = schedule.value["ramp_down_capacity_threshold_percent"]
    ramp_down_stop_hosts_when            = schedule.value["ramp_down_stop_hosts_when"]
    off_peak_start_time                  = schedule.value["off_peak_start_time"]
    off_peak_load_balancing_algorithm    = schedule.value["off_peak_load_balancing_algorithm"]
      }
  }
  host_pool {
    hostpool_id          = azurerm_virtual_desktop_host_pool.hostpool.id
    scaling_plan_enabled = var.host_pool_scaling_plan_enabled
  }
  
  tags     = var.tags
}

resource "azurerm_network_interface" "avd_vm_nic" {
  count               = var.rdsh_count
  name                = "${var.prefix}-${count.index + 1}-nic"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = data.azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
  }

  tags     = var.tags
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                 = var.rdsh_count
  name                  = "${var.prefix}-${count.index + 1}"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = data.azurerm_resource_group.rg.location
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent    = true
  admin_username        = var.local_admin_username
  admin_password        = "${data.azurerm_key_vault_secret.winAdmin.value}"

  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-avd"
    version   = "latest"
  }
  
  secure_boot_enabled = true
  vtpm_enabled = true

  tags     = var.tags
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}-${count.index + 1}-domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "Name": "${var.dc_domain_name}",
      "OUPath": "${var.ou_path}",
      "User": "${var.administrator_user_name}@${var.dc_domain_name}",
      "Restart": "true",
      "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${data.azurerm_key_vault_secret.winAdmin.value}"
    }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
}

resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}${count.index + 1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.usgovcloudapi.net/galleryartifacts/Configuration_1.0.02439.203.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool.name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.domain_join,
    azurerm_virtual_desktop_host_pool.hostpool
  ]
}