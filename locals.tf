locals {
  # Calculate resource names
  name_replacements = {
    workload       = var.resource_name_workload
    environment    = var.resource_name_environment
    location       = var.location
    location_short = var.resource_name_location_short == "" ? module.regions.regions_by_name[var.location].geo_code : var.resource_name_location_short
    uniqueness     = random_string.unique_name.id
    sequence       = format("%03d", var.resource_name_sequence_start)
  }

  resource_names = { for key, value in var.resource_name_templates : key => templatestring(value, local.name_replacements) }

  # Calculate the CIDR for the subnets
  subnets = { for key, value in var.subnets : key => {
    name             = key
    address_prefixes = [module.avm-utl-network-ip-addresses.address_prefixes[key]]
    }
  }

  # Diagnostic settings
  diagnostic_settings = {
    sendToLogAnalytics = {
      name                  = "sendToLogAnalytics"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  # Storage account scope supports metrics only (logs are rejected at this scope).
  diagnostic_settings_storage_account = {
    sendToLogAnalytics = {
      name                  = "sendToLogAnalytics"
      workspace_resource_id = module.log_analytics_workspace.resource_id
      metrics = [
        {
          category = "AllMetrics"
          enabled  = true
        }
      ]
    }
  }

  diagnostic_settings_blob = {
    sendToLogAnalytics = {
      name                  = "sendToLogAnalytics"
      workspace_resource_id = module.log_analytics_workspace.resource_id
      logs = [
        {
          category_group = "allLogs"
          enabled        = true
        }
      ]
      metrics = [
        {
          category = "AllMetrics"
          enabled  = true
        }
      ]
    }
  }

}
