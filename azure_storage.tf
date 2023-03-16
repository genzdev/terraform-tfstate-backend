data "azurerm_resource_group" "axer" {
  name = "Axer"
}

data "azurerm_storage_account" "axerstandard" {
  name                = "axerstandard"
  resource_group_name = data.azurerm_resource_group.axer.name
}

resource "azurerm_storage_container" "tf_state_bucket" {
  name                  = "${var.namespace}-${var.stage}-${var.name}-state-backend"
  storage_account_name  = data.azurerm_storage_account.axerstandard.name
  container_access_type = "private"
}
