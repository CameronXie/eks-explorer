output "s3_bucket_names" {
  description = "Map of Mimir S3 bucket names by type"
  value = {
    for k, v in aws_s3_bucket.mimir : k => v.id
  }
}

output "s3_bucket_arns" {
  description = "Map of Mimir S3 bucket ARNs by type"
  value = {
    for k, v in aws_s3_bucket.mimir : k => v.arn
  }
}

output "pod_identity_role_arn" {
  description = "IAM role ARN for Mimir pod identity"
  value       = module.mimir_pod_identity.iam_role_arn
}
