# S3 buckets for Loki distributed storage backend
resource "aws_s3_bucket" "loki" {
  for_each      = local.bucket_names
  bucket_prefix = "${each.value}-"

  tags = local.tags
}

# Enforce AWS ownership of objects in Loki buckets
resource "aws_s3_bucket_ownership_controls" "loki" {
  for_each = aws_s3_bucket.loki
  bucket   = each.value.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block all public access to Loki S3 buckets
resource "aws_s3_bucket_public_access_block" "loki" {
  for_each = aws_s3_bucket.loki
  bucket   = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption with AES256 for Loki buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "loki" {
  for_each = aws_s3_bucket.loki
  bucket   = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Disable versioning for Loki buckets (not needed for log data)
resource "aws_s3_bucket_versioning" "loki" {
  for_each = aws_s3_bucket.loki
  bucket   = each.value.id

  versioning_configuration {
    status = "Disabled"
  }
}

# Lifecycle policy to transition objects to lower-cost storage classes
resource "aws_s3_bucket_lifecycle_configuration" "loki" {
  for_each = aws_s3_bucket.loki
  bucket   = each.value.id

  rule {
    id     = "cost-optimization"
    status = "Enabled"

    filter {
      prefix = ""
    }

    # Transition to Infrequent Access after configured days
    transition {
      days          = var.s3_lifecycle_days_to_ia
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier Instant Retrieval for long-term storage
    transition {
      days          = var.s3_lifecycle_days_to_glacier
      storage_class = "GLACIER_IR"
    }

    # Apply same transitions to non-current versions
    noncurrent_version_transition {
      noncurrent_days = var.s3_lifecycle_days_to_ia
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = var.s3_lifecycle_days_to_glacier
      storage_class   = "GLACIER_IR"
    }

    # Remove expired object delete markers
    expiration {
      expired_object_delete_marker = true
    }
  }
}
