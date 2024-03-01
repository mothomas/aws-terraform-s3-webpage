resource "aws_iam_role" "example_role" {

  name = var.role_name
  assume_role_policy =<<EOF
{

  "Version": "2012-10-17",

  "Statement": [

    {

      "Effect": "Allow",

      "Principal": {

        "Service": "lambda.amazonaws.com"

      },

      "Action": "sts:AssumeRole"

    }

  ]

}

EOF

}


resource "aws_iam_role_policy_attachment" "example_attachment" {

  role       = var.role_name

  policy_arn = var.policy_attachment

}


data "archive_file" "zip_the_insert_code" {

type        = "zip"

source_file  = "/root/aws-serverlessapp/lambda/python/insert.py"

output_path = "insert-python.zip"

}


data "archive_file" "zip_the_get_code" {

type        = "zip"

source_file  = "/root/aws-serverlessapp/lambda/python/get.py"

output_path = "get.zip"
}

data "archive_file" "zip_the_delete_code" {

type        = "zip"

source_file  = "/root/aws-serverlessapp/lambda/python/delete.py"

output_path = "delete.zip"
}





resource "aws_lambda_function" "terraform_lambda_func1" {

  filename                       = "insert-python.zip"

  function_name                  = "insertEmployee"

  role                           = aws_iam_role.example_role.arn

  handler                        = "insert.lambda_handler"

  runtime                        = "python3.9"

  depends_on                     = [aws_iam_role_policy_attachment.example_attachment]

}
resource "aws_lambda_function" "terraform_lambda_func2" {

  filename                       = "get.zip"

  function_name                  = "getEmployee"

  role                           = aws_iam_role.example_role.arn

  handler                        = "get.lambda_handler"

  runtime                        = "python3.9"

  depends_on                     = [aws_iam_role_policy_attachment.example_attachment]

}

resource "aws_lambda_function" "terraform_lambda_func3" {

  filename                       = "delete.zip"

  function_name                  = "deleteEmployee"

  role                           = aws_iam_role.example_role.arn

  handler                        = "delete.lambda_handler"

  runtime                        = "python3.9"

  depends_on                     = [aws_iam_role_policy_attachment.example_attachment]

}


resource "aws_api_gateway_rest_api" "lambda_get_employee" {

  name = "get_employee"

  
  endpoint_configuration {

    types = ["EDGE"]

  }

}

resource "aws_api_gateway_resource" "root" {

  rest_api_id = aws_api_gateway_rest_api.lambda_get_employee.id

  parent_id = aws_api_gateway_rest_api.lambda_get_employee.root_resource_id

  path_part = "mypath"

}
resource "aws_api_gateway_method" "get_employee" {
  rest_api_id = aws_api_gateway_rest_api.lambda_get_employee.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = "GET"

  authorization = "NONE"  
   
}



resource "aws_api_gateway_integration" "lambda_function2" {

  rest_api_id = aws_api_gateway_rest_api.lambda_get_employee.id

  resource_id = aws_api_gateway_resource.root.id

  http_method = aws_api_gateway_method.get_employee.http_method
  integration_http_method = "GET"

  type = "AWS"
  uri = aws_lambda_function.terraform_lambda_func2.invoke_arn

}




resource "aws_api_gateway_method_response" "cors_get" {

  rest_api_id = aws_api_gateway_rest_api.lambda_get_employee.id

  resource_id = aws_api_gateway_resource.root.id

  http_method = aws_api_gateway_method.get_employee.http_method

  status_code = "200"



response_parameters = {

    "method.response.header.Access-Control-Allow-Headers" = true,

    "method.response.header.Access-Control-Allow-Methods" = true,

    "method.response.header.Access-Control-Allow-Origin" = true

  }



}


resource "aws_api_gateway_integration_response" "cors_get2" {

  rest_api_id = aws_api_gateway_rest_api.lambda_get_employee.id

  resource_id = aws_api_gateway_resource.root.id

  http_method = aws_api_gateway_method.get_employee.http_method
 
  status_code = aws_api_gateway_method_response.cors_get.status_code



response_parameters = {

    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",

    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",

    "method.response.header.Access-Control-Allow-Origin" = "'*'"

}



  depends_on = [

    aws_api_gateway_method.get_employee,

    aws_api_gateway_integration.lambda_function2
  ]


}





resource "aws_api_gateway_rest_api" "lambda_insert_employee" {

  name = "insert_employee"

  
  endpoint_configuration {

    types = ["EDGE"]

  }

}

resource "aws_api_gateway_resource" "root2" {

  rest_api_id = aws_api_gateway_rest_api.lambda_insert_employee.id

  parent_id = aws_api_gateway_rest_api.lambda_insert_employee.root_resource_id

  path_part = "mypath"

}




resource "aws_api_gateway_method" "insert_employee" {
  rest_api_id = aws_api_gateway_rest_api.lambda_insert_employee.id
  resource_id = aws_api_gateway_resource.root2.id
  http_method = "POST"

  authorization = "NONE"  
   
}



resource "aws_api_gateway_integration" "lambda_function1" {

  rest_api_id = aws_api_gateway_rest_api.lambda_insert_employee.id

  resource_id = aws_api_gateway_resource.root2.id

  http_method = aws_api_gateway_method.insert_employee.http_method

  integration_http_method = "POST"
  type = "AWS"
  uri = aws_lambda_function.terraform_lambda_func1.invoke_arn
}



resource "aws_api_gateway_method_response" "cors_insert" {

  rest_api_id = aws_api_gateway_rest_api.lambda_insert_employee.id

  resource_id = aws_api_gateway_resource.root2.id

  http_method = aws_api_gateway_method.insert_employee.http_method

  status_code = "200"


  response_parameters = {

    "method.response.header.Access-Control-Allow-Headers" = true,

    "method.response.header.Access-Control-Allow-Methods" = true,

    "method.response.header.Access-Control-Allow-Origin" = true

  }



}



resource "aws_api_gateway_integration_response" "cors_insert2" {

  rest_api_id = aws_api_gateway_rest_api.lambda_insert_employee.id

  resource_id = aws_api_gateway_resource.root2.id

  http_method = aws_api_gateway_method.insert_employee.http_method

  status_code = aws_api_gateway_method_response.cors_insert.status_code

  response_parameters = {

    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",

    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",

    "method.response.header.Access-Control-Allow-Origin" = "'*'"

}



  depends_on = [

    aws_api_gateway_method.insert_employee,

    aws_api_gateway_integration.lambda_function1
  ]

}






resource "aws_api_gateway_rest_api" "lambda_delete_employee" {

  name = "delete_employee"

  
  endpoint_configuration {

    types = ["EDGE"]

  }

}


resource "aws_api_gateway_resource" "root3" {

  rest_api_id = aws_api_gateway_rest_api.lambda_delete_employee.id

  parent_id = aws_api_gateway_rest_api.lambda_delete_employee.root_resource_id

  path_part = "mypath"

}






resource "aws_api_gateway_method" "delete_employee" {
  rest_api_id = aws_api_gateway_rest_api.lambda_delete_employee.id
  resource_id = aws_api_gateway_resource.root3.id
  http_method = "DELETE"

  authorization = "NONE"  
   
}

resource "aws_api_gateway_integration" "lambda_function3" {

  rest_api_id = aws_api_gateway_rest_api.lambda_delete_employee.id

  resource_id = aws_api_gateway_resource.root3.id

  http_method = aws_api_gateway_method.delete_employee.http_method
 
  integration_http_method = "DELETE"

  type = "AWS"
  uri = aws_lambda_function.terraform_lambda_func3.invoke_arn
}



resource "aws_api_gateway_method_response" "cors_delete" {

  rest_api_id = aws_api_gateway_rest_api.lambda_delete_employee.id

  resource_id = aws_api_gateway_resource.root3.id

  http_method = aws_api_gateway_method.delete_employee.http_method
  
  status_code = "200"
    

  response_parameters = {

    "method.response.header.Access-Control-Allow-Headers" = true,

    "method.response.header.Access-Control-Allow-Methods" = true,

    "method.response.header.Access-Control-Allow-Origin" = true

  }



}



resource "aws_api_gateway_integration_response" "cors_delete2" {

  rest_api_id = aws_api_gateway_rest_api.lambda_delete_employee.id

  resource_id = aws_api_gateway_resource.root3.id

  http_method = aws_api_gateway_method.delete_employee.http_method
  
  status_code = aws_api_gateway_method_response.cors_delete.status_code
  
  response_parameters = {

    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",

    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",

    "method.response.header.Access-Control-Allow-Origin" = "'*'"

}



  depends_on = [

    aws_api_gateway_method.delete_employee,

    aws_api_gateway_integration.lambda_function3
  ]

}




