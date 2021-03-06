terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_cosmosdb_account" "cdb" {
  name                            = var.name
  location                        = var.locations[0]
  resource_group_name             = var.resource_group
  offer_type                      = "Standard"
  kind                            = "GlobalDocumentDB"
  enable_automatic_failover       = true
  enable_multiple_write_locations = var.multi_master
  enable_free_tier                = var.free

  dynamic "capabilities" {
    for_each = var.serverless ? ["1"] : []
    content {
      name = "EnableServerless"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  dynamic "geo_location" {
    for_each = var.locations
    content {
      failover_priority = geo_location.key
      location          = geo_location.value
    }
  }
}

resource "azurerm_cosmosdb_sql_database" "access_db" {
  name                = "access"
  resource_group_name = azurerm_cosmosdb_account.cdb.resource_group_name
  account_name        = azurerm_cosmosdb_account.cdb.name
}

resource "azurerm_cosmosdb_sql_container" "user_preference_access_cont" {
  name                  = "UserPreferences"
  resource_group_name   = azurerm_cosmosdb_account.cdb.resource_group_name
  account_name          = azurerm_cosmosdb_account.cdb.name
  database_name         = azurerm_cosmosdb_sql_database.access_db.name
  partition_key_path    = "/id"
  partition_key_version = 2
}



resource "azurerm_cosmosdb_sql_database" "notifications_db" {
  name                = "notifications"
  resource_group_name = azurerm_cosmosdb_account.cdb.resource_group_name
  account_name        = azurerm_cosmosdb_account.cdb.name
}

resource "azurerm_cosmosdb_sql_container" "push_subscriptions_notifications_cont" {
  name                  = "PushSubscriptions"
  resource_group_name   = azurerm_cosmosdb_account.cdb.resource_group_name
  account_name          = azurerm_cosmosdb_account.cdb.name
  database_name         = azurerm_cosmosdb_sql_database.notifications_db.name
  partition_key_path    = "/UserId"
  partition_key_version = 2
}

resource "azurerm_cosmosdb_sql_container" "notifications_notifications_cont" {
  name                  = "Notifications"
  resource_group_name   = azurerm_cosmosdb_account.cdb.resource_group_name
  account_name          = azurerm_cosmosdb_account.cdb.name
  database_name         = azurerm_cosmosdb_sql_database.notifications_db.name
  partition_key_path    = "/UserId"
  partition_key_version = 2
}




resource "azurerm_cosmosdb_sql_database" "forms_db" {
  name                = "forms"
  resource_group_name = azurerm_cosmosdb_account.cdb.resource_group_name
  account_name        = azurerm_cosmosdb_account.cdb.name
}

resource "azurerm_cosmosdb_sql_container" "forms_forms_cont" {
  name                  = "Forms"
  resource_group_name   = azurerm_cosmosdb_account.cdb.resource_group_name
  account_name          = azurerm_cosmosdb_account.cdb.name
  database_name         = azurerm_cosmosdb_sql_database.forms_db.name
  partition_key_path    = "/UserId"
  partition_key_version = 2
}

resource "azurerm_cosmosdb_sql_container" "forms_datas_forms_cont" {
  name                  = "FormDatas"
  resource_group_name   = azurerm_cosmosdb_account.cdb.resource_group_name
  account_name          = azurerm_cosmosdb_account.cdb.name
  database_name         = azurerm_cosmosdb_sql_database.forms_db.name
  partition_key_path    = "/FormId"
  partition_key_version = 2
}
