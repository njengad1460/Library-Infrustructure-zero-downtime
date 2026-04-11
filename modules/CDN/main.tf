resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "ALBOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for ${var.project_name}"
  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALBOrigin"

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin"] # Important for multi-tenant or origin-specific headers
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
  }

  # PriceClass_200 includes Africa (Edge location in Nairobi, Kenya)
  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none" # Allow global but optimized for Africa
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.project_name}-cdn"
  }
}
