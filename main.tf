module "resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.4.0"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.2"

  parent_id     = module.resource_group.resource_id
  subnets       = var.subnets
  address_space = [var.address_space]
  location      = var.location
  name          = var.vnet_name
  tags          = var.tags
}

module "private_dns_zone_storage_account" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.5.0"

  parent_id   = module.resource_group.resource_id
  domain_name = "privatelink.blob.core.windows.net"

  virtual_network_links = {
    vnetlink1 = {
      name               = "storage-account"
      virtual_network_id = module.virtual_network.resource_id
    }
  }

  tags = var.tags
}

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.10.0"

  account_replication_type          = "LRS"
  location                          = var.location
  name                              = var.storage_account_name
  parent_id                         = module.resource_group.resource_id
  infrastructure_encryption_enabled = true

  managed_identities = {
    system_assigned = true
  }

  containers = {
    demo = {
      name          = "demo"
      public_access = "None"
    }
  }

  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [module.private_dns_zone_storage_account.resource_id]
      subnet_resource_id            = module.virtual_network.subnets["subnet1"].resource_id
      subresource_name              = "blob"
      tags                          = var.tags
    }
  }

  tags = var.tags
}
