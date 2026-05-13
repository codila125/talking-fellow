import json
import logging
import os
import time
import uuid
from datetime import UTC, datetime, timedelta
from typing import Any

import boto3

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

DYNAMODB_TABLE = os.environ["DYNAMODB_TABLE"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
TRANSCRIPT_ARCHIVE_BUCKET = os.environ["TRANSCRIPT_ARCHIVE_BUCKET"]
TRANSCRIPT_TTL_DAYS = int(os.getenv("TRANSCRIPT_TTL_DAYS", "30"))

LANG_MAP_RAW = os.getenv("TRANSLATE_LANG_MAP", "en:en,es:es,fr:fr")
SUPPORTED_LANG_MAP = {
    item.split(":")[0]: item.split(":")[1] for item in LANG_MAP_RAW.split(",") if ":" in item
}

DDB = boto3.resource("dynamodb")
TABLE = DDB.Table(DYNAMODB_TABLE)
TRANSLATE = boto3.client("translate")
COMPREHEND = boto3.client("comprehend")
SNS = boto3.client("sns")
S3 = boto3.client("s3")


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    LOGGER.info("Received event: %s", json.dumps(event))

    if "sessionState" in event:
        return _handle_lex_event(event)

    if event.get("requestContext"):
        return _handle_api_gateway_event(event)

    return {
        "statusCode": 400,
        "body": json.dumps({"message": "Unsupported event format"}),
    }


def _handle_lex_event(event: dict[str, Any]) -> dict[str, Any]:
    session_id = event.get("sessionId") or str(uuid.uuid4())
    user_id = event.get("sessionState", {}).get("sessionAttributes", {}).get("userId", "anonymous")
    locale_id = event.get("bot", {}).get("localeId", "en_US")
    preferred_lang = _extract_lang_from_locale(locale_id)
    input_text = event.get("inputTranscript", "")
    intent_name = event.get("sessionState", {}).get("intent", {}).get("name", "UnknownIntent")

    detected_lang = _detect_language(input_text) or preferred_lang
    source_code = _normalize_lang_code(detected_lang)
    target_code = "en"

    translated_to_english = (
        _translate_text(input_text, source_code, target_code) if input_text else ""
    )
    sentiment = _detect_sentiment(translated_to_english)

    response_in_english = _generate_support_response(intent_name, translated_to_english, sentiment)
    translated_response = _translate_text(response_in_english, "en", preferred_lang)

    if sentiment == "NEGATIVE":
        _publish_escalation(session_id, user_id, translated_to_english, sentiment)

    _persist_conversation(
        conversation_id=session_id,
        user_id=user_id,
        input_text=input_text,
        translated_input=translated_to_english,
        response_text=translated_response,
        intent=intent_name,
        source_lang=source_code,
        target_lang=preferred_lang,
        sentiment=sentiment,
    )

    _archive_transcript_entry(
        session_id=session_id,
        payload={
            "user_id": user_id,
            "intent": intent_name,
            "input": input_text,
            "translated_input": translated_to_english,
            "response": translated_response,
            "sentiment": sentiment,
            "source_lang": source_code,
            "target_lang": preferred_lang,
            "timestamp": datetime.now(UTC).isoformat(),
        },
    )

    return {
        "sessionState": {
            "dialogAction": {"type": "Close"},
            "intent": {"name": intent_name, "state": "Fulfilled"},
        },
        "messages": [
            {
                "contentType": "PlainText",
                "content": translated_response,
            }
        ],
    }


def _handle_api_gateway_event(event: dict[str, Any]) -> dict[str, Any]:
    try:
        body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return _api_response(400, {"message": "Invalid JSON"})

    input_text = body.get("message", "")
    user_id = body.get("user_id", "anonymous")
    session_id = body.get("session_id", str(uuid.uuid4()))
    preferred_lang = _normalize_lang_code(body.get("preferred_language", "en"))

    if not input_text:
        return _api_response(400, {"message": "message is required"})

    detected_lang = _detect_language(input_text) or preferred_lang
    source_code = _normalize_lang_code(detected_lang)

    translated_to_english = _translate_text(input_text, source_code, "en")
    sentiment = _detect_sentiment(translated_to_english)
    response_in_english = _generate_support_response(
        "ApiGatewaySupportIntent", translated_to_english, sentiment
    )
    translated_response = _translate_text(response_in_english, "en", preferred_lang)

    if sentiment == "NEGATIVE":
        _publish_escalation(session_id, user_id, translated_to_english, sentiment)

    _persist_conversation(
        conversation_id=session_id,
        user_id=user_id,
        input_text=input_text,
        translated_input=translated_to_english,
        response_text=translated_response,
        intent="ApiGatewaySupportIntent",
        source_lang=source_code,
        target_lang=preferred_lang,
        sentiment=sentiment,
    )

    _archive_transcript_entry(
        session_id=session_id,
        payload={
            "user_id": user_id,
            "intent": "ApiGatewaySupportIntent",
            "input": input_text,
            "translated_input": translated_to_english,
            "response": translated_response,
            "sentiment": sentiment,
            "source_lang": source_code,
            "target_lang": preferred_lang,
            "timestamp": datetime.now(UTC).isoformat(),
        },
    )

    return _api_response(
        200,
        {
            "session_id": session_id,
            "source_language": source_code,
            "preferred_language": preferred_lang,
            "sentiment": sentiment,
            "response": translated_response,
        },
    )


def _api_response(status_code: int, body: dict[str, Any]) -> dict[str, Any]:
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def _extract_lang_from_locale(locale_id: str) -> str:
    if not locale_id or "_" not in locale_id:
        return "en"
    lang = locale_id.split("_", maxsplit=1)[0].lower()
    return _normalize_lang_code(lang)


def _normalize_lang_code(lang_code: str) -> str:
    normalized = (lang_code or "en").lower()
    if normalized.startswith("es"):
        return "es"
    if normalized.startswith("fr"):
        return "fr"
    return "en"


def _detect_language(text: str) -> str | None:
    if not text.strip():
        return None

    if len(text) < 20:
        return None

    try:
        result = COMPREHEND.detect_dominant_language(Text=text)
        languages = result.get("Languages", [])
        if not languages:
            return None
        return languages[0].get("LanguageCode")
    except Exception as exc:  # noqa: BLE001
        LOGGER.warning("Language detection failed: %s", exc)
        return None


def _detect_sentiment(text: str) -> str:
    if not text.strip():
        return "NEUTRAL"

    try:
        result = COMPREHEND.detect_sentiment(Text=text, LanguageCode="en")
        return result.get("Sentiment", "NEUTRAL")
    except Exception as exc:  # noqa: BLE001
        LOGGER.warning("Sentiment detection failed: %s", exc)
        return "NEUTRAL"


def _translate_text(text: str, source_lang: str, target_lang: str) -> str:
    if not text:
        return ""
    if source_lang == target_lang:
        return text

    try:
        result = TRANSLATE.translate_text(
            Text=text,
            SourceLanguageCode=source_lang,
            TargetLanguageCode=target_lang,
        )
        return result.get("TranslatedText", text)
    except Exception as exc:  # noqa: BLE001
        LOGGER.warning("Translation failed (%s->%s): %s", source_lang, target_lang, exc)
        return text


def _generate_support_response(intent_name: str, translated_input: str, sentiment: str) -> str:
    lowered = translated_input.lower()

    if sentiment == "NEGATIVE":
        return (
            "I understand this is frustrating. I have flagged your case for priority follow-up "
            "from our support team."
        )

    if "billing" in lowered or "payment" in lowered or "invoice" in lowered:
        return (
            "For billing issues, please share your invoice number. "
            "I can also connect you with billing support."
        )

    if "order" in lowered or "delivery" in lowered or "tracking" in lowered:
        return "For order help, please provide your order ID so I can check the latest status."

    if "technical" in lowered or "error" in lowered or "bug" in lowered:
        return "For technical issues, please describe the exact error message and when it started."

    return (
        f"I can help with billing, order, or technical requests. "
        f"I received: {translated_input[:200]}"
    )


def _persist_conversation(
    conversation_id: str,
    user_id: str,
    input_text: str,
    translated_input: str,
    response_text: str,
    intent: str,
    source_lang: str,
    target_lang: str,
    sentiment: str,
) -> None:
    now_ms = int(time.time() * 1000)
    expires_at = int((datetime.now(UTC) + timedelta(days=TRANSCRIPT_TTL_DAYS)).timestamp())

    TABLE.put_item(
        Item={
            "conversation_id": conversation_id,
            "message_ts": now_ms,
            "user_id": user_id,
            "input_text": input_text,
            "translated_input": translated_input,
            "response_text": response_text,
            "intent": intent,
            "source_lang": source_lang,
            "target_lang": target_lang,
            "sentiment": sentiment,
            "expires_at": expires_at,
            "created_at": datetime.now(UTC).isoformat(),
        }
    )


def _archive_transcript_entry(session_id: str, payload: dict[str, Any]) -> None:
    now = datetime.now(UTC)
    key = f"transcripts/{now.strftime('%Y/%m/%d')}/{session_id}-{now.strftime('%H%M%S%f')}.json"

    S3.put_object(
        Bucket=TRANSCRIPT_ARCHIVE_BUCKET,
        Key=key,
        Body=json.dumps(payload).encode("utf-8"),
        ContentType="application/json",
    )


def _publish_escalation(session_id: str, user_id: str, message: str, sentiment: str) -> None:
    SNS.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject="High-priority support escalation",
        Message=json.dumps(
            {
                "session_id": session_id,
                "user_id": user_id,
                "sentiment": sentiment,
                "message": message,
                "created_at": datetime.now(UTC).isoformat(),
            },
            indent=2,
        ),
    )
