resource "aws_s3_bucket" "tf_state_bucket" {
  bucket        = "${var.namespace}-${var.stage}-${var.name}-state-backend"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "tf_state_bucket" {
  bucket = aws_s3_bucket.tf_state_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tf_state_bucket" {
  bucket = aws_s3_bucket.tf_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_notification" "tf_state_bucket" {
  count  = var.primary_cloud == "aws" ? 1 : 0
  bucket = aws_s3_bucket.tf_state_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.MultiCloudSync.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "env%3A/dev/"
    filter_suffix       = ".tfstate"
  }

  depends_on = [aws_lambda_permission.MultiCloudSync]
}
