module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     =  var.db_name
  hash_key = var.hashkey

  attributes = [
    {
      name = var.db_attribute
    }
  ]
