data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_execution" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    sid    = "CloudWatchLogsWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.fulfillment.arn}:*"]
  }

  statement {
    sid    = "DynamoDbConversationWrite"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:Query"
    ]
    resources = [aws_dynamodb_table.conversations.arn]
  }

  statement {
    sid    = "TranslateUsage"
    effect = "Allow"
    actions = [
      "translate:TranslateText"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ComprehendLanguageAndSentiment"
    effect = "Allow"
    actions = [
      "comprehend:DetectDominantLanguage",
      "comprehend:DetectSentiment"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SnsEscalationPublish"
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [aws_sns_topic.escalations.arn]
  }

  statement {
    sid    = "S3TranscriptArchiveWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.transcripts.arn}/*"]
  }
}

resource "aws_iam_role_policy" "lambda_inline" {
  name   = "${local.name_prefix}-lambda-inline-policy"
  role   = aws_iam_role.lambda_execution.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

data "aws_iam_policy_document" "lex_assume_role" {
  statement {
    sid     = "LexAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lexv2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lex_service_role" {
  name               = "${local.name_prefix}-lex-role"
  assume_role_policy = data.aws_iam_policy_document.lex_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lex_runtime_policy" {
  role       = aws_iam_role.lex_service_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonLexFullAccess"
}
