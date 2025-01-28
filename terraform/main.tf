provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Application = var.app_name
    }
  }
}

# TODO: add API Gateway?

# S3 Bucket
resource "aws_s3_bucket" "website" {
  bucket = var.domain_name
}

# S3 Bucket - Public Access Block
# I think this is optional since S3 buckets are private by default...
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy for CloudFront access
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = jsonencode(
    {
      Id = "PolicyForCloudFrontPrivateContent"
      Statement = [
        {
          Action = "s3:GetObject"
          Condition = {
            StringEquals = {
              "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
            }
          }
          Effect = "Allow"
          Principal = {
            Service = "cloudfront.amazonaws.com"
          }
          Resource = "${aws_s3_bucket.website.arn}/*"
          Sid      = "AllowCloudFrontServicePrincipal"
        },
      ]
      Version = "2008-10-17"
    }
  )
}

resource "aws_cloudfront_distribution" "website" {
  aliases             = [var.domain_name]
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All" # TODO: change to a cheaper price class?
  wait_for_deployment = true

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # This is AWS-managed policy ID for CachingOptimized
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = aws_s3_bucket.website.id # has to match origin_id in origin
    viewer_protocol_policy = "redirect-to-https"

    grpc_config {
      enabled = false
    }
  }

  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name # where CloudFront will get files from
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
    origin_id                = aws_s3_bucket.website.id # has to match target_origin_id in default_cache_behavior
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

# Add Origin Access Control
resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.domain_name}-oac"
  description                       = "Origin Access Control for ${var.domain_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ACM Certificate
resource "aws_acm_certificate" "website" {
  domain_name               = var.domain_name
  subject_alternative_names = [var.domain_name, "www.${var.domain_name}"]
  validation_method         = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  # create the new certificate before destroying the old one
  lifecycle {
    create_before_destroy = true
  }
}

# DynamoDB table
# TODO: had to manually create an item with a "views" attribute via the AWS console
resource "aws_dynamodb_table" "website" {
  name         = var.app_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# Route 53 zone
# resource "aws_route53_zone" "website" {
#   name              = var.domain_name
# }

# data "aws_route53_zone" "website" {
#   name = var.domain_name
# }

# Route 53 record for ACM validation
# resource "aws_route53_record" "acm_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.website.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   name    = each.value.name
#   records = [each.value.record]
#   ttl     = 300
#   type    = each.value.type
#   zone_id = data.aws_route53_zone.website.zone_id
# }

# Resource Group
resource "aws_resourcegroups_group" "website" {
  name = var.app_name

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "Application"
          Values = [var.app_name]
        }
      ]
    })
  }
}