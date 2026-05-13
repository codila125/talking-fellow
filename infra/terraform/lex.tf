resource "aws_lexv2models_bot" "support_bot" {
  name                        = var.lex_bot_name
  description                 = "Multilingual customer support assistant with Lambda fulfillment"
  idle_session_ttl_in_seconds = 300
  role_arn                    = aws_iam_role.lex_service_role.arn

  data_privacy {
    child_directed = false
  }
}

resource "aws_lexv2models_bot_locale" "en" {
  bot_id                           = aws_lexv2models_bot.support_bot.id
  bot_version                      = "DRAFT"
  locale_id                        = "en_US"
  n_lu_intent_confidence_threshold = 0.4
}

resource "aws_lexv2models_bot_locale" "es" {
  bot_id                           = aws_lexv2models_bot.support_bot.id
  bot_version                      = "DRAFT"
  locale_id                        = "es_ES"
  n_lu_intent_confidence_threshold = 0.4
}

resource "aws_lexv2models_bot_locale" "fr" {
  bot_id                           = aws_lexv2models_bot.support_bot.id
  bot_version                      = "DRAFT"
  locale_id                        = "fr_FR"
  n_lu_intent_confidence_threshold = 0.4
}

resource "aws_lexv2models_intent" "fallback_en" {
  bot_id                  = aws_lexv2models_bot.support_bot.id
  bot_version             = "DRAFT"
  locale_id               = aws_lexv2models_bot_locale.en.locale_id
  name                    = "FallbackIntentEN"
  parent_intent_signature = "AMAZON.FallbackIntent"
}

resource "aws_lexv2models_intent" "fallback_es" {
  bot_id                  = aws_lexv2models_bot.support_bot.id
  bot_version             = "DRAFT"
  locale_id               = aws_lexv2models_bot_locale.es.locale_id
  name                    = "FallbackIntentES"
  parent_intent_signature = "AMAZON.FallbackIntent"
}

resource "aws_lexv2models_intent" "fallback_fr" {
  bot_id                  = aws_lexv2models_bot.support_bot.id
  bot_version             = "DRAFT"
  locale_id               = aws_lexv2models_bot_locale.fr.locale_id
  name                    = "FallbackIntentFR"
  parent_intent_signature = "AMAZON.FallbackIntent"
}

resource "aws_lexv2models_slot_type" "support_topic_en" {
  bot_id      = aws_lexv2models_bot.support_bot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.en.locale_id
  name        = "SupportTopicTypeEN"

  slot_type_values {
    sample_value {
      value = "billing"
    }
    synonyms {
      value = "payment"
    }
    synonyms {
      value = "invoice"
    }
  }

  slot_type_values {
    sample_value {
      value = "technical"
    }
    synonyms {
      value = "bug"
    }
    synonyms {
      value = "error"
    }
  }

  slot_type_values {
    sample_value {
      value = "order"
    }
    synonyms {
      value = "delivery"
    }
    synonyms {
      value = "tracking"
    }
  }

  value_selection_setting {
    resolution_strategy = "TopResolution"
  }
}

resource "aws_lexv2models_slot_type" "support_topic_es" {
  bot_id      = aws_lexv2models_bot.support_bot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.es.locale_id
  name        = "SupportTopicTypeES"

  slot_type_values {
    sample_value {
      value = "facturacion"
    }
    synonyms {
      value = "pago"
    }
    synonyms {
      value = "factura"
    }
  }

  slot_type_values {
    sample_value {
      value = "tecnico"
    }
    synonyms {
      value = "error"
    }
    synonyms {
      value = "falla"
    }
  }

  slot_type_values {
    sample_value {
      value = "pedido"
    }
    synonyms {
      value = "entrega"
    }
    synonyms {
      value = "rastreo"
    }
  }

  value_selection_setting {
    resolution_strategy = "TopResolution"
  }
}

resource "aws_lexv2models_slot_type" "support_topic_fr" {
  bot_id      = aws_lexv2models_bot.support_bot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.fr.locale_id
  name        = "SupportTopicTypeFR"

  slot_type_values {
    sample_value {
      value = "facturation"
    }
    synonyms {
      value = "paiement"
    }
    synonyms {
      value = "facture"
    }
  }

  slot_type_values {
    sample_value {
      value = "technique"
    }
    synonyms {
      value = "erreur"
    }
    synonyms {
      value = "bug"
    }
  }

  slot_type_values {
    sample_value {
      value = "commande"
    }
    synonyms {
      value = "livraison"
    }
    synonyms {
      value = "suivi"
    }
  }

  value_selection_setting {
    resolution_strategy = "TopResolution"
  }
}

resource "aws_lexv2models_intent" "support_en" {
  bot_id      = aws_lexv2models_bot.support_bot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.en.locale_id
  name        = "CustomerSupportIntentEN"

  sample_utterance {
    utterance = "I need help with {SupportTopic}"
  }

  sample_utterance {
    utterance = "Can you assist me with my order"
  }

  sample_utterance {
    utterance = "I have a problem with billing"
  }

  fulfillment_code_hook {
    enabled = true
  }
}

resource "aws_lexv2models_intent" "support_es" {
  bot_id      = aws_lexv2models_bot.support_bot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.es.locale_id
  name        = "CustomerSupportIntentES"

  sample_utterance {
    utterance = "Necesito ayuda con {SupportTopic}"
  }

  sample_utterance {
    utterance = "Tengo un problema con mi pedido"
  }

  sample_utterance {
    utterance = "Ayuda con facturacion"
  }

  fulfillment_code_hook {
    enabled = true
  }
}

resource "aws_lexv2models_intent" "support_fr" {
  bot_id      = aws_lexv2models_bot.support_bot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.fr.locale_id
  name        = "CustomerSupportIntentFR"

  sample_utterance {
    utterance = "J'ai besoin d'aide pour {SupportTopic}"
  }

  sample_utterance {
    utterance = "J'ai un probleme de commande"
  }

  sample_utterance {
    utterance = "Aide pour la facturation"
  }

  fulfillment_code_hook {
    enabled = true
  }
}

resource "aws_lexv2models_slot" "support_topic_en" {
  bot_id      = aws_lexv2models_bot.support_bot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.en.locale_id
  intent_id   = aws_lexv2models_intent.support_en.intent_id
  name        = "SupportTopic"
  slot_type_id = aws_lexv2models_slot_type.support_topic_en.slot_type_id

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
      allow_interrupt            = true
      max_retries                = 2
      message_selection_strategy = "Ordered"

      message_group {
        message {
          plain_text_message {
            value = "What type of support do you need: billing, technical, or order?"
          }
        }
      }
    }
  }
}

resource "aws_lexv2models_slot" "support_topic_es" {
  bot_id      = aws_lexv2models_bot.support_bot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.es.locale_id
  intent_id   = aws_lexv2models_intent.support_es.intent_id
  name        = "SupportTopic"
  slot_type_id = aws_lexv2models_slot_type.support_topic_es.slot_type_id

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
      allow_interrupt            = true
      max_retries                = 2
      message_selection_strategy = "Ordered"

      message_group {
        message {
          plain_text_message {
            value = "Que tipo de ayuda necesitas: facturacion, tecnico o pedido?"
          }
        }
      }
    }
  }
}

resource "aws_lexv2models_slot" "support_topic_fr" {
  bot_id      = aws_lexv2models_bot.support_bot.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.fr.locale_id
  intent_id   = aws_lexv2models_intent.support_fr.intent_id
  name        = "SupportTopic"
  slot_type_id = aws_lexv2models_slot_type.support_topic_fr.slot_type_id

  value_elicitation_setting {
    slot_constraint = "Required"

    prompt_specification {
      allow_interrupt            = true
      max_retries                = 2
      message_selection_strategy = "Ordered"

      message_group {
        message {
          plain_text_message {
            value = "Quel type d'aide vous faut-il : facturation, technique ou commande ?"
          }
        }
      }
    }
  }
}

resource "aws_lexv2models_bot_version" "v1" {
  bot_id = aws_lexv2models_bot.support_bot.id

  locale_specification = {
    "en_US" = {
      source_bot_version = "DRAFT"
    }
    "es_ES" = {
      source_bot_version = "DRAFT"
    }
    "fr_FR" = {
      source_bot_version = "DRAFT"
    }
  }

  depends_on = [
    aws_lexv2models_intent.fallback_en,
    aws_lexv2models_intent.fallback_es,
    aws_lexv2models_intent.fallback_fr,
    aws_lexv2models_slot.support_topic_en,
    aws_lexv2models_slot.support_topic_es,
    aws_lexv2models_slot.support_topic_fr
  ]
}
