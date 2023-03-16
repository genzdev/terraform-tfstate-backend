# Example with terraform-state-backend module

## Configuration setup and migrate state to remote backend:

- Include `terraform-state-backend` module with your existing configuration, while on `local` state as shown below.

```
module "tf_state_backend_multi_cloud" {
  source        = "../.."
  name          = "multicloud"
  namespace     = "ifs"
  stage         = terraform.workspace
  primary_cloud = "azure"
  aws_profile = {
    dev  = "dev_profile"
    prod = "prod_profile"
  }
  storage_admins = [
    "user:xxxxxx@gmail.com",
    "user:yyyyyy@gmail.com"
  ]
  force_destroy = true
}
```

- Make sure to select the initial `primary_cloud` correctly.
- If you want to state from `local` to `s3` initially, then set `primary_cloud` as `aws`. Same with other remote backends.
- Apply the configuration on `dev` workspace.
- Make sure to include backend config files exactly as defined in `config` folder.
- Above naming convention of state files allows us to seamlessly migrate between remote backends (i.e `s3`, `gcs`, `azurerm`).
- Now migrate to initial `primary_cloud` backend using `terraform init --backend-config=config/aws/dev.txt -force-copy` command.
- At this moment, terraform state is sucessfully migrated to `s3` backend.
- If you do an apply now with modified infrastructure, the updated state is transferred to `gcs` and `azurerm` as well.
- Above step happens for every consequent applies.
- If you wish to use `gcs` backend instead of `s3`, then do `terraform init --backend-config=config/gcp/dev.txt -force-copy`.
- This is an **IMPORTANT** step, after migrating to `gcs` backend, change `primary_cloud` to `google` and then do an apply on `dev` workspace.
- Above steps activates google cloud function to transfer updated state to other clouds (i.e `s3` & `azurerm`).
- Same steps goes with `azurerm` migration as well.
- This time after migration, set `primary_cloud` to `azure` and do an apply on `dev` workspace.
- At some point in future, if you wish to destroy configuration while state is on remote backend. Then migrate to `local` backend and set `force_destroy` to `true` and do `terraform destroy` on required workspace.
- Hurray!! Now you can use multiple backends using this module.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version        |
| ------------------------------------------------------------------------ | -------------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.13.0      |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 3.38        |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >= 3.0.0       |
| <a name="requirement_google"></a> [google](#requirement_google)          | < 5.0, >= 3.83 |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | 4.53.0  |

## Modules

| Name                                                                                                                    | Source | Version |
| ----------------------------------------------------------------------------------------------------------------------- | ------ | ------- |
| <a name="module_tf_state_backend_multi_cloud"></a> [tf_state_backend_multi_cloud](#module_tf_state_backend_multi_cloud) | ../..  | n/a     |

## Resources

| Name                                                                                                                                       | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| [aws_s3_bucket.sample_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                       | resource |
| [aws_s3_bucket_acl.sample_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)               | resource |
| [aws_s3_bucket_versioning.sample_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name                                                               | Description                                                         | Type          | Default                                                                 | Required |
| ------------------------------------------------------------------ | ------------------------------------------------------------------- | ------------- | ----------------------------------------------------------------------- | :------: |
| <a name="input_aws_profile"></a> [aws_profile](#input_aws_profile) | Map of AWS profiles based on terraform workspace                    | `map(string)` | <pre>{<br> "dev": "axdev",<br> "prod": "axprod"<br>}</pre>              |    no    |
| <a name="input_aws_region"></a> [aws_region](#input_aws_region)    | Map of AWS regions to deploy resources based on terraform workspace | `map(string)` | <pre>{<br> "dev": "ca-central-1",<br> "prod": "ca-central-1"<br>}</pre> |    no    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
