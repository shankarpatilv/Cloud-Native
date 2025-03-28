resource "random_uuid" "bucket_uuid" {}

resource "aws_s3_bucket" "Bucket-webapp" {
  bucket        = random_uuid.bucket_uuid.result
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example_encryption" {
  bucket = aws_s3_bucket.Bucket-webapp.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle" {
  bucket = aws_s3_bucket.Bucket-webapp.id
  rule {
    id = "TransitionToIA"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    status = "Enabled"
  }
}

