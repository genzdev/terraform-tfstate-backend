# --------------------------------------------------------------------------------
# NewUserEvent
# --------------------------------------------------------------------------------

data "archive_file" "MultiCloudSync" {
  type        = "zip"
  source_dir  = "${path.module}/functions/MultiCloudSync"
  output_path = "${path.module}/zip/MultiCloudSync.zip"
}

module "aws_lambda_function_MultiCloudSync_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = ["lambda"]
  tags = {
    "Stage"     = var.stage
    "Namespace" = var.namespace
  }
}

resource "aws_lambda_function" "MultiCloudSync" {
  function_name    = module.aws_lambda_function_MultiCloudSync_label.id
  description      = "Managed by Terraform."
  filename         = data.archive_file.MultiCloudSync.output_path
  handler          = "MultiCloudSync.handler"
  role             = aws_iam_role.MultiCloudSync.arn
  layers           = [aws_lambda_layer_version.main.arn]
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.MultiCloudSync.output_base64sha256
  tags             = module.aws_lambda_function_MultiCloudSync_label.tags
  timeout          = 5

  environment {
    variables = {
      ENV_STAGE                        = terraform.workspace
      REGION                           = var.aws_region[terraform.workspace]
      STATE_BUCKET                     = aws_s3_bucket.tf_state_bucket.id
      GOOGLE_APPLICATION_CREDENTIALS   = "lambdaServiceAccount.json"
      AZURE_STORAGE_ACCOUNT_ACCESS_KEY = data.azurerm_key_vault_secret.storage_account_access_key.value
    }
  }

  depends_on = [
    aws_s3_bucket.tf_state_bucket
  ]
}

resource "aws_lambda_permission" "MultiCloudSync" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.MultiCloudSync.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.tf_state_bucket.arn
}


