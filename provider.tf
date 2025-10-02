terraform {
  required_version = ">= 1.2.0" # corrected (1.12.2 is invalid, should be 1.2.x+)

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.71, <5.0" # allow both 3.71.x and 4.x range
    }
  }
}

# Provider for resources needing ~>3.71 (e.g. DCE, DCR)
provider "azurerm" {
  alias   = "v371"
  version = "~>3.71"
  features {}
}

# Provider for resources needing ~>4.0 (e.g. Eventhub, Alerts, AppInsights)
provider "azurerm" {
  alias   = "v40"
  version = "~>4.0"
  features {}
}

--------------------------------------------
# Data Collection Endpoint (needs 3.71)
module "dce" {
  source    = "Azure/avm-res-insights-datacollectionendpoint/azurerm"
  providers = { azurerm = azurerm.v371 }

  name                = "my-dce"
  location            = var.location
  resource_group_name = var.rg_name
}

# Eventhub Namespace (needs 4.0)
module "eventhub_ns" {
  source    = "Azure/avm-res-eventhub-namespace/azurerm"
  providers = { azurerm = azurerm.v40 }

  name                = "myehns"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"
  capacity            = 1
}
