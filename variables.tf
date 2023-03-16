variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "stage" {
  type = string
}

variable "aws_region" {
  type        = map(string)
  description = "Map of AWS regions to deploy resources based on terraform workspace"
  default = {
    dev  = "ca-central-1"
    prod = "ca-central-1"
  }
}

variable "aws_profile" {
  type        = map(string)
  description = "Map of AWS profiles based on terraform workspace"
}

variable "logs_retention_days" {
  type    = number
  default = 90
}

variable "google_region" {
  type        = string
  description = "Region where the Cloud Storage bucket is created"
  default     = "US"
}

variable "storage_admins" {
  type        = list(string)
  description = "List of principals to assign storage admin role to the bucket. if user should be of form `user:*****@gmail.com`"
}

variable "object_viewers" {
  type        = list(string)
  description = "List of principals to assign storage bucket object viewer role to the bucket. if user should be of form `user:*****@gmail.com`"
  default     = [""]
}

variable "force_destroy" {
  type        = bool
  description = "Whether to delete storage bucket even if it is not empty"
  default     = false
}

variable "primary_cloud" {
  type        = string
  description = "Primary cloud to store state files. Allowed values are `aws`, `google` & `azure`"
  default     = "aws"

  validation {
    condition     = contains(["aws", "google", "azure"], var.primary_cloud)
    error_message = "Allowed values for input_parameter are \"aws\", \"google\", or \"azure\"."
  }
}
