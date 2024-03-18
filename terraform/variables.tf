# //////////////////////////////
# VARIABLES
# //////////////////////////////

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The region of the aws account"
}

variable "environment" {
  type        = string
  description = "The deployment environment"
}

variable "vpc_id" {
  type        = string
  description = "The vpc id details of where to deploy the app"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The vpc id details of where to deploy the app"
}

variable "image_identifier" {
  type        = string
  description = "The image to deploy to app runner"
}

variable "aws_apprunner_domain" {
  type        = string
  description = "The details of the custom domain to be used by app runner"
  default     = "helpfinder.click"
}

variable "access_token" {
  type        = string
  description = "The details of the github token"
}
