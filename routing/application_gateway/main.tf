locals {
  resource_group="app-grp"
  location="West US"  
}

resource "azurerm_resource_group" "app_grp"{
  name=local.resource_group
  location=local.location
}
