terraform {
  required_version = "~> 0.12"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]

    principals {
      type = "AWS"

      identifiers = concat(
        [aws_cloudfront_origin_access_identity.this.iam_arn],
        var.s3_allowed_roles
      )
    }
  }

  statement {
    effect    = "Deny"
    actions   = ["s3:GetObject"]
    resources = [for file in var.s3_forbidden_files : format("${aws_s3_bucket.this.arn}/%s", file)]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = format("%s-uploads-", var.name)
  acl           = "private"

  tags = var.tags
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_cloudfront_origin_access_identity" "this" {}

resource "aws_cloudfront_distribution" "this" {
  comment = var.comment == "" ? format("CDN for Uploads (%s)", var.name) : var.comment

  enabled     = true
  aliases     = var.cloudfront_aliases
  price_class = var.cloudfront_price_class

  origin {
    domain_name = aws_s3_bucket.this.bucket_domain_name
    origin_id   = aws_s3_bucket.this.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_s3_bucket.this.id

    forwarded_values {
      query_string = true
      headers = [
        "Origin",
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
      ]

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "custom_error_response" {
    for_each = [for c in [400, 403, 404, 405, 414, 416, 500, 501, 503, 504] : { code = c }]

    content {
      error_caching_min_ttl = 0
      error_code            = custom_error_response.value.code
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cloudfront_acm_certificate_arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  tags = var.tags
}
