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
  resource_group="tfstate-rg"
  location="East US"
}

resource "azurerm_resource_group" "tfstate_rg"{
  name=local.resource_group
  location=local.location
}

resource "azurerm_storage_account" "tfstate_storage" {
  name                     = "tfstatestoracceric"
  resource_group_name      = azurerm_resource_group.tfstate_rg.name
  location                 = azurerm_resource_group.tfstate_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate_storage.name
  container_access_type = "private"
#   container_access_type = "public"
  depends_on = [
    azurerm_storage_account.tfstate_storage
  ]
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "tfstate_vault" {  
  name                        = "tfstate-vault-eric"
  location                    = azurerm_resource_group.tfstate_rg.location
  resource_group_name         = azurerm_resource_group.tfstate_rg.name  
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Get",
    ]
    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]
    storage_permissions = [
      "Get",
    ]
  }
  depends_on = [
    azurerm_resource_group.tfstate_rg
  ]
}

resource "azurerm_key_vault_secret" "storage_key" {
  name         = "storage-accesskey"
  value        = azurerm_storage_account.tfstate_storage.primary_access_key
  key_vault_id = azurerm_key_vault.tfstate_vault.id
  depends_on = [ 
      azurerm_key_vault.tfstate_vault,
      azurerm_storage_account.tfstate_storage ]
}