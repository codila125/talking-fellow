output "lambda_function_name" {
  description = "Fulfillment Lambda function name"
  value       = aws_lambda_function.fulfillment.function_name
}

output "lambda_function_arn" {
  description = "Fulfillment Lambda function ARN"
  value       = aws_lambda_function.fulfillment.arn
}

output "dynamodb_table_name" {
  description = "Conversation history table"
  value       = aws_dynamodb_table.conversations.name
}

output "transcript_archive_bucket" {
  description = "Private S3 bucket storing conversation archives"
  value       = aws_s3_bucket.transcripts.bucket
}

output "escalation_topic_arn" {
  description = "SNS escalation topic ARN"
  value       = aws_sns_topic.escalations.arn
}

output "api_gateway_chat_url" {
  description = "HTTP API endpoint for external chat clients"
  value       = aws_apigatewayv2_api.chat_api.api_endpoint
}

output "lex_bot_id" {
  description = "Lex bot ID (used when creating bot alias)"
  value       = aws_lexv2models_bot.support_bot.id
}

output "lex_bot_version" {
  description = "Published Lex bot version"
  value       = aws_lexv2models_bot_version.v1.bot_version
}

output "website_bucket_name" {
  description = "Private S3 bucket storing website assets"
  value       = var.deploy_website ? aws_s3_bucket.website[0].bucket : null
}

output "website_url" {
  description = "CloudFront URL for the hosted web frontend"
  value       = var.deploy_website ? "https://${aws_cloudfront_distribution.website[0].domain_name}" : null
}
