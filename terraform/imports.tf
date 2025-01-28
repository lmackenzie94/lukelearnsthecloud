# -------------------------------------------------------------------------------------------------
# Import existing AWS resources
# No longer needed since I've already imported them - keeping for reference
# -------------------------------------------------------------------------------------------------

# # S3 Bucket
# import {
#   to = aws_s3_bucket.website
#   id = "lukelearnsthe.cloud"
# }

# CloudFront distribution
# import {
#   to = aws_cloudfront_distribution.website
#   id = "E2N6KLWY1L9MPP"
# }

# Origin Access Control
# import {
#   to = aws_cloudfront_origin_access_control.website
#   id = "E3O0OXL1KGE8M5"
# }

# ACM Certificate
# import {
#   to = aws_acm_certificate.website
#   id = "arn:aws:acm:us-east-1:021891593951:certificate/93baf604-83b9-4c39-973e-c5440c9b43c9"
# }

# Route 53 zone
# TODO: import hosted zone AND all records
# import {
#   to = aws_route53_zone.website
#   id = "Z09880863NKPZ2ATME6VN"
# }