# S3 bucket for Tempo distributed tracing storage
resource "aws_s3_bucket" "tempo" {
  bucket_prefix = "${local.tempo_bucket_name}-"

  tags = merge(local.final_tags, {
    Name       = local.tempo_bucket_name
    BucketType = "traces"
  })
}

# Enforce AWS ownership of objects in Tempo bucket
resource "aws_s3_bucket_ownership_controls" "tempo" {
  bucket = aws_s3_bucket.tempo.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block all public access to Tempo S3 bucket
resource "aws_s3_bucket_public_access_block" "tempo" {
  bucket = aws_s3_bucket.tempo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption with AES256 for Tempo bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "tempo" {
  bucket = aws_s3_bucket.tempo.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Disable versioning for Tempo bucket (not needed for trace data)
resource "aws_s3_bucket_versioning" "tempo" {
  bucket = aws_s3_bucket.tempo.id

  versioning_configuration {
    status = "Disabled"
  }
}

# Lifecycle policy to transition objects to lower-cost storage classes
resource "aws_s3_bucket_lifecycle_configuration" "tempo" {
  bucket = aws_s3_bucket.tempo.id

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
