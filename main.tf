resource "aws_s3_bucket" "s3_cloudfront_bucket" {
  bucket = local.bucket_name

  tags = {
    Name = "${var.domain_name} - bucket"
  }
}

resource "aws_s3_bucket_acl" "s3_cloudfront_bucket_acl" {
  bucket = aws_s3_bucket.s3_cloudfront_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "s3_policy_cloudfront_origin" {
  bucket = aws_s3_bucket.s3_cloudfront_bucket.id
  policy = <<CLOUDFRONTPOLICY
{
  "Version": "2012-10-17",
  "Id": "${aws_s3_bucket.s3_cloudfront_bucket.id}-policy",
  "Statement": [
    {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.cloudfront_origin_id.iam_arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.s3_cloudfront_bucket.arn}/*"
    }
  ]
}
CLOUDFRONTPOLICY
}

resource "aws_s3_object" "s3_cloudfront_bucket_site" {
  for_each = fileset("${path.root}/${var.source_directory}", "**/*")

  bucket = aws_s3_bucket.s3_cloudfront_bucket.id
  key    = each.value
  source = "${path.root}/${var.source_directory}/${each.value}"

  etag         = filemd5("${path.root}/${var.source_directory}/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
}

moved {
  from = aws_s3_bucket_object.s3_cloudfront_bucket_site
  to = aws_s3_object.s3_cloudfront_bucket_site
}
resource "aws_s3_object" "s3_cloudfront_bucket_index_html" {
  count                  = var.source_file != "" ? 1 : 0
  key                    = var.uri_path
  bucket                 = aws_s3_bucket.s3_cloudfront_bucket.id
  source                 = var.source_file
  server_side_encryption = "AES256"
  etag                   = filemd5(var.source_file)
  content_type           = lookup(local.mime_types, regex("\\.[^.]+$", "index.html"), null)
  acl = var.acl
}

moved {
  from = aws_s3_bucket_object.s3_cloudfront_bucket_index_html
  to = aws_s3_object.s3_cloudfront_bucket_index_html
}
locals {
  bucket_name       = var.bucket_name == "" ? "${local.distribution_name}-cloudfront-bucket" : var.bucket_name
  s3_origin_id      = var.domain_name
  distribution_name = var.domain_name
  zone_name         = var.zone_name == "" ? var.domain_name : var.zone_name
  aliases           = [var.domain_name]
}

# TODO Add support again for the certificate
# module "acm" {
#   source  = "sudoinclabs/sudo-acm/aws"
#   version = "0.1.1"
#   domain_name = var.domain_name
#   zone_name   = local.zone_name
# }
resource "aws_cloudfront_origin_access_identity" "cloudfront_origin_id" {
  comment = local.distribution_name
}

resource "aws_cloudfront_distribution" "distribution" {

  aliases = local.aliases
  comment = var.comment
  default_root_object             = var.default_root_object

  default_cache_behavior {
    allowed_methods = [
      "HEAD",
      "GET",
      "OPTIONS"
    ]
    cached_methods = [
      "HEAD",
      "GET",
    ]
    default_ttl = 3600
    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
    max_ttl                = 86400
    min_ttl                = 0
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
  }
  enabled         = true
  is_ipv6_enabled = true

  lifecycle {
    ignore_changes = [default_cache_behavior]
  }

  origin {
    domain_name = aws_s3_bucket.s3_cloudfront_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_origin_id.cloudfront_access_identity_path
    }
  }
  price_class = "PriceClass_All"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  /*viewer_certificate {
    ssl_support_method             = null
    minimum_protocol_version       = "TLSv1"
    cloudfront_default_certificate = true
  }*/

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn != "" ? [1] : []
    content {
      acm_certificate_arn = var.acm_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }
  dynamic "custom_error_response" {
    for_each = length(flatten([var.custom_error_response])[0]) > 0 ? flatten([var.custom_error_response]) : []

    content {
      error_code = custom_error_response.value["error_code"]

      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
    }
  }
}
data "aws_route53_zone" "route53_cloudfront_zone" {
  count = var.zone_name != null ? 1 : 0

  name = local.zone_name
}
resource "aws_route53_record" "route53_distribution_record" {
  count = var.zone_name != null ? 1 : 0
  allow_overwrite = true
  name            = var.domain_name
  type            = "A"
  zone_id         = data.aws_route53_zone.route53_cloudfront_zone[0].zone_id
  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
