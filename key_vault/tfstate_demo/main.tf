terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.1.0"
    }
  }
    backend "azurerm" {
        resource_group_name  = "tfstate-rg"
        storage_account_name = "tfstatestoracceric"
        container_name       = "tfstate"
        key                  = "demo-terraform.tfstate"
    }

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "state-demo-secure" {
  name     = "state-demo"
  location = "eastus"
}