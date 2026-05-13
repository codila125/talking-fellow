# Deployment Guide

## 1. Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.6
- `uv` for Python dependency/tool management
- `jq` installed (for alias helper script)
- Permissions to create IAM, Lambda, Lex, DynamoDB, S3, SNS, API Gateway, CloudWatch resources
- Permissions to create CloudFront resources for website hosting

## 2. Install Python dependencies and run lint checks
```bash
uv sync --all-groups
uv run ruff format lambda/fulfillment/app.py
uv run ruff check lambda/fulfillment/app.py
```

## 3. Configure variables
```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars values
```

## 4. Initialize and apply infrastructure
```bash
terraform init
terraform plan
terraform apply
```

## 5. Capture outputs
```bash
terraform output
```
Required outputs for alias setup:
- `lex_bot_id`
- `lex_bot_version`
- `lambda_function_arn`
- `website_url` (frontend)
- `api_gateway_chat_url` (API for frontend)

## 6. Create Lex bot alias and attach Lambda hook
From repository root:
```bash
chmod +x scripts/create_lex_alias.sh
./scripts/create_lex_alias.sh <LEX_BOT_ID> <LEX_BOT_VERSION> <LAMBDA_ARN> PROD
```

## 7. Verify resources
- Lambda: ensure log stream exists in CloudWatch Logs
- DynamoDB: table `*-conversations` created with SSE enabled
- S3: transcript bucket exists with public access blocked
- API Gateway: `POST /chat` route available
- CloudFront: website distribution deployed and serving `index.html`
- Lex: bot version and alias available

## 8. Optional: SNS email confirmation
If `support_email` is set, confirm the email subscription sent by SNS.
