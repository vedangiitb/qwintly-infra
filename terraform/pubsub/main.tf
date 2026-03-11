resource "google_pubsub_topic" "topic" {
  name                       = var.topic_name
  labels                     = var.topic_labels
  kms_key_name               = var.kms_key_name
  message_retention_duration = var.topic_message_retention_duration

  dynamic "message_storage_policy" {
    for_each = length(var.allowed_persistence_regions) > 0 ? [1] : []

    content {
      allowed_persistence_regions = var.allowed_persistence_regions
    }
  }

  dynamic "schema_settings" {
    for_each = var.schema_settings == null ? [] : [var.schema_settings]

    content {
      schema   = schema_settings.value.schema
      encoding = schema_settings.value.encoding
    }
  }
}

resource "google_pubsub_subscription" "subscription" {
  name                         = coalesce(var.subscription_name, "${var.topic_name}-sub")
  topic                        = google_pubsub_topic.topic.name
  labels                       = var.subscription_labels
  ack_deadline_seconds         = var.ack_deadline_seconds
  message_retention_duration   = var.subscription_message_retention_duration
  retain_acked_messages        = var.retain_acked_messages
  enable_message_ordering      = var.enable_message_ordering
  enable_exactly_once_delivery = var.enable_exactly_once_delivery
  filter                       = var.subscription_filter

  dynamic "expiration_policy" {
    for_each = var.subscription_expiration_ttl == null ? [] : [var.subscription_expiration_ttl]

    content {
      ttl = expiration_policy.value
    }
  }

  dynamic "dead_letter_policy" {
    for_each = var.dead_letter_policy == null ? [] : [var.dead_letter_policy]

    content {
      dead_letter_topic     = dead_letter_policy.value.dead_letter_topic
      max_delivery_attempts = dead_letter_policy.value.max_delivery_attempts
    }
  }

  dynamic "retry_policy" {
    for_each = var.retry_policy == null ? [] : [var.retry_policy]

    content {
      minimum_backoff = retry_policy.value.minimum_backoff
      maximum_backoff = retry_policy.value.maximum_backoff
    }
  }
}
