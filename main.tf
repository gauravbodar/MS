# event_hub_namespace.tf
module "eventhub_namespace" {
  source  = "Azure/monitor/eventhub-namespace/azurerm"
  version = "4.0.0"

  resource_group_name = var.rg_name
  location            = var.location
  name                = var.eh_namespace
  sku                 = "Standard"
  capacity            = 1
  tags                = var.tags
}

# event_hub.tf
module "eventhub" {
  source  = "Azure/monitor/eventhub/azurerm"
  version = "4.0.0"

  resource_group_name  = var.rg_name
  namespace_name       = module.eventhub_namespace.name
  name                 = var.eh_name
  partition_count      = 4
  message_retention    = 1
  tags                 = var.tags
}

# eventhub_data_export_rule.tf
module "eventhub_export_rule" {
  source  = "Azure/monitor/eventhub-data-export/azurerm"
  version = "4.0.0"

  resource_group_name = var.rg_name
  name                = "${var.prefix}-${var.environment}-export-rule"
  eventhub_namespace  = module.eventhub_namespace.name
  eventhub_name       = module.eventhub.name
  # example: attach export from Log Analytics or Diagnostic Settings later
  tags = var.tags
}

# logic_app.tf
module "logic_app" {
  source  = "Azure/logic-app/azurerm" # if using AVM Logic App module; if not, use native azurerm_logic_app_workflow
  version = "4.0.0"

  resource_group_name = var.rg_name
  location            = var.location
  name                = var.logic_app_name
  state               = "Enabled"
  tags                = var.tags

  # expose a webhook trigger endpoint in outputs for Action Group to call
}

# action_group.tf
module "action_group" {
  source  = "Azure/monitor/action-group/azurerm"
  version = "4.0.0"

  resource_group_name = var.rg_name
  name                = "${var.prefix}-${var.environment}-ag"
  short_name          = "${var.prefix}AG"
  email_receivers = [{
    name                  = "oncall"
    email_address         = "oncall@acme.example"
    use_common_alert_schema = true
  }]
  webhook_receivers = [{
    name = "logicapp-webhook"
    service_uri = module.logic_app.callback_url # assumes module exports callback_url
  }]
  tags = var.tags
}

# metric_alert.tf
module "metric_alert" {
  source  = "Azure/monitor/metric-alert/azurerm"
  version = "4.0.0"

  resource_group_name = var.rg_name
  name                = "${var.prefix}-${var.environment}-high-cpu"
  scopes              = [module.eventhub_namespace.id] # example target; replace with VM or AKS scope
  criteria = {
    metric_name = "Percentage CPU"
    operator    = "GreaterThan"
    threshold   = 90
    time_aggregation = "Average"
    evaluation_periods = 3
  }
  actions = [{
    action_group_id = module.action_group.id
  }]
  tags = var.tags
}

# ampls_scoped_service.tf
module "ampls_scoped_service" {
  source  = "Azure/monitor/ampls-scoped-service/azurerm"
  version = "4.0.0"

  resource_group_name = var.rg_name
  location            = var.location
  name                = "${var.prefix}-${var.environment}-ampls"
  # properties to scope monitoring workload or downstream settings
  tags = var.tags
}

###############################################
# diagnostic_to_eventhub.tf
resource "azurerm_monitor_diagnostic_setting" "la_to_eh" {
  name               = "${var.prefix}-${var.environment}-la-to-eh"
  target_resource_id = module.log_analytics_workspace.id
  eventhub_name      = module.eventhub.name
  eventhub_namespace_id = module.eventhub_namespace.id
  log {
    category = "Administrative"
    enabled  = true
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  depends_on = [module.eventhub, module.eventhub_namespace]
}
