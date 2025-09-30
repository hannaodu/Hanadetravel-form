# resrouces
locals {
  prefix = "Hanadetravel-form"
}

# 1. S3 Bucket for website (The House)
resource "aws_s3_bucket" "website" {
  bucket = "${local.prefix}-website-${random_id.suffix.hex}"
}

# bucket publicly readable for website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Allow public read access to the bucket
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Policy to allow public read access
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

# 2. DynamoDB Table (The Filing Cabinet for form submissions)
resource "aws_dynamodb_table" "submissions" {
  name           = "${local.prefix}-submissions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "submissionId"

  attribute {
    name = "submissionId"
    type = "S"
  }

  tags = {
    Project = "HanadeTravel Contact Form"
  }
}

# 3. Lambda Function (The Brain that processes forms)
resource "aws_lambda_function" "contact_form" {
  filename      = "../lambda/function.zip"
  function_name = "${local.prefix}-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30

  environment {
    variables = {
      TABLE_NAME    = aws_dynamodb_table.submissions.name
      SENDER_EMAIL  = var.sender_email
      BUSINESS_EMAIL = var.business_email
    }
  }
}

# 4. API Gateway (The Doorbell that receives form submissions)
resource "aws_apigatewayv2_api" "contact_api" {
  name          = "${local.prefix}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

# Connect API Gateway to Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.contact_api.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = aws_lambda_function.contact_form.invoke_arn
}

# Create the route that receives form submissions
resource "aws_apigatewayv2_route" "contact_route" {
  api_id    = aws_apigatewayv2_api.contact_api.id
  route_key = "POST /contact"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Deploy the API
resource "aws_apigatewayv2_stage" "production" {
  api_id      = aws_apigatewayv2_api.contact_api.id
  name        = "production"
  auto_deploy = true
}

# 5. IAM Roles (Security Permissions)
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

# Allow Lambda to write to DynamoDB and send emails
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

# 6. Random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# 7. Verify SES Email Addresses
resource "aws_ses_email_identity" "sender" {
  email = var.sender_email
}

resource "aws_ses_email_identity" "business" {
  email = var.business_email
}

# Outputs 
output "website_url" {
  value = "http://${aws_s3_bucket.website.bucket}.s3-website-${var.aws_region}.amazonaws.com"
}

output "api_url" {
  value = "${aws_apigatewayv2_api.contact_api.api_endpoint}/contact"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.website.bucket
}