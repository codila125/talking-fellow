resource "aws_sns_topic" "escalations" {
  name = local.escalation_topic_name
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.support_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.escalations.arn
  protocol  = "email"
  endpoint  = var.support_email
}
