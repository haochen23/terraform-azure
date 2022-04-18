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

data azurerm_linux_web_app "node_webapp" {
    name           = "primaryapp10003212"
    resource_group_name = "app-grp"
}

resource "azurerm_web_app_active_slot" "example" {
  slot_id = format("%s/slots/stage", data.azurerm_linux_web_app.node_webapp.id)

}