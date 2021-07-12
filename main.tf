provider "aws" {
   region = "us-east-1"
}

########## AWS SNS ##########

 # Alert (with an alert email)
resource "aws_sns_topic" "topic" {
  name = "email-alert"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = "hibtal@gmail.com"
  endpoint_auto_confirms = true
}

######### DynamoDB #############

resource "aws_dynamodb_table" "ddbtable" {
  name           = "MyDb"
  hash_key       = "myId"
  range_key      = "myValue"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "myId"
    type = "S"
  }

  attribute {
    name = "myValue"
    type = "S"
  }

  tags = {
    Name        = "MyDb"
    Environment = "production"
  }
}


 # We’ll define the actions that our lambda function can perform and on DynamoDB table (myTable)
resource "aws_iam_role_policy" "write_policy" {
  name = "lambda_write_policy"
  role = aws_iam_role.writeRole.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Stmt1604733000129",
        "Action": [
            "dynamodb:BatchWriteItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem"
           ],
           "Effect": "Allow",
           "Resource": "arn:aws:dynamodb:us-east-1:384519549636:table/MyDb"
       },
      {
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "arn:aws:sns:us-east-1:384519549636:email-alert"
        }
    ]
}
  EOF

}


resource "aws_iam_role_policy" "read_policy" {
  name = "lambda_read_policy"
  role = aws_iam_role.readRole.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1604732925387",
            "Action": [
              "dynamodb:BatchGetItem",
              "dynamodb:GetItem",
              "dynamodb:Query",
              "dynamodb:Scan"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:dynamodb:us-east-1:384519549636:table/MyDb"
        },
        {
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "arn:aws:sns:us-east-1:384519549636:email-alert"
        }
      ]
}
  EOF

}

 # IAM role which dictates what other AWS services the Lambda function may access.
resource "aws_iam_role" "writeRole" {
  name = "myWriteRole"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
  EOF

}


resource "aws_iam_role" "readRole" {
  name = "myReadRole"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service":
            "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
  EOF
}


############   Lambda #############

resource "aws_lambda_function" "writeLambda" {
  filename      = "PutLambdaFunction.zip"
  function_name = "PutLambdaFunction"
//  s3_bucket     = "mybuck7086125"
//  s3_key        = "PutLambdaFunction.zip"
  role          = aws_iam_role.writeRole.arn
  handler       = "PutLambdaFunction.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("PutLambdaFunction.zip")

  runtime       = "python3.8"

  environment {
    variables = {
      snsARN = aws_sns_topic.topic.arn
    }
  }
}


resource "aws_lambda_function" "readLambda" {
  filename      = "GetLambdaFunction.zip"
  function_name = "GetLambdaFunction"
//  s3_bucket     = "mybuck7086125"
//  s3_key        = "GetLambdaFunction.zip"
  role          = aws_iam_role.readRole.arn
  handler       = "GetLambdaFunction.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("GetLambdaFunction.zip")

  runtime       = "python3.8"

  environment {
    variables = {
      snsARN = aws_sns_topic.topic.arn
    }
  }
}


################ Api Gateway ##################

resource "aws_api_gateway_rest_api" "apiLambda" {
  name        = "myAPI"

}


resource "aws_api_gateway_resource" "writeResource" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "PutLambdaFunction"

}


resource "aws_api_gateway_method" "writeMethod" {
   rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
   resource_id   = aws_api_gateway_resource.writeResource.id
   http_method   = "POST"
   authorization = "NONE"
}


resource "aws_api_gateway_resource" "readResource" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "GetLambdaFunction"

}


resource "aws_api_gateway_method" "readMethod" {
   rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
   resource_id   = aws_api_gateway_resource.readResource.id
   http_method   = "POST"
   authorization = "NONE"
}




resource "aws_api_gateway_integration" "writeInt" {
   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   resource_id = aws_api_gateway_resource.writeResource.id
   http_method = aws_api_gateway_method.writeMethod.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.writeLambda.invoke_arn

}


resource "aws_api_gateway_integration" "readInt" {
   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   resource_id = aws_api_gateway_resource.readResource.id
   http_method = aws_api_gateway_method.readMethod.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.readLambda.invoke_arn

}



resource "aws_api_gateway_deployment" "apideploy" {
   depends_on = [ aws_api_gateway_integration.writeInt, aws_api_gateway_integration.readInt]

   rest_api_id = aws_api_gateway_rest_api.apiLambda.id
   stage_name  = "Prod"
}


resource "aws_lambda_permission" "writePermission" {
   statement_id  = "AllowExecutionFromAPIGateway"
   action        = "lambda:InvokeFunction"
   function_name = "PutLambdaFunction"
   principal     = "apigateway.amazonaws.com"

   source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/Prod/POST/PutLambdaFunction"

}


resource "aws_lambda_permission" "readPermission" {
   statement_id  = "AllowExecutionFromAPIGateway"
   action        = "lambda:InvokeFunction"
   function_name = "GetLambdaFunction"
   principal     = "apigateway.amazonaws.com"

   source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/Prod/POST/GetLambdaFunction"

}


output "base_url" {
  value = aws_api_gateway_deployment.apideploy.invoke_url
}