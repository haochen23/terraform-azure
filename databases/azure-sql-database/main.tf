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

resource "azurerm_mssql_server" "app_server" {
  name                         = "appsqlsvr231"
  resource_group_name          = azurerm_resource_group.app_grp.name
  location                     = local.location
  version             = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Azure@123"
}

resource "azurerm_mssql_database" "app_db" {
  name                = "appdb"
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "BC_Gen5_2"
  zone_redundant = false
  server_id         = azurerm_mssql_server.app_server.id
   depends_on = [
     azurerm_mssql_server.app_server
   ]
}

resource "azurerm_mssql_firewall_rule" "app_server_firewall_rule" {
  name                = "app-server-firewall-rule"
  server_id        = azurerm_mssql_server.app_server.id
  start_ip_address    = "101.98.111.142"
  end_ip_address      = "101.98.111.142"
  depends_on = [
    azurerm_mssql_server.app_server
  ]
}

resource "null_resource" "database_setup" {
  provisioner "local-exec" {
      command = "sqlcmd -S appsqlsvr231.database.windows.net -U sqladmin -P Azure@123 -d appdb -i init.sql"
  }
  depends_on=[
    azurerm_mssql_server.app_server
  ]
}