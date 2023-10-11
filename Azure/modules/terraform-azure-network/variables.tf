variable "rg_name" {
  type        = string
  description = "Default Resource Group Name."
}

variable "rg_location" {
  type        = string
  description = "Locations in Azure for regional datacenters."
}

//Network Variables
variable "vnet_name" {
  type        = string
  description = "Standard vNet name for resource in Azure."
}

variable "vnet_cidr" {
  type        = list(string)
  description = "vNet cidr for resources in Azure."
}

variable "subnet_cidr" {
  type        = string
  default     = ""
  description = "Subnet cidr for resources in Azure."
}

//Tag Variables
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to set on the bucket."
}

variable "subnets" {
  description = "For each subnet, create an object that contain fields"
  default     = {}
}