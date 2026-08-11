output "bucket_id" {
    value = aws_s3_bucket.s3-bucket.id
}

output "bucket_arn" {
    value = aws_s3_bucket.s3-bucket.arn
}

output "bucket_regional_domain_name" {
    description = "Used as the CloudFront origin domain "
    value = aws_s3_bucket.s3-bucket.bucket_regional_domain_name
}