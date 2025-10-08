# log_analytics.tf
module "log_analytics_workspace" {
  source  = "Azure/monitor/log-analytics/azurerm"
  version = "3.7.1"

  resource_group_name = var.rg_name
  location            = var.location
  workspace_name      = var.la_workspace_name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = var.tags

  # example naming/tagging fields supported by AVM
  prefix = var.prefix
  environment = var.environment
}

# data_collection_endpoint.tf
module "data_collection_endpoint" {
  source  = "Azure/monitor/data-collection-endpoint/azurerm"
  version = "3.7.1"

  resource_group_name = var.rg_name
  location            = var.location
  name                = var.dce_name
  tags                = var.tags
}

# data_collection_rule.tf
module "data_collection_rule" {
  source  = "Azure/monitor/data-collection-rule/azurerm"
  version = "3.7.1"

  resource_group_name      = var.rg_name
  location                 = var.location
  name                     = var.dcr_name
  data_collection_endpoint = module.data_collection_endpoint.id
  # bind to the Log Analytics workspace as destination
  destinations = {
    log_analytics = {
      workspace_resource_id = module.log_analytics_workspace.id
    }
  }
  # sample streams, transforms can be supplied as inputs
  tags = var.tags
}

# application_insights.tf
module "app_insights" {
  source  = "Azure/monitor/application-insights/azurerm"
  version = "3.7.1"

  resource_group_name = var.rg_name
  location            = var.location
  name                = var.app_insights_name
  application_type    = "web"
  # Link App Insights to Log Analytics workspace for cross-resource queries
  workspace_id = module.log_analytics_workspace.id
  tags = var.tags
}
