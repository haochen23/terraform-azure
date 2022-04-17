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



// We need to define the action group
resource "azurerm_monitor_action_group" "email_alert" {
  name                = "email-alert"
  resource_group_name = azurerm_resource_group.app_grp.name
  short_name          = "email-alert"

   email_receiver {
    name                    = "sendtoAdmin"
    email_address           = "testemail@example.com"
    use_common_alert_schema = true
  }

}

resource "azurerm_consumption_budget_resource_group" "Monthly_budget" {
  name              = "Monthly-budget"
  resource_group_id = azurerm_resource_group.app_grp.id

  amount     = 100
  time_grain = "Monthly"

  time_period {
    start_date = "2022-05-01T00:00:00Z"
    end_date   = "2022-12-01T00:00:00Z"
  }

    notification {
    enabled        = true
    threshold      = 70.0
    operator       = "EqualTo"
    threshold_type = "Forecasted"

    
    contact_groups = [
      azurerm_monitor_action_group.email_alert.id,
    ]

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
    }

    notification {
    enabled   = false
    threshold = 100.0
    operator  = "GreaterThan"

    contact_emails = [
      "foo@example.com",
      "bar@example.com",
    ]
  }
  depends_on = [
    azurerm_resource_group.app_grp,
    azurerm_monitor_action_group.email_alert
  ]
}