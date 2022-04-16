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
  name                = "primary-plan10003211"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.app_grp.name

  os_type             = "Linux"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_linux_web_app" "primary_webapp" {
  name                = "primaryapp10003211"
  location            = "North Europe"
  resource_group_name = azurerm_resource_group.app_grp.name
  service_plan_id = azurerm_service_plan.primary_plan.id

  site_config {    
    application_stack {
          docker_image = "ericchen23/demoapp1"
          docker_image_tag = "0.1.0"
      }
  }

  depends_on = [
    azurerm_service_plan.primary_plan
  ]
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
          docker_image = "ericchen23/demoapp2"
          docker_image_tag = "0.1.0"
      }
  }
  depends_on = [
    azurerm_service_plan.secondary_plan
  ]
}

// Here we are creating a Traffic Manager Profile

resource "azurerm_traffic_manager_profile" "traffic_profile" {
  name                   = "traffic-profile20003211"
  resource_group_name    = azurerm_resource_group.app_grp.name
  traffic_routing_method = "Priority"
   dns_config {
    relative_name = "traffic-profile20003211"
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
