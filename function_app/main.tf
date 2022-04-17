terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}


locals {
  resource_group="app-grp"
  location="North Europe"
}


resource "azurerm_resource_group" "app_grp"{
  name=local.resource_group
  location=local.location
}

resource "azurerm_storage_account" "functionstore_0sfe9" {
  name                     = "functionstore0sfe9"
  resource_group_name      = azurerm_resource_group.app_grp.name
  location                 = azurerm_resource_group.app_grp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "function_app_plan" {
  name                = "function-app-plan"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  os_type             = "Linux"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_linux_function_app" "linux_function3321" {
  name                = "linuxfunction3321"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location

  storage_account_name = azurerm_storage_account.functionstore_0sfe9.name
  service_plan_id      = azurerm_service_plan.function_app_plan.id

  site_config {
      application_stack {
          node_version = "14"
      }
  }
}

