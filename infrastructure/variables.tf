variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "business_email" {
  description = "Business email to receive contact form submissions"
  type        = string
}

variable "sender_email" {
  description = "Email address that will send confirmation emails"
  type        = string
}