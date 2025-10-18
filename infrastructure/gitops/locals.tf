locals {
  # Stack configuration
  platform_ssm_prefix = "/${var.environment}/${var.project_name}/platform"
  addons_ssm_prefix   = "/${var.environment}/${var.project_name}/addons"

  # S3 bucket mappings for observability components
  loki_s3_buckets = {
    for k, v in data.aws_ssm_parameter.loki_s3_individual : k => v.value
  }

  mimir_s3_buckets = {
    for k, v in data.aws_ssm_parameter.mimir_s3_individual : k => v.value
  }

  tempo_s3_bucket = data.aws_ssm_parameter.tempo_s3.value
}

# Data sources - EKS cluster information from SSM
data "aws_ssm_parameter" "cluster_name" {
  name = "${local.platform_ssm_prefix}/eks/cluster-name"
}

data "aws_eks_cluster" "this" {
  name = data.aws_ssm_parameter.cluster_name.value
}

data "aws_eks_cluster_auth" "this" {
  name = data.aws_ssm_parameter.cluster_name.value
}

# ArgoCD admin credentials
data "kubernetes_secret_v1" "argocd_initial_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.argocd_namespace
  }
}

# Loki S3 bucket configuration from SSM
data "aws_ssm_parameters_by_path" "loki_s3" {
  path            = "${local.addons_ssm_prefix}/loki/s3"
  with_decryption = false
  recursive       = true
}

data "aws_ssm_parameter" "loki_s3_individual" {
  for_each = toset([
    for path in data.aws_ssm_parameters_by_path.loki_s3.names :
    split("/", path)[length(split("/", path)) - 2]
  ])
  name = "${local.addons_ssm_prefix}/loki/s3/${each.key}/name"
}

# Mimir S3 bucket configuration from SSM
data "aws_ssm_parameters_by_path" "mimir_s3" {
  path            = "${local.addons_ssm_prefix}/mimir/s3"
  with_decryption = false
  recursive       = true
}

data "aws_ssm_parameter" "mimir_s3_individual" {
  for_each = toset([
    for path in data.aws_ssm_parameters_by_path.mimir_s3.names :
    split("/", path)[length(split("/", path)) - 2]
  ])
  name = "${local.addons_ssm_prefix}/mimir/s3/${each.key}/name"
}

# Tempo S3 bucket configuration from SSM
data "aws_ssm_parameter" "tempo_s3" {
  name = "${local.addons_ssm_prefix}/tempo/s3/trace/name"
}
