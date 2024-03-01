variable "role_name" {
  default = "LambdaRole"
  type  = "string"
}


variable "policy_attachment" {
   default = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
   type  = "string"
}

