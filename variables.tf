variable "location" {
  type        = string
  default     = "swedencentral"
  description = "The region to deploy the resources to"
}

variable "resource_group_name" {
  type        = string
  default     = "rg-demo-dev-swedencentral-001"
  description = "The name of the resource group for the Storage Account and App Configuration which will contain the terraform backend and exported values"
}

variable "tags" {
  type = map(string)
  default = {
    env  = "AVM Lab"
    dept = "Skillable"
  }
  description = "Tags to apply to the resources"
}

variable "address_space" {
  type        = string
  description = "The address space that is used the virtual network"
}

variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  description = "The subnets"
}

variable "vnet_name" {
  type        = string
  description = "The name of the virtual network"
}

variable "storage_account_name" {
  type = string
}
