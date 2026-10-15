output "domain_name" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "zone_id" {
  value = aws_cloudfront_distribution.distribution.hosted_zone_id
}

output "distribution_id" {
  value = aws_cloudfront_distribution.distribution.id
}

output "arn" {
  value = aws_cloudfront_distribution.distribution.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.s3_cloudfront_bucket.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.s3_cloudfront_bucket.arn
}
