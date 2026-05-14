# Talking Fellow

Talking Fellow is a multilingual customer support assistant built for global products.
It helps teams support customers in multiple languages without increasing response complexity.

## Product Summary
- Understands customer intent in support conversations
- Replies in the customer's preferred language
- Flags frustrated users for faster human follow-up
- Keeps a searchable conversation history for quality and operations

## Why This Product
Customer support teams often struggle with language barriers, slow triage, and poor visibility into conversation outcomes. Talking Fellow addresses those problems with automated language handling, reliable workflow routing, and built-in observability.

## Core Capabilities
- Multilingual support for English, Spanish, and French
- Real-time intent handling for billing, technical, and order support
- Sentiment-aware escalation to support teams
- Conversation persistence and transcript archiving
- API-ready backend for web and mobile chat channels
- AWS-hosted website frontend for direct product access

## Typical User Flow
1. Customer sends a support message.
2. Talking Fellow understands the request and normalizes the message.
3. The system generates a support response and translates it back to the user language.
4. If urgency is detected, the case is escalated automatically.
5. Conversation records are stored for analytics and support audits.

## Who This Is For
- SaaS products with international customers
- E-commerce and marketplace support teams
- Startups that need enterprise-style support automation on AWS

## Technical Documentation
Product README is intentionally non-technical.
For implementation details, use:
- [Technical Overview](docs/TECHNICAL.md)
- [Deployment Guide](docs/deployment-guide.md)
- [Testing Guide](docs/testing-guide.md)
- [Security Model](docs/security-model.md)
- [Cleanup Guide](docs/cleanup-guide.md)
- [AWS SAA Mapping](docs/saa-mapping.md)

## Status
- Repository: production-style portfolio project
- Stack: AWS serverless architecture with infrastructure as code

## Standard Developer Commands
```bash
make install
make lint
make format
make infra-init
make infra-plan
make infra-apply
make run
make destroy
```
