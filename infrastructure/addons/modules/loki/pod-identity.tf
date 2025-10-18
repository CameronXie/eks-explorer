# IAM policy for Loki to access S3 buckets
data "aws_iam_policy_document" "loki_s3_access" {
  # Allow listing and getting bucket location
  statement {
    sid    = "LokiListBuckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.loki["chunks"].arn,
      aws_s3_bucket.loki["ruler"].arn,
      aws_s3_bucket.loki["admin"].arn,
    ]
  }

  # Allow read/write operations on bucket objects
  statement {
    sid    = "LokiObjectOperations"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:PutObjectTagging",
      "s3:GetObjectTagging"
    ]
    resources = [
      "${aws_s3_bucket.loki["chunks"].arn}/*",
      "${aws_s3_bucket.loki["ruler"].arn}/*",
      "${aws_s3_bucket.loki["admin"].arn}/*",
    ]
  }
}

# EKS Pod Identity for Loki to assume IAM role
module "loki_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.0"

  name = "${var.cluster_name}-loki"

  # Attach custom inline policy allowing S3 access
  attach_custom_policy    = true
  source_policy_documents = [data.aws_iam_policy_document.loki_s3_access.json]

  # Association to the Loki service account
  associations = {
    loki = {
      cluster_name    = var.cluster_name
      namespace       = var.namespace
      service_account = var.service_account
    }
  }

  tags = local.tags
}
