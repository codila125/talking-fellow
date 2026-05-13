# Testing Guide

## Test matrix

1. English request
- Input: `I need help with billing`
- Expected:
  - Lex routes to support intent
  - Lambda returns billing follow-up
  - DynamoDB record written
  - CloudWatch logs show invocation

2. Spanish request
- Input: `Necesito ayuda con mi pedido`
- Expected:
  - Input translated to English for processing
  - Response translated back to Spanish
  - Record stored with `source_lang=es` and `target_lang=es`

3. French request
- Input: `J'ai un probleme technique`
- Expected:
  - Input translated to English
  - Technical support response in French

4. Negative sentiment escalation
- Input: `This service is terrible and I need immediate help`
- Expected:
  - Sentiment detected as `NEGATIVE`
  - SNS publish occurs to escalation topic

5. API Gateway integration test
```bash
curl -X POST "$(terraform -chdir=infra/terraform output -raw api_gateway_chat_url)/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "u-1001",
    "session_id": "sess-abc-001",
    "preferred_language": "fr",
    "message": "Je veux de l'aide pour ma facture"
  }'
```
Expected:
- HTTP 200 response
- JSON includes `response`, `session_id`, `sentiment`
- Conversation row exists in DynamoDB

## Sample Lex conversations

### English
User: `I need help with billing`
Bot: `For billing issues, please share your invoice number. I can also connect you with billing support.`

### Spanish
User: `Necesito ayuda con facturacion`
Bot: `Para problemas de facturacion, comparte tu numero de factura. Tambien puedo conectarte con soporte de facturacion.`

### French
User: `J'ai besoin d'aide pour ma commande`
Bot: `Pour l'aide sur les commandes, veuillez fournir votre identifiant de commande afin que je puisse verifier le statut.`

## Observability checks
- CloudWatch Logs: `/aws/lambda/<function-name>`
- CloudWatch Metrics:
  - Lambda `Errors`, `Duration`, `Invocations`
  - API Gateway `4XXError`, `5XXError`, `Latency`
- DynamoDB item count growth verifies persistence path
