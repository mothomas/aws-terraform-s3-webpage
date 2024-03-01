module "waf" {
     source = "../../modules/web-application-fw"
     # Other module configurations
   }

module "cloudformation-s3" {
     source = "../../modules/cloudfront-s3"
     arn_id = module.waf.arn_id
     # Other module configurations
   }

