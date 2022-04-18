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

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

locals {
  resource_group="app-grp"
  location="West US"  
}


resource "azurerm_resource_group" "app_grp"{
  name=local.resource_group
  location=local.location
}

resource "azurerm_cosmosdb_account" "db" {
  name                = "tfex-cosmos-db-${random_integer.ri.result}"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = false

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

#   geo_location {
#     location          = var.failover_location
#     failover_priority = 1
#   }

  geo_location {
    location          = azurerm_resource_group.app_grp.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "cosmos_mongo" {
  name                = "demo-cosmos-mongo-db"
  resource_group_name = azurerm_resource_group.app_grp.name
  account_name        = azurerm_cosmosdb_account.db.name
  throughput          = 400
  depends_on = [
    azurerm_cosmosdb_account.db
  ]
}

# output "connection" {
#   value = azurerm_cosmosdb_account.db.
# }

resource "azurerm_service_plan" "primary_plan" {
  name                = "primary-plan10003262"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  os_type             = "Linux"
  sku_name            = "B1"
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_linux_web_app" "node_webapp" {
  name                = "primaryapp10003262"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  service_plan_id = azurerm_service_plan.primary_plan.id

  site_config {    
    application_stack {
        node_version = "14-lts"
    }
  }
  app_settings = {
      "DATABASE_URL"=tostring("${azurerm_cosmosdb_account.db.connection_strings[0]}")
      }

  depends_on = [
    azurerm_service_plan.primary_plan,
    azurerm_cosmosdb_mongo_database.cosmos_mongo
  ]
}

// forked the repo from microsoft for the demo
resource "azurerm_app_service_source_control" "primary_source" {
  app_id   = azurerm_linux_web_app.node_webapp.id
  repo_url = "https://github.com/haochen23/msdocs-nodejs-mongodb-azure-sample-app"
  branch   = "main"
}