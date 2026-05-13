# AWS SAA Concept Mapping

## 1. Design resilient architectures
- Serverless decoupling with Lex + Lambda + DynamoDB + SNS
- Managed services reduce operational overhead
- SNS escalation path for operational continuity

## 2. Design high-performing architectures
- DynamoDB on-demand scales with traffic spikes
- Lambda auto-scaling for bursty chatbot traffic
- API Gateway throttling and default stage controls

## 3. Design secure architectures
- IAM least privilege for Lambda and Lex
- No hardcoded credentials
- Config via environment variables
- S3 private bucket with public access blocks
- DynamoDB encryption and CloudWatch auditability

## 4. Design cost-optimized architectures
- Pay-per-use services (Lex, Lambda, DynamoDB on-demand)
- Log retention to control CloudWatch costs
- TTL on transcript records for data lifecycle management

## 5. Operational excellence
- CloudWatch logs + metrics for observability
- Structured deployment/cleanup runbooks
- Terraform for repeatable infrastructure provisioning
