

resource "aws_cloudfront_cache_policy" "cache1234-policy" {
  comment     = "Policy with caching enabled. Supports Gzip and Brotli compression."
  default_ttl = "86400"
  max_ttl     = "31536000"
  min_ttl     = "1"
  name        = "Test-Managed-CachingOptimized"

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    enable_accept_encoding_brotli = "true"
    enable_accept_encoding_gzip   = "true"

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "serverlessapptestbucket-oac" {
  name                              = "${var.s3_bucketname}.s3.${var.region}.amazonaws.com"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "serverlesstestapp" {
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id        = "${aws_cloudfront_cache_policy.cache1234-policy.id}"
    compress               = "true"
    default_ttl            = "0"
    max_ttl                = "0"
    min_ttl                = "0"
    smooth_streaming       = "false"
    target_origin_id       = "${var.s3_bucketname}.s3.${var.region}.amazonaws.com"
    viewer_protocol_policy = "allow-all"
  }

  default_root_object = "index.html"
  enabled             = "true"
  http_version        = "http2"
  is_ipv6_enabled     = "true"

  origin {
    connection_attempts = "3"
    connection_timeout  = "10"
    origin_access_control_id = "${aws_cloudfront_origin_access_control.serverlessapptestbucket-oac.id}"
    domain_name         = "${aws_s3_bucket.serverlessapptest.bucket_domain_name}"
    origin_id           = "${var.s3_bucketname}.s3.${var.region}.amazonaws.com"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  retain_on_delete = "false"

  viewer_certificate {
    cloudfront_default_certificate = "true"
    minimum_protocol_version       = "TLSv1"
  }

#addvariable
  web_acl_id = var.arn_id
}

provider "aws" {
   region = var.region
}
# Create a S3 Bucket
resource "aws_s3_bucket" "serverlessapptest" {
  bucket =  var.s3_bucketname
#addvariable
}
# Upload files to S3 Bucket
resource "aws_s3_object" "provision_source_files" {
   bucket = aws_s3_bucket.serverlessapptest.id
#myapp/ is the Directory contains files to be uploaded to S3
   for_each = fileset("../../../web/", "**/*.*")
   key = each.value
   source= "../../../web/${each.value}"

}
