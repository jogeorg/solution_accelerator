variable "nsg_name" {
  type        = string
  description = "Network Security Group name."
}

variable "security_rule" {
  type = list(object
    ({
      name                       = string
      priority                   = string
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string

  }))
  default = null
  nullable = true
  description = "Optional. List of security rules to apply to NSG"
}

variable "resourcelocations" {
  type = string
  
}

variable "resource_group_name" {
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