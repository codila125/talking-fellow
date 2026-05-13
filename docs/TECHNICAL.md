# Talking Fellow: Technical Overview

## Architecture
Talking Fellow is implemented as a serverless support workflow on AWS:
- Amazon Lex V2 for intent recognition and slot handling
- AWS Lambda for fulfillment and orchestration logic
- Amazon Translate for inbound/outbound translation
- Amazon Comprehend for language and sentiment analysis
- DynamoDB for conversation history
- S3 for transcript archive
- SNS for escalation notifications
- API Gateway for external chat integration
- CloudWatch for logging and runtime metrics
- Terraform for infrastructure provisioning

## Repository Structure
```text
talking-fellow/
├── infra/terraform/              # IaC: IAM, Lambda, Lex, API Gateway, DDB, S3, SNS, logs
├── lambda/fulfillment/app.py     # Fulfillment runtime logic
├── lex/                          # Intent/slot config and alias settings
├── iam/                          # Least-privilege policy references
├── scripts/create_lex_alias.sh   # Alias + Lambda code-hook setup helper
└── docs/                         # Deployment, testing, security, and operations docs
```

## Runtime Flow
1. User request reaches Lex or API Gateway.
2. Lambda receives message payload.
3. Comprehend and Translate normalize message processing.
4. Business response is generated based on detected support topic and sentiment.
5. DynamoDB stores conversation event.
6. S3 stores transcript artifact.
7. SNS receives escalation when sentiment is negative.
8. CloudWatch captures logs/metrics for operations.

## Security Controls
- No hardcoded credentials
- IAM least privilege on Lambda and Lex roles
- Environment variables for runtime config
- DynamoDB encryption enabled
- S3 bucket private with public access blocks
- CloudWatch logging with retention policy

## Local Engineering Workflow
```bash
uv sync --all-groups
uv run ruff format lambda/fulfillment/app.py
uv run ruff check lambda/fulfillment/app.py
```

## Deployment
Use Terraform from `infra/terraform`:
```bash
terraform init
terraform plan
terraform apply
```
Then create the Lex alias with:
```bash
./scripts/create_lex_alias.sh <LEX_BOT_ID> <LEX_BOT_VERSION> <LAMBDA_ARN> PROD
```

For step-by-step operations, continue with:
- `docs/deployment-guide.md`
- `docs/testing-guide.md`
- `docs/cleanup-guide.md`
