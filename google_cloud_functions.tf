locals {
  timestamp = formatdate("YYMMDDhhmmss", timestamp())
}

data "google_service_account" "terraform_service_account" {
  account_id = "axer"
}

data "google_compute_default_service_account" "default" {
}

data "google_storage_project_service_account" "gcs_account" {
  project = "ax-dev-0"
}

resource "google_project_iam_member" "gcs-pubsub-publishing" {
  project = "ax-dev-0"
  role    = "roles/pubsub.publisher"
  member  = data.google_storage_project_service_account.gcs_account.member
}

resource "google_project_iam_member" "invoking" {
  project    = "ax-dev-0"
  role       = "roles/run.invoker"
  member     = "serviceAccount:${data.google_compute_default_service_account.default.email}"
  depends_on = [google_project_iam_member.gcs-pubsub-publishing]
}

resource "google_project_iam_member" "event-receiving" {
  project    = "ax-dev-0"
  role       = "roles/eventarc.eventReceiver"
  member     = "serviceAccount:${data.google_compute_default_service_account.default.email}"
  depends_on = [google_project_iam_member.invoking]
}

resource "google_project_iam_member" "artifactregistry-reader" {
  project    = "ax-dev-0"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${data.google_compute_default_service_account.default.email}"
  depends_on = [google_project_iam_member.event-receiving]
}

data "archive_file" "MultiCloudSyncGCloud" {
  type        = "zip"
  source_dir  = "${path.module}/functions/MultiCloudSyncGCloud"
  output_path = "${path.module}/zip/MultiCloudSyncGCloud.zip"
}

resource "google_storage_bucket" "tf_state_bucket" {
  name                        = "${var.namespace}-${var.stage}-${var.name}-state-backend"
  location                    = var.google_region
  uniform_bucket_level_access = true
  force_destroy               = var.force_destroy
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "cloud_functions_archive" {
  name                        = "${var.namespace}-${var.stage}-${var.name}-functions-archive"
  location                    = var.google_region
  uniform_bucket_level_access = true
  force_destroy               = var.force_destroy
  versioning {
    enabled = true
  }
}

data "google_iam_policy" "archive_policy" {
  binding {
    role    = "roles/storage.admin"
    members = compact(concat(var.storage_admins, ["serviceAccount:${data.google_compute_default_service_account.default.email}"]))
  }

  # binding {
  #   role    = "roles/storage.objectViewer"
  #   members = var.object_viewers
  # }
}

resource "google_storage_bucket_iam_policy" "archive_policy" {
  bucket      = google_storage_bucket.cloud_functions_archive.name
  policy_data = data.google_iam_policy.archive_policy.policy_data
}

resource "google_storage_bucket_object" "MultiCloudSync_archive" {
  name   = "MultiCloudSync_${local.timestamp}.zip"
  bucket = google_storage_bucket.cloud_functions_archive.name
  source = data.archive_file.MultiCloudSyncGCloud.output_path
}

resource "google_cloudfunctions2_function" "MultiCloudSync" {
  count       = var.primary_cloud == "google" ? 1 : 0
  name        = "cloud-sync"
  location    = "us-central1"
  description = "CloudEvent function to sync GCS objects across AWS and Azure"

  build_config {
    runtime     = "nodejs16"
    entry_point = "MultiCloudSync" # Set the entry point in the code
    environment_variables = {
      ENV = terraform.workspace
    }
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_functions_archive.name
        object = google_storage_bucket_object.MultiCloudSync_archive.name
      }
    }
  }

  service_config {
    max_instance_count = 3
    min_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 30
    environment_variables = {
      ENV                   = terraform.workspace
      STATE_BUCKET          = google_storage_bucket.tf_state_bucket.name
      AWS_ACCESS_KEY_ID     = data.google_secret_manager_secret_version.aws_access_key.secret_data
      AWS_SECRET_ACCESS_KEY = data.google_secret_manager_secret_version.aws_access_key_secret.secret_data
      AZURE_ACCESS_KEY      = data.google_secret_manager_secret_version.azure_access_key.secret_data
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = data.google_compute_default_service_account.default.email
  }

  event_trigger {
    trigger_region        = "us" # The trigger must be in the same location as the bucket
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = data.google_compute_default_service_account.default.email
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.tf_state_bucket.name
    }
  }

  depends_on = [
    google_project_iam_member.event-receiving,
    google_project_iam_member.artifactregistry-reader,
  ]
}
