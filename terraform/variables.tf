variable "aws_region" {
  description = "The AWS region to deploy the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "lukelearnsthe.cloud"
}

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "lukelearnsthe.cloud"
}