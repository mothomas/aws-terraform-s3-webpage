variable "region" {
 description = "name of the region"
 default = ""
}

variable "s3_bucketname" {
  description = "Name of S3 bucket"
  default = "serverlessapptestbucket"
}

variable "arn_id" {
  description = "arn_id of webacl"
}
