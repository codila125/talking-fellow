# Cleanup Guide

## 1. Delete Terraform resources
```bash
cd infra/terraform
terraform destroy
```

## 2. Verify bucket emptiness (if destroy is blocked)
If S3 versioned objects remain:
```bash
aws s3 rb s3://<transcript-bucket-name> --force
```
Then rerun:
```bash
terraform destroy
```

## 3. Remove Lex alias (if created manually)
```bash
aws lexv2-models list-bot-aliases --bot-id <BOT_ID>
aws lexv2-models delete-bot-alias --bot-id <BOT_ID> --bot-alias-id <ALIAS_ID>
```

## 4. Confirm no billable resources remain
- Lambda functions
- DynamoDB table
- API Gateway API
- SNS topic/subscriptions
- S3 bucket
- CloudWatch log groups
