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
  default = {
    dev  = "axdev"
    prod = "axprod"
  }
}

# Custom variables
