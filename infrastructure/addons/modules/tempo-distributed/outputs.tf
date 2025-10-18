output "s3_bucket_name" {
  description = "Tempo S3 bucket name for trace storage"
  value       = aws_s3_bucket.tempo.id
}

output "s3_bucket_arn" {
  description = "Tempo S3 bucket ARN"
  value       = aws_s3_bucket.tempo.arn
}

output "pod_identity_role_arn" {
  description = "IAM role ARN for Tempo pod identity"
  value       = module.tempo_pod_identity.iam_role_arn
}
