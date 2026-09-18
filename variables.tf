variable "location" {
  type        = string
  default     = "swedencentral"
  description = "The region to deploy the resources to"
}

variable "tags" {
  type = map(string)
  default = {
    env  = "AVM Lab"
    dept = "Skillable"
  }
  description = "Tags to apply to the resources"
}

variable "resource_name_location_short" {
  type        = string
  description = "The short name segment for the location"
  default     = ""
  validation {
    condition     = length(var.resource_name_location_short) == 0 || can(regex("^[a-z]+$", var.resource_name_location_short))
    error_message = "The short name segment for the location must only contain lowercase letters"
  }
  validation {
    condition     = length(var.resource_name_location_short) <= 3
    error_message = "The short name segment for the location must be 3 characters or less"
  }
}

variable "resource_name_workload" {
  type        = string
  description = "The name segment for the workload"
  default     = "demo"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.resource_name_workload))
    error_message = "The name segment for the workload must only contain lowercase letters and numbers"
  }
  validation {
    condition     = length(var.resource_name_workload) <= 4
    error_message = "The name segment for the workload must be 4 characters or less"
  }
}

variable "resource_name_environment" {
  type        = string
  description = "The name segment for the environment"
  default     = "dev"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.resource_name_environment))
    error_message = "The name segment for the environment must only contain lowercase letters and numbers"
  }
  validation {
    condition     = length(var.resource_name_environment) <= 4
    error_message = "The name segment for the environment must be 4 characters or less"
  }
}

variable "resource_name_sequence_start" {
  type        = number
  description = "The number to use for the resource names"
  default     = 1
  validation {
    condition     = var.resource_name_sequence_start >= 1 && var.resource_name_sequence_start <= 999
    error_message = "The number must be between 1 and 999"
  }
}

variable "resource_name_templates" {
  type        = map(string)
  description = "A map of resource names to use"
  default = {
    resource_group_name          = "rg-$${workload}-$${environment}-$${location}-$${sequence}"
    log_analytics_workspace_name = "law-$${workload}-$${environment}-$${location}-$${sequence}"
    virtual_network_name         = "vnet-$${workload}-$${environment}-$${location}-$${sequence}"
    storage_account_name         = "sto$${workload}$${environment}$${location_short}$${sequence}$${uniqueness}"
  }
}

variable "address_space" {
  type        = string
  description = "The address space that is used the virtual network"
}

variable "subnets" {
  type = map(object({
    size = number
  }))
  description = "The subnets"
}