data "azurerm_key_vault" "axer_key_vault" {
  name                = "axer-key-vault"
  resource_group_name = data.azurerm_resource_group.axer.name
}

data "azurerm_key_vault_secret" "storage_account_access_key" {
  name         = "axerstandard-access-key"
  key_vault_id = data.azurerm_key_vault.axer_key_vault.id
}

data "azurerm_key_vault_secret" "aws_access_key_id" {
  name         = "aws-access-key-id"
  key_vault_id = data.azurerm_key_vault.axer_key_vault.id
}

data "azurerm_key_vault_secret" "aws_secret_access_key" {
  name         = "aws-secret-access-key"
  key_vault_id = data.azurerm_key_vault.axer_key_vault.id
}
