terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.1.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "azurerm_resource_group" "app_rg"{
  name="app-rp" 
  location="East US"
}

# Here we are creating a storage account.
# The storage account service has more properties and hence there are more arguements we can specify here

resource "azurerm_storage_account" "storage_account" {
  name                     = "terraformstorestoracc"
  resource_group_name      = azurerm_resource_group.app_rg.name
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = true
  depends_on = [
    azurerm_resource_group.app_rg
  ]
}

# Here we are creating a container in the storage account
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.storage_account.name
#   container_access_type = "private"
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

# This is used to upload a local file onto the container
resource "azurerm_storage_blob" "sample" {
  name                   = "test_upload.txt"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.data.name
  type                   = "Block"
  source                 = "test_upload.txt"
  depends_on = [
    azurerm_storage_container.data
  ]
}