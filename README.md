# terraform-tfstate-backend

A multi-cloud Terraform module that provision an storage space to store the `terraform.tfstate` file and a DB table to lock the state file to prevent concurrent modifications and state corruption.

## Usage:

### Steps to Configure:

- Set the `primary_cloud` input to the initial remote backend, while being on `local` backend.
- Suppose you want to migrate the state to `s3` backend initially, set the `primary_cloud` input to `aws`.
- Now do an apply while being on `local` backend.
- This step enables primary cloud trigger and its required function handler.
- Set the backend configuration files as included in `examples/complete` directory for specific workspace in the root configuration.
- Now initialize terraform with initial remote state with `-force-copy` flag, in our example it was `s3`.
- Immediate step after changing backend is to change `primary_cloud` input to the specific cloud. Except for the initial transfer from `local` to `s3` or `gcs` or `azurerm`.
- Now do an apply with specific remote backend and on correct workspace.
- Above step enables specific backend trigger and its function handler.
- Repeat these steps, whenever changing backends.
- Do not `terraform destroy`, while state is being stored on any of the remote backend. Instead change the backend to `local` and set `force_destroy` input to `true`, before destroying the resources.
- This module supports fault tolerence, so if state is lost we can recover from other clouds object storage.

### Note:

- Include google service account key json file from your GCP with Storage Admin access as `functions/MultiCloudSync/lambdaServiceAccount.json` for authentication to google storage from `MultiCloudSync` Lambda.
- Include google service account key json file from your GCP with Storage Admin access as `functions/MultiCloudSyncAzure/MultiCloudSync/azureServiceAccount.json` for authentication to google storage from `MultiCloudSync` Azure Function.
- For Above steps, naming of files should be exact.

## Terraform setup with Google Cloud provider:

### Assumptions:

- You have a active `Google Cloud Project` configured.
- You have attached a valid `Billing Account` to the above project.
- You have installed and initialized `gcloud` CLI tool on your local system.

### Steps:

- To authorize Terraform to deploy cloud resources, we need a `Google Service Account` with appropriate permissions representing Terraform as a service.
- To create `Service Account`, navigate to Service Accounts page under `IAM` in Google cloud console.
- While configuring Service Account, attach appropriate roles(i.e `Basic roles`, `Predefined roles` or `Custom roles`) to the Service account.
- For example, if Terraform needs to deploy resources in `Cloud Storage`, grant `Owner` Basic role and `Storage Admin` Predefined role to the Service account.
- After Successfully creating Service account, download the `Key JSON` file and store it locally inside Terraform project.
- Reference the above Key JSON file inside Terraform google provider block for `credentials` attribute(i.e Local path to the file).
- Now Intialize Terraform(i.e `terraform init`). Hurray!! You are now successfully authenticated to Google cloud.

### Note:

- Google Cloud's `Owner` Basic role, doesn't have all the permissions for a specific resource. Instead it has most of the commonly used permissions for all the resources.
- So if you want Admin level access to a specific resource, add the specific resource Admin Predefined role to your use case.
- For example, you need Admin level access to `Cloud Storage` resource add `roles/storage.admin` Predefined role.

## Terraform setup with Azure provider:

### Assumptions:

- You already have Azure account set using Microsoft account.
- You have a active `Azure Subscription` linked to `Azure AD` instance(i.e `tenant`).
- You have installed `Azure CLI` tool on your system.

### Steps:

- To Authenticate Terraform using `Azure CLI`, run

  ```shell
  az login
  ```

- The above command will initiate web-browser based authentication to Microsoft Azure.
- Sign-in with the account, which is linked to the active tenant(i.e where the resources gets deployed).
- You should see a JSON object similar to this on command-line, after successfull authentication.

  ```
  [
  {
      "cloudName": "AzureCloud",
      "homeTenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "id": "00000000-0000-0000-0000-000000000000",
      "isDefault": true,
      "managedByTenants": [],
      "name": "Azure subscription 1",
      "state": "Enabled",
      "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "user": {
          "name": "user@example.com",
          "type": "user"
      }
  }
  ]
  ```

- Where `id` is the Azure Subscription ID associated with that tenant.
- As a result, `~/.azure/azureProfile.json` file is created, which is used by terraform to authenticate to Azure.
- Hurray !!, you have successfully authenticated Terraform with Azure.

### Note:

- To work on a different terraform workspace, do

  ```shell
  az login --tenant <tenant_id>
  ```

  using appropriate tenant ID.

## Requirements

| Name                                                                     | Version        |
| ------------------------------------------------------------------------ | -------------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.13.0      |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 3.38        |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >= 3.0.0       |
| <a name="requirement_google"></a> [google](#requirement_google)          | < 5.0, >= 3.83 |

## Providers

| Name                                                         | Version        |
| ------------------------------------------------------------ | -------------- |
| <a name="provider_archive"></a> [archive](#provider_archive) | n/a            |
| <a name="provider_aws"></a> [aws](#provider_aws)             | >= 3.38        |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | >= 3.0.0       |
| <a name="provider_google"></a> [google](#provider_google)    | < 5.0, >= 3.83 |

## Modules

| Name                                                                                                                                                                       | Source                | Version |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- | ------- |
| <a name="module_aws_cloudwatch_log_group_MultiCloudSync_label"></a> [aws_cloudwatch_log_group_MultiCloudSync_label](#module_aws_cloudwatch_log_group_MultiCloudSync_label) | cloudposse/label/null | 0.25.0  |
| <a name="module_aws_iam_MultiCloudSync_label"></a> [aws_iam_MultiCloudSync_label](#module_aws_iam_MultiCloudSync_label)                                                    | cloudposse/label/null | 0.25.0  |
| <a name="module_aws_lambda_function_MultiCloudSync_label"></a> [aws_lambda_function_MultiCloudSync_label](#module_aws_lambda_function_MultiCloudSync_label)                | cloudposse/label/null | 0.25.0  |
| <a name="module_lambda_layer_main_label"></a> [lambda_layer_main_label](#module_lambda_layer_main_label)                                                                   | cloudposse/label/null | 0.25.0  |

## Resources

| Name                                                                                                                                                                                  | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_log_group.MultiCloudSync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                           | resource    |
| [aws_iam_role.MultiCloudSync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                   | resource    |
| [aws_iam_role_policy.MultiCloudSync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                                     | resource    |
| [aws_lambda_function.MultiCloudSync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                                     | resource    |
| [aws_lambda_layer_version.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version)                                                     | resource    |
| [aws_lambda_permission.MultiCloudSync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                                                 | resource    |
| [aws_s3_bucket.tf_state_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                | resource    |
| [aws_s3_bucket_acl.tf_state_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                                        | resource    |
| [aws_s3_bucket_notification.tf_state_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification)                                      | resource    |
| [aws_s3_bucket_versioning.tf_state_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                          | resource    |
| [azurerm_application_insights.application_insights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights)                             | resource    |
| [azurerm_linux_function_app.function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app)                                         | resource    |
| [azurerm_service_plan.app_service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan)                                                 | resource    |
| [azurerm_storage_blob.function_releases](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob)                                                | resource    |
| [azurerm_storage_container.function_releases](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container)                                      | resource    |
| [azurerm_storage_container.tf_state_bucket](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container)                                        | resource    |
| [google_cloudfunctions2_function.MultiCloudSync](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function)                             | resource    |
| [google_project_iam_member.artifactregistry-reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member)                                | resource    |
| [google_project_iam_member.event-receiving](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member)                                        | resource    |
| [google_project_iam_member.gcs-pubsub-publishing](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member)                                  | resource    |
| [google_project_iam_member.invoking](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member)                                               | resource    |
| [google_secret_manager_secret_iam_binding.aws_access_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_binding)           | resource    |
| [google_secret_manager_secret_iam_binding.aws_access_key_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_binding)    | resource    |
| [google_secret_manager_secret_iam_binding.azure_access_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_binding)         | resource    |
| [google_storage_bucket.cloud_functions_archive](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)                                        | resource    |
| [google_storage_bucket.tf_state_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)                                                | resource    |
| [google_storage_bucket_iam_policy.archive_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_policy)                           | resource    |
| [google_storage_bucket_object.MultiCloudSync_archive](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object)                           | resource    |
| [archive_file.MultiCloudSync](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                                                                | data source |
| [archive_file.MultiCloudSyncAzure](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                                                           | data source |
| [archive_file.MultiCloudSyncGCloud](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                                                          | data source |
| [archive_file.layer_main_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                                                                | data source |
| [aws_iam_policy_document.MultiCloudSync_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                 | data source |
| [aws_iam_policy_document.MultiCloudSync_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                          | data source |
| [azurerm_key_vault.axer_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault)                                                      | data source |
| [azurerm_key_vault_secret.aws_access_key_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret)                                     | data source |
| [azurerm_key_vault_secret.aws_secret_access_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret)                                 | data source |
| [azurerm_key_vault_secret.storage_account_access_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret)                            | data source |
| [azurerm_resource_group.axer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                                                      | data source |
| [azurerm_storage_account.axerstandard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account)                                            | data source |
| [azurerm_storage_account_blob_container_sas.function_releases](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account_blob_container_sas) | data source |
| [google_compute_default_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_default_service_account)                   | data source |
| [google_iam_policy.archive_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy)                                                      | data source |
| [google_secret_manager_secret_version.aws_access_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version)                | data source |
| [google_secret_manager_secret_version.aws_access_key_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version)         | data source |
| [google_secret_manager_secret_version.azure_access_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version)              | data source |
| [google_service_account.terraform_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account)                                 | data source |
| [google_storage_project_service_account.gcs_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_project_service_account)               | data source |

## Inputs

| Name                                                                                       | Description                                                                                                                    | Type           | Default                                                                                     | Required |
| ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------ | -------------- | ------------------------------------------------------------------------------------------- | :------: |
| <a name="input_aws_profile"></a> [aws_profile](#input_aws_profile)                         | Map of AWS profiles based on terraform workspace                                                                               | `map(string)`  | <pre>{<br> "dev": "axdev",<br> "prod": "axprod"<br>}</pre>                                  |    no    |
| <a name="input_aws_region"></a> [aws_region](#input_aws_region)                            | Map of AWS regions to deploy resources based on terraform workspace                                                            | `map(string)`  | <pre>{<br> "dev": "ca-central-1",<br> "prod": "ca-central-1"<br>}</pre>                     |    no    |
| <a name="input_force_destroy"></a> [force_destroy](#input_force_destroy)                   | Whether to delete storage bucket even if it is not empty                                                                       | `bool`         | `false`                                                                                     |    no    |
| <a name="input_google_region"></a> [google_region](#input_google_region)                   | Region where the Cloud Storage bucket is created                                                                               | `string`       | `"US"`                                                                                      |    no    |
| <a name="input_logs_retention_days"></a> [logs_retention_days](#input_logs_retention_days) | n/a                                                                                                                            | `number`       | `90`                                                                                        |    no    |
| <a name="input_name"></a> [name](#input_name)                                              | n/a                                                                                                                            | `string`       | `"multicloud"`                                                                              |    no    |
| <a name="input_namespace"></a> [namespace](#input_namespace)                               | n/a                                                                                                                            | `string`       | `"ifs"`                                                                                     |    no    |
| <a name="input_object_viewers"></a> [object_viewers](#input_object_viewers)                | List of principals to assign storage bucket object viewer role to the bucket. if user should be of form `user:*****@gmail.com` | `list(string)` | <pre>[<br> ""<br>]</pre>                                                                    |    no    |
| <a name="input_primary_cloud"></a> [primary_cloud](#input_primary_cloud)                   | Primary cloud to store state files. Allowed values are `aws`, `google` & `azure`                                               | `string`       | `"aws"`                                                                                     |    no    |
| <a name="input_stage"></a> [stage](#input_stage)                                           | n/a                                                                                                                            | `string`       | `"dev"`                                                                                     |    no    |
| <a name="input_storage_admins"></a> [storage_admins](#input_storage_admins)                | List of principals to assign storage admin role to the bucket. if user should be of form `user:*****@gmail.com`                | `list(string)` | <pre>[<br> "user:example@domain.com",<br> "user:example@gmail.com"<br>]</pre> |    no    |

## Outputs

No outputs.
