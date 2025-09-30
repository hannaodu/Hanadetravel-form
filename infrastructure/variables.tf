#  infrastructure will live
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

#  domain name (am  using S3 website URL for now)
variable "website_domain" {
  description = "Domain name for the website"
  type        = string
  default     = "travelease-contact"
}

# Email that will receive contact form submissions
variable "business_email" {
  description = "Business email to receive contact form submissions"
  type        = string
}

# Email that will send confirmation emails to customers
variable "sender_email" {
  description = "Email address that will send confirmation emails"
  type        = string
}