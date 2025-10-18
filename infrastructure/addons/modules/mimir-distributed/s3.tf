# S3 buckets for Mimir distributed metrics storage
resource "aws_s3_bucket" "mimir" {
  for_each      = local.bucket_names
  bucket_prefix = "${each.value}-"

  tags = merge(local.tags, {
    Name       = each.value
    BucketType = each.key
  })
}

# Enforce AWS ownership of objects in Mimir buckets
resource "aws_s3_bucket_ownership_controls" "mimir" {
  for_each = aws_s3_bucket.mimir
  bucket   = each.value.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block all public access to Mimir S3 buckets
resource "aws_s3_bucket_public_access_block" "mimir" {
  for_each = aws_s3_bucket.mimir
  bucket   = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption with AES256 for Mimir buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "mimir" {
  for_each = aws_s3_bucket.mimir
  bucket   = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Disable versioning for Mimir buckets (not needed for metrics data)
resource "aws_s3_bucket_versioning" "mimir" {
  for_each = aws_s3_bucket.mimir
  bucket   = each.value.id

  versioning_configuration {
    status = "Disabled"
  }
}

# Lifecycle policy to transition objects to lower-cost storage classes
resource "aws_s3_bucket_lifecycle_configuration" "mimir" {
  for_each = aws_s3_bucket.mimir
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
