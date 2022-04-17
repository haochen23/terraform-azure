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

resource "azurerm_service_plan" "primary_plan" {
  name                = "primary-plan1000321"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.app_grp.name

  os_type             = "Linux"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_linux_web_app" "primary_webapp" {
  name                = "primaryapp1000321"
  location            = "North Europe"
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
  app_id   = azurerm_linux_web_app.primary_webapp.id
  repo_url = "https://github.com/haochen23/demoApp1"
  branch   = "master"
}

resource "azurerm_service_plan" "secondary_plan" {
  name                = "secondary-plan1000231"
  location            = "UK South"
  resource_group_name = azurerm_resource_group.app_grp.name

  os_type             = "Linux"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_linux_web_app" "secondary_webapp" {
  name                = "secondaryapp1000321"
  location            = "UK South"
  resource_group_name = azurerm_resource_group.app_grp.name
  service_plan_id = azurerm_service_plan.secondary_plan.id

  site_config {    
    application_stack {
        node_version = "14-lts"
    }
  }
  depends_on = [
    azurerm_service_plan.secondary_plan
  ]
}

resource "azurerm_app_service_source_control" "secondary_source" {
  app_id   = azurerm_linux_web_app.secondary_webapp.id
  repo_url = "https://github.com/haochen23/demoApp2"
  branch   = "master"
}

// Here we are creating a Traffic Manager Profile

resource "azurerm_traffic_manager_profile" "traffic_profile" {
  name                   = "traffic-profile2000321"
  resource_group_name    = azurerm_resource_group.app_grp.name
  traffic_routing_method = "Priority"
   dns_config {
    relative_name = "traffic-profile2000321"
    ttl           = 100
  }
  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 2
  }
  }


resource "azurerm_traffic_manager_azure_endpoint" "primary_endpoint" {
  name               = "primary-endpoint"
  profile_id         = azurerm_traffic_manager_profile.traffic_profile.id
  priority           = 1
  weight             = 100
  target_resource_id = azurerm_linux_web_app.primary_webapp.id
}


resource "azurerm_traffic_manager_azure_endpoint" "secondary_endpoint" {
  name               = "secondary-endpoint"
  profile_id         = azurerm_traffic_manager_profile.traffic_profile.id
  priority           = 2
  weight             = 100
  target_resource_id = azurerm_linux_web_app.secondary_webapp.id
}
