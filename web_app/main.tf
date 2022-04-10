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

resource "azurerm_service_plan" "app_plan_linux" {
  name                = "app-plan-erictestlinux"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  os_type             = "Linux"
  sku_name            = "B1"
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_service_plan" "app_plan_windows" {
  name                = "app-plan-erictestwindows"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  os_type             = "Windows"
  sku_name            = "B1"
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "testwebappericlinux"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  service_plan_id = azurerm_service_plan.app_plan_linux.id

  site_config {}
  depends_on = [
    azurerm_service_plan.app_plan_linux
    ]
}

resource "azurerm_windows_web_app" "webappwindows" {
  name                = "testwebappericwindows"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  service_plan_id = azurerm_service_plan.app_plan_windows.id

  site_config {}
  depends_on = [
    azurerm_service_plan.app_plan_windows
  ]
}