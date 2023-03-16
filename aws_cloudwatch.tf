# --------------------------------------------------------------
# MultiCloudSync Cloudwatch Logs
# --------------------------------------------------------------

module "aws_cloudwatch_log_group_MultiCloudSync_label" {
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

resource "aws_cloudwatch_log_group" "MultiCloudSync" {
  name              = "/aws/lambda/${module.aws_cloudwatch_log_group_MultiCloudSync_label.id}"
  tags              = module.aws_cloudwatch_log_group_MultiCloudSync_label.tags
  retention_in_days = var.logs_retention_days
}
