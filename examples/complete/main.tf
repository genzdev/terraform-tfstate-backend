module "tf_state_backend_multi_cloud" {
  source        = "../.."
  name          = "multicloud"
  namespace     = "ifs"
  stage         = terraform.workspace
  primary_cloud = "azure"
  aws_profile = {
    dev  = "axdev"
    prod = "axprod"
  }
  storage_admins = [
    "user:example@yourdomain.com"
  ]
  force_destroy = true
}

# Sample infrastructure

resource "aws_s3_bucket" "sample_bucket" {
  bucket = "example-complete-bucket"
}

resource "aws_s3_bucket_acl" "sample_bucket" {
  bucket = aws_s3_bucket.sample_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "sample_bucket" {
  bucket = aws_s3_bucket.sample_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
