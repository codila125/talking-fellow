variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
  default     = "multilingual-support-chatbot"
}

variable "environment" {
  description = "Deployment environment label."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "lambda_runtime" {
  description = "Runtime for fulfillment lambda."
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout_seconds" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 30
}

variable "lambda_memory_mb" {
  description = "Lambda memory size in MB."
  type        = number
  default     = 256
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention for Lambda logs."
  type        = number
  default     = 14
}

variable "lex_bot_name" {
  description = "Amazon Lex V2 bot name."
  type        = string
  default     = "CustomerSupportMultilingualBot"
}

variable "support_email" {
  description = "Optional support email endpoint for SNS notifications. Leave empty to skip subscription creation."
  type        = string
  default     = ""
}

variable "transcript_ttl_days" {
  description = "Conversation record TTL in days for DynamoDB."
  type        = number
  default     = 30
}
