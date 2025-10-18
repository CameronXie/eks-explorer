# Store Loki S3 bucket names in SSM for GitOps stack
resource "aws_ssm_parameter" "loki_s3_buckets" {
  for_each = var.enable_loki ? module.loki[0].s3_bucket_names : {}

  name        = "/${var.environment}/${var.project_name}/addons/loki/s3/${each.key}/name"
  type        = "String"
  value       = each.value
  description = "Loki S3 ${each.key} bucket name"

  tags = merge(local.common_tags, {
    Component = "loki-${each.key}"
  })
}

# Store Mimir S3 bucket names in SSM for GitOps stack
resource "aws_ssm_parameter" "mimir_s3_buckets" {
  for_each = var.enable_mimir ? module.mimir[0].s3_bucket_names : {}

  name        = "/${var.environment}/${var.project_name}/addons/mimir/s3/${each.key}/name"
  type        = "String"
  value       = each.value
  description = "Mimir S3 ${each.key} bucket name"

  tags = merge(local.common_tags, {
    Component = "mimir-${each.key}"
  })
}

# Store Tempo S3 bucket name in SSM for GitOps stack
resource "aws_ssm_parameter" "tempo_s3" {
  count = var.enable_tempo ? 1 : 0

  name        = "/${var.environment}/${var.project_name}/addons/tempo/s3/trace/name"
  type        = "String"
  value       = module.tempo[0].s3_bucket_name
  description = "Tempo S3 trace bucket name"

  tags = merge(local.common_tags, {
    Component = "tempo"
  })
}