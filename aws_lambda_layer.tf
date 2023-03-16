# --------------------------------------------------
# Main Lambda Layer
# --------------------------------------------------
data "archive_file" "layer_main_zip" {
  type        = "zip"
  source_dir  = "${path.module}/opt"
  output_path = "${path.module}/zip/layerMain.zip"
}

module "lambda_layer_main_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  namespace  = var.namespace
  stage      = terraform.workspace
  name       = var.name
  attributes = ["main"]
  tags = {
    "Stage"     = terraform.workspace
    "Namespace" = var.namespace
  }
}

resource "aws_lambda_layer_version" "main" {
  layer_name          = module.lambda_layer_main_label.id
  filename            = data.archive_file.layer_main_zip.output_path
  compatible_runtimes = ["nodejs16.x"]
  source_code_hash    = filebase64sha256(data.archive_file.layer_main_zip.output_path)
}
