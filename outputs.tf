output "dns_name" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "zone_id" {
  value = aws_cloudfront_distribution.distribution.hosted_zone_id
}

output "distribution_id" {
  value = aws_cloudfront_distribution.distribution.id
}

output "bucket_id" {
  value = aws_s3_bucket.website.id
}

output "bucket_arn" {
  value = aws_s3_bucket.website.arn
}