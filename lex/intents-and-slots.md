# Lex V2 Configuration

## Intents

### 1) `CustomerSupportIntentEN` (`en_US`)
- Sample utterances:
  - `I need help with {SupportTopic}`
  - `Can you assist me with my order`
  - `I have a problem with billing`
- Fulfillment: Lambda code hook enabled
- Slot required:
  - `SupportTopic` (slot type `SupportTopicTypeEN`)

### 2) `CustomerSupportIntentES` (`es_ES`)
- Sample utterances:
  - `Necesito ayuda con {SupportTopic}`
  - `Tengo un problema con mi pedido`
  - `Ayuda con facturacion`
- Fulfillment: Lambda code hook enabled
- Slot required:
  - `SupportTopic` (slot type `SupportTopicTypeES`)

### 3) `CustomerSupportIntentFR` (`fr_FR`)
- Sample utterances:
  - `J'ai besoin d'aide pour {SupportTopic}`
  - `J'ai un probleme de commande`
  - `Aide pour la facturation`
- Fulfillment: Lambda code hook enabled
- Slot required:
  - `SupportTopic` (slot type `SupportTopicTypeFR`)

### 4) Fallback intents (required by Lex)
- `FallbackIntentEN` with parent signature `AMAZON.FallbackIntent`
- `FallbackIntentES` with parent signature `AMAZON.FallbackIntent`
- `FallbackIntentFR` with parent signature `AMAZON.FallbackIntent`

## Slot Types

### `SupportTopicTypeEN`
- Values: billing, technical, order
- Synonyms: payment/invoice, bug/error, delivery/tracking

### `SupportTopicTypeES`
- Values: facturacion, tecnico, pedido
- Synonyms: pago/factura, error/falla, entrega/rastreo

### `SupportTopicTypeFR`
- Values: facturation, technique, commande
- Synonyms: paiement/facture, erreur/bug, livraison/suivi

## Alias and Code Hook

Terraform creates the bot and version. Alias creation/wiring is done by:
- `scripts/create_lex_alias.sh`
- `lex/alias-locale-settings.json`

This is where Lex is attached to the Lambda function for runtime fulfillment.
