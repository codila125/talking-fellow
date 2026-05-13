resource "aws_cloudwatch_log_group" "fulfillment" {
  name              = local.lambda_log_group_name
  retention_in_days = var.cloudwatch_log_retention_days
}

resource "aws_lambda_function" "fulfillment" {
  function_name = local.lambda_function_name
  role          = aws_iam_role.lambda_execution.arn
  handler       = "app.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout_seconds
  memory_size   = var.lambda_memory_mb

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE            = aws_dynamodb_table.conversations.name
      SNS_TOPIC_ARN             = aws_sns_topic.escalations.arn
      TRANSCRIPT_ARCHIVE_BUCKET = aws_s3_bucket.transcripts.bucket
      TRANSLATE_LANG_MAP        = local.supported_translate_lang_map
      TRANSCRIPT_TTL_DAYS       = tostring(var.transcript_ttl_days)
      POWERTOOLS_SERVICE_NAME   = local.lambda_function_name
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_inline,
    aws_cloudwatch_log_group.fulfillment
  ]
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fulfillment.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.chat_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_lex" {
  statement_id  = "AllowLexInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fulfillment.function_name
  principal     = "lexv2.amazonaws.com"
  source_arn    = "arn:${data.aws_partition.current.partition}:lex:${var.aws_region}:${data.aws_caller_identity.current.account_id}:bot-alias/${aws_lexv2models_bot.support_bot.id}/*"
}
