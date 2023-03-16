# ------------------------------------------------------------
# MultiCloudSync Lambda IAM permissions
# ------------------------------------------------------------

module "aws_iam_MultiCloudSync_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = ["MultiCloudSync", "lambda"]
  tags = {
    "Stage"     = var.stage
    "Namespace" = var.namespace
  }
}

data "aws_iam_policy_document" "MultiCloudSync_iam_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "MultiCloudSync_iam_role_policy" {

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "${aws_s3_bucket.tf_state_bucket.arn}",
      "${aws_s3_bucket.tf_state_bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = ["${aws_cloudwatch_log_group.MultiCloudSync.arn}:*"]
  }

}

resource "aws_iam_role" "MultiCloudSync" {
  name               = module.aws_iam_MultiCloudSync_label.id
  tags               = module.aws_iam_MultiCloudSync_label.tags
  assume_role_policy = data.aws_iam_policy_document.MultiCloudSync_iam_role.json
}

resource "aws_iam_role_policy" "MultiCloudSync" {
  name   = module.aws_iam_MultiCloudSync_label.id
  role   = aws_iam_role.MultiCloudSync.id
  policy = data.aws_iam_policy_document.MultiCloudSync_iam_role_policy.json
}
