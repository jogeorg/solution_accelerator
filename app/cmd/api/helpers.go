package main

import (
	"fmt"
	"os"
)

func DCVM(data []VirtualMachine) string {
	dc_code := ""

	source_image_reference_publisher := "MicrosoftWindowsServer"
	source_image_reference_offer := "WindowsServer"
	source_image_reference_sku := "2019-datacenter-gensecond"
	for _, vm := range data {

		if vm.Image == "ubuntu" {
			source_image_reference_publisher = "UbuntuServer"
			source_image_reference_offer = "Ubuntu"
			source_image_reference_sku = "Ubuntu"
		}
        // Append Terraform code for each VM to the code string
        dc_code += fmt.Sprintf(`
	%s_dc = {
		%s = {
		 name = "%s"
		 computer_name = "%s"
		 vm_size = "%s"
		 zone = "2"
		 assign_identity = true
		 availability_set_key                 = null
		 vm_nic_keys                          = ["%snic"]
		 source_image_reference_publisher     = "%s"
		 source_image_reference_offer         = "%s"
		 source_image_reference_sku           = "%s"
		 source_image_reference_version       = "latest"
		 os_disk_name                         = "%s"
		 storage_os_disk_caching              = "ReadWrite"
		 managed_disk_type                    = "Standard_LRS"
		 disk_size_gb                         = %s
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
	   }`, vm.Image, vm.Name, vm.Name, vm.Name, vm.Size, vm.Name, source_image_reference_publisher, source_image_reference_offer, source_image_reference_sku, vm.Name, vm.Disk_size)
		}

	return dc_code
}

func VM(data []VirtualMachine) string {
	vm_code := ""

	source_image_reference_publisher := "MicrosoftWindowsServer"
	source_image_reference_offer := "WindowsServer"
	source_image_reference_sku := "2019-datacenter-gensecond"
	for _, vm := range data {

		if vm.Image == "ubuntu" {
			source_image_reference_publisher = "UbuntuServer"
			source_image_reference_offer = "Ubuntu"
			source_image_reference_sku = "Ubuntu"
		}
        // Append Terraform code for each VM to the code string
        vm_code += fmt.Sprintf(`
	%s_vm = {
		%s = {
		 name = "%s"
		 computer_name = "%s"
		 vm_size = "%s"
		 zone = "2"
		 assign_identity = true
		 availability_set_key                 = null
		 vm_nic_keys                          = ["%snic"]
		 source_image_reference_publisher     = "%s"
		 source_image_reference_offer         = "%s"
		 source_image_reference_sku           = "%s"
		 source_image_reference_version       = "latest"
		 os_disk_name                         = "%s"
		 storage_os_disk_caching              = "ReadWrite"
		 managed_disk_type                    = "Standard_LRS"
		 disk_size_gb                         = %s
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
	   }`, vm.Image, vm.Name, vm.Name, vm.Name, vm.Size, vm.Name, source_image_reference_publisher, source_image_reference_offer, source_image_reference_sku, vm.Name, vm.Disk_size)
		}

	return vm_code
}

func writer(code, filename string) error {
	return os.WriteFile(filename, []byte(code), 0644)
}