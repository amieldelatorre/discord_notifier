variable "region" {
  description = "Region to launch resources in. Default is ap-southeast-2"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  description = "AWS profile to use to deploy resources"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "discord_notifier"
  
  validation {
    condition     = length(var.project_name) <= 42
    error_message = "The project name cannot be longer than 42 characters"
  }
}

variable "lambda_function_zip_filename" {
  description = "File name of the zip file for the code of the lambda function"
  type        = string
  default     = "myFunction.zip"
}

variable "scheduler_input" {
  description = "Value for the payload sent to the lambda. MUST be a JSON string"
  type        = string
}