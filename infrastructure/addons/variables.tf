# Project configuration
variable "region" {
  description = "AWS region for resource deployment"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
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

# ArgoCD configuration
variable "enable_argocd" {
  description = "Enable ArgoCD bootstrap installation"
  type        = bool
  default     = true
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "8.5.8"
}

# Observability stack configuration
variable "enable_loki" {
  description = "Enable Loki log aggregation stack"
  type        = bool
  default     = true
}

variable "enable_mimir" {
  description = "Enable Mimir metrics storage stack"
  type        = bool
  default     = true
}

variable "enable_tempo" {
  description = "Enable Tempo distributed tracing stack"
  type        = bool
  default     = true
}
