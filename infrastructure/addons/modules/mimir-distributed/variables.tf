# Project configuration
variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_name))
    error_message = "Project name must start with a letter, contain only lowercase letters, numbers, and hyphens."
  }
}

variable "tags" {
  description = "Additional tags to apply to resources (module tags will be added automatically)"
  type        = map(string)
  default     = {}
}

# EKS cluster configuration
variable "cluster_name" {
  description = "EKS cluster name where Mimir will be deployed"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Mimir service account"
  type        = string
}

variable "service_account" {
  description = "Kubernetes service account name for Mimir pods"
  type        = string
}

# S3 lifecycle configuration
variable "s3_lifecycle_days_to_ia" {
  description = "Days before transitioning objects to STANDARD_IA storage class"
  type        = number
  default     = 30
}

variable "s3_lifecycle_days_to_glacier" {
  description = "Days before transitioning objects to GLACIER_IR storage class"
  type        = number
  default     = 90
}
