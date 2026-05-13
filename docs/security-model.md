# Security Model

## Controls implemented
- Credentials: Uses IAM role-based access only (no static keys in code)
- IAM least privilege: Lambda policy only includes required service actions
- Encryption at rest:
  - DynamoDB SSE enabled
  - S3 default encryption enabled
- S3 access: Public access blocked at bucket level
- Secrets/config:
  - Runtime configuration via Lambda environment variables
- Logging:
  - CloudWatch Logs enabled with retention policy
- Data minimization:
  - DynamoDB TTL expires historical conversation records

## Security review checklist
- [ ] Validate Lambda role only has expected actions
- [ ] Confirm no wildcard admin policies are attached
- [ ] Confirm SNS subscriptions are approved recipients
- [ ] Confirm CloudWatch retention matches compliance policy
- [ ] Confirm alias-level Lex->Lambda permission is constrained to bot alias ARN
