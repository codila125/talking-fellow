#!/usr/bin/env bash
set -euo pipefail

# Usage:
# ./scripts/create_lex_alias.sh <BOT_ID> <BOT_VERSION> <LAMBDA_ARN> [ALIAS_NAME]
# Example:
# ./scripts/create_lex_alias.sh ABCDE12345 1 arn:aws:lambda:us-east-1:123456789012:function:multilingual-support-chatbot-dev-fulfillment PROD

BOT_ID="${1:-}"
BOT_VERSION="${2:-}"
LAMBDA_ARN="${3:-}"
ALIAS_NAME="${4:-PROD}"

if [[ -z "$BOT_ID" || -z "$BOT_VERSION" || -z "$LAMBDA_ARN" ]]; then
  echo "Missing required arguments."
  echo "Usage: $0 <BOT_ID> <BOT_VERSION> <LAMBDA_ARN> [ALIAS_NAME]"
  exit 1
fi

TMP_JSON="$(mktemp)"
sed "s|REPLACE_WITH_LAMBDA_ARN|${LAMBDA_ARN}|g" lex/alias-locale-settings.json > "$TMP_JSON"

echo "Creating Lex alias ${ALIAS_NAME} for bot ${BOT_ID} version ${BOT_VERSION}..."
aws lexv2-models create-bot-alias \
  --bot-id "$BOT_ID" \
  --bot-alias-name "$ALIAS_NAME" \
  --bot-version "$BOT_VERSION" \
  --bot-alias-locale-settings "file://${TMP_JSON}" \
  --output json > /tmp/lex-alias-output.json

ALIAS_ID="$(jq -r '.botAliasId' /tmp/lex-alias-output.json)"

if [[ -z "$ALIAS_ID" || "$ALIAS_ID" == "null" ]]; then
  echo "Alias creation output:"
  cat /tmp/lex-alias-output.json
  echo "Could not determine alias ID."
  exit 1
fi

echo "Created alias ID: ${ALIAS_ID}"

echo "Ensure Lambda permission exists for Lex bot alias invocation."
# This permission command is idempotent-safe only if statement-id is unique.
# If it already exists, delete and recreate or use a new statement id.
aws lambda add-permission \
  --function-name "$LAMBDA_ARN" \
  --statement-id "LexInvoke-${BOT_ID}-${ALIAS_ID}" \
  --action lambda:InvokeFunction \
  --principal lexv2.amazonaws.com \
  --source-arn "arn:aws:lex:${AWS_REGION:-us-east-1}:${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}:bot-alias/${BOT_ID}/${ALIAS_ID}" || true

echo "Alias setup complete."
echo "Use this alias at runtime: ${ALIAS_ID}"
rm -f "$TMP_JSON"
