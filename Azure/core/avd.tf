module "windows_dc" {
  source = "../modules/terraform-azure-virtualMachineDC"

  rg_name                   = data.azurerm_resource_group.core.name
  windows_dc                = var.windows_dc
  windows_dc_nics           = var.windows_dc_nics
  dc_domain_prefix          = var.dc_domain_prefix
  storage_accountname       = data.azurerm_storage_account.core.name
  subnet_name               = var.subnet_name
  administrator_user_name   = var.administrator_user_name
  key_vault_name            = data.azurerm_key_vault.core.name
  kv_resource_group         = data.azurerm_resource_group.core.name
  vnet_name                 = var.vnet_name
  dc_domain_name            = var.dc_domain_name

  tags       = var.tags
  depends_on = [module.vnet]
}

resource "time_sleep" "wait_500_seconds" {
  create_duration = "500s"
  depends_on = [module.windows_dc]
}

module "avd" {
    source = "../modules/terraform-azure-AVD"

    workspace_name                  = var.workspace_name
    workspace_description           = var.workspace_description
    host_pool_name                  = var.host_pool_name
    validate_environment            = var.validate_environment
    start_vm_on_connect             = var.start_vm_on_connect
    custom_rdp_properties           = var.custom_rdp_properties
    host_pool_type                  = var.host_pool_type
    maximum_sessions_allowed        = var.maximum_sessions_allowed
    load_balancer_type              = var.load_balancer_type
    host_pool_description           = var.host_pool_description
    app_group_name                  = var.app_group_name
    app_group_type                  = var.app_group_type
    app_group_description           = var.app_group_description
    scaling_plan_name               = var.scaling_plan_name
    scaling_plan_time_zone          = var.scaling_plan_time_zone
    scaling_plan_description        = var.scaling_plan_description
    scaling_plan_schedule           = var.scaling_plan_schedule
    host_pool_scaling_plan_enabled  = var.host_pool_scaling_plan_enabled
    rdsh_count                      = var.rdsh_count
    prefix                          = var.prefix
    vm_size                         = var.vm_size
    local_admin_username            = var.local_admin_username
    vnet_name                       = var.vnet_name
    subnet_name                     = var.subnet_name
    rg_name                         = data.azurerm_resource_group.core.name
    key_vault_name                  = var.key_vault_name
    dc_domain_name                  = var.dc_domain_name
    windows_dc                      = var.windows_dc
    administrator_user_name         = var.administrator_user_name
    
    tags                            = var.tags
    depends_on = [module.windows_dc, time_sleep.wait_500_seconds]
}