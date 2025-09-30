terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

locals {
  prefix = "hanadetravel-form"
}

resource "aws_s3_bucket" "website" {
  bucket = "${local.prefix}-website-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

resource "aws_dynamodb_table" "submissions" {
  name           = "${local.prefix}-submissions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "submissionId"

  attribute {
    name = "submissionId"
    type = "S"
  }
}

resource "aws_lambda_function" "contact_form" {
  filename      = "function.zip"
  function_name = "${local.prefix}-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.submissions.name
      SENDER_EMAIL   = var.sender_email          
      BUSINESS_EMAIL = var.business_email 
    }
  }
}

resource "aws_apigatewayv2_api" "contact_api" {
  name          = "${local.prefix}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.contact_api.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = aws_lambda_function.contact_form.invoke_arn
}

resource "aws_apigatewayv2_route" "contact_route" {
  api_id    = aws_apigatewayv2_api.contact_api.id
  route_key = "POST /contact"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "production" {
  api_id      = aws_apigatewayv2_api.contact_api.id
  name        = "production"
  auto_deploy = true
}

resource "aws_iam_role" "lambda_role" {
  name = "${local.prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${local.prefix}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.submissions.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_ses_email_identity" "sender" {
  email = var.sender_email
}

resource "aws_ses_email_identity" "business" {
  email = var.business_email
}

output "website_url" {
  value = "http://${aws_s3_bucket.website.bucket}.s3-website-eu-west-2.amazonaws.com"
}

output "api_url" {
  value = "${aws_apigatewayv2_api.contact_api.api_endpoint}/contact"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.website.bucket
}
