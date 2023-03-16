data "archive_file" "MultiCloudSyncAzure" {
  type        = "zip"
  source_dir  = "${path.module}/functions/MultiCloudSyncAzure"
  output_path = "${path.module}/zip/MultiCloudSyncAzure.zip"
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.namespace}-${var.stage}-${var.name}-application-insights"
  location            = data.azurerm_resource_group.axer.location
  resource_group_name = data.azurerm_resource_group.axer.name
  application_type    = "Node.JS"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.namespace}-${var.stage}-${var.name}-app-service-plan"
  resource_group_name = data.azurerm_resource_group.axer.name
  location            = data.azurerm_resource_group.axer.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_storage_container" "function_releases" {
  name                  = "${var.namespace}-${var.stage}-${var.name}-function-releases"
  storage_account_name  = data.azurerm_storage_account.axerstandard.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "function_releases" {
  name                   = "${filesha256(data.archive_file.MultiCloudSyncAzure.output_path)}.zip"
  storage_account_name   = data.azurerm_storage_account.axerstandard.name
  storage_container_name = azurerm_storage_container.function_releases.name
  type                   = "Block"
  source                 = data.archive_file.MultiCloudSyncAzure.output_path
}

resource "azurerm_linux_function_app" "function_app" {
  enabled             = var.primary_cloud == "azure" ? true : false
  name                = "${var.namespace}-${var.stage}-${var.name}-function-app"
  resource_group_name = data.azurerm_resource_group.axer.name
  location            = data.azurerm_resource_group.axer.location

  storage_account_name       = data.azurerm_storage_account.axerstandard.name
  storage_account_access_key = data.azurerm_storage_account.axerstandard.primary_access_key
  service_plan_id            = azurerm_service_plan.app_service_plan.id

  site_config {
    application_insights_key               = azurerm_application_insights.application_insights.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.application_insights.connection_string
    application_stack {
      node_version = 16
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"                 = "https://${data.azurerm_storage_account.axerstandard.name}.blob.core.windows.net/${azurerm_storage_container.function_releases.name}/${azurerm_storage_blob.function_releases.name}${data.azurerm_storage_account_blob_container_sas.function_releases.sas}",
    "AWS_ACCESS_KEY_ID"                        = data.azurerm_key_vault_secret.aws_access_key_id.value,
    "AWS_SECRET_ACCESS_KEY"                    = data.azurerm_key_vault_secret.aws_secret_access_key.value,
    "AzureWebJobsStorage"                      = "DefaultEndpointsProtocol=https;AccountName=${data.azurerm_storage_account.axerstandard.name};AccountKey=${data.azurerm_key_vault_secret.storage_account_access_key.value};EndpointSuffix=core.windows.net",
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = "DefaultEndpointsProtocol=https;AccountName=${data.azurerm_storage_account.axerstandard.name};AccountKey=${data.azurerm_key_vault_secret.storage_account_access_key.value};EndpointSuffix=core.windows.net",
    "ENV"                                      = terraform.workspace,
    "STATE_BUCKET"                             = azurerm_storage_container.tf_state_bucket.name
  }
}

data "azurerm_storage_account_blob_container_sas" "function_releases" {
  connection_string = data.azurerm_storage_account.axerstandard.primary_connection_string
  container_name    = azurerm_storage_container.function_releases.name
  https_only        = true

  start  = formatdate("YYYY-MM-DD", timestamp())
  expiry = formatdate("YYYY-MM-DD", timeadd(timestamp(), "24h"))

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = true
  }
}
