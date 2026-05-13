resource "aws_dynamodb_table" "conversations" {
  name         = local.conversation_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "conversation_id"
  range_key    = "message_ts"

  attribute {
    name = "conversation_id"
    type = "S"
  }

  attribute {
    name = "message_ts"
    type = "N"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }
}
