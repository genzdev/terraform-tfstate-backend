
resource "google_secret_manager_secret_iam_binding" "aws_access_key" {
  project   = "ax-dev-0"
  secret_id = "aws-access-key"
  role      = "roles/secretmanager.secretAccessor"
  members = [
    data.google_service_account.terraform_service_account.member,
  ]
}

resource "google_secret_manager_secret_iam_binding" "aws_access_key_secret" {
  project   = "ax-dev-0"
  secret_id = "aws-access-key-secret"
  role      = "roles/secretmanager.secretAccessor"
  members = [
    data.google_service_account.terraform_service_account.member,
  ]
}

resource "google_secret_manager_secret_iam_binding" "azure_access_key" {
  project   = "ax-dev-0"
  secret_id = "azure-storage-account-access-key"
  role      = "roles/secretmanager.secretAccessor"
  members = [
    data.google_service_account.terraform_service_account.member,
  ]
}

data "google_secret_manager_secret_version" "aws_access_key" {
  secret = "aws-access-key"
}

data "google_secret_manager_secret_version" "aws_access_key_secret" {
  secret = "aws-access-key-secret"
}

data "google_secret_manager_secret_version" "azure_access_key" {
  secret = "azure-storage-account-access-key"
}
