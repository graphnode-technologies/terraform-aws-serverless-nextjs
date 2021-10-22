locals {
  bucket_name = replace(var.domain_name, ".", "-")
}

resource "aws_s3_bucket" "website" {
  bucket = local.bucket_name

  force_destroy = true

  tags = var.tags

}

resource "aws_cloudfront_distribution" "distribution" {

  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = local.bucket_name
  }
  enabled             = true
  aliases             = concat([var.domain_name], var.alternative_names)
  price_class         = var.price_class
  wait_for_deployment = true
  retain_on_delete    = false

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.bucket_name
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  lifecycle {
    ignore_changes = [
      ordered_cache_behavior,
      origin,
      default_cache_behavior
    ]
  }

  tags = merge({ Name = "${var.domain_name}-cloudfront-${var.environment}" }, var.tags)
}

// -----------

resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = var.alternative_names
  validation_method         = "DNS"
  tags                      = var.tags
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "domain" {
  for_each        = toset(concat([var.domain_name], var.alternative_names))
  zone_id         = var.zone_id
  name            = each.key
  type            = "A"
  allow_overwrite = true
  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
