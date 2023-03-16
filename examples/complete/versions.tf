provider "aws" {
  region  = var.aws_region[terraform.workspace]
  profile = var.aws_profile[terraform.workspace]
}

provider "google" {
  credentials = file("${path.module}/config/gcp.json")
  project     = "ax-dev-0"
  region      = "us-central1"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.38"
    }
    google = {
      source  = "hashicorp/google"
      version = "< 5.0, >= 3.83"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }

  backend "azurerm" {}
}
