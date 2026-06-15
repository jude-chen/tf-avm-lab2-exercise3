module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.12.0"
}

resource "random_string" "unique_name" {
  length  = 3
  special = false
  upper   = false
  numeric = false
}

module "resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.4.0"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  name                = local.resource_names.log_analytics_workspace_name
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
}

module "avm-utl-network-ip-addresses" {
  source  = "Azure/avm-utl-network-ip-addresses/azurerm"
  version = "0.1.1"

  address_space    = var.address_space
  address_prefixes = { for key, value in var.subnets : key => value.size }
}

module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.18.0"

  parent_id = module.resource_group.resource_id
  subnets   = local.subnets
  address_space = [var.address_space]
  location  = var.location
  name      = local.resource_names.virtual_network_name
  diagnostic_settings = local.diagnostic_settings
  tags      = var.tags
}

module "private_dns_zone_storage_account" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"

  parent_id   = module.resource_group.resource_id
  domain_name = "privatelink.blob.core.windows.net"

  virtual_network_links = {
    vnetlink1 = {
      name             = "storage-account"
      virtual_network_id = module.virtual_network.resource_id
    }
  }

  tags = var.tags
}

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.7.2"

  account_replication_type          = "LRS"
  location                          = var.location
  name                              = local.resource_names.storage_account_name
  parent_id                         = module.resource_group.resource_id
  infrastructure_encryption_enabled = true

  managed_identities = {
    system_assigned = true
    # user_assigned_resource_ids = [module.user_assigned_managed_identity.resource_id]
  }

  #   customer_managed_key = {
  #     key_vault_resource_id  = module.key_vault.resource_id
  #     key_name               = reverse(split("/", module.key_vault.keys_resource_ids["cmk_for_storage_account"].versionless_id))[0]
  #     user_assigned_identity = { resource_id = module.user_assigned_managed_identity.resource_id }
  #   }

  containers = {
    demo = {
      name           = "demo"
      public_access  = "None"
    }
  }

  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [module.private_dns_zone_storage_account.resource_id]
      subnet_resource_id            = module.virtual_network.subnets["private_endpoints"].resource_id
      subresource_name              = "blob"
      tags                          = var.tags
    }
  }

  diagnostic_settings_storage_account = local.diagnostic_settings
  diagnostic_settings_blob            = local.diagnostic_settings
  tags                                = var.tags
}