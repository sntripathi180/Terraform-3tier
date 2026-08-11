terraform {
    required_providers {
        random = {
            source = "hashicorp/random"
            version = "~> 3.6"
        }
    }
}

locals {
    name_prefix = "${var.project_name}-${var.environment}"
}

resource "random_id" "suffix" {
    byte_length = 4
}

resource "aws_s3_bucket" "s3-bucket" {
    bucket = "${local.name_prefix}-${var.bucket_suffix}-${random_id.suffix.hex}"

    tags = merge(var.tags,{
        Name = "${local.name_prefix}-${var.bucket_suffix}"
    })
}

resource "aws_s3_bucket_public_access_block" "this" {
    bucket  = aws_s3_bucket.s3-bucket.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
    bucket = aws_s3_bucket.s3-bucket.id

    versioning_configuration {
        status = var.enable_versioning ? "Enabled" : "Disabled"
    }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    bucket = aws_s3_bucket.s3-bucket.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}


resource "aws_s3_bucket_lifecycle_configuration" "this" {
    count = var.enable_versioning ? 1 : 0 
    bucket = aws_s3_bucket.s3-bucket.id

    rule  {
        id = "expire-old-versions"
        status = "Enabled"

        filter {
      prefix = ""
    }
        noncurrent_version_expiration {

            noncurrent_days = var.noncurrent_version_expiration_days
        }
    }

    depends_on = [aws_s3_bucket_versioning.this]
}