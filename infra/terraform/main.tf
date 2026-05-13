data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../lambda/fulfillment/app.py"
  output_path = "${path.module}/../../build/fulfillment.zip"
}

locals {
  name_prefix                  = "${var.project_name}-${var.environment}"
  conversation_table_name      = "${local.name_prefix}-conversations"
  transcript_archive_bucket    = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-transcripts"
  escalation_topic_name        = "${local.name_prefix}-escalations"
  lambda_function_name         = "${local.name_prefix}-fulfillment"
  lambda_log_group_name        = "/aws/lambda/${local.lambda_function_name}"
  api_name                     = "${local.name_prefix}-api"
  supported_translate_lang_map = "en:en,es:es,fr:fr"
}
