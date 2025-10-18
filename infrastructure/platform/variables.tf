# project configuration
variable "region" {
  description = "AWS region for resource deployment (e.g., us-east-1, us-west-2)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod) - determines resource naming and configuration"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_name))
    error_message = "Project name must start with a letter, contain only lowercase letters, numbers, and hyphens."
  }
}

# VPC configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

# EKS Cluster configuration
variable "kubernetes_version" {
  description = "EKS cluster Kubernetes version"
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS managed node groups - multiple types for better availability"
  type        = list(string)
  default     = ["m5.large"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "At least one instance type must be specified."
  }
}
