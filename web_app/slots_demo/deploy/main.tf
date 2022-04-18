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
  location="West US"  
}


resource "azurerm_resource_group" "app_grp"{
  name=local.resource_group
  location=local.location
}

resource "azurerm_service_plan" "primary_plan" {
  name                = "primary-plan10003212"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  os_type             = "Linux"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_linux_web_app" "node_webapp" {
  name                = "primaryapp10003212"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  service_plan_id = azurerm_service_plan.primary_plan.id

  site_config {    
    application_stack {
        node_version = "14-lts"
    }
  }

  depends_on = [
    azurerm_service_plan.primary_plan
  ]
}

resource "azurerm_app_service_source_control" "primary_source" {
  app_id   = azurerm_linux_web_app.node_webapp.id
  repo_url = "https://github.com/haochen23/demoApp1"
  branch   = "master"
}

resource "azurerm_linux_web_app_slot" "stage_slot" {
  name           = "stage"
  app_service_id = azurerm_linux_web_app.node_webapp.id

  site_config {
      application_stack {
        node_version = "14-lts"
    }
  }
  depends_on = [
    azurerm_linux_web_app.node_webapp
  ]
}


resource "azurerm_app_service_source_control_slot" "stage_source" {
  slot_id  = azurerm_linux_web_app_slot.stage_slot.id
  repo_url = "https://github.com/haochen23/demoApp1"
  branch   = "feature/green-bg"
}