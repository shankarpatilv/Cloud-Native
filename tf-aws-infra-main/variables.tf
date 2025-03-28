variable "aws_region" {
  type        = string
  description = ""
}

variable "vpc_name" {
  description = ""
  type        = string


}
variable "cidr" {
  type        = string
  description = ""
}
variable "ami_id" {
  type        = string
  description = ""
}


variable "ssh_key" {
  type        = string
  description = ""
}
variable "DB_NAME" {
  type        = string
  description = ""
}

variable "accountID" {
  type        = string
  description = ""
}
# variable "sendgridID" {
#   type        = string
#   description = ""
# }
variable "email" {
  type        = string
  description = ""
}
variable "route_name" {
  type        = string
  description = ""
}



variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string

}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string

}

variable "lambda_handler" {
  description = "Handler function for the Lambda"
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = ""
}


variable "BASE_URL" {
  description = "Path to the Lambda deployment package"
  type        = string
}


variable "lambda_zip_path" {
  description = "Path to the Lambda deployment package"
  type        = string
}










