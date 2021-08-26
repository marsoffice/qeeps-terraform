terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}


resource "azurerm_storage_account" "storage_account" {
  name                     = var.name
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = var.tier
  account_replication_type = var.replication_type
  access_tier = var.access_tier
}

resource "azurerm_storage_container" "user_files_container" {
  name                  = "userfiles"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"

  count = var.create_containers == true ? 1 : 0
}
