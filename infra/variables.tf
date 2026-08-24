variable "region" {
  description = "AWS region for the sample workload"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment represented by this state file"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "name_prefix" {
  description = "Prefix used for resource names"
  type        = string
  default     = "team-infra"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix may contain lowercase letters, digits, and hyphens only."
  }
}
